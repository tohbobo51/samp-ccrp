#include <pp-hooks>

hook OnPlayerDisconnect(playerid) {
    new targetid = DragInfo[playerid][drag_targetid];
    if(IsPlayerConnected(targetid)) {
        EMIT_PlayerSystemChat(targetid, -1, "DRAG: Pemain yang kamu tarik telah terputus dari server.");
        Character::SetDragging(targetid, INVALID_PLAYER_ID);
    }
    DragInfo[playerid][dragged] = false;
}

public SecondInterval() {
#if defined SHOW_PERFORMANCE_LOG
    new start = GetTickCount();
    new end;
#endif

    TickDroppedItem();
    BuffSystemTick();

    JobLumber::Tick();
    JobMiner::Tick();
    JobSweeper::Tick();

    for(new i =0;i<GetMaxPlayers();i++){
        GUI_Emit_PlayerData(i);
        JobSweeper::DelayTimer(i);
        JobsBus::DelayTimer(i);
    }

    Farming::Tick();

#if defined SHOW_PERFORMANCE_LOG
    end = GetTickCount();
    printf("Second Interval takes: %dms", (end-start));
#endif
}

public MinuteInterval() {
    // printf("[DEBUG] Minute Interval");
    TickPlayTime();
    foreach(new p : Player) {
        Character::HealthCheck(p);
    }
}

public HungerInterval() {
    ReduceHunger(); 
}

callback DraggingTimer(playerid) {
    if(!DragInfo[playerid][dragged]) return 0;
    if(DragInfo[playerid][drag_time] <= 0 || !IsPlayerConnected(DragInfo[playerid][drag_targetid])) {
        KillTimer(DragInfo[playerid][drag_timer]);
        Character::SetDragging(DragInfo[playerid][drag_targetid], INVALID_PLAYER_ID);
        DragInfo[playerid][drag_time] = 0;
        DragInfo[playerid][drag_targetid] = INVALID_PLAYER_ID;
        TogglePlayerControllable(playerid, true);
        return 1;
    }
    new Float:tPos[3];
    new tid = DragInfo[playerid][drag_targetid];
    GetPlayerPos(tid, tPos[X], tPos[Y], tPos[Z]);
    SetPlayerPos(playerid, tPos[X] + 1.0, tPos[Y], tPos[Z]);
    DragInfo[playerid][drag_time]--;
    return 1;
}
