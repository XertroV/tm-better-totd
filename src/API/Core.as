
const string LocalAccountId {
    get {
        return cast<CGameManiaPlanet>(GetApp()).MenuManager.MenuCustom_CurrentManiaApp.LocalUser.WebServicesUserId;
    }
}


const string CurrentMapUid {
    get {
        auto m = GetApp().RootMap;
        if (m is null) return "";
        return m.EdChallengeId;
    }
}


// Do not keep handles to these objects around
CNadeoServicesMap@ GetMapFromUid(const string &in mapUid) {
    if (mapUid.Length < 10) {
        log_warn('passing bad map uids can crash the game');
        throw('bad map uid passed: ' + mapUid);
    }
    auto app = cast<CGameManiaPlanet>(GetApp());
    auto userId = app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr.Users[0].Id;
    auto resp = app.MenuManager.MenuCustom_CurrentManiaApp.DataFileMgr.Map_NadeoServices_GetFromUid(userId, mapUid);
    WaitAndClearTaskLater(resp, app.MenuManager.MenuCustom_CurrentManiaApp.DataFileMgr);
    if (resp.HasFailed || !resp.HasSucceeded) {
        NotifyWarning("Couldn't load map info :(");
        log_warn('GetMapFromUid failed for ' + mapUid + ': ' + resp.ErrorCode + ", " + resp.ErrorType + ", " + resp.ErrorDescription);
        return null;
    }
    return resp.Map;
}


// Do not keep handles to these objects around
array<CNadeoServicesMap@> GetMapsFromUids(MwFastBuffer<wstring> &in mapUids) {
    auto app = cast<CGameManiaPlanet>(GetApp());
    auto userId = app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr.Users[0].Id;
    auto resp = app.MenuManager.MenuCustom_CurrentManiaApp.DataFileMgr.Map_NadeoServices_GetListFromUid(userId, mapUids);
    WaitAndClearTaskLater(resp, app.MenuManager.MenuCustom_CurrentManiaApp.DataFileMgr);
    if (resp.HasFailed || !resp.HasSucceeded) {
        NotifyWarning("Couldn't load " + mapUids.Length + " map infos :(");
        log_warn('GetMapsFromUids failed: ' + resp.ErrorCode + ", " + resp.ErrorType + ", " + resp.ErrorDescription);
        return {};
    }
    auto ret = array<CNadeoServicesMap@>();
    for (uint i = 0; i < resp.MapList.Length; i++) {
        ret.InsertLast(resp.MapList[i]);
    }
    return ret;
}

// do not keep handles to this object around!
CMapRecord@ GetPlayerRecordOnMap(const string &in mapUid) {
    auto app = cast<CGameManiaPlanet>(GetApp());
    auto mccma = app.MenuManager.MenuCustom_CurrentManiaApp;
    auto userId = mccma.UserMgr.Users[0].Id;
    MwFastBuffer<wstring> wsids = MwFastBuffer<wstring>();
    wsids.Add(mccma.LocalUser.WebServicesUserId);
    auto task = mccma.ScoreMgr.Map_GetPlayerListRecordList(userId, wsids, mapUid, "PersonalBest", "", "TimeAttack", "");
    WaitAndClearTaskLater(task, mccma.ScoreMgr);
    if (task.HasFailed || !task.HasSucceeded) {
        log_warn("Failed to get player record on map: " + mapUid + ' // Error: ' + task.ErrorCode + ", " + task.ErrorType + ", " + task.ErrorDescription);
        return null;
    }
    if (task.MapRecordList.Length == 0) {
        // log_warn("No record for map: " + mapUid + ' // Error: ' + task.ErrorCode + ", " + task.ErrorType + ", " + task.ErrorDescription);
        return null;
    }
    return task.MapRecordList[0];
}

uint Map_GetRecord_v2(const string &in mapUid) {
    auto app = cast<CGameManiaPlanet>(GetApp());
    auto mccma = app.MenuManager.MenuCustom_CurrentManiaApp;
    auto userId = mccma.UserMgr.Users[0].Id;
    return mccma.ScoreMgr.Map_GetRecord_v2(userId, mapUid, "PersonalBest", "", "TimeAttack", "");
}
