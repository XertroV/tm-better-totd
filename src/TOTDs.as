// Json::Value@ totdInfo = null;
DictOfTrackOfTheDayEntry_WriteLog@ totdDb = DictOfTrackOfTheDayEntry_WriteLog(IO::FromStorageFolder(""), "totd.db");

uint totalMonths = 0;
uint totalCampaigns = 0;

bool logNewTOTDs = false;
int64 newTotdAt = 0;
int64 newTotdWaitFor = 0;
int nbTotdReqs = 0;


namespace TOTD {
    // March 2023 has a monthIx of 32
    int maxMonthIx = 32;
    bool initialSyncDone = false;

    void SyncMain() {
        maxMonthIx = TimestampToMonthIx(-1);
        totdDb.AwaitInitialized();
        // totdDb.DeleteAll();

        totalMonths = maxMonthIx + 1;
        totalCampaigns = maxMonthIx / 3 + 1;

        auto missing = LoadExistingTotds();
        nbTotdReqs = missing.Length;
        for (uint i = 0; i < missing.Length; i++) {
            SyncTotdMonth(missing[i]);
        }
        logNewTOTDs = true;
        initialSyncDone = true;
    }

    int nextSyncLoopFor = 0;
    // idempotent
    void NextSyncLoop() {
        if (Math::Abs(nextSyncLoopFor - newTotdAt) < 2) return;
        nextSyncLoopFor = newTotdAt;
        int64 waitTill = newTotdAt;
        int64 waitFor = newTotdWaitFor;
        log_trace("NextSyncLoop running at " + FmtTimestamp(waitTill) + " which is in " + waitFor + " seconds.");
        sleep((waitFor - 5) * 1000);
        log_trace("NextSyncLoop yielding until correct timestamp.");
        if (Math::Abs(waitTill - Time::Stamp - 5) > 2) {
            log_warn("NextSyncLoop out by > 2s");
        }
        while (Time::Stamp < waitTill) yield();
        maxMonthIx = TimestampToMonthIx(-1);
        log_trace("NextSyncLoop getting month number " + maxMonthIx + " (and prior month)");
        nbTotdReqs += 2;
        SyncTotdMonth(maxMonthIx, true);
        // also get month prior to be sure we get everything -- possible edge case near end of month if plugin loaded just before new TOTD.
        SyncTotdMonth(maxMonthIx - 1);
    }

    void SyncTotdMonth(int monthIx, bool expectNew = false) {
        int offset = maxMonthIx - monthIx;
        auto totdJson = Live::GetTotdByMonth(1, offset);
        nbTotdReqs--;

        newTotdWaitFor = totdJson.Get('relativeNextRequest', 8640);
        newTotdAt = Time::Stamp + newTotdWaitFor;
        startnew(NextSyncLoop);

        auto monthList = totdJson.Get('monthList');
        if (monthList.Length == 0) {
            log_warn("Got empty TOTD month (ix: "+monthIx+")");
            return;
        }
        auto days = monthList[0].Get('days');
        int iYear = monthList[0]['year'];
        int iMonth = monthList[0]['month'];
        for (uint m = 0; m < days.Length; m++) {
            auto day = days[m];
            string uid = day.Get('mapUid', '');
            if (uid.Length == 0 || totdDb.Exists(uid)) continue;
            if (logNewTOTDs) log_info("New TOTD: " + iYear + "-" + iMonth + "-" + (m + 1) + "; uid: " + uid);
            auto totd = TrackOfTheDayEntry(day);
            totdDb.Set(uid, totd);
            auto lm = LazyMap(totd, iYear, iMonth);
            if (totdMaps.Exists(uid)) throw('duplicate');
            totdMaps[uid] = @lm;
            allTotds.InsertLast(lm);
        }
        SortTotds();
        if (expectNew) startnew(OnPossibleFreshTOTD);
        PopulateMapInfos();
    }

    // Return a list of all months that are missing
    int[]@ LoadExistingTotds() {
        auto nbTracks = array<int>(maxMonthIx + 1);
        auto totdUids = totdDb.GetKeys();
        for (uint i = 0; i < totdUids.Length; i++) {
            auto item = totdDb[totdUids[i]];
            nbTracks[TimestampToMonthIx(item.startTimestamp)] += 1;
            auto lm = LazyMap(item);
            if (totdMaps.Exists(lm.uid)) throw('duplicate');
            totdMaps[lm.uid] = @lm;
            allTotds.InsertLast(lm);
        }
        SortTotds();
        PopulateMapInfos();
        int[] missing = {};
        for (uint i = nbTracks.Length - 1; i < nbTracks.Length; i--) {
            if (ExpectedTracksForMonthIx(i) != nbTracks[i]) {
                missing.InsertLast(i);
            }
        }
        // always add current month so we make at least 1 request
        if (missing.Find(maxMonthIx) < 0) {
            missing.InsertAt(0, maxMonthIx);
        }
        return missing;
    }

    int TimestampToMonthIx(int ts) {
        auto dparts = FmtTimestampDateOnlyUTC(ts).Split("-");
        int yr = Text::ParseInt(dparts[0]);
        int mo = Text::ParseInt(dparts[1]);
        return YrMoToMonthIx(yr, mo);
    }

    int ExpectedTracksForMonthIx(int monthIx) {
        int mo = (monthIx + 6) % 12;
        int year = (monthIx + 6) / 12 + 2020;
        if (mo == 1) {
            return year % 4 == 0 ? 29 : 28;
        }
        // 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
        if (mo < 7) {
            return mo % 2 == 0 ? 31 : 30;
        }
        return mo % 2 == 0 ? 30 : 31;
    }

    void SortTotds() {
        // keep the main list in this order
        totdsQuicksort(allTotds, Less_OldFirst);
    }

    void OnPossibleFreshTOTD() {
        // expect allTotds to be sorted already.
        if (allTotds.Length == 0) return;
        auto latest = allTotds[allTotds.Length - 1];
        auto mapAgeSeconds = Math::Abs(Time::Stamp - latest.startTimestamp);
        // only do this if the timestamp is within 20s of expected
        if (mapAgeSeconds < 20 && S_InstaLoadTOTD > 0) {
            while (!latest.MapInfoLoaded) yield();
            auto app = GetApp();
            bool inEditor = app.Editor !is null;
            if (inEditor) return;
            bool inMenu = app.Switcher.ModuleStack.Length == 0
                || cast<CTrackManiaMenus>(app.Switcher.ModuleStack[0]) !is null;
            // we always do this in-menu if the setting is > 0
            if (inMenu || S_InstaLoadTOTD > 1) {
                Notify("Loading fresh TOTD: " + latest.name);
                latest.LoadThisMapBlocking();
                return;
            }
        }
    }
}

funcdef int MapLessF(LazyMap@ m1, LazyMap@ m2);

int Less_TrackName(LazyMap@ m1, LazyMap@ m2) {
    if (m1.cleanName < m2.cleanName) return -1;
    if (m1.cleanName > m2.cleanName) return 1;
    return 0;
}
int Less_AuthorName(LazyMap@ m1, LazyMap@ m2) {
    if (m1.author < m2.author) return -1;
    if (m1.author > m2.author) return 1;
    return 0;
}
int Less_AuthorTime(LazyMap@ m1, LazyMap@ m2) {
    if (m1.medals[0] == m2.medals[0]) return 0;
    if (m1.medals[0] <= -1) return 1;
    if (m2.medals[0] <= -1) return -1;
    return Math::Clamp(m1.medals[0] - m2.medals[0], -1, 1);
}
int Less_FewestATs(LazyMap@ m1, LazyMap@ m2) {
    if (m1.AtCount == m2.AtCount) return 0;
    if (m1.AtCount <= -1) return 1;
    if (m2.AtCount <= -1) return -1;
    return Math::Clamp(m1.AtCount - m2.AtCount, -1, 1);
}
int Less_MostATs(LazyMap@ m1, LazyMap@ m2) {
    if (m1.AtCount == m2.AtCount) return 0;
    if (m1.AtCount <= -1) return 1;
    if (m2.AtCount <= -1) return -1;
    return Math::Clamp(m2.AtCount - m1.AtCount, -1, 1);
}

int Less_PB_NewFirst(LazyMap@ m1, LazyMap@ m2) {
    if (m1.playerRecordTimestamp == m2.playerRecordTimestamp) return 0;
    if (m1.playerRecordTimestamp <= -1) return 1;
    if (m2.playerRecordTimestamp <= -1) return -1;
    return Math::Clamp(m2.playerRecordTimestamp - m1.playerRecordTimestamp, -1, 1);
}

int Less_PB_OldFirst(LazyMap@ m1, LazyMap@ m2) {
    if (m1.playerRecordTimestamp == m2.playerRecordTimestamp) return 0;
    if (m1.playerRecordTimestamp <= -1) return 1;
    if (m2.playerRecordTimestamp <= -1) return -1;
    return Math::Clamp(m1.playerRecordTimestamp - m2.playerRecordTimestamp, -1, 1);
}

int Less_NewFirst(LazyMap@ m1, LazyMap@ m2) {
    return Math::Clamp(m2.startTimestamp - m1.startTimestamp, -1, 1);
}

int Less_OldFirst(LazyMap@ m1, LazyMap@ m2) {
    return Math::Clamp(m1.startTimestamp - m2.startTimestamp, -1, 1);
}

enum SortMethod {
    NewFirst,
    OldFirst,
    PB_NewFirst,
    PB_OldFirst,
    TrackName,
    AuthorName,
    AuthorTime,
    FewestATs,
    MostATs,
    // put new entries here
    _LastNop
}

MapLessF@[] sortMethods = {
    Less_NewFirst,
    Less_OldFirst,
    Less_PB_NewFirst,
    Less_PB_OldFirst,
    Less_TrackName,
    Less_AuthorName,
    Less_AuthorTime,
    Less_FewestATs,
    Less_MostATs
};

void totdsQuicksort(LazyMap@[]@ arr, MapLessF@ f, int left = 0, int right = -1) {
    if (right < 0) right = arr.Length - 1;
    if (arr.Length == 0) return;
    int i = left;
    int j = right;
    LazyMap@ pivot = arr[(left + right) / 2];

    while (i <= j) {
        while (f(arr[i], pivot) < 0) i++;
        while (f(arr[j], pivot) > 0) j--;
        if (i <= j) {
            LazyMap@ temp = arr[i];
            @arr[i] = arr[j];
            @arr[j] = temp;
            i++;
            j--;
        }
    }

    if (left < j) totdsQuicksort(arr, f, left, j);
    if (i < right) totdsQuicksort(arr, f, i, right);
}


dictionary totdMaps;
LazyMap@[] allTotds;

int nbMapInfoRequests = 0;

void PopulateMapInfos() {
    int total = allTotds.Length;
    int _ix = 0;
    while (_ix < total) {
        MwFastBuffer<wstring> uids = MwFastBuffer<wstring>();
        int i = _ix;
        for (; i < total && uids.Length < 100; i++) {
            if (allTotds[i].MapInfoLoaded) continue;
            uids.Add(allTotds[i].uid);
        }
        _ix = i;
        nbMapInfoRequests += uids.Length;
        auto mapInfos = GetMapsFromUids(uids);
        nbMapInfoRequests -= uids.Length;
        for (uint j = 0; j < mapInfos.Length; j++) {
            auto mi = mapInfos[j];
            auto lm = cast<LazyMap>(totdMaps[mi.Uid]);
            lm.SetMapInfoFrom(mi);
        }
    }
}

string g_mapUid;
string g_lastMapUid;
void WatchForMapChange() {
    auto app = cast<CGameManiaPlanet>(GetApp());
    while (true) {
        yield();
        if (app.RootMap is null && g_mapUid != "") {
            g_lastMapUid = g_mapUid;
            g_mapUid = "";
            OnMapChanged();
        } else if (app.RootMap !is null && app.RootMap.EdChallengeId != g_mapUid) {
            g_lastMapUid = g_mapUid;
            g_mapUid = app.RootMap.EdChallengeId;
            OnMapChanged();
        }
    }
}
void OnMapChanged() {
    if (totdMaps.Exists(g_lastMapUid)) {
        try {
            cast<LazyMap>(totdMaps[g_lastMapUid]).ReloadRecord();
        } catch {
            log_warn("Error refreshing record for map with uid: " + g_lastMapUid);
        }
    }
}



uint lastTime = 0;
uint rateLimitMs = 200;

void RateLimit() {
    while (true) {
        if (Time::Now > (lastTime + rateLimitMs)) {
            lastTime = Time::Now;
            return;
        }
        sleep(rateLimitMs - (Time::Now - lastTime) + rateLimitMs * Math::Rand(0, g_mapUid.Length > 0 ? 20 : 3));
    }
}


/* totd day info:
{
    "campaignId": 3132, "mapUid": "fJlplQyZV3hcuD7T1gPPTXX7esd", "day": 4,
    "monthDay": 31, "seasonUid": "aad0f073-c9e0-45da-8a70-c06cf99b3023",
    "leaderboardGroup": null, "startTimestamp": 1596210000, "endTimestamp": 1596300000,
    "relativeStart": -57779100, "relativeEnd": -57692700
}
*/

int nbPlayerRecordReqs = 0;
dictionary pbRecordsReqs;

void PbReqStarted(const string &in uid) {
    nbPlayerRecordReqs += 1;
    if (!pbRecordsReqs.Exists(uid)) pbRecordsReqs[uid] = 1;
    else pbRecordsReqs[uid] = int(pbRecordsReqs[uid]) + 1;
}
void PbReqFinished(const string &in uid) {
    nbPlayerRecordReqs -= 1;
    if (!pbRecordsReqs.Exists(uid)) {
        log_warn(uid + ' Request finished but 0 inprogress');
        return;
    }
    int newReqs = int(pbRecordsReqs[uid]) - 1;
    if (newReqs == 0) pbRecordsReqs.Delete(uid);
    else pbRecordsReqs[uid] = newReqs;
}

int YrMoToMonthIx(int yr, int mo) {
    // -6 at end b/c TOTDs started in July
    return (yr - 2020) * 12 + (mo - 1) - 6;
}

class LazyMap {
    string uid;
    int year;
    int month;
    int day;
    int weekDay;
    int startTimestamp;
    int endTimestamp;
    string date;
    TrackOfTheDayEntry@ totdEntry;
    bool IsLikelyTroll = false;
    string monthCampaignId;
    // we get this from author-tracker.com
    int AtCount = -1;

    LazyMap(TrackOfTheDayEntry@ totd, int _year = -1, int _month = -1) {
        @totdEntry = totd;
        this.uid = totd.mapUid;
        date = FmtTimestampDateOnlyUTC(totd.startTimestamp);
        if (_year < 2020 || _month < 0) {
            auto dparts = date.Split("-");
            this.year = Text::ParseInt(dparts[0]);
            this.month = Text::ParseInt(dparts[1]);
        } else {
            this.year = _year;
            this.month = _month;
        }

        monthCampaignId = Text::Format("%d" + year, month);

        if (year < 2020 || year > 2100 || month < 1 || month > 12) {
            throw("LazyMap: Bad year/month. date: " + date);
        }

        day = totd.monthDay;
        weekDay = totd.day;
        startTimestamp = totd.startTimestamp;
        endTimestamp = totd.endTimestamp;
        date = tostring(this.year) + '-' + Text::Format('%02d', month) + '-' + Text::Format('%02d', day);
        startnew(CoroutineFunc(LoadRecord));

        int yrOffs = this.year - 2020;
        int monthOffs = month - 1;
        int startMonth = 6;

        monthIx = yrOffs * 12 + monthOffs - startMonth;
        campaignIx = monthIx / 3;
        // march 2021 is when they start
        IsLikelyTroll = day == 1 && monthIx >= 8;
    }

    bool MapInfoLoaded = false;
    string name = "??";
    string rawName = "??";
    string cleanName = "??";
    string author = "??";
    string authorByLine = "??";
    string authorTime = "??";
    string goldTime;
    string silverTime;
    string bronzeTime;
    string thumbUrl;
    string mapUrl;

    int[] medals = {-1, -1, -1, -1};
    int playerRecordTime = -2;
    string playerRecordTimeStr;
    string playerRecordTimeStrShort;
    int playerMedal = -1;
    int64 playerRecordTimestamp = -1;

    int campaignIx = 0;
    int monthIx = 0;

    // load just this map -- don't use this except like manually refreshing.
    void LoadMap() {
        RateLimit();
        auto map = GetMapFromUid(uid);
        SetMapInfoFrom(map);
    }

    void SetMapInfoFrom(CNadeoServicesMap@ map) {
        if (map is null) {
            name = "UNKNOWN!!";
            return;
        }

        name = ColoredString(map.Name);
        rawName = map.Name;
        cleanName = StripFormatCodes(map.Name);
        author = map.AuthorDisplayName;
        authorByLine = "\\$888by \\$z" + author;
        authorTime = Time::Format(map.AuthorScore);
        goldTime = Time::Format(map.GoldScore);
        silverTime = Time::Format(map.SilverScore);
        bronzeTime = Time::Format(map.BronzeScore);
        medals[0] = map.AuthorScore;
        medals[1] = map.GoldScore;
        medals[2] = map.SilverScore;
        medals[3] = map.BronzeScore;
        thumbUrl = map.ThumbnailUrl;
        mapUrl = map.FileUrl;
        // startnew(CoroutineFunc(LoadThumbnail));

        MapInfoLoaded = true;
    }

    string playerMedalLabel = Icons::QuestionCircle;
    void LoadRecord() {
        _SetPlayerRecordTime(int(Map_GetRecord_v2(uid)));
        UpdateMedalsInfo();
        startnew(CoroutineFunc(LoadRecordFromAPI));
    }

    bool rateLimitGetPb = true;

    void LoadRecordFromAPI() {
        PbReqStarted(uid);
        if (rateLimitGetPb) RateLimit();
        auto rec = GetPlayerRecordOnMap(uid);
        PbReqFinished(uid);
        // don't rate limit future requests b/c it's probably when we exit a map.
        rateLimitGetPb = false;

        bool timeChanged = false;
        if (rec !is null) {
            timeChanged = playerRecordTime != int(rec.Time);
            _SetPlayerRecordTime(rec.Time);
            playerRecordTimestamp = rec.Timestamp;
        } else if (playerRecordTime < 0) {
            playerRecordTime = -1;
        }
        UpdateMedalsInfo();
    }

    void _SetPlayerRecordTime(int time) {
        playerRecordTime = time;
        if (playerRecordTime > 0) {
            playerRecordTimeStrShort = "\\$s" + Time::Format(playerRecordTime, true, false);
            playerRecordTimeStr = Time::Format(playerRecordTime);
        }
    }

    void UpdateMedalsInfo() {
        while (!MapInfoLoaded) {
            yield();
        }
        playerMedalLabel = GetPlayerMedalIcon();
        if (playerRecordTime < 0) playerMedal = 5;
        else if (playerRecordTime <= medals[0]) playerMedal = 0;
        else if (playerRecordTime <= medals[1]) playerMedal = 1;
        else if (playerRecordTime <= medals[2]) playerMedal = 2;
        else if (playerRecordTime <= medals[3]) playerMedal = 3;
        else playerMedal = 4;
        btnColsSet = false;
        MarkRecordCacheStale();
    }

    void ReloadRecord() {
        startnew(CoroutineFunc(LoadRecord));
    }

    void DrawTableRow() {
        UI::PushID(uid);
        UI::TableNextRow();
        UI::TableNextColumn();
        UI::AlignTextToFramePadding();
        UI::Text(date);
        UI::TableNextColumn();
        if (IsLikelyTroll) {
            UI::Text("\\$888T");
            AddSimpleTooltip("Troll TOTD");
        }
        UI::TableNextColumn();
        UI::Text(name);
        UI::TableNextColumn();
        UI::Text(authorByLine);
        UI::TableNextColumn();
        UI::Text(playerMedalLabel);
        UI::TableNextColumn();
        if (playerRecordTime < -1) UI::Text(HourGlassAnim());
        else UI::Text(playerRecordTimeStr);
        UI::TableNextColumn();
        if (playerRecordTimestamp > 0)
            UI::Text(FmtTimestampDateOnly(playerRecordTimestamp));
        UI::TableNextColumn();
        if (AtCount >= 0) {
            string _atCount = Text::Format("%d \\$071", AtCount) + Icons::Globe;
            auto size = Draw::MeasureString(_atCount);
            UI::SetCursorPos(UI::GetCursorPos() + vec2(atCountWidth - size.x, 0));
            UI::Text(_atCount);
        }
        UI::TableNextColumn();
        if (UI::Button("Play")) {
            startnew(CoroutineFunc(LoadThisMapBlocking));
        }
        UI::SameLine();
        if (UI::Button(TM_IO_ICON)) {
            OpenBrowserURL('https://trackmania.io/#/leaderboard/' + uid);
        }
        UI::SameLine();
        UI::BeginDisabled(GetTmxInfo() is null);
        if (UI::Button("TMX")) {
            TMX::OpenTmxTrack(tmxInfo.TrackID);
        }
        UI::EndDisabled();
        // UI::SameLine();
        // if (UI::Button("TMX")) {
        //     // todo
        // }

        UI::PopID();
    }

    const string GetPlayerMedal() {
        if (playerRecordTime < -1 || medals[0] < 0) return "??";
        if (playerRecordTime > 0) {
            if (playerRecordTime <= medals[0]) return "AT";
            if (playerRecordTime <= medals[1]) return "Gold";
            if (playerRecordTime <= medals[2]) return "Silver";
            if (playerRecordTime <= medals[3]) return "Bronze";
        }
        return "--";
    }

    const string GetPlayerMedalIcon() {
        if (playerRecordTime < -1 || medals[0] < 0) return Icons::HourglassHalf;
        if (playerRecordTime > 0) {
            if (playerRecordTime <= medals[0]) return iconAuthor;
            if (playerRecordTime <= medals[1]) return iconGold;
            if (playerRecordTime <= medals[2]) return iconSilver;
            if (playerRecordTime <= medals[3]) return iconBronze;
            return iconPlayed;
        }
        return iconUnplayed;
    }

    void DrawCalendarButton(vec2 size) {
        auto pos = UI::GetCursorPos();
        UI::PushID(uid);
        PushButtonCols();
        bool pressed = UI::Button("", size);
        PopButtonCols();
        if (UI::IsItemHovered()) DrawMapTooltip();
        UI::PopID();
        auto endPos = UI::GetCursorPos();

        UI::PushFont(g_LargeFont);
        auto fontH = UI::GetTextLineHeight();
        UI::SetCursorPos(pos + size * vec2(.05, .5) - vec2(0, fontH/2.));
        UI::PushStyleColor(UI::Col::Text, vec4(1, 1, 1, .5));
        UI::Text(tostring(day) + ".");
        UI::PopStyleColor();
        UI::SetCursorPos(pos + size * vec2(.5, .5) - vec2(fontH/2.66, fontH/2.) * .9);
        UI::Text(playerMedalLabel);
        UI::PopFont();

        if (playerRecordTime > 0) {
            // auto smallFontH = UI::GetTextLineHeight();
            UI::PushFont(g_BoldFont);
            auto recSz = Draw::MeasureString(playerRecordTimeStrShort);
            UI::SetCursorPos(pos + size * vec2(.5, .5) - recSz / 2.);
            UI::Text(playerRecordTimeStrShort);
            UI::PopFont();
        }

        UI::SetCursorPos(endPos);

        if (pressed) {
            log_info("Play map: " + name);
            startnew(CoroutineFunc(LoadThisMapBlocking));
        }
    }

    void LoadThisMapBlocking() {
        bool isLive = startTimestamp <= Time::Stamp && Time::Stamp < endTimestamp;
        // string settings = """<root>
		// 		<setting name="S_CampaignId" value="_DailyMap.CampaignId" type="integer"/>
		// 		<setting name="xS_CampaignMonthlyId" value="_CurrentCampaign.Id" type="integer"/>
		// 		<setting name="S_CampaignType" value="0" type="integer"/>
		// 		<setting name="S_CampaignIsLive" value="IsCampaignLive" type="boolean"/>
		// 	</root>""";
        // settings = settings
        //     .Replace("IsCampaignLive", isLive ? "1" : "0")
        //     .Replace("_DailyMap.CampaignId", tostring(totdEntry.campaignId))
        //     .Replace("_CurrentCampaign.Id", monthCampaignId);
        // log_trace("Loading map with settings: " + settings);
        string settings = "";
        Notify("Loading " + cleanName);
#if DEPENDENCY_MLHOOK
        if (Meta::GetPluginFromID("MLHook").Enabled) {
            // MLHook::Queue_Menu_SendCustomEvent("TMNext_CampaignStore_Action_LoadMonthlyCampaignsList", {tostring(TOTD::maxMonthIx - monthIx), "12"});
            // sleep(500);
            // we need this call to have the in-game menu load correctly.
            // MLHook::Queue_Menu_SendCustomEvent("TMNext_CampaignStore_Action_LoadMonthlyCampaign", {monthCampaignId});
            MLHook::Queue_Menu_SendCustomEvent("Event_UpdateLoadingScreen", {rawName});
            // give a chance for the ML to load the monthly stuff since the menu ML gets paused once we're in-map
            // sleep(500);
        }
#endif
        LoadMapNowWrapper(mapUrl, settings);
    }

    void DrawMapTooltip() {
        UI::BeginTooltip();

        UI::PushFont(g_MidFont);
        UI::AlignTextToFramePadding();
        UI::Text(name);
        UI::PopFont();
        vec2 off = vec2(0, UI::GetTextLineHeight() * .4);
        UI::SetCursorPos(UI::GetCursorPos() - off);
        UI::Text(authorByLine);
        UI::SetCursorPos(UI::GetCursorPos() + off);
        if (playerMedal == 0) PBText();
        UI::Text(iconAuthor + authorTime);
        if (playerMedal == 1) PBText();
        UI::Text(iconGold + goldTime);
        if (playerMedal == 2) PBText();
        UI::Text(iconSilver + silverTime);
        if (playerMedal == 3) PBText();
        UI::Text(iconBronze + bronzeTime);
        if (playerMedal > 3 || playerMedal < 0) PBText();
        UI::EndTooltip();
    }

    void PBText() {
        if (playerRecordTime < 0) UI::Text("No PB");
        else UI::Text("PB " + playerRecordTimeStr);
    }

    void PushButtonCols() {
        SetButtonCols();
        UI::PushStyleColor(UI::Col::Button, btnCol);
        UI::PushStyleColor(UI::Col::ButtonHovered, btnColHov);
        UI::PushStyleColor(UI::Col::ButtonActive, btnColAct);
    }

    void PopButtonCols() {
        UI::PopStyleColor(3);
    }

    bool btnColsSet = false;
    vec4 btnCol;
    vec4 btnColHov;
    vec4 btnColAct;
    void SetButtonCols() {
        if (btnColsSet) return;
        btnColsSet = true;
        if (playerMedal == 0) btnCol = vec4(0, .6, .1, .9);
        else if (playerMedal == 1) btnCol = vec4(.95, .75, .01, .9);
        else if (playerMedal == 2) btnCol = vec4(.5, .55, .55, .9);
        else if (playerMedal == 3) btnCol = vec4(.6, .4, .25, .9);
        else btnCol = vec4(.3, .3, .3, .9);
        btnColHov = vec4(Math::Pow(btnCol.xyz, 0.75), btnCol.w);
        btnColAct = vec4(Math::Pow(btnCol.xyz, 1.5), btnCol.w);
    }

    TmxMapInfo@ tmxInfo = null;
    TmxMapInfo@ GetTmxInfo() {
        if (tmxInfo !is null) return tmxInfo;
        if (tmxDb.Exists(uid))
            @tmxInfo = tmxDb.Get(uid);
        return tmxInfo;
    }

    // UI::Texture@ tex;
    // void LoadThumbnail() {
    //     trace('loading thumbnail: ' + thumbUrl);
    //     auto req = Net::HttpGet(thumbUrl);
    //     while (!req.Finished()) yield();
    //     @tex = UI::LoadTexture(req.Buffer());
    // }

    // void DrawThumbnail(vec2 size = vec2()) {
    //     if (tex is null) {
    //         UI::Text("Loading thumbnail...");
    //     } else {
    //         if (size.LengthSquared() > 0)
    //             UI::Image(tex, size);
    //         else
    //             UI::Image(tex);
    //     }
    // }
}

namespace Math {
    vec3 Sqrt(vec3 &in v) {
        return vec3(Sqrt(v.x), Sqrt(v.y), Sqrt(v.z));
    }

    vec3 Pow(vec3 &in v, float ix) {
        return vec3(Pow(v.x, ix), Pow(v.y, ix), Pow(v.z, ix));
    }
}
