const string TMX_DB_PATH = IO::FromStorageFolder("tmx.db");
DictOfTmxMapInfo_WriteLog@ tmxDb = DictOfTmxMapInfo_WriteLog(IO::FromStorageFolder(""), "tmx.db");

void LoadTmxDB() {
    tmxDb.AwaitInitialized();
}

bool tmxScanStarted = false;
void ScanForMissingTmx() {
    if (tmxScanStarted) return;
    tmxScanStarted = true;
    LoadTmxDB();

    uint lastNbTracks = 0;
    while (true) {
        sleep(1000);
        if (allTotds.Length == lastNbTracks) continue;
        lastNbTracks = allTotds.Length;
        string[] toCheck = {};
        for (uint i = 0; i < allTotds.Length; i++) {
            auto lm = allTotds[i];
            if (!tmxDb.Exists(lm.uid)) {
                toCheck.InsertLast(lm.uid);
            }
        }
        CacheTmxInfoFor(toCheck);
    }
}

int nbTmxReqs = 0;

void CacheTmxInfoFor(string[] &in allUids) {
    log_trace("Syncing " + allUids.Length + " maps via TMX");
    nbTmxReqs += allUids.Length;
    string[] uids = {};
    for (uint i = 0; i < allUids.Length; i++) {
        uids.InsertLast(allUids[i]);
        if (uids.Length >= 5) {
            CacheTmxInfoForChunk(uids);
            nbTmxReqs -= uids.Length;
            uids.RemoveRange(0, uids.Length);
        }
    }
    if (uids.Length > 0) CacheTmxInfoForChunk(uids);
    nbTmxReqs -= uids.Length;
}

void CacheTmxInfoForChunk(string[] &in uids) {
    log_trace("["+Time::Now+"] Syncing chunk of " + uids.Length + " maps via TMX.");
    auto j = TMX::GetMapsByUids(uids);
    if (j is null || j.GetType() != Json::Type::Array) {
        log_warn("Failed tmx get maps by uid, trying once more in 1s");
        sleep(1000);
        @j = TMX::GetMapsByUids(uids);
    }
    if (j is null || j.GetType() != Json::Type::Array) {
        log_warn("Failed tmx get maps by uid for 2nd time, returning early.");
        return;
    }
    for (uint i = 0; i < j.Length; i++) {
        try {
            CacheTmxInfoForMap(j[i]);
        } catch {
            log_warn("Exception (" +getExceptionInfo()+ ") caching this data: " + Json::Write(j[i]));
            throw(getExceptionInfo());
        }
    }
    log_trace("Size of TMX db: " + tmxDb.GetSize());
}

string[] copyTmxKeys = {"TrackID", "Name", "Tags"};

void CacheTmxInfoForMap(Json::Value@ map) {
    string uid = map.Get('TrackUID');
    tmxDb.Set(uid, TmxMapInfo(map));
}
