CGameDataFileManagerScript@ TryGetDataFileMgr()
{
    CTrackMania@ app = cast<CTrackMania>(GetApp());
    if (app !is null)
    {
        CSmArenaRulesMode@ playgroundScript = cast<CSmArenaRulesMode>(app.PlaygroundScript);
        if (playgroundScript !is null)
        {
            CGameDataFileManagerScript@ dataFileMgr = cast<CGameDataFileManagerScript>(playgroundScript.DataFileMgr);
            if (dataFileMgr !is null)
            {
                return dataFileMgr;
            }
        }
    }
    return null;
}

string ParsePath(bool is_PB) {
    string parsed_path = base_path;

    string mapName = Text::StripFormatCodes(map.MapName);
    if (remove_ft_folder) mapName = RemoveFt(mapName);

    string if_pattern = "\\?(.*?):(.*?):(.*?)\\?";
    while (Regex::Contains(parsed_path, if_pattern)) {
        string[]@ match = Regex::Search(parsed_path, if_pattern);

        // defaults to false if statement does not match tokens
        string replacement = match[3];

        if (match[1] == "<isCAMP>" && is_Campaign) replacement = match[2];
        if (match[1] == "<isTOTD>" && is_TOTD) replacement = match[2];
        if (match[1] == "<isPB>" && is_PB) replacement = match[2];

        parsed_path = parsed_path.Replace(match[0], replacement);
    }


    parsed_path = parsed_path.Replace("<mapName>", mapName);
    parsed_path = parsed_path.Replace("<date>", Time::FormatString("%F"));

    return IO::FromUserGameFolder("Replays") + "/" + parsed_path;
}

string RemoveFt(string _mapName) {
    int tmp = _mapName.IndexOf(" ft'");
    if (tmp < 0) tmp = _mapName.IndexOf(" ft");
    if (tmp < 0) tmp = _mapName.IndexOf(" ft.");
    if (tmp > 0) _mapName = _mapName.SubStr(0, tmp);
    return _mapName;
}

string FormatTimer(int time) {
    int ms = time % 1000;
    time /= 1000;
    int hours = time / 60 / 60;
    int minutes = (time / 60) % 60;
    int seconds = time % 60;

    string result = "";

    if (hours > 0) {
        result += Text::Format("%02d", hours) + ":";
    }
    if (minutes > 0 || (hours > 0 && minutes < 10)) {
        result += Text::Format("%02d", minutes) + ":";
    }
    result += Text::Format("%02d", seconds) + "." + Text::Format("%03d", ms);

    return result;
}