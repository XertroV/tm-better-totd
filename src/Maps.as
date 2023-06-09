void LoadMapNowWrapper(const string &in url, const string &in settings) {
#if DEPENDENCY_ARCHIVIST
    if (S_LoadInArchivist) {
        try {
            Archivist::LoadMapFromUrlNow(url);
            return;
        } catch {}
    }
#endif
    // only load this if MLHook is installed b/c the UI sucks otherwise.
    // PlayMap ui is better than bad campaign ui
#if DEPENDENCY_MLHOOK
    if (Meta::GetPluginFromID("MLHook").Enabled) {
        // LoadMapNow(url, "TrackMania/TM_Campaign_Local", settings);
        // return;
    }
#endif
    LoadMapNow(url, "", settings);
}

void LoadMapNow(const string &in url, const string &in mode = "", const string &in settingsXml = "") {
    if (!Permissions::PlayLocalMap()) {
        NotifyError("Refusing to load map because you lack the necessary permissions. Standard or Club access required");
        return;
    }
    // change the menu page to avoid main menu bug where 3d scene not redrawn correctly (which can lead to a script error and `recovery restart...`)
    auto app = cast<CGameManiaPlanet>(GetApp());
    ReturnToMenu(true);
    app.ManiaTitleControlScriptAPI.PlayMap(url, mode, settingsXml);
}

void EditMapNow(const string &in url) {
    if (!Permissions::OpenAdvancedMapEditor()) {
        NotifyError("Refusing to load the map editor because you lack the necessary permissions.");
        return;
    }
    auto app = cast<CGameManiaPlanet>(GetApp());
    ReturnToMenu(true);
    app.ManiaTitleControlScriptAPI.EditMap(url, "", "");
}

void ReturnToMenu(bool yieldTillReady = false) {
    auto app = cast<CGameManiaPlanet>(GetApp());
    if (app.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed) {
        app.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);
    }
    app.BackToMainMenu();
    while (yieldTillReady && !app.ManiaTitleControlScriptAPI.IsReady) yield();
}

bool CurrentlyInMap {
    get {
        return GetApp().RootMap !is null && GetApp().CurrentPlayground !is null;
    }
}
