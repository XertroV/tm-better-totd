bool UserHasPermissions = false;

void Main() {
    UserHasPermissions = Permissions::PlayLocalMap()
        && Permissions::PlayTOTDChannel();
    if (!UserHasPermissions) {
        NotifyWarning("You need the permissions to play local maps and play TOTDs to use this plugin.");
        return;
    }
    startnew(TOTD::SyncMain);
    startnew(ClearTaskCoro);
    startnew(WatchForMapChange);
    startnew(WatchStaleStatsCache);
    startnew(ScanForMissingTmx);
}

void OnDestroyed() { Unload(); }
void OnDisabled() { Unload(); }
void Unload() {
    ClearAllTasksNow();
}

void Notify(const string &in msg) {
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg);
    trace("Notified: " + msg);
}

void NotifyError(const string &in msg) {
    log_warn(msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Error", msg, vec4(.9, .3, .1, .3), 15000);
}

void NotifyWarning(const string &in msg) {
    log_warn(msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Warning", msg, vec4(.9, .6, .2, .3), 15000);
}

const string PluginIcon = Icons::CalendarCheckO;
const string MenuTitle = "\\$3bf" + PluginIcon + "\\$z " + Meta::ExecutingPlugin().Name;
const string FullWindowTitle = MenuTitle + "\\$888   by XertroV";

const string TM_IO_ICON = "\\$3af" + Icons::Heartbeat;

// show the window immediately upon installation
[Setting hidden]
bool ShowWindow = true;

/** Render function called every frame intended only for menu items in `UI`. */
void RenderMenu() {
    UI::BeginDisabled(!UserHasPermissions);
    if (UI::MenuItem(MenuTitle, "", ShowWindow)) {
        ShowWindow = !ShowWindow;
    }
    UI::EndDisabled();
}

/** Render function called every frame.
*/
void RenderInterface() {
    RenderTrackStylesWindow();

    if (!UserHasPermissions) return;
    // if (!ShowWindow || CurrentlyInMap || GetApp().Editor !is null) return;
    if (!ShowWindow) return;
    vec2 size = vec2(900, 650);
    vec2 pos = (vec2(Draw::GetWidth(), Draw::GetHeight()) - size) / 2.;
    UI::SetNextWindowSize(int(size.x), int(size.y), UI::Cond::FirstUseEver);
    UI::SetNextWindowPos(int(pos.x), int(pos.y), UI::Cond::FirstUseEver);
    UI::PushStyleColor(UI::Col::FrameBg, vec4(.2, .2, .2, .5));
    if (UI::Begin(FullWindowTitle, ShowWindow)) {
        RenderMainWindowInner();
    }
    UI::End();
    UI::PopStyleColor();
}



// string tmxIdToUrl(const string &in id) {
//     if (m_UseTmxMirror) {
//         return "https://cgf.s3.nl-1.wasabisys.com/" + id + ".Map.Gbx";
//     }
//     return "https://trackmania.exchange/maps/download/" + id;
// }



const string FmtTimestamp(int64 timestamp) {
    // return Time::FormatString("%c", timestamp);
    return Time::FormatString("%Y-%m-%d %H:%M", timestamp);
}

const string FmtTimestampUTC(int64 timestamp) {
    return Time::FormatStringUTC("%Y-%m-%d %H:%M", timestamp);
}

const string FmtTimestampDateOnly(int64 timestamp = -1) {
    return Time::FormatString("%Y-%m-%d", timestamp);
}

const string FmtTimestampDateOnlyUTC(int64 timestamp) {
    return Time::FormatStringUTC("%Y-%m-%d", timestamp);
}





void AddSimpleTooltip(const string &in msg) {
    if (UI::IsItemHovered()) {
        UI::BeginTooltip();
        UI::Text(msg);
        UI::EndTooltip();
    }
}
