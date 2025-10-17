UI::Font@ g_BoldFont = UI::Font::DefaultBold;

void UI_PushFont_Large() {
    UI::PushFont(UI::Font::Default, 26.0);
}

void UI_PushFont_Mid() {
    UI::PushFont(UI::Font::Default, 20.0);
}

void RenderMainWindowInner() {
    if (!UserHasPermissions) {
        UI::Text("Missing permissions.");
        return;
    }
    if (!totdDb.Initialized) {
        UI::Text("TOTD Info Loading...");
        return;
    }
    DrawHomeStats();
}

string g_SelectStatsTab = "";
bool StatsTab(const string &in name) {
    auto flags = g_SelectStatsTab == name ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None;
    return UI::BeginTabItem(name, flags);
}

void DrawHomeStats() {
    UI::BeginTabBar("stats tabs");

    if (StatsTab("Overview")) {
        DrawOverviewStats();
        UI::EndTabItem();
    }
    if (StatsTab("By Campaign")) {
        DrawStatsByCampaign();
        UI::EndTabItem();
    }
    if (StatsTab("By Month")) {
        DrawStatsByMonth();
        UI::EndTabItem();
    }
    if (StatsTab("All TOTDs")) {
        DrawTotdAll();
        UI::EndTabItem();
    }
    DrawAboutTabOuter();
    AuthorTracker::DrawTab();

    UI::EndTabBar();
    g_SelectStatsTab = "";
}

vec4 overviewTableRowBg = vec4(.2, .2, .2, .2);

void DrawOverviewStats() {
    globalStats.DrawStatus();
    UI::Separator();
    if (UI::BeginChild("overview months")) {
        UI::ListClipper clip(campaignStats.Length);
        UI::PushStyleColor(UI::Col::TableRowBg, overviewTableRowBg);
        // UI::PushStyleVar(UI::StyleVar::FramePadding);
        if (UI::BeginTable("month-ov", 3, UI::TableFlags::SizingFixedFit | UI::TableFlags::RowBg)) {
            UI::TableSetupColumn("year");
            UI::TableSetupColumn("months-inner", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn("play-campgn");
            while (clip.Step()) {
                for (int i = clip.DisplayStart; i < clip.DisplayEnd; i++) {
                    DrawCampaignOverview(totalCampaigns - 1 - i);
                }
            }
            UI::EndTable();
        }
        UI::PopStyleColor();
    }
    UI::EndChild();
}

/**
 * |      | month1 | 1/2 2/3 3/4 4/5 | [>] | [ \  ]
 * | year | month2 | 1/2 2/3 3/4 4/5 | [>] | [  > ]
 * |      | month3 | 1/2 2/3 3/4 4/5 | [>] | [ /  ]
 */
void DrawCampaignOverview(int ix) {
    UI::PushID("c-o-" + ix);
    auto fp = UI::GetStyleVarVec2(UI::StyleVar::FramePadding);
    auto lineHeight = UI::GetTextLineHeightWithSpacing() + fp.y; // / 2.;
    UI::TableNextRow();
    UI::TableNextColumn();
    UI_PushFont_Large();
    UI::SetCursorPos(UI::GetCursorPos() + vec2(10, (lineHeight * 3. + fp.y) / 2. - (26. + fp.y) / 2));
    UI::Text(CampaignYr(ix) + "  ");
    UI::PopFont();
    UI::TableNextColumn();
    DrawCampaignRowMonthsInner(ix);
    UI::TableNextColumn();
    UI_PushFont_Large();
    auto btnPrePos = UI::GetCursorPos();
    UI::Dummy(vec2(lineHeight * 3. + fp.y));
    UI::SetCursorPos(btnPrePos + vec2(0, fp.y));
    if (UI::Button(Icons::Play, vec2(lineHeight * 3.0 - fp.y))) {            // todo
        g_SelectStatsTab = "By Campaign";
        g_SelectedCampaign = ix;
    }
    UI::PopFont();
    UI::PopID();
}

void DrawCampaignRowMonthsInner(int cIx) {
    UI::PushID("c-m-inner-"+cIx);
    if (UI::BeginTable("month-inner", 3)) {
        UI::TableSetupColumn("month", UI::TableColumnFlags::WidthFixed, UI::GetTextLineHeight() * 1.9);
        UI::TableSetupColumn("medals", UI::TableColumnFlags::WidthStretch);
        UI::TableSetupColumn("btn", UI::TableColumnFlags::WidthFixed);

        int monthIx = cIx * 3;
        DrawCampaignRowMonthRow(monthIx + 2);
        DrawCampaignRowMonthRow(monthIx + 1);
        DrawCampaignRowMonthRow(monthIx);

        UI::EndTable();
    }
    UI::PopID();
}

void DrawCampaignRowMonthRow(uint mIx) {
    UI::PushID(tostring(mIx));
    UI::TableNextRow();
    UI::TableNextColumn();
    UI::AlignTextToFramePadding();
    UI::Text(MonthShortStr(mIx, false));
    UI::TableNextColumn();
    bool exists = mIx < monthStats.Length && monthStats[mIx] !is null;
    if (exists) {
        monthStats[mIx].DrawStatus();
    }
    UI::TableNextColumn();
    if (exists && UI::Button(Icons::Play)) {
        g_SelectStatsTab = "By Month";
        g_SelectedMonth = mIx;
    }
    UI::PopID();
}



[Setting hidden]
int g_SelectedCampaign = -1;
void DrawStatsByCampaign() {
    bool changed;
    if (campaignStats.Length == 0) {
        UI::Text("No stats yet...");
        return;
    }
    if (g_SelectedCampaign == -1) g_SelectedCampaign = campaignStats.Length - 1;
    g_SelectedCampaign = DrawPaginationBar(CampaignStr(g_SelectedCampaign), g_SelectedCampaign, 0, campaignStats.Length - 1, changed);
    if (g_SelectedCampaign >= int(campaignStats.Length) || campaignStats[g_SelectedCampaign] is null) {
        UI::Text("Stats not accessible; index (" + g_SelectedCampaign + ") outside range or stats are null.");
        return;
    }
    campaignStats[g_SelectedCampaign].DrawStatus();
    UI::Separator();
    if (UI::BeginChild("totds-details")) {
        int mIx = g_SelectedCampaign * 3;
        DrawMonthDetails(mIx);
        UI::Separator();
        DrawMonthDetails(mIx + 1);
        UI::Separator();
        DrawMonthDetails(mIx + 2);
    }
    UI::EndChild();
}

[Setting hidden]
int g_SelectedMonth = -1;
void DrawStatsByMonth() {
    bool changed;
    if (monthStats.Length == 0) {
        UI::Text("No stats yet...");
        return;
    }
    if (g_SelectedMonth == -1) g_SelectedMonth = monthStats.Length - 1;
    g_SelectedMonth = DrawPaginationBar(MonthStr(g_SelectedMonth), g_SelectedMonth, 0, monthStats.Length - 1, changed);
    if (g_SelectedMonth >= int(monthStats.Length) || monthStats[g_SelectedMonth] is null) {
        UI::Text("Stats not accessible; index (" + g_SelectedMonth + ") outside range or stats are null.");
        return;
    }
    monthStats[g_SelectedMonth].DrawStatus();
    UI::Separator();
    if (UI::BeginChild("totds-details")) {
        DrawMonthDetails(g_SelectedMonth, false);
    }
    UI::EndChild();
}

void DrawMonthDetails(uint mIx, bool drawMonthTitle = true) {
    if (mIx >= monthStats.Length) return;
    if (drawMonthTitle) {
        UI_PushFont_Mid();
        UI::AlignTextToFramePadding();
        UI::Text(MonthStr(mIx));
        UI::PopFont();
    }
    monthStats[mIx].DrawCalendarSelect();
}

const string MonthStr(int monthIx, bool withYear = true) {
    int m = (monthIx + 6) % 12;
    int y = (monthIx + 6) / 12 + 2020;
    string monthName = monthNames[m];
    if (withYear) monthName += " " + y;
    return monthName;
}

const string MonthShortStr(int monthIx, bool withYear = true) {
    int m = (monthIx + 6) % 12;
    int y = (monthIx + 6) / 12 + 2020;
    string monthName = monthShortNames[m];
    if (withYear) monthName += " " + y;
    return monthName;
}

string[] monthNames = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
string[] monthShortNames = {"Jan", "Feb", "Mar", "April", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"};

const string CampaignStr(int campaignIx) {
    int monthIx = campaignIx * 3;
    int mLow = (monthIx + 6) % 12;
    int mHigh = mLow + 2;
    int y = (monthIx + 6) / 12 + 2020;
    return monthShortNames[mLow] + " - " + monthShortNames[mHigh] + " " + y;
}

int CampaignYr(int cIx) {
    return ((cIx * 3) + 6) / 12 + 2020;
}

// use PushID before this if you want more than one at once.
int DrawPaginationBar(const string &in label, int curr, int min, int max, bool &out changed) {
    bool decr = false, incr = false, decrMuch = false, incrMuch = false, goMin = false, goMax = false;
    if (UI::BeginTable(label+"paginate", 5, UI::TableFlags::SizingFixedFit)) {
        UI::TableSetupColumn("prev", UI::TableColumnFlags::WidthFixed);
        UI::TableSetupColumn("sl", UI::TableColumnFlags::WidthStretch);
        UI::TableSetupColumn("label", UI::TableColumnFlags::WidthFixed);
        UI::TableSetupColumn("sr", UI::TableColumnFlags::WidthStretch);
        UI::TableSetupColumn("next", UI::TableColumnFlags::WidthFixed);

        UI::TableNextRow();
        UI::TableNextColumn();
        goMin = UI::Button(Icons::FastBackward);
        UI::SameLine();
        decrMuch = UI::Button(Icons::Backward);
        UI::SameLine();
        decr = UI::Button(Icons::ChevronLeft);
        UI::TableNextColumn();
        UI::TableNextColumn();
        UI::Text(label);
        UI::TableNextColumn();
        UI::TableNextColumn();
        incr = UI::Button(Icons::ChevronRight);
        UI::SameLine();
        incrMuch = UI::Button(Icons::Forward);
        UI::SameLine();
        goMax = UI::Button(Icons::FastForward);

        UI::EndTable();
    }

    if (decr) curr--;
    else if (incr) curr++;
    else if (decrMuch) curr -= 4;
    else if (incrMuch) curr += 4;
    else if (goMax) curr = max;
    else if (goMin) curr = min;

    changed = decr || incr || decrMuch || incrMuch || goMax || goMin;

    return Math::Clamp(curr, min, max);
}

float dateWidth = 50;
float timeWidth = 60;
float atCountWidth = 60;
void DrawTotdAll() {
    startnew(GetSomeMissingPBs);
    globalStats.DrawStatus();
    DrawTotdFilters();
    UI::Separator();
    if (filteredTotds is null) return;
    dateWidth = Draw::MeasureString("2222-22-22  ").x;
    timeWidth = Draw::MeasureString("00:00:00.000").x;
    atCountWidth = Draw::MeasureString("99999 xx ").x;
    if (UI::BeginChild("all-totds")) {
        UI::PushStyleColor(UI::Col::TableRowBg, overviewTableRowBg);
        if (UI::BeginTable("totds table", 9, UI::TableFlags::SizingFixedFit | UI::TableFlags::RowBg)) {
            UI::TableSetupColumn("date", UI::TableColumnFlags::WidthFixed, dateWidth);
            UI::TableSetupColumn("troll", UI::TableColumnFlags::WidthFixed, dateWidth / 4.);
            UI::TableSetupColumn("name", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn("author", UI::TableColumnFlags::WidthFixed, timeWidth * 2.);
            UI::TableSetupColumn("medal", UI::TableColumnFlags::WidthFixed, dateWidth / 3.);
            UI::TableSetupColumn("pb", UI::TableColumnFlags::WidthFixed, timeWidth);
            UI::TableSetupColumn("pb-set", UI::TableColumnFlags::WidthFixed, dateWidth);
            UI::TableSetupColumn("nb-ats", UI::TableColumnFlags::WidthFixed, atCountWidth);
            UI::TableSetupColumn("btns");
            DrawTotdTableInner();
            UI::EndTable();
        }
        UI::PopStyleColor();
    }
    UI::EndChild();
}


void DrawTotdTableInner() {
    UI::ListClipper clip(filteredTotds.Length);
    while (clip.Step()) {
        for (int i = clip.DisplayStart; i < clip.DisplayEnd; i++) {
            filteredTotds[i].DrawTableRow(i);
        }
    }
}

LazyMap@[]@ filteredTotds = null;

string f_Author;
string f_TrackName;
int f_AfterMonth = -1;
int f_BeforeMonth = -1;
int f_MissingMedals = -1;
int f_HaveMedals = -1;
bool f_ExcludeTroll = false;

void ResetFilters() {
    f_Author = "";
    f_TrackName = "";
    f_AfterMonth = -1;
    f_BeforeMonth = -1;
    f_MissingMedals = -1;
    f_HaveMedals = -1;
    f_ExcludeTroll = false;
    g_FiltersChanged = true;
    setAllTags(tags, true);
}

bool g_FiltersChanged = false;
float widthScale = 1;
// this initializes `filteredTotds`
void DrawTotdFilters() {
    widthScale = UI::GetTextLineHeight() * 6.3 / 100.;
    UI::FullWidthCentered("totd filters 1", FiltersTopRow);
    UI::FullWidthCentered("totd filters 2", FiltersMidRow);
    UI::FullWidthCentered("totd filters 3", FiltersThirdRow);

    if (filteredTotds !is null && !g_FiltersChanged) return;
    g_FiltersChanged = false;
    log_debug("Updating TOTD filtered list");

    PrepAuthorFilter();
    PrepNameFilter();

    @filteredTotds = array<LazyMap@>();
    for (uint i = 0; i < allTotds.Length; i++) {
        auto map = allTotds[i];
        if (f_AfterMonth >= 0 && map.monthIx < f_AfterMonth) continue;
        if (f_BeforeMonth >= 0 && map.monthIx > f_BeforeMonth) continue;
        if (f_MissingMedals >= 0 && 0 <= map.playerMedal && map.playerMedal <= f_MissingMedals) continue;
        if (f_HaveMedals >= 0 && map.playerMedal > f_HaveMedals) continue;
        if (f_ExcludeTroll && map.IsLikelyTroll) continue;
        if (f_Author.Length > 0 && !MatchAuthorSearchString(map.author)) continue;
        if (f_TrackName.Length > 0 && !MatchNameSearchString(map.cleanName)) continue;
        if (!TrackMatchesTagsFilters(map.GetTmxInfo())) continue;
        filteredTotds.InsertLast(map);
    }
    totdsQuicksort(filteredTotds, f_SortMethod < int(sortMethods.Length) ? sortMethods[f_SortMethod] : Less_NewFirst);
}

void FiltersTopRow() {
    // changed does nothing, relic of broken attempt
    bool changed;
    UI::SetNextItemWidth(widthScale * 100);
    f_AfterMonth = UI::FilterMonth("After", f_AfterMonth, changed);
    UI::SameLine();
    UI::SetNextItemWidth(widthScale * 100);
    f_BeforeMonth = UI::FilterMonth("Before", f_BeforeMonth, changed);
    UI::SameLine();
    UI::SetNextItemWidth(widthScale * 55);
    f_MissingMedals = UI::FilterMedals("Missing", f_MissingMedals, changed);
    UI::SameLine();
    UI::SetNextItemWidth(widthScale * 55);
    f_HaveMedals = UI::FilterMedals("Have", f_HaveMedals, changed);
}

void FiltersMidRow() {
    // changed does nothing, relic of broken attempt
    bool changed;
    UI::SetNextItemWidth(widthScale * 80);
    f_TrackName = UI::FilterString("Name", f_TrackName, changed);
    AddSimpleTooltip("Case insensitive. Wildcard: `*`.");
    UI::SameLine();
    UI::SetNextItemWidth(widthScale * 80);
    f_Author = UI::FilterString("Author", f_Author, changed);
    AddSimpleTooltip("Case insensitive. Wildcard: `*`.");
    UI::SameLine();
    if (UI::Button(TrackStylesBtnText())) {
        g_OpenTrackStyles = true;
    }
    UI::SameLine();
    f_ExcludeTroll = UI::FilterBool("No Troll", f_ExcludeTroll, changed);
}

[Setting hidden]
SortMethod f_SortMethod = SortMethod::NewFirst;

void FiltersThirdRow() {
    uint nbFilteredTracks = filteredTotds is null ? 0 : filteredTotds.Length;
    UI::AlignTextToFramePadding();
    UI::Text(""+nbFilteredTracks+" Tracks");
    UI::SameLine();
    if (UI::Button(Icons::Times)) {
        ResetFilters();
    }
    AddSimpleTooltip("Reset Filters");
    UI::SameLine();

    UI::SetNextItemWidth(widthScale * 120);
    if (UI::BeginCombo("Sort", tostring(f_SortMethod))) {
        for (int i = 0; i < SortMethod::_LastNop; i++) {
            auto sm = SortMethod(i);
            if (UI::Selectable(tostring(sm), f_SortMethod == sm)) {
                f_SortMethod = sm;
                TOTD::SortTotds();
                g_FiltersChanged = true;
            }
        }
        UI::EndCombo();
    }

    UI::SameLine();
    if (UI::Button(Icons::Play + " Random")) {
        startnew(PickRandomFromFiltered);
    }
}

void PickRandomFromFiltered() {
    if (filteredTotds.Length == 0) {
        NotifyError("Can't pick a random map when there are 0 to pick from.");
        return;
    }
    auto choice = Math::Rand(0, filteredTotds.Length);
    auto map = filteredTotds[choice];
    SetMapLoadedSource(TrackLoadSrc::Random);
    map.LoadThisMapBlocking();
}

string[]@ f_authorParts;
void PrepAuthorFilter() {
    if (f_Author.Length == 0) return;
    @f_authorParts = f_Author.ToLower().Split("*");
}
string[]@ f_nameParts;
void PrepNameFilter() {
    if (f_TrackName.Length == 0) return;
    @f_nameParts = f_TrackName.ToLower().Split("*");
}

bool MatchAuthorSearchString(const string &in author) {
    if (f_authorParts.Length == 0) return true;
    int lastIx = 0;
    for (uint i = 0; i < f_authorParts.Length; i++) {
        // this way will not match order
        // if (!author.Contains(f_authorParts[i])) return false;
        // this way should match order
        if (f_authorParts[i].Length == 0) continue;
        auto ix = author.SubStr(lastIx).IndexOfI(f_authorParts[i]) + lastIx;
        if (ix < lastIx) return false;
        lastIx = ix + f_authorParts[i].Length;
    }
    return true;
}

bool MatchNameSearchString(const string &in name) {
    if (f_nameParts.Length == 0) return true;
    int lastIx = 0;
    for (uint i = 0; i < f_nameParts.Length; i++) {
        if (f_nameParts[i].Length == 0) continue;
        auto ix = name.SubStr(lastIx).IndexOfI(f_nameParts[i]) + lastIx;
        if (ix < lastIx) return false;
        lastIx = ix + f_nameParts[i].Length;
    }
    return true;
}



namespace UI {
    int FilterMonth(const string &in label, int val, bool &out changed) {
        auto ret = val;
        // auto clampedVal = Math::Clamp(val, 0, int(monthStats.Length) - 1);
        if (UI::BeginCombo(label, val < 0 ? "" : MonthShortStr(val))) {
            for (int i = 0; i < int(monthStats.Length); i++) {
                if (UI::Selectable(MonthShortStr(i), val == i)) {
                    g_FiltersChanged = true;
                    ret = i;
                }
            }
            UI::EndCombo();
        }
        return ret;
    }
    int FilterMedals(const string &in label, int val, bool &out changed) {
        auto ret = val;
        if (UI::BeginCombo(label, GetMedalIcon(val))) {
            for (int i = -1; i < 6; i++) {
                if (UI::Selectable(GetMedalIcon(i), val == i)) {
                    g_FiltersChanged = true;
                    ret = i;
                }
            }
            UI::EndCombo();
        }
        return ret;
    }
    bool FilterBool(const string &in label, bool val, bool &out changed) {
        bool ret = UI::Checkbox(label, val);
        if (ret != val) g_FiltersChanged = true;
        return ret;
    }
    string FilterString(const string &in label, const string &in val, bool &out changed) {
        auto ret = UI::InputText(label, val, changed);
        if (changed) g_FiltersChanged = true;
        return ret;
    }
}

bool g_OpenTrackStyles = false;

const string TrackStylesBtnText() {
    return g_TrackTagsSetToAny ? "TMX Tags" : "TMX Tags*";
}

void RenderTrackStylesWindow() {
    if (!g_OpenTrackStyles) return;
    if (UI::Begin(MenuTitle + ": Filter TOTD Tags (TMX Only)", g_OpenTrackStyles, UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse)) {
        TagsSelectWindowInner();
    }
    UI::End();
}
