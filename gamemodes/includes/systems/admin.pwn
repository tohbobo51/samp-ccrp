#include <pp-hooks>
AdminSystem::InitSystem() {
    printf("[GAMEMDOE SYSTEM] Initializing Admin System");
    AdminSystem::admin_list = map_new();
    InitSystem();
}

AdminSystem::ShutdownSystem() {
    printf("[GAMEMDOE SYSTEM] Admin System Cleanup");
    map_delete(AdminSystem::admin_list);
    ShutdownSystem();
}


AdminSystem::FetchPermission(userid) {
    RequestJSON(
        httpClient,
        sprintf("admin/permission/%i", userid),
        HTTP_METHOD_GET,
        "OnGotUserPermissions",
        .headers = RequestHeaders()
    );
}

bool:AdminSystem::IsAdmin(playerid) {
    return AccountInfo[playerid][AccountInfo::admin_level] > 0;
}

bool:AdminSystem::HasPerms(playerid, const perm[]) {
    if(map_has_key(AdminSystem::admin_list, playerid)) {
        new Map:pmap = Map:map_get(AdminSystem::admin_list, playerid);
        return map_has_str_key(pmap, perm);
    }
    EMIT_PlayerSystemChat(playerid, -1, "SYSTEM: Unknown commands");
    return false;
}

callback OnGotUserPermissions(Request:id, E_HTTP_STATUS:status, Node:node) {
    new accountid;
    new ret;
    new permLength;
    new Node:permData;
    ret = JsonGetInt(node, "accountid", accountid);
    if(ret) {
        printf("Failed to get accountid\n");
        return 0;
    }
    ret = JsonGetArray(node,"data", permData);
    if(ret) {
        printf("Failed to get data\n");
        return 0;
    }
    ret = JsonArrayLength(permData, permLength);
    if(ret) {
        printf("Failed to get data length\n");
        return 0;
    }
    if(permLength < 1) {
        printf("Account %i doesn't have any permissions\n", accountid);
        return 0;
    }
    new pid = AdminSystem::PIDFromAccID(accountid);
    if(pid == -1) {
        printf("ADM_SYS: Player doesn't exists %i", pid);
        return 0;
    }

    new Map:pmap = map_new();
    new pname[128];
    for(new i=0;i<permLength;i++) {
        new Node:permNode;
        ret = JsonArrayObject(permData, i, permNode);
        if(ret) {
            printf("Failed to get perm node\n");
            return 0;
        }
        ret = JsonGetString(permNode, "name", pname);
        if(ret) {
            printf("Failed to get perm name\n");
            return 0;
        }
        map_str_set(pmap, pname, true);
    }
    map_set(AdminSystem::admin_list, pid, pmap);
    return 1;
}


AdminSystem::PIDFromAccID(accountid) {
    foreach(new i : Player) {
        if(AccountInfo[i][AccountInfo::id] == accountid) {
            return i;
        }
    }
    return -1;
}

AdminSystem::Kick(playerid, const reason[]) {
    ShowPlayerDialog(playerid, 
        DIALOG_NOTICE, 
        DIALOG_STYLE_MSGBOX,
        "ERROR",
        sprintf("You've been kicked from the server.\nREASON: %s", reason), "Close", "");
    wait_ms(500);
    Kick(playerid);
    return 1;
}


// FUNCTION HOOK
#if defined _ALS_InitSystem
    #undef InitSystem
#else 
    #define _ALS_InitSystem
#endif

#define InitSystem sys_adm_InitSystem

#if defined _ALS_ShutdownSystem
    #undef ShutdownSystem
#else 
    #define _ALS_ShutdownSystem
#endif

#define ShutdownSystem sys_adm_ShutdownSystem

// CALLBACK HOOK
hook OnPlayerDisconnect(playerid, reason) {
    // Clean up admin permissions
    if(map_has_key(AdminSystem::admin_list, playerid)) {
        new Map:pmap = Map:map_get(AdminSystem::admin_list, playerid);
        map_delete(pmap);
        map_remove(AdminSystem::admin_list, playerid);
    }
    
    // If this player was being spectated by someone, stop their spectating
    foreach(new i : Player) {
        if(AdminSystem::IsSpectating(i) && AdminSystem::GetSpectateTarget(i) == playerid) {
            // Execute specoff command for admins spectating this player
            PC_EmulateCommand(i, "/specoff");
        }
    }
}

hook OnPlayerStateChange(playerid, newstate, oldstate) {
    // Handle vehicle state changes for players being spectated
    if((newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) && oldstate == PLAYER_STATE_ONFOOT) {
        // Player entered a vehicle
        foreach(new i : Player) {
            if(AdminSystem::IsSpectating(i) && AdminSystem::GetSpectateTarget(i) == playerid) {
                PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));
            }
        }
    }
    else if(newstate == PLAYER_STATE_ONFOOT && (oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)) {
        // Player exited a vehicle
        foreach(new i : Player) {
            if(AdminSystem::IsSpectating(i) && AdminSystem::GetSpectateTarget(i) == playerid) {
                PlayerSpectatePlayer(i, playerid);
            }
        }
    }
}
