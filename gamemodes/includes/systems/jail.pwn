JailSystem::InitSystem() {
    printf("[GAMEMDOE SYSTEM] Initializing Jail System");
    JailSystem::jailed_players = list_new();
    JailSystem::tick_timer = SetTimer("JailSystemTick", 1000, true);
    InitSystem();
}

JailSystem::ShutdownSystem() {
    printf("[GAMEMDOE SYSTEM] Jail System Cleanup");
    KillTimer(JailSystem::tick_timer);
    ShutdownSystem();
}

public JailSystemTick() {
    if(list_size(JailSystem::jailed_players) < 1) return;
    for_list(i : JailSystem::jailed_players) {
        new pID = iter_get(i); 
        if(CharacterData[pID][p_jailed] && CharacterData[pID][p_jail_time] > 0) {
            CharacterData[pID][p_jail_time] -= 1;
            if(CharacterData[pID][p_jail_time] == 0) {
                JailSystem::FreePlayer(pID);
            }
        }
    }
}

JailSystem::JailPlayer(playerid, JailSystem::e_Type:jail_type, jail_time) {
    if(jail_type == Jail::NONE) return 0;
    if(list_find(JailSystem::jailed_players, playerid) == -1) {
        list_add(JailSystem::jailed_players, playerid);
        CharacterData[playerid][p_jailed] = true;
        CharacterData[playerid][p_jail_type] = jail_type;
        CharacterData[playerid][p_jail_time] = jail_time;
        SetPlayerPos(playerid,
                 JailSystem::JailPos[jail_type][Jail::pos][X],
                 JailSystem::JailPos[jail_type][Jail::pos][Y],
                 JailSystem::JailPos[jail_type][Jail::pos][Z]
                 );
        SetPlayerFacingAngle(playerid, JailSystem::JailPos[jail_type][Jail::facing]);
        SetPlayerInterior(playerid, JailSystem::JailPos[jail_type][Jail::int]);
        SetPlayerVirtualWorld(playerid, JailVW+playerid);
        LSPD::ClearSuspect(CharacterData[playerid][p_ID]);
    }
    return 1;
}


JailSystem::FreePlayer(playerid) {
    EMIT_PlayerSystemChat(playerid, -1, "JAIL: Waktu penjara telah berakhir");
    new JailSystem::e_Type:jail_type = JailSystem::e_Type:CharacterData[playerid][p_jail_type];
    SetPlayerPos(playerid, 
                 JailSystem::AfterJailPos[jail_type][Jail::pos][X],
                 JailSystem::AfterJailPos[jail_type][Jail::pos][Y],
                 JailSystem::AfterJailPos[jail_type][Jail::pos][Z]
                 );
    SetPlayerFacingAngle(playerid, JailSystem::AfterJailPos[jail_type][Jail::facing]);
    SetPlayerInterior(playerid, JailSystem::AfterJailPos[jail_type][Jail::int]);
    SetPlayerVirtualWorld(playerid, 0);
    CharacterData[playerid][p_jailed] = false;
    CharacterData[playerid][p_jail_time] = 0;
    CharacterData[playerid][p_jail_type] = Jail::NONE;
    
    new index = list_find(JailSystem::jailed_players, playerid);
    if( index != -1) {
        list_remove(JailSystem::jailed_players, index);
    }
    return 1;
}

WriteJailLog(playerid, jail_type, jail_time, issuer) {
    if(!IsPlayerConnected(playerid)) return 0;
    new str_issuer[128];
    new str_target[128];
    format(str_target,sizeof(str_target), "%s (%i)", GetName(playerid), playerid);
    if(issuer == -1) {
        format(str_issuer, sizeof(str_issuer), "System");
    } else {
        format(str_issuer,sizeof(str_issuer), "%s (%i)", GetName(issuer), issuer);
    }
    switch(jail_type) {
        case Jail::POLICE: {
            format(szMiscArray, sizeof(szMiscArray), 
                "%s has been jailed for %i second by officer %s",
                str_target, jail_time, str_issuer
            );
        }
        case Jail::ADMIN: {
            format(szMiscArray, sizeof(szMiscArray), 
                "%s has been jailed for %i second by %s",
                str_target, jail_time, str_issuer
            );
        }
    }
    // TODO: Write Log to Database via Redis / API
    return 1;
}


#if defined _ALS_InitSystem
    #undef InitSystem
#else 
    #define _ALS_InitSystem
#endif

#define InitSystem sys_jail_InitSystem

#if defined _ALS_ShutdownSystem
    #undef ShutdownSystem
#else 
    #define _ALS_ShutdownSystem
#endif

#define ShutdownSystem sys_jail_ShutdownSystem
