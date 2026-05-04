const string TMX_DB_PATH = IO::FromStorageFolder("tmx.db");
DictOfTmxMapInfo_WriteLog@ tmxDb = InitializeTmxDB();

DictOfTmxMapInfo_WriteLog@ InitializeTmxDB(bool allowDeleteAndRecreate = true) {
    try {
        return DictOfTmxMapInfo_WriteLog(IO::FromStorageFolder(""), "tmx.db");
    } catch {
        auto ex = getExceptionInfo();
        log_error("Failed to initialize TMX DB: " + ex);
        if (allowDeleteAndRecreate) {
            log_warn("Deleting and recreating TMX DB...");
            try {
                if (IO::FileExists(TMX_DB_PATH)) {
                    IO::Delete(TMX_DB_PATH);
                }
                return DictOfTmxMapInfo_WriteLog(IO::FromStorageFolder(""), "tmx.db");
            } catch {
                ex = getExceptionInfo();
                log_error("Failed to delete and recreate TMX DB: " + ex);
                throw(ex);
            }
        } else {
            throw(ex);
        }
        return null;
    }
}

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
        if (uids.Length >= TMX::maxTmxUidsLength) {
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
    if (j is null || !j.HasKey("Results")|| j["Results"].GetType() != Json::Type::Array) {
        log_warn("Failed tmx get maps by uid, trying once more in 1s");
        sleep(1000);
        @j = TMX::GetMapsByUids(uids);
    }
    if (j is null || !j.HasKey("Results")|| j["Results"].GetType() != Json::Type::Array) {
        log_warn("Failed tmx get maps by uid for 2nd time, returning early.");
        return;
    }

    auto results = j["Results"];

    for (uint i = 0; i < results.Length; i++) {
        try {
            CacheTmxInfoForMap(results[i]);
        } catch {
            log_warn("Exception (" +getExceptionInfo()+ ") caching this data: " + Json::Write(results[i]));
            throw(getExceptionInfo());
        }
    }
    log_trace("Size of TMX db: " + tmxDb.GetSize());
}

string[] copyTmxKeys = {"MapId", "Name", "Tags"};

void CacheTmxInfoForMap(Json::Value@ map) {
    string uid = map["MapUid"];
    tmxDb.Set(uid, TmxMapInfo(map));
}
