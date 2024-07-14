bool RecordIndividualMap() {
    string[] map_arr = maps.Split("\n");
    for (uint i = 0; i < map_arr.Length; i++) {
        if (map.IdName == (map_arr[i])) {
            in_maps = true;
            return true;
        }
    }

    in_maps = false;
    return false;
}

void ReceiveTrackInfo() {
    if(@req_map != null && req_map.Finished()) {
        waiting_for_map = false;
        Json::Value@ response = Json::Parse(req_map.String());
        @req_map = null;

        if (response.Get("officialYear") > 0) is_Campaign = true;
        if (response.Get("totdYear") > 0) is_TOTD = true;

        if (!inProgress && (is_Campaign && record_camp || is_TOTD && record_totd)) {
            StartRecording(true);
        }
    }
}

uint LoadPB() {
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);
    auto map = app.RootMap;

    auto userMgr = network.ClientManiaAppPlayground.UserMgr;
    MwId userId;
    if (userMgr.Users.Length > 0) {
        userId = userMgr.Users[0].Id;
    } else {
        userId.Value = uint(-1);
    }

    auto scoreMgr = network.ClientManiaAppPlayground.ScoreMgr;
    uint local_pb = scoreMgr.Map_GetRecord_v2(userId, map.MapInfo.MapUid, "PersonalBest", "", "TimeAttack", "");

    //start loading pb from online leaderboard
    string mapid = network.ClientManiaAppPlayground.Playground.Map.MapInfo.MapUid;
    if (NadeoServices::IsAuthenticated("NadeoLiveServices")) {
        @req_pb = NadeoServices::Get("NadeoLiveServices", NadeoServices::BaseURLLive() + "/api/token/leaderboard/group/Personal_Best/map/" + mapid + "/surround/0/0?onlyWorld=true");
        req_pb.Start();
        waiting_for_pb = true;
    }

    return local_pb;
}

void UpdateOnlinePB() {
    if (!req_pb.Finished()) return;
    waiting_for_pb = false;
    Json::Value@ response = Json::Parse(req_pb.String());
    @req_map = null;

    if(response.GetType() != Json::Type::Null) {
        auto tops = response["tops"];
        if(tops.GetType() == Json::Type::Array) {
            auto top = tops[0]["top"];
            if(top.Length > 0) {
                uint online_pb = top[0]["score"];
                if (online_pb < pb_time) pb_time = online_pb;
            }
        }
    }
}

void AddMap() {
    if (maps != "") maps += "\n";
    maps = maps + map.IdName;
    maps = maps.Replace("\n\n", "\n");
    in_maps = true;
}

void RemoveMap() {
    maps = maps.Replace(map.IdName, "");
    maps = maps.Replace("\n\n", "\n");
    if (maps == "\n") maps = "";
    in_maps = false;
}
