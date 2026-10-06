
// Pawn.CMD
enum (<<=1)
{
    CMD_SUPER_ADMIN = 1,
    CMD_SENIOR_ADMIN,
    CMD_JUNIOR_ADMIN,
    CMD_SENIOR_HELPER,
    CMD_JUNIOR_HELPER
};
// Pawn.CMD

public OnPlayerCommandReceived(playerid, cmd[], params[], flags) {
    if(!isSpawned[playerid]) {
        if(strcmp(cmd, "dton") == 0 || strcmp(cmd, "dtoff") == 0) {
            return 1;
        }
        return 0;
    }
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags) {
    if(result == -1) {
        EMIT_PlayerSystemChat(playerid, -1, "Command not available. use /help for more info.");
        return 0;
    }
    return 1;
}


CMD:help(playerid, params[]) {
    EMIT_PlayerSystemChat(playerid, -1, "HELP: Command Executed!");
    return 1;
}


CMD:me(playerid, params[]) {
    new text[256];
    // new message[256];
    if(!isSpawned[playerid]) return -1;
    if(sscanf(params, "s[256]", text)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /me [action]");

    // format(message,sizeof(message), "* %s %s", GetName(playerid), text);
    SendProximityAction(30.0, playerid, "rp", "me", text, COLOR_ORCHID);
    return 1;
}

CMD:ame(playerid, params[]) {
    new text[256];
    new message[256];
    if(!isSpawned[playerid]) return -1;
    if(sscanf(params,"s[256]", text)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /ame [action]");

    format(message,sizeof(message), "* %s",text);
    SetPlayerChatBubble(playerid, text, COLOR_ORCHID,PLAYER_TEXT_CHAT_RADIUS,5000);
    return 1;
}

CMD:do(playerid, params[]) {
    new text[256];
    // new message[256];

    if(!isSpawned[playerid]) return -1;
    if(sscanf(params, "s[128]", text)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /do [action]");

    // format(message,sizeof(message), "**%s ((%s))", text, GetName(playerid));
    SendProximityAction(30.0, playerid, "rp", "do", text, COLOR_ORCHID);

    return 1;
}

CMD:b(playerid,params[]) {
    new text[256];
    // new message[256];

    if(!isSpawned[playerid]) return -1;
    if(sscanf(params,"s[256]", text)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /b [text]");

    // format(message,sizeof(message), "(( %s: %s ))", GetName(playerid), text);
    SendProximityMessage(30.0, playerid, "ooc", text,COLOR_GRAY1000);

    return 1;
}


CMD:shout(playerid, params[]) {
    new text[256];
    new message[512];
    if(!isSpawned[playerid]) return -1;
    if(sscanf(params, "s[256]", text)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /s [text]");
    format(message,sizeof(message), "%s shout: %s", GetName(playerid), text);
    SendProximityMessage(PLAYER_TEXT_SHOUT_RADIUS, playerid,"shout", text, -1);
    SetPlayerChatBubble(playerid, message, -1,PLAYER_TEXT_SHOUT_RADIUS, 5000);
    return 1;
}
alias:shout("s")

CMD:whisp(playerid, params[]) {
    new text[256];
    new message[512];
    if(!isSpawned[playerid]) return -1;
    if(sscanf(params, "s[256]", text)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /w [text]");
    format(message,sizeof(message), "%s whisp: %s", GetName(playerid), text);
    SendProximityMessage(PLAYER_TEXT_WHISP_RADIUS, playerid, "whisp", text, -1);
    SetPlayerChatBubble(playerid, message, -1,PLAYER_TEXT_WHISP_RADIUS, 5000);
    return 1;
}
alias:whisp("w")

CMD:acceptdeath(playerid, params[]) {
    if(CharacterData[playerid][p_injured] && CharacterData[playerid][p_injured_time] < 1) {
        CharacterData[playerid][p_injured] = false;
        CharacterData[playerid][p_health] = 20.0;
        Character::SetHealth(playerid, 20.0);
        CharacterData[playerid][p_posX] = svSpawnPos[ASGH][se_posX];
        CharacterData[playerid][p_posY] = svSpawnPos[ASGH][se_posY];
        CharacterData[playerid][p_posZ] = svSpawnPos[ASGH][se_posZ];
        CharacterData[playerid][p_angle] = svSpawnPos[ASGH][se_angle];
        Character::RePosition(playerid);
        TogglePlayerControllable(playerid, true);
        ClearAnimations(playerid);
        SetCameraBehindPlayer(playerid);
        DeathSystem::removePlayer(playerid);
    }
    return 1;
}
alias:acceptdeath("adeath")

CMD:accept(playerid, params[]) {
    new choice[32];
    if(sscanf(params, "s[32]", choice)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /accept [choice]");
    if(strcmp(choice, "faction") == 0) {
        if(!Faction::FactionInvite(playerid)) return EMIT_PlayerSystemChat(playerid, -1, "ERROR: Tidak ada undangan dari faction.");
        new eFaction:factionid = eFaction:Faction::FactionInviteID(playerid);
        CharacterData[playerid][p_faction] = factionid;
        CharacterData[playerid][p_faction_level] = 0;
        Faction::SetFactionInvite(playerid, false);
        Faction::SetFactionInviteID(playerid, 0);
        Faction::SendChat(factionid, sprintf("%s telah bergabung kedalam faction.", GetName(playerid)));
        EMIT_PlayerSystemChat(playerid, -1, "Faction: Kamu telah menerima undangan faction.");
        return 1;
    }
    if(strcmp(choice, "heal") == 0) {
        EMS::AcceptHeal(playerid);
        return 1;
    }
    EMIT_PlayerSystemChat(playerid, -1, sprintf("Invalid choice '%s'.", choice));
    return 1;
}

CMD:leave(playerid, params[]) {
    new choice[32];
    if(sscanf(params, "s[32]", choice)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /leave [choice]");
    if(strcmp(choice, "faction") == 0) {
        if(CharacterData[playerid][p_faction] == Faction::NONE) return EMIT_PlayerSystemChat(playerid, -1, "Kamu tidak berada didalam Faction.");
        if(isPlayerUIInteractable[playerid]) {
            HideCEFUI(playerid); 
        }
        new Task:ret = Dialog::ShowAsyncDialog(playerid, Dialog::MSGBOX, "Confirmation", "Apakah kamu yakin ingin keluar dari faction?", "Ya", "Batal");
        await ret;
        new a_res = Dialog::Response[playerid][DialogResponse::response];
        if(!a_res) {
            return 0;
        }
        new eFaction:pFaction = CharacterData[playerid][p_faction];
        EMIT_PlayerSystemChat(playerid, -1, sprintf("FACTION: Kamu telah keluar dari faction", Faction::NAME[pFaction]));
        CharacterData[playerid][p_faction] = Faction::NONE;
        CharacterData[playerid][p_faction_level] = 0;
        Faction::SendChat(pFaction, sprintf("%s telah keluar dari faction", GetName(playerid)));
        return 1;
    }
    EMIT_PlayerSystemChat(playerid, -1, sprintf("Invalid choice '%s'.", choice));
    return 1;
}

CMD:drag(playerid, params[]) {
    new targetid;
    if(sscanf(params, "u", targetid)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /drag [target]");
    if(!IsPlayerConnected(targetid) && IsPlayerNPC(targetid)) return EMIT_PlayerSystemChat(playerid, -1, "ERROR: Invalid target");
    
    if(!IsPlayerCuffed(playerid) &&
        !CharacterData[playerid][p_injured]
    ) {
        EMIT_PlayerSystemChat(playerid, -1, "ERROR: target sedang tidak dalam posisi bisa di drag");
        return 0;
    }
   
    DragInfo[targetid][dragged] = true;
    DragInfo[targetid][drag_timer] = SetTimerEx("DraggingTimer", 1000, 1, "d", targetid);
    DragInfo[targetid][drag_time] = 120;
    DragInfo[targetid][drag_targetid] = playerid;
    Character::SetDragging(playerid, targetid);
    TogglePlayerControllable(targetid, false);
    
    SendProximityAction(30.0, playerid, "rp", "me", sprintf("mulai menarik %s", GetName(targetid)), COLOR_ORCHID);
    return 1;
}

CMD:dragstop(playerid, params[]) {
    new targetid = Character::Dragging(playerid);
    if(targetid == INVALID_PLAYER_ID) return 0;
    DragInfo[targetid][drag_time] = 0;
    EMIT_PlayerSystemChat(playerid, -1, "DRAG: Kamu berhenti menarik.");
    EMIT_PlayerSystemChat(targetid, -1, "DRAG: Kamu telah berhenti ditarik.");
    return 1;
}

CMD:throw(playerid, params[]) {
    if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_SMOKE_CIGGY) {
        if(Character::JointLeft(playerid) > 0) {
            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
            EMIT_PlayerSystemChat(playerid, -1, "CIGARETTE: Kamu telah membuang rokokmu.");
        }
    }
    return 1;
}
