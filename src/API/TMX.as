namespace TMX {
    const string getMapByUidEndpoint = "https://trackmania.exchange/api/maps/get_map_info/uid/{id}";

    // <https://api2.mania.exchange/Method/Index/37>
    Json::Value@ GetMapFromUid(const string &in uid) {
        string url = getMapByUidEndpoint.Replace("{id}", uid);
        auto req = PluginGetRequest(url);
        req.Start();
        while (!req.Finished()) yield();
        if (req.ResponseCode() >= 400 || req.ResponseCode() < 200 || req.Error().Length > 0) {
            log_warn("[status:" + req.ResponseCode() + "] Error getting map by UID from TMX: " + req.Error());
            return null;
        }
        // log_info("Debug tmx get map by uid: " + req.String());
        return Json::Parse(req.String());
    }

    // <https://api2.mania.exchange/Method/Index/1>
    const string getMapsByUidsEndpoint = "https://trackmania.exchange/api/maps/get_map_info/multi/{ids,}";
    Json::Value@ GetMapsByUids(string[] &in uids) {
        // 8 uids works, 10 doesn't
        if (uids.Length > 8) throw("More than 8 uids passed in at once");
        string url = getMapsByUidsEndpoint.Replace("{ids,}", string::Join(uids, ","));
        auto req = PluginGetRequest(url);
        req.Start();
        while (!req.Finished()) yield();
        if (req.ResponseCode() >= 400 || req.Error().Length > 0) {
            log_warn("[status:" + req.ResponseCode() + "] Error getting map by UIDs from TMX. URL: " + url + "; Error: " + req.Error());
            return null;
        }
        return Json::Parse(req.String());
    }

    void OpenTmxTrack(int TrackID) {
#if DEPENDENCY_MANIAEXCHANGE
        try {
            if (Meta::GetPluginFromID("ManiaExchange").Enabled) {
                ManiaExchange::ShowMapInfo(TrackID);
                return;
            }
        } catch {}
#endif
        OpenBrowserURL("https://trackmania.exchange/s/tr/" + TrackID);
    }

    void OpenTmxAuthor(int TMXAuthorID) {
#if DEPENDENCY_MANIAEXCHANGE
        try {
            if (Meta::GetPluginFromID("ManiaExchange").Enabled) {
                ManiaExchange::ShowUserInfo(TMXAuthorID);
                return;
            }
        } catch {}
#endif
        OpenBrowserURL("https://trackmania.exchange/user/profile/" + TMXAuthorID);
    }
}
