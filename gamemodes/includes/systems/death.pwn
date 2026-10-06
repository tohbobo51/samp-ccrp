DeathSystem::InitSystem() {
    printf("[GAMEMDOE SYSTEM] Initializing Death System");
    DeathSystem::injured_players = list_new();
    DeathSystem::tickTimer = SetTimer("DeathSystemTick", 1000, true);
    InitSystem();
}

DeathSystem::ShutdownSystem() {
    printf("[GAMEMDOE SYSTEM] Death System Cleanup");
    KillTimer(DeathSystem::tickTimer);
    ShutdownSystem();
}

public DeathSystemTick() {
    if(list_size(DeathSystem::injured_players) < 1) return;
    for_list(i : DeathSystem::injured_players) {
        new pID = iter_get(i); 
        if(CharacterData[pID][p_injured] && CharacterData[pID][p_injured_time] > 0) {
            CharacterData[pID][p_injured_time] -= 1;
        }
    }
    return;
}

DeathSystem::pushPlayer(playerid) {
    if(list_find(DeathSystem::injured_players, playerid) == -1) {
        list_add(DeathSystem::injured_players, playerid);
    }
    return 1;
}

DeathSystem::removePlayer(playerid) {
    new index = list_find(DeathSystem::injured_players, playerid);
    if( index != -1) {
        list_remove(DeathSystem::injured_players, index);
    }
    return 1;
}


#if defined _ALS_InitSystem
    #undef InitSystem
#else 
    #define _ALS_InitSystem
#endif

#define InitSystem sys_dth_InitSystem

#if defined _ALS_ShutdownSystem
    #undef ShutdownSystem
#else 
    #define _ALS_ShutdownSystem
#endif

#define ShutdownSystem sys_dth_ShutdownSystem
