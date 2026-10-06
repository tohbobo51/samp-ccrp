#include <pp-hooks>
hook OnPlayerConnect(playerid) {
    if(!IsPlayerNPC(playerid)) {
        authSuccess[playerid] = false;
        ResetAccount(playerid);
        Logger_Log("Player connected", Logger_S("module", "account"), Logger_I("playerid", playerid));
    }
}

hook OnPlayerDisconnect(playerid, reason) {
    if(!IsPlayerNPC(playerid)) {
        Logger_Log("Player disconnected", Logger_S("module", "account"), Logger_I("playerid", playerid));
        new l_genNewToken[21];
        GenerateRandomString(20,l_genNewToken);
        mysql_format(MainConn,
                     szMiscArray,sizeof(szMiscArray),
                     "UPDATE `user` SET `webui_token` = '%s' WHERE `id` = '%d'",
                     l_genNewToken, AccountInfo[playerid][AccountInfo::id]);
        
        mysql_tquery(MainConn,szMiscArray);
        cef_destroy_browser(playerid, GET_BROWSER_ID(playerid));
        ResetAccount(playerid);
    }
}


ResetAccount(playerid) 
{
    AccountInfo[playerid][AccountInfo::id] = 0;
    AccountInfo[playerid][AccountInfo::vip_level] = 0;
    AccountInfo[playerid][AccountInfo::vip_exp] = 0;
    AccountInfo[playerid][AccountInfo::admin_level] = 0;
    return 1;
}

LoadAccount(playerid) 
{
    new l_genNewToken[21];
    new l_genNewUIToken[21];
    GenerateRandomString(20,l_genNewToken);
    cache_get_value_name_int(0,"id",AccountInfo[playerid][AccountInfo::id]);
    cache_get_value_name_int(0, "vip_level", AccountInfo[playerid][AccountInfo::vip_level]);
    cache_get_value_name(0, "vip_exp", AccountInfo[playerid][AccountInfo::vip_exp]);
    cache_get_value_name_int(0, "admin_level", AccountInfo[playerid][AccountInfo::admin_level]);

    format(
        szMiscArray,sizeof(szMiscArray), 
        "UPDATE `user` SET login_token = '%s' WHERE id = '%d'",
        l_genNewToken, AccountInfo[playerid][AccountInfo::id]);

    Logger_Log("Updating login token", Logger_S("module", "account"));
    mysql_tquery(MainConn,szMiscArray);
    new l_newPName[MAX_PLAYER_NAME];
    format(l_newPName, sizeof(l_newPName), "WAITINGPLAYER_%d", playerid);
    SetPlayerName(playerid, l_newPName);

    // Set GUI Token for Calling API from GUI
    GenerateRandomString(20,l_genNewUIToken);
    format(
        szMiscArray,sizeof(szMiscArray),
        "UPDATE `user` SET webui_token = '%s' WHERE id = '%d'",
        l_genNewUIToken, AccountInfo[playerid][AccountInfo::id]);

    
    Logger_Log("Updating WebUI token", Logger_S("module", "account"));
    mysql_tquery(MainConn,szMiscArray);

    cef_emit_event(playerid, "cfg:got_webui_token",CEFSTR(l_genNewUIToken));

    if(AccountInfo[playerid][AccountInfo::admin_level] > 0) {
        AdminSystem::FetchPermission(AccountInfo[playerid][AccountInfo::id]);
    }
    return 1;
}
