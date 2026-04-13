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
int requestLength = 0;
int maxUriLength = 800; // TMX has a limit of 1000 chars for the URI. So we set out URI length lower to account for the rest of the URL.

void CacheTmxInfoFor(string[] &in allUids) {
    log_trace("Syncing " + allUids.Length + " maps via TMX");
    nbTmxReqs += allUids.Length;
    string[] uids = {};
    for (uint i = 0; i < allUids.Length; i++) {
        uids.InsertLast(allUids[i]);
        requestLength += allUids[i].Length;
        if (requestLength >= maxUriLength) {
            CacheTmxInfoForChunk(uids);
            nbTmxReqs -= uids.Length;
            uids.RemoveRange(0, uids.Length);
            requestLength = 0;
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
