namespace AuthorTracker {
    const string CACHE_FILE = IO::FromStorageFolder("authortracker.json");
    const string CACHE_FILE_INFO = IO::FromStorageFolder("authortracker-meta.json");
    Json::Value@ data = null;
    Json::Value@ meta = null;
    // 4 hrs
    const int CHECK_LIMIT_S = 60 * 60 * 4;
    // if the player's data isn't found, use a well known player instead
    const string SPAMS_WSID = "3bb0d130-637d-46a6-9c19-87fe4bda3c52";

    void Load() {
        if (data !is null) return;
        if (IO::FileExists(CACHE_FILE))
            @data = Json::FromFile(CACHE_FILE);
        if (IO::FileExists(CACHE_FILE_INFO))
            @meta = Json::FromFile(CACHE_FILE_INFO);
        if (meta is null) {
            @meta = Json::Object();
            meta['lastRequested'] = "0";
        }
        if (data !is null) OnUpdateMaps();
        startnew(_UpdateLoop);
    }

    int NextRequestWaitTimeSeconds() {
        if (meta is null) return 0;
        int lastReq = Text::ParseInt(meta.Get('lastRequested'));
        auto lastReqAgo = Time::Stamp - lastReq;
        return Math::Max(0, CHECK_LIMIT_S - lastReqAgo);
    }

    uint updateErrorCount = 0;
    void _UpdateLoop() {
        while (true) {
            yield();
            auto sleepSecs = NextRequestWaitTimeSeconds();
            if (sleepSecs > 0) {
                sleep(sleepSecs * 1000);
            }
            auto newData = GetPlayersInfo(LocalAccountId);
            if (newData is null || lastGetPlayersInfoRaw.Length < 2048) {
                updateErrorCount++;
                if (updateErrorCount > 5) {
                    log_error("Author tracker data failed to update.");
                    return;
                }
                log_warn("Got null back for players info from a-t.com or a very short response. Sleeping for 60s. (error count = "+updateErrorCount+")");
                sleep(60*1000);
                continue;
            }
            IO::File cache(CACHE_FILE, IO::FileMode::Write);
            cache.Write(lastGetPlayersInfoRaw);
            cache.Close();
            @data = newData;
            meta['lastRequested'] = tostring(Time::Stamp);
            Json::ToFile(CACHE_FILE_INFO, meta);
            OnUpdateMaps();
        }
    }

    int nbReqs = 0;
    string lastGetPlayersInfoRaw;
    Json::Value@ GetPlayersInfo(const string &in wsid) {
        string url = "https://author-tracker.socr.am/api/nadeo/totdAtCount";
        auto req = PluginGetRequest(url);
        nbReqs++;
        req.Start();
        while (!req.Finished()) yield();
        nbReqs--;
        // if the player results in a 404, it's likely they don't have enough ATs. soln: use a diff player
        if (req.ResponseCode() == 404) {
            return GetPlayersInfo(SPAMS_WSID);
        }
        if (req.ResponseCode() >= 400 || req.Error().Length > 0) {
            log_warn("Failed to get player info from author-tracker.socr.am. Error: " + req.Error());
            return null;
        }
        lastGetPlayersInfoRaw = req.String();
        return Json::Parse(lastGetPlayersInfoRaw);
    }

    void OnUpdateMaps() {
        while (!TOTD::initialSyncDone) yield();
        auto tracks = data.Get('tracks');
        bool limitExecTime = !ShowWindow || !UI::IsOverlayShown();
        uint count = 0;
        for (uint i = 0; i < tracks.Length; i++) {
            auto month = tracks[i];
            auto mTracks = month.Get('tracks');
            for (uint j = 0; j < mTracks.Length; j++) {
                auto map = mTracks[j];
                string uid = map.Get('mapUid');
                if (!totdMaps.Exists(uid)) {
                    log_warn("at.com data: missing uid: `" + uid + "` for track: " + Json::Write(map));
                    continue;
                }
                auto lm = cast<LazyMap>(totdMaps[uid]);
                if (lm is null) throw('failed to cast map: ' + uid);
                lm.AtCount = map.Get('atCount');

                count++;
                if (limitExecTime && count % 50 == 0) yield();
            }
        }
        log_trace("Set AtCount on " + count + " maps.");
        if (limitExecTime) yield();
        MarkRecordCacheStale();
    }

    const string PlayersRanking() {
        if (data is null) return "Coming soon...";
        try {
            if (string(data.Get('player').Get('id')) != LocalAccountId) {
                return "Unranked";
            }
            return tostring(int(data.Get('rank')));

        } catch {}
        return "Coming soon...";
    }

    void DrawTab() {
        // disable for the moment
        return;
        // if (data is null) return;
        // if (StatsTab("Author Tracker")) {
        //     UI::FullWidthCentered("atcom-main", DrawMainData);
        //     UI::EndTabItem();
        // }
    }

    void DrawMainData() {
        UI::Text(Json::Write(data.Get('player')));
    }
}
