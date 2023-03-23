void DrawAboutTabInner() {
    UI::FullWidthCentered("MainTitle", About::MainTitle);
    UI::FullWidthCentered("VersionLineInfo", About::VersionLineInfo);
    UI::Separator();
    UI::FullWidthCentered("RequestsStatus", About::RequestsStatus);
}

namespace About {
    void MainTitle() {
        UI::PushFont(g_LargeFont);
        UI::AlignTextToFramePadding();
        UI::Text(FullWindowTitle);
        UI::PopFont();
    }

    void VersionLineInfo() {
        auto p = Meta::ExecutingPlugin();
        UI::PushStyleColor(UI::Col::Text, vec4(.5, .5, .5, 1));
        UI::AlignTextToFramePadding();
        UI::Text("Version: " + p.Version);
        UI::PopStyleColor();
        UI::SameLine();
        if (UI::Button(Icons::Heartbeat + " Openplanet")) {
            OpenBrowserURL("https://openplanet.dev/plugin/bettertotd");
        }
        UI::SameLine();
        if (UI::Button(Icons::Stethoscope + " Discord / Bugs")) {
            OpenBrowserURL("https://discord.com/channels/276076890714800129/1088306856079933481");
        }
    }

    void RequestsStatus() {
        UI::Text("Current Requests:");
        UI::SameLine();
        UI::Text("TOTD: " + nbTotdReqs);
        UI::SameLine();
        UI::Text("Maps: " + nbMapInfoRequests);
        UI::SameLine();
        UI::Text("PBs: " + nbPlayerRecordReqs);
        UI::SameLine();
        UI::Text("TMX: " + nbTmxReqs);
    }
}

namespace UI {
    void FullWidthCentered(const string &in id, CoroutineFunc@ f) {
        UI::PushID(id);
        if (UI::BeginTable("c", 3, UI::TableFlags::SizingFixedFit)) {
            UI::TableSetupColumn("lhs", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn("mid", UI::TableColumnFlags::WidthFixed);
            UI::TableSetupColumn("rhs", UI::TableColumnFlags::WidthStretch);
            UI::TableNextRow();
            UI::TableNextColumn();
            UI::TableNextColumn();
            f();
            UI::TableNextColumn();
            UI::EndTable();
        }
        UI::PopID();
    }
}
