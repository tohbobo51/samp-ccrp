RadioSystem::InitSystem() {
    printf("[GAMEMDOE SYSTEM] Initializing Radio System");
    InitSystem();
}

RadioSystem::ShutdownSystem() {
    printf("[GAMEMDOE SYSTEM] Radio System Cleanup");
    ShutdownSystem();
}


CMD:radio(playerid, params[]) {
    new wt_item_slot = CheckItemInInventory(playerid, ITEM_TOOLS_WALKIETALKIE);
    if(wt_item_slot == -1) {
        EMIT_PlayerSystemChat(playerid, -1, "Kamu tidak memiliki item 'Walkie Talkie'");
        return 0;
    }
    // TODO: Emit Radio when player in channel
    return 1;
}
alias:radio("r")

#if defined _ALS_InitSystem
    #undef InitSystem
#else 
    #define _ALS_InitSystem
#endif

#define InitSystem sys_rdo_InitSystem

#if defined _ALS_ShutdownSystem
    #undef ShutdownSystem
#else 
    #define _ALS_ShutdownSystem
#endif

#define ShutdownSystem sys_rdo_ShutdownSystem
