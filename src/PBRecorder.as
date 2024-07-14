string save_path;
bool inProgress;
int totalRecorded;

bool finishedOnce;

bool map_loaded = false;
uint pb_time;
bool is_Campaign;
bool is_TOTD;
bool in_maps;

CGameCtnChallenge@ map;
CSmArenaRulesMode@ playgroundScript;
CSmArenaClient@ playground;
CGameDataFileManagerScript@ m_gameDataFileManager;

Net::HttpRequest@ req_map;
Net::HttpRequest@ req_pb;
bool waiting_for_map = false;
bool waiting_for_pb = false;

void Main()
{
    NadeoServices::AddAudience("NadeoLiveServices");
}

void Update(float dt)
{
    @playground = cast<CSmArenaClient>(GetApp().CurrentPlayground);
    @playgroundScript = cast<CSmArenaRulesMode>(GetApp().PlaygroundScript);
    if (playground !is null) {
        @map = playground.Map;
    } else {
        map_loaded = false;
        inProgress = false;
        return;
    }

    if (!map_loaded) {
        OnMapChange();
        map_loaded = true;
        if (inProgress) StartRecording(true);
    }

    if (waiting_for_map) ReceiveTrackInfo();
    if (waiting_for_pb) UpdateOnlinePB();

    if (inProgress && map !is null && playgroundScript !is null && playground.GameTerminals.Length > 0) {
        CSmPlayer@ player = cast<CSmPlayer>(playground.GameTerminals[0].ControlledPlayer);
        if (playground.GameTerminals[0].UISequence_Current == SGamePlaygroundUIConfig::EUISequence::Finish && player !is null && !finishedOnce) {
            finishedOnce = true;
            CSmScriptPlayer@ playerScriptAPI = cast<CSmScriptPlayer>(player.ScriptAPI);
            CGameGhostScript@ ghost = playgroundScript.Ghost_RetrieveFromPlayer(playerScriptAPI);
            uint compare_time = (ghost.Result.Time > record_margin) ? ghost.Result.Time - record_margin : 0;
            if (ghost !is null && compare_time < pb_time) {
                SaveReplay(ghost);
                if (ghost.Result.Time < pb_time) pb_time = ghost.Result.Time;
                playgroundScript.DataFileMgr.Ghost_Release(ghost.Id);
            }
        } else if (playground.GameTerminals[0].UISequence_Current == SGamePlaygroundUIConfig::EUISequence::Playing && player !is null && finishedOnce) {
            finishedOnce = false;
        }
    }
}

void SaveReplay(CGameGhostScript@ ghost)
{
    @m_gameDataFileManager = TryGetDataFileMgr();
    if (m_gameDataFileManager !is null) {
        totalRecorded++;

        string safeMapName = Text::StripFormatCodes(map.MapName);
        if (remove_ft_file) safeMapName = RemoveFt(safeMapName);
        string safeUserName = ghost.Nickname;
        string fmtGhostTime = FormatTimer(ghost.Result.Time).Replace(":", "-");

        string replayName = file_name;

        replayName = replayName.Replace("<mapName>", safeMapName);
        replayName = replayName.Replace("<userName>", safeUserName);
        replayName = replayName.Replace("<timestamp>", Time::FormatString("%F_%H-%M-%S"));
        replayName = replayName.Replace("<date>", Time::FormatString("%F"));
        replayName = replayName.Replace("<ghostTime>", fmtGhostTime);

        string replayFilePath = ParsePath(ghost.Result.Time < pb_time) + "/" + replayName;
        m_gameDataFileManager.Replay_Save(replayFilePath, map, ghost);

        UI::ShowNotification("\\$6f9" + Icons::VideoCamera + " \\$zReplay saved!", replayName);
    }
}

void StartRecording(bool show_notif) {
    if (show_notif) UI::ShowNotification("\\$6f9" + Icons::PlayCircle + " \\$zStarted Recording!");
    inProgress = true;
    pb_time = LoadPB();
    finishedOnce = false;
    save_path = ParsePath(true);
}

void OnMapChange() {
    inProgress = RecordIndividualMap();
    totalRecorded = 0;

    is_TOTD = false;
    is_Campaign = false;

    // start request if map is totd/campaign
    if (NadeoServices::IsAuthenticated("NadeoLiveServices")) {
        @req_map = NadeoServices::Get("NadeoLiveServices", NadeoServices::BaseURLLive() + "/api/campaign/map/" + map.IdName);
        req_map.Start();
        waiting_for_map = true;
    }
}
