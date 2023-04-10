[Setting name="replay folder path" category="Folder Path" description="resolves <mapName>, <date> if statements using ?<if>:<true>:<false>? || <if> can be <isPB>, <isCAMP>, <isTOTD>"]
string base_path = "My Replays/<mapName>";

[Setting name="remove featuring from folder path" category="Folder Path"]
bool remove_ft_folder = false;

[Setting name="replay file name" category="File Name" description="resolves <mapName>, <userName>, <timestamp>, <date>, <ghostTime>"]
string file_name = "<mapName> - <userName> - <timestamp> (<ghostTime>)";

[Setting name="remove featuring from file name" category="File Name"]
bool remove_ft_file = false;

[Setting name="always record Official Campaigns" category="Record"]
bool record_camp = false;

[Setting name="always record TOTDs" category="Record"]
bool record_totd = false;

[Setting name="always record maps" multiline category="Record" description="Tracks in this list will be recorded automaticly. Enter UID of track per line."]
string maps = "";

[Setting name="record slower runs in ms" drag category="Record"]
uint record_margin = 0;
