const int NUM_TAGS = 47;

bool g_TrackTagsSetToAny = true;
bool g_TrackTagsModeExclusive = false;

class Tag {
    bool checked;
    TagTypes type;
    Tag(TagTypes type, bool checked = false){
        this.checked = checked;
        this.type = type;
    }
    void setChecked(bool check){
        this.checked = check;
    }
}

enum TagTypes {
    Arena = 40,
    Backwards = 34,
    Bobsleigh = 44,
    Bumper = 20,
    Competitive = 13,
    Dirt = 15,
    Educational = 42,
    Endurance = 24,
    FlagRush = 46,
    Fragile = 21,
    Freestyle = 41,
    Freewheel = 35,
    FullSpeed = 2,
    Grass = 33,
    Ice = 14,
    Kacky = 23,
    Lol = 5,
    Mini = 25,
    Minigame = 30,
    Mixed = 27,
    MultiLap = 8,
    Nascar = 28,
    Obstacle = 31,
    Offroad = 9,
    Pathfinding = 45,
    Plastic = 39,
    Platform = 18,
    PressForward = 6,
    Puzzle = 47,
    Race = 1,
    Refactor = 17,
    Remake = 26,
    Royal = 37,
    Rpg = 4,
    Sausage = 43,
    Scenery = 22,
    Signature = 36,
    SlowMotion = 19,
    SpeedDrift = 29,
    SpeedFun = 12,
    SpeedTech = 7,
    Stunt = 16,
    Tech = 3,
    Transitional = 32,
    Trial = 10,
    Water = 38,
    Zrt = 11
}

TagTypes[] TagsAlphabetical = {
    TagTypes::Arena,
    TagTypes::Backwards,
    TagTypes::Bobsleigh,
    TagTypes::Bumper,
    TagTypes::Competitive,
    TagTypes::Dirt,
    TagTypes::Educational,
    TagTypes::Endurance,
    TagTypes::FlagRush,
    TagTypes::Fragile,
    TagTypes::Freestyle,
    TagTypes::Freewheel,
    TagTypes::FullSpeed,
    TagTypes::Grass,
    TagTypes::Ice,
    TagTypes::Kacky,
    TagTypes::Lol,
    TagTypes::Mini,
    TagTypes::Minigame,
    TagTypes::Mixed,
    TagTypes::MultiLap,
    TagTypes::Nascar,
    TagTypes::Obstacle,
    TagTypes::Offroad,
    TagTypes::Pathfinding,
    TagTypes::Plastic,
    TagTypes::Platform,
    TagTypes::PressForward,
    TagTypes::Puzzle,
    TagTypes::Race,
    TagTypes::Refactor,
    TagTypes::Remake,
    TagTypes::Royal,
    TagTypes::Rpg,
    TagTypes::Sausage,
    TagTypes::Scenery,
    TagTypes::Signature,
    TagTypes::SlowMotion,
    TagTypes::SpeedDrift,
    TagTypes::SpeedFun,
    TagTypes::SpeedTech,
    TagTypes::Stunt,
    TagTypes::Tech,
    TagTypes::Transitional,
    TagTypes::Trial,
    TagTypes::Water,
    TagTypes::Zrt
};

array<Tag@> generateTags() {
    array<Tag@> tags;
    for (int i = 1; i <= NUM_TAGS; i++){
        tags.InsertLast(Tag(TagTypes(i), true));
    }
    setAllTags(tags, true);
    return tags;
}

const string toTagString(array<Tag@>& tags){
    string s;
    for (int i = 0; i < NUM_TAGS; i++){
        if(tags[i].checked){
            int n = tags[i].type;
            s += (i > 0 ? "," : "") + tostring(n);
        }
    }
    return s;
}

void setAllTags(array<Tag@>& tags, bool val) {
    for (int i = 0; i < NUM_TAGS; i++) {
        tags[i].setChecked(val);
    }
    g_FilteresChanged = true;
    g_TrackTagsSetToAny = true;
}

array<Tag@> tags = generateTags();

void TagsSelectWindowInner() {
    // if (UI::Button("Defaults")) setAllTagsToDefault(tags);
    // UI::SameLine();
    if (UI::Button("Check All")) setAllTags(tags, true);
    UI::SameLine();
    if (UI::Button("Uncheck All")) setAllTags(tags, false);
    UI::SameLine();
    bool changed = g_TrackTagsModeExclusive;
    g_TrackTagsModeExclusive = UI::Checkbox("Exclusive Selection?", g_TrackTagsModeExclusive);
    AddSimpleTooltip("Exclusive mode: tracks must have ALL of the selected tags.\nInclusive mode: tracks must have ONE of the selected tags.\nSelecting all or zero tracks searches for 'any'.");
    if (changed != g_TrackTagsModeExclusive) UpdateTagsCachedValues();
    DrawTagsCheckboxes(tags);
    UI::Separator();
    DrawTagsSearchDescription();
}

void DrawTagsCheckboxes(array<Tag@>& tags) {
    if (tags is null) return;
    if (UI::BeginTable("tags", 6, UI::TableFlags::SizingFixedFit)) {
        UI::AlignTextToFramePadding();
        // UI::Columns(6);
        for (uint ti = 0; ti < TagsAlphabetical.Length; ti++) {
            int i = TagsAlphabetical[ti] - 1;
            UI::TableNextColumn();
            bool changed = tags[i].checked;
            tags[i].checked = UI::Checkbox(tostring(tags[i].type), tags[i].checked);
            if (changed != tags[i].checked) {
                startnew(UpdateTagsCachedValues);
            }
        }
        UI::EndTable();
    }
}

void UpdateTagsCachedValues() {
    g_FilteresChanged = true;
    g_TrackTagsSetToAny = true;
    bool expected = tags[0].checked;
    for (uint i = 1; i < tags.Length; i++) {
        if (tags[i].checked != expected) {
            g_TrackTagsSetToAny = false;
            break;
        }
    }
}

void DrawTagsSearchDescription() {
    string sFor = "Searching for";
    if (g_TrackTagsSetToAny) {
        sFor += ": any tags";
    } else {
        if (g_TrackTagsModeExclusive) {
            sFor += " tracks excluding: ";
            uint count = 0;
            for (uint i = 0; i < tags.Length; i++) {
                auto tag = tags[i];
                if (!tag.checked) {
                    sFor += count == 0 ? tostring(tag.type) : (", " + tostring(tag.type));
                    count++;
                }
            }
        } else {
            sFor += " tracks including: ";
            uint count = 0;
            for (uint i = 0; i < tags.Length; i++) {
                auto tag = tags[i];
                if (tag.checked) {
                    sFor += count == 0 ? tostring(tag.type) : (", " + tostring(tag.type));
                    count++;
                }
            }
        }
    }
    UI::TextWrapped(sFor);
}
