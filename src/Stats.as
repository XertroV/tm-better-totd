uint staleTime = 0;
bool recordStatsStale = false;

void MarkRecordCacheStale() {
    recordStatsStale = true;
    if (staleTime == 0)
        staleTime = Time::Now;
}

void WatchStaleStatsCache() {
    while (true) {
        sleep(100);
        if (recordStatsStale && staleTime + 500 <= Time::Now) {
            recordStatsStale = false;
            staleTime = 0;
            RecalcTotdStats();
        }
    }
}

void RecalcTotdStats() {
    globalStats.Reset();
    campaignStats.Resize(totalCampaigns);
    monthStats.Resize(totalMonths);
    for (uint i = 0; i < campaignStats.Length; i++) {
        if (campaignStats[i] is null) @campaignStats[i] = Stats();
        else campaignStats[i].Reset();
    }
    for (uint i = 0; i < monthStats.Length; i++) {
        if (monthStats[i] is null) @monthStats[i] = Stats();
        else monthStats[i].Reset();
    }
    // pause if the window isn't visible
    bool doPauses = !ShowWindow || !UI::IsOverlayShown();
    if (doPauses) yield();
    for (uint i = 0; i < allTotds.Length; i++) {
        auto lm = allTotds[i];
        globalStats.CountLazyMap(lm);
        campaignStats[lm.campaignIx].CountLazyMap(lm);
        monthStats[lm.monthIx].CountLazyMap(lm);
        if (doPauses && i % 100 == 0) yield();
    }
    if (doPauses) yield();
    g_FiltersChanged = true;
    // ! testing
    // for (uint i = monthStats.Length - 1; i < monthStats.Length; i--) {
    //     if (monthStats[i].nbTracks == 0) monthStats.RemoveLast();
    //     else break;
    // }
    // for (uint i = campaignStats.Length - 1; i < campaignStats.Length; i--) {
    //     if (campaignStats[i].nbTracks == 0) campaignStats.RemoveLast();
    //     else break;
    // }
}


const string iconUnplayed = "\\$444" + Icons::CircleO + " \\$z";
const string iconPlayed = "\\$444" + Icons::Circle + " \\$z";
const string iconBronze = "\\$964" + Icons::Circle + " \\$z";
const string iconSilver = "\\$899" + Icons::Circle + " \\$z";
const string iconGold = "\\$db4" + Icons::Circle + " \\$z";
const string iconAuthor = "\\$071" + Icons::Circle + " \\$z";

array<string> medalIconsArr = {iconAuthor, iconGold, iconSilver, iconBronze, iconPlayed, iconUnplayed};

const string GetMedalIcon(int medal) {
    if (medal < 0) return Icons::QuestionCircle;
    return medalIconsArr[medal];
}

class Stats {
    Stats() {}

    int nbTracks = 0;
    int nbRecords = 0;
    int nbBronze = 0;
    int nbSilver = 0;
    int nbGold = 0;
    int nbAuthor = 0;
    int nbUnknown = 0;
    int nbUnplayed = 0;

    float pctPlayed;
    float pctBronze;
    float pctSilver;
    float pctGold;
    float pctAuthor;
    float pctUnknown;
    float pctUnplayed;

    LazyMap@[] maps;

    void Reset() {
        maps.RemoveRange(0, maps.Length);
        nbTracks = 0;
        nbRecords = 0;
        nbBronze = 0;
        nbSilver = 0;
        nbGold = 0;
        nbAuthor = 0;
        nbUnknown = 0;
        nbUnplayed = 0;
    }

    void CountLazyMap(LazyMap@ lm) {
        maps.InsertLast(lm);
        nbTracks++;
        // we only return early if something in the map is still loading.
        if (lm.playerRecordTime < -1 || lm.medals[0] < 0) {
            nbUnknown++;
            return;
        }
        if (lm.playerRecordTime > 0) nbRecords++;
        if (lm.playerRecordTime == -1) nbUnplayed++;
        if (lm.playerRecordTime > 0 && lm.medals[0] > 0) {
            if (lm.medals[0] >= lm.playerRecordTime) nbAuthor++;
            if (lm.medals[1] >= lm.playerRecordTime) nbGold++;
            if (lm.medals[2] >= lm.playerRecordTime) nbSilver++;
            if (lm.medals[3] >= lm.playerRecordTime) nbBronze++;
        }
        pctUnknown = float(nbUnknown * 100) / float(nbTracks);
        pctUnplayed = float(nbUnplayed * 100) / float(nbTracks);
        pctPlayed = float(nbRecords * 100) / float(nbTracks);
        pctBronze = float(nbBronze * 100) / float(nbTracks);
        pctSilver = float(nbSilver * 100) / float(nbTracks);
        pctGold = float(nbGold * 100) / float(nbTracks);
        pctAuthor = float(nbAuthor * 100) / float(nbTracks);
    }

    void DrawSimple() {
        // UI::Text("Tracks: " + nbTracks);
        if (nbUnknown > 0)
            UI::Text("Loading: " + nbUnknown + " / " + nbTracks + Text::Format(" (%.2f%%)", pctUnknown));
        UI::Text("Unplayed: " + nbUnplayed + " / " + nbTracks + Text::Format(" (%.2f%%)", pctUnplayed));
        UI::Text("Played: " + nbRecords + " / " + nbTracks + Text::Format(" (%.2f%%)", pctPlayed));
        UI::Text("Bronze: " + nbBronze + " / " + nbTracks + Text::Format(" (%.2f%%)", pctBronze));
        UI::Text("Silver: " + nbSilver + " / " + nbTracks + Text::Format(" (%.2f%%)", pctSilver));
        UI::Text("Gold: " + nbGold + " / " + nbTracks + Text::Format(" (%.2f%%)", pctGold));
        UI::Text("Author: " + nbAuthor + " / " + nbTracks + Text::Format(" (%.2f%%)", pctAuthor));
    }

    void DrawStatus() {
        UI::PushID(this);
        uint nCols = 6 + 2;
        if (nbUnknown > 0) nCols++;
        if (UI::BeginTable("maps status", nCols, UI::TableFlags::SizingFixedSame)) {
            UI::TableSetupColumn("lhs", UI::TableColumnFlags::WidthStretch);
            for (uint i = 0; i < nCols - 2; i++) {
                UI::TableSetupColumn("c"+i, UI::TableColumnFlags::WidthFixed);
            }
            UI::TableSetupColumn("rhs", UI::TableColumnFlags::WidthStretch);
            UI::TableNextRow();
            // empty first
            UI::TableNextColumn();
            // conditional loading
            if (nbUnknown > 0) {
                UI::TableNextColumn();
                UI::Text(ProgressStr(HourGlassAnim() + " ", nbUnknown, pctUnknown));
            }
            // unplayed
            UI::TableNextColumn();
            UI::Text(ProgressStr(iconUnplayed, nbUnplayed, pctUnplayed));
            // played
            UI::TableNextColumn();
            UI::Text(ProgressStr(iconPlayed, nbRecords, pctPlayed));
            // bronze
            UI::TableNextColumn();
            UI::Text(ProgressStr(iconBronze, nbBronze, pctBronze));
            // silver
            UI::TableNextColumn();
            UI::Text(ProgressStr(iconSilver, nbSilver, pctSilver));
            // gold
            UI::TableNextColumn();
            UI::Text(ProgressStr(iconGold, nbGold, pctGold));
            // at
            UI::TableNextColumn();
            UI::Text(ProgressStr(iconAuthor, nbAuthor, pctAuthor));
            // empty
            UI::TableNextColumn();
            UI::EndTable();
        }

        UI::PopID();
    }

    const string ProgressStr(const string &in pre, int nb, float pct) {
        // return pre + nb + " / " + nbTracks + Text::Format(" (%.2f%%)", pct);
        return pre + nb + " / " + nbTracks;
    }

    void DrawCalendarSelect() {
        if (maps.Length == 0) {
            UI::Text("No maps :(");
            return;
        }
        auto map1 = maps[0];
        int calStartOff = map1.weekDay;
        auto width = UI::GetWindowContentRegionWidth();
        auto fp = UI::GetStyleVarVec2(UI::StyleVar::FramePadding);
        auto colWidth = width / 8.;
        float tableWidth = width / 8. * 7.;
        UI::SetCursorPos(UI::GetCursorPos() + vec2(colWidth / 2., 0));
        vec2 btnSize = vec2(colWidth - fp.x, 50.);
        if (UI::BeginTable("month-table-" + map1.monthIx, 7, UI::TableFlags::None, vec2(tableWidth, 0))) {
            // skip to day of first map
            for (int i = 0; i < calStartOff; i++) {
                UI::TableNextColumn();
            }
            for (uint i = 0; i < maps.Length; i++) {
                auto map = maps[i];
                UI::TableNextColumn();
                map.DrawCalendarButton(btnSize);
                // check for most recent TOTD
                if (map.endTimestamp > Time::Stamp && Time::Stamp > map.startTimestamp) {
                    UI::TableNextColumn();
                    DrawNextTotdCountdownButton(btnSize);
                }
            }

            UI::EndTable();
        }
    }
}


void DrawNextTotdCountdownButton(vec2 size) {
    auto pos = UI::GetCursorPos();
    UI::BeginDisabled();
    UI::PushStyleColor(UI::Col::Button, vec4(.3));
    UI::Button("", size);
    UI::PopStyleColor();
    UI::EndDisabled();
    auto endPos = UI::GetCursorPos();

    UI::PushFont(g_MidFont);
    // auto fontH = UI::GetTextLineHeight();
    auto timeLeft = "Next TOTD\n" + Time::Format(Math::Max(0, newTotdAt - Time::Stamp) * 1000, false, true, true);
    auto textSz = Draw::MeasureString(timeLeft);
    UI::SetCursorPos(pos + size * vec2(.5, .5) - textSz / 2.);
    UI::PushStyleColor(UI::Col::Text, vec4(1, 1, 1, .5));
    UI::Text(timeLeft);
    UI::PopStyleColor();
    UI::PopFont();
    UI::SetCursorPos(endPos);
}


Stats@ globalStats = Stats();
Stats@[] campaignStats = {};
Stats@[] monthStats = {};

string[] hourGlassIcons = {Icons::HourglassStart, Icons::HourglassHalf, Icons::HourglassEnd};
const string HourGlassAnim() {
    return hourGlassIcons[(Time::Now / 2) % 1000 / 334];
}
