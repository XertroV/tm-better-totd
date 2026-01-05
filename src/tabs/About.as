void DrawAboutTabOuter() {
    auto totalReqs = nbTotdReqs + nbMapInfoRequests + nbPlayerRecordReqs + nbTmxReqs + AuthorTracker::nbReqs;
    auto label = totalReqs == 0 ? "About###about-tab" : ("About (" + HourGlassAnim() + " " + totalReqs + ")###about-tab");
    if (UI::BeginTabItem(label, UI::TabItemFlags::Trailing)) {
        DrawAboutTabInner();
        UI::EndTabItem();
    }
}

void DrawAboutTabInner() {
    UI::FullWidthCentered("MainTitle", About::MainTitle);
    UI::FullWidthCentered("VersionLineInfo", About::VersionLineInfo);
    UI::Separator();
    UI::FullWidthCentered("RequestsStatus", About::RequestsStatus);
    UI::FullWidthCentered("DrawNextRequestsAt", About::DrawNextRequestsAt);
    if (UI::CollapsingHeader("In-progress PB requests")) {
        About::DrawInProgressPbReqs();
    }
    UI::Separator();
    UI::FullWidthCentered("UtilButtons", About::UtilButtons);
}

namespace About {
    void MainTitle() {
        UI_PushFont_Large();
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
        UI::AlignTextToFramePadding();
        UI::Text("Current Requests:");
        UI::SameLine();
        UI::Text("TOTD: " + nbTotdReqs);
        UI::SameLine();
        UI::Text("Maps: " + nbMapInfoRequests);
        UI::SameLine();
        UI::Text("PBs: " + nbPlayerRecordReqs);
        UI::SameLine();
        UI::Text("TMX: " + nbTmxReqs);
        UI::SameLine();
        UI::Text("Author Tracker: " + AuthorTracker::nbReqs);
    }

    void DrawNextRequestsAt() {
        UI::Text("Author Tracker update in " + GetHumanTimePeriod(AuthorTracker::NextRequestWaitTimeSeconds()));
        UI::Text("Next TOTD in " + GetHumanTimePeriod(newTotdAt - Time::Stamp));
    }

    void UtilButtons() {
        if (UI::Button("Your Author Tracker rank: " + AuthorTracker::PlayersRanking())) {
            OpenBrowserURL("https://www.author-tracker.socr.am");
        }
    }

    void DrawInProgressPbReqs() {
        auto uids = pbRecordsReqs.GetKeys();
        UI::ListClipper clip(uids.Length);
        while (clip.Step()) {
            for (int i = clip.DisplayStart; i < clip.DisplayEnd; i++) {
                string uid = uids[i];
                auto map = cast<LazyMap>(totdMaps[uid]);
                UI::Text(map.cleanName + ": " + int(pbRecordsReqs[uid]));
            }
        }
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
