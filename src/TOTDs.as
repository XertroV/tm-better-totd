Json::Value@ totdInfo = null;
bool g_doneTotdInfoInitialLoad = false;

uint totalMonths = 0;
uint totalCampaigns = 0;

bool logNewTOTDs = false;
int64 newTotdAt = 0;

const string TOTD_JSON_CACHE_FILE = IO::FromStorageFolder("totd.json");

// spawns an infinite loop if it's sucessful
void UpdateTotdInfo() {
    bool shouldUpdate = totdInfo is null || totdInfo.Get('nextRequestTimestamp', 0) <= Time::Stamp;
    if (shouldUpdate) {
        if (totdInfo is null) startnew(LoadTotdFromCache);
        @totdInfo = Live::GetTotdByMonth();
        // immediately copy this string and save it
        CacheTotdJson(_LastLiveEndpointRaw);
        OnTotdJsonLoad();
        g_doneTotdInfoInitialLoad = true;
    } else return;
    // 10% of a day default
    int64 waitSeconds = totdInfo.Get('relativeNextRequest', 8640);
    newTotdAt = Time::Stamp + waitSeconds;
    sleep(waitSeconds * 1000);
    startnew(UpdateTotdInfo);
}

void OnTotdJsonLoad() {
    startnew(UpdateTotdCacheData);
    totalMonths = totdInfo['monthList'].Length;
    totalCampaigns = (totalMonths - 1) / 3 + 1;
}

void LoadTotdFromCache() {
    if (totdInfo !is null) return;
    if (IO::FileExists(TOTD_JSON_CACHE_FILE)) {
        auto _totdsLast = Json::FromFile(TOTD_JSON_CACHE_FILE);
        if (totdInfo !is null) return;
        @totdInfo = _totdsLast;
        OnTotdJsonLoad();
    }
}

void CacheTotdJson(string _raw) {
    IO::File totdCache(TOTD_JSON_CACHE_FILE, IO::FileMode::Write);
    totdCache.Write(_raw);
    totdCache.Close();
}


dictionary totdMaps;
string[] totdUids;
LazyMap@[] allTotds;

void UpdateTotdCacheData() {
    auto monthList = totdInfo.Get('monthList');
    for (uint i = monthList.Length - 1; i < monthList.Length; i--) {
        auto month = monthList[i];
        auto days = month.Get('days');
        int iYear = month['year'];
        int iMonth = month['month'];
        // for (uint m = days.Length - 1; m < days.Length; m--) {
        for (uint m = 0; m < days.Length; m++) {
            auto day = days[m];
            string uid = day.Get('mapUid', '');
            if (uid.Length == 0 || totdMaps.Exists(uid)) continue;
            if (logNewTOTDs) log_info("New TOTD: " + uid + " " + iYear + "-" + iMonth + "-" + (m + 1));
            totdUids.InsertLast(uid);
            auto lm = LazyMap(uid, iYear, iMonth, day);
            totdMaps[uid] = @lm;
            allTotds.InsertLast(lm);
        }
    }
    PopulateMapInfos();
    logNewTOTDs = true;
    // ! testing
    // while (allTotds.Length > 0) {
    //     sleep(1000);
    //     allTotds.RemoveLast();
    //     MarkRecordCacheStale();
    // }
}

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
        auto mapInfos = GetMapsFromUids(uids);
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


class LazyMap {
    string uid;
    int year;
    int month;
    int day;
    int weekDay;
    int startTimestamp;
    int endTimestamp;
    string date;
    bool IsLikelyTroll = false;

    LazyMap(const string &in uid, int year, int month, Json::Value@ totdJson) {
        this.uid = uid;
        this.year = year;
        this.month = month;
        day = totdJson['monthDay'];
        weekDay = totdJson['day'];
        startTimestamp = totdJson["startTimestamp"];
        endTimestamp = totdJson["endTimestamp"];
        date = FmtTimestampDateOnlyUTC(startTimestamp);
        date = tostring(year) + '-' + Text::Format('%02d', month) + '-' + Text::Format('%02d', day);
        // startnew(CoroutineFunc(LoadMap));
        // recordCoros.InsertLast(startnew(CoroutineFunc(LoadRecord)));
        startnew(CoroutineFunc(LoadRecord));

        int yrOffs = year - 2020;
        int monthOffs = month - 1;
        int startMonth = 6;

        monthIx = yrOffs * 12 + monthOffs - startMonth;
        campaignIx = monthIx / 3;
        // march 2021 is when they start
        IsLikelyTroll = day == 1 && monthIx >= 8;
    }

    bool MapInfoLoaded = false;
    string name = "??";
    string cleanName = "??";
    string author = "??";
    string authorTime = "??";
    string goldTime;
    string silverTime;
    string bronzeTime;
    string thumbUrl;
    string mapUrl;

    int[] medals = {-1, -1, -1, -1};
    int playerRecordTime = -2;
    string playerRecordTimeStr;
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
        cleanName = StripFormatCodes(map.Name);
        author = map.AuthorDisplayName;
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
        playerRecordTime = int(Map_GetRecord_v2(uid));
        if (playerRecordTime > 0)
            playerRecordTimeStr = Time::Format(playerRecordTime);
        UpdateMedalsInfo();
        startnew(CoroutineFunc(LoadRecordFromAPI));
    }

    void LoadRecordFromAPI() {
        RateLimit();
        auto rec = GetPlayerRecordOnMap(uid);
        bool timeChanged = false;
        if (rec !is null) {
            timeChanged = playerRecordTime != int(rec.Time);
            playerRecordTime = rec.Time;
            playerRecordTimeStr = Time::Format(rec.Time);
            playerRecordTimestamp = rec.Timestamp;
        } else if (playerRecordTime < 0) {
            playerRecordTime = -1;
        }
        if (timeChanged)
            UpdateMedalsInfo();
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
        UI::Text(author);
        UI::TableNextColumn();
        UI::Text(playerMedalLabel);
        UI::TableNextColumn();
        if (playerRecordTime < -1) UI::Text(HourGlassAnim());
        else UI::Text(playerRecordTimeStr);
        UI::TableNextColumn();
        if (playerRecordTimestamp > 0)
            UI::Text(FmtTimestampDateOnly(playerRecordTimestamp));
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
            auto recSz = Draw::MeasureString(playerRecordTimeStr);
            UI::SetCursorPos(pos + size * vec2(.5, .5) - recSz / 2.);
            UI::Text(playerRecordTimeStr);
            UI::PopFont();
        }

        UI::SetCursorPos(endPos);

        if (pressed) {
            log_info("Play map: " + name);
            startnew(CoroutineFunc(LoadThisMapBlocking));
        }
    }

    void LoadThisMapBlocking() {
        LoadMapNowWrapper(mapUrl);
    }

    void DrawMapTooltip() {
        UI::BeginTooltip();

        UI::PushFont(g_MidFont);
        UI::AlignTextToFramePadding();
        UI::Text(name);
        UI::PopFont();
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
