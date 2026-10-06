checkPlayerLoginToken(playerid) {
#if defined DEBUG
    if(authSuccess[playerid]) return 1; // for debugging when refreshing UI
#endif
    new l_loginToken[MAX_PLAYER_NAME];
    GetPlayerName(playerid, l_loginToken, sizeof(l_loginToken));

    Logger_Log("Player check login token", Logger_I("playerid", playerid), Logger_S("token", l_loginToken));
    mysql_format(MainConn, 
                 szMiscArray,sizeof(szMiscArray),
                 "SELECT * FROM `user` WHERE `login_token` = '%s'", l_loginToken);
    mysql_tquery(MainConn, szMiscArray, "OnLoginTokenCheck", "i", playerid);
    return 1;
}

callback GUI_GetCharacter(playerid) {
    ClearChat(playerid);
    await task_ms(1000);
    cef_emit_event(playerid, "login:get_characters");
}

public OnLoginTokenCheck(playerid) {
    if(IsPlayerConnected(playerid)) {
        new rows, fields;
        cache_get_row_count(rows);
        cache_get_field_count(fields);
        if(rows) {
            cache_set_result(0);
            LoadAccount(playerid);
            Logger_Log("Auth successfully", Logger_I("playerid", playerid));
            cef_focus_browser(playerid, GET_BROWSER_ID(playerid), true);
            
            list_remove(auth_queue, auth_q_index);
            auth_q_processing = false;
            auth_q_curr_playerid = INVALID_PLAYER_ID;
            auth_q_index = -1;
            
            CallLocalFunction(#GUI_GetCharacter, "d", playerid);
        } else {
            Logger_Err("Invalid login account", Logger_I("playerid", playerid));
            printf("Invalid Login account!");
            ShowPlayerDialog(playerid, 
                             DIALOG_NOTICE, 
                             DIALOG_STYLE_MSGBOX,
                             "ERROR",
                             "Login process failed.\nMake sure you are using CCRP launcher to start SA:MP.", "Close", "");
            wait_ms(500);
            Kick(playerid);
        }
    }
}

callback AuthProcess() {
    if(list_size(auth_queue) < 1) {
        return 1; 
    }
    if(auth_q_processing) {
        for(new i=0;i<list_size(auth_queue);i++) {
            new pID = list_get(auth_queue, i);
            if(i == auth_q_index) continue;
            ClearChat(pID);
            SendClientMessage(pID, -1, "[AUTENTIKASI]: Sedang memeriksa akun.");
            SendClientMessage(pID, -1, "[AUTENTIKASI]: Mohon menunggu...");
            new l_str[128];
            format(l_str,sizeof(l_str), "[AUTENTIKASI]: Anda dalam antrian ke %i", i);
            SendClientMessage(pID, -1, l_str);
        }
        return 1;
    }
    Logger_Log("Processing connected players", Logger_I("auth_queue", list_size(auth_queue)));
    for(new i=0;i<list_size(auth_queue);i++) {
        new player_id = list_get(auth_queue, i);
        
        if(!IsPlayerConnected(player_id)) {
            list_remove(auth_queue, i);
            auth_q_processing = true;
            auth_q_curr_playerid = INVALID_PLAYER_ID;
            auth_q_index = -1;
            auth_q_err_c = 0;
            continue; 
        }
        
        if(!IsPlayerUsingCHandling(player_id)) {
            printf("Player %d does not have CHandling installed", player_id);
            SendClientMessage(player_id, -1, "Kamu tidak memiliki file yang sesuai dengan server. Gunakan launcher kami untuk update file.");
            wait_ticks(1);
            Kick(player_id);
            list_remove(auth_queue, i);
            continue; 
        }
        if(!cef_player_has_plugin(player_id)) {
            if(auth_q_err_c > 5) {
                printf("Player %d does not have CEF Installed.", player_id);
                SendClientMessage(player_id, -1, "Tidak dapat masuk ke server karena tidak menemukan CEF plugin.");
                wait_ticks(1);
                Kick(player_id);
                list_remove(auth_queue, i);
                auth_q_err_c = 0;
                return 1;
            }
            printf("Player %d cef still loading ? err c: %i", player_id, auth_q_err_c);
            auth_q_err_c += 1;
            return 1;
        }
        Logger_Log("got cef after", Logger_I("error_count", auth_q_err_c));
        Logger_Log("spawning browser", Logger_I("playerid", player_id));
        ClearChat(player_id);
        SendClientMessage(player_id, -1, "[AUTENTIKASI]: Loading karakter.");
        Logger_Log("[DEBUG] auth browser ", Logger_S("url", INTERFACE_BROWSER_URL));
        cef_create_browser(player_id, GET_BROWSER_ID(player_id), INTERFACE_BROWSER_URL, false, false);
        auth_q_processing = true;
        auth_q_curr_playerid = player_id;
        auth_q_index = i;
        auth_q_err_c = 0;
        return 1; 
    } 
    return 1;
}

