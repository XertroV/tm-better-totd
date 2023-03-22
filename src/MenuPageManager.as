namespace MM {
    CGameUILayer@ _layer = null;

    CGameUILayer@ getControlLayer() {
        if (_layer is null) {
            auto mm = cast<CTrackMania>(GetApp()).MenuManager;
            @_layer = mm.MenuCustom_CurrentManiaApp.UILayerCreate();
            _layer.AttachId = "ChangeMenuScreen";
        }
        return _layer;
    }

    /**
     * Set the menu page. Setting a nonexistant route will result in an empty screen (with only the BG showing), but otherwise works fine.
     *
     * Example routes:
     * - /home
     * - /local
     * - /live
     * - /solo
     */
    void setMenuPage(const string &in routeName) {
        getControlLayer().ManialinkPage = genManialinkPushRoute(routeName);
    }

    /**
     * Generate the ML wrapper for Router_Push event.
     */
    const string genManialinkPushRoute(const string &in routeName) {
        string name = routeName.StartsWith("/") ? routeName : ("/" + routeName);
        string mlCode = """
<manialink name="CGF_AvoidHomePage" version="3">
<script><!--

main() {
  declare Integer Nonce;
  Nonce = """;
  mlCode += tostring(Time::Now);
  mlCode += ";\n";
  mlCode += "  SendCustomEvent(\"Router_Push\", [\"" + name + "\", \"{}\", \"" + RouterPushJson + "\"]);\n";
  mlCode += """
}

--></script>
</manialink>
        """;
        return mlCode;
    }

    // this is the payload associated with most of the main menu transitions beteween pages. we include it mostly to avoid issues that might arise by not including it.
    const string RouterPushJson = """{\"SaveHistory\":true,\"ResetPreviousPagesDisplayed\":true,\"KeepPreviousPagesDisplayed\":false,\"HidePreviousPage\":true,\"ShowParentPage\":false,\"ExcludeOverlays\":[]}""";
}
