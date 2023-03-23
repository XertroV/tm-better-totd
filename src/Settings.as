[Setting category="General" name="Log Level"]
LogLevel S_LogLevel = LogLevel::Info;

[Setting category="Integrations" name="Load using 'Archivist' if installed"]
bool S_LoadInArchivist = true;

enum AutoLoadTOTD {
    Never,
    In_Main_Menu,
    Anywhere_But_Editor
}
[Setting category="General" name="Auto-load new TOTDs" description="This will load fresh track of the days the second they become available. It will never do this if you are in the editor."]
AutoLoadTOTD S_InstaLoadTOTD = AutoLoadTOTD::Never;
