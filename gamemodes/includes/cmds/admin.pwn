// Helper Utilities
CMD:spectate(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_SPECTATE)) return 0;
    
    new targetid;
    if(sscanf(params, "i", targetid)) {
        // If already spectating someone, this will stop it
        if(AdminSystem::IsSpectating(playerid)) {
            PC_EmulateCommand(playerid, "/specoff");
            return 1;
        }
        return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /spectate [playerid] or /spectate (to stop spectating)");
    }
    
    // Check if target is valid
    if(!IsPlayerConnected(targetid)) {
        return EMIT_PlayerSystemChat(playerid, -1, "ERROR: That player is not connected.");
    }
    
    // Can't spectate yourself
    if(targetid == playerid) {
        return EMIT_PlayerSystemChat(playerid, -1, "ERROR: You cannot spectate yourself.");
    }
    
    // Save admin's position before spectating for later restoration
    new Float:pos[3], interior, virtualworld;
    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
    interior = GetPlayerInterior(playerid);
    virtualworld = GetPlayerVirtualWorld(playerid);
    
    // Store last position data
    AdminSystem::SetSpectatorLastPos(playerid, "spec_lastX", pos[0]);
    AdminSystem::SetSpectatorLastPos(playerid, "spec_lastY", pos[1]);
    AdminSystem::SetSpectatorLastPos(playerid, "spec_lastZ", pos[2]);
    SetPVarInt(playerid, "spec_lastInterior", interior);
    SetPVarInt(playerid, "spec_lastVW", virtualworld);
    
    // Start spectating
    AdminSystem::SetSpectating(playerid, 1);
    AdminSystem::SetSpectateTarget(playerid, targetid);
    
    // Put player in spectate mode
    TogglePlayerSpectating(playerid, 1);
    
    // Spectate the player
    if(IsPlayerInAnyVehicle(targetid)) {
        PlayerSpectateVehicle(playerid, GetPlayerVehicleID(targetid));
    } else {
        PlayerSpectatePlayer(playerid, targetid);
    }
    
    // Match target's interior and virtual world
    SetPlayerInterior(playerid, GetPlayerInterior(targetid));
    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));
    
    EMIT_PlayerSystemChat(playerid, -1, sprintf("You are now spectating %s (ID: %d). Use /specoff to stop.", GetName(targetid), targetid));
    
    return 1;    
}

CMD:specoff(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_SPECTATE)) return 0;
    
    // Check if player is actually spectating
    if(!AdminSystem::IsSpectating(playerid)) {
        return EMIT_PlayerSystemChat(playerid, -1, "ERROR: You are not spectating anyone.");
    }
    
    // Stop spectating
    TogglePlayerSpectating(playerid, 0);
    
    // Restore player position
    new Float:pos[3], interior, virtualworld;
    pos[0] = AdminSystem::GetSpectatorLastPos(playerid, "spec_lastX");
    pos[1] = AdminSystem::GetSpectatorLastPos(playerid, "spec_lastY");
    pos[2] = AdminSystem::GetSpectatorLastPos(playerid, "spec_lastZ");
    interior = GetPVarInt(playerid, "spec_lastInterior");
    virtualworld = GetPVarInt(playerid, "spec_lastVW");
    
    // Set player back to their original position
    SetPlayerPos(playerid, pos[0], pos[1], pos[2]);
    SetPlayerInterior(playerid, interior);
    SetPlayerVirtualWorld(playerid, virtualworld);
    
    // Reset spectating status
    AdminSystem::SetSpectating(playerid, 0);
    AdminSystem::SetSpectateTarget(playerid, INVALID_PLAYER_ID);
    
    EMIT_PlayerSystemChat(playerid, -1, "You have stopped spectating.");
    
    return 1;
}

CMD:speclist(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_SPECTATE)) return 0;
    
    new count = 0;
    EMIT_PlayerSystemChat(playerid, -1, "=== SPECTATOR LIST ===");
    
    foreach(new i : Player) {
        if(AdminSystem::IsSpectating(i)) {
            new targetid = AdminSystem::GetSpectateTarget(i);
            if(IsPlayerConnected(targetid)) {
                count++;
                EMIT_PlayerSystemChat(playerid, -1, sprintf("%s (ID: %d) is spectating %s (ID: %d)", 
                    GetName(i), i, GetName(targetid), targetid));
            }
        }
    }
    
    if(count == 0) {
        EMIT_PlayerSystemChat(playerid, -1, "No admins are currently spectating.");
    }
    
    EMIT_PlayerSystemChat(playerid, -1, "=====================");
    return 1;
}
CMD:get(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_GET)) return 0;
    
    new l_tgt;
    if(sscanf(params,"i", l_tgt)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /get [playerid]");
    if(l_tgt == INVALID_PLAYER_ID) {
        EMIT_PlayerSystemChat(playerid, -1, "CMD:get [Error] Invalid playerid");
        return 0;
    }
    if(!IsPlayerConnected(l_tgt)) {
        EMIT_PlayerSystemChat(playerid, -1, "CMD:get [Error] Player not connected");
        return 0;
    }
    new l_intid = GetPlayerInterior(playerid);
    new l_vw = GetPlayerVirtualWorld(playerid);
    new Float:l_pos[3];
    GetPlayerPos(playerid, l_pos[X], l_pos[Y], l_pos[Z]);
    SetPlayerPos(l_tgt, l_pos[X], l_pos[Y], l_pos[Z]);
    SetPlayerInterior(l_tgt, l_intid);
    SetPlayerVirtualWorld(l_tgt, l_vw);
    EMIT_PlayerSystemChat(l_tgt, -1, sprintf("Kamu telah di GET oleh %s", GetName(playerid)));
    return 1;
}

CMD:goto(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_GOTO)) return 0;
    new l_tgt;
    if(sscanf(params,"i", l_tgt)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /goto [playerid]");
    if(l_tgt == INVALID_PLAYER_ID) {
        EMIT_PlayerSystemChat(playerid, -1, "CMD:get [Error] Invalid playerid");
        return 0;
    }
    if(!IsPlayerConnected(l_tgt)) {
        EMIT_PlayerSystemChat(playerid, -1, "CMD:get [Error] Player not connected");
        return 0;
    }
    new l_intid = GetPlayerInterior(l_tgt);
    new l_vw = GetPlayerVirtualWorld(l_tgt);
    new Float:l_pos[3];
    GetPlayerPos(l_tgt, l_pos[X], l_pos[Y], l_pos[Z]);
    SetPlayerPos(playerid, l_pos[X], l_pos[Y], l_pos[Z]);
    SetPlayerInterior(playerid, l_intid);
    SetPlayerVirtualWorld(playerid, l_vw);
    return 1;
}

CMD:warn(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_WARN)) return 0;
    // TODO: Implement
    return 1;
}

CMD:kick(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_KICK)) return 0;
    new l_tgt;
    if(sscanf(params,"i", l_tgt)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /kick [playerid]");
    if(l_tgt == INVALID_PLAYER_ID) {
        EMIT_PlayerSystemChat(playerid, -1, "CMD:kick [Error] Invalid playerid");
        return 0;
    }
    if(!IsPlayerConnected(l_tgt)) {
        EMIT_PlayerSystemChat(playerid, -1, "CMD:kick [Error] Player not connected");
        return 0;
    }
    AdminSystem::Kick(l_tgt, "You have been kicked from the server.");
    EMIT_PlayerSystemChat(playerid, -1, sprintf("You have kicked %s from the server.", GetName(l_tgt)));
    EMIT_PlayerSystemChat(l_tgt, -1, sprintf("You have been kicked from the server."));
    return 1;
}

CMD:ban(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_BAN)) return 0;
    // TODO: Implement
    return 1;
}

CMD:banhw(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_BAN)) return 0;
    // TODO: Implement
    return 1;
}

CMD:banip(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_BAN)) return 0;
    // TODO: Implement
    return 1;
}

// Faction
CMD:asetfacleader(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_MANAGE_FACTION)) return 0;
    new target_id;
    new eFaction:faction_id;
    if(sscanf(params, "ii", target_id, faction_id)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /asetfacleader [playerid][faction_id] (0=NONE, 1=GOV, 2=LSPD, 3=EMS, 4=SANEWS)");
    if(!IsPlayerConnected(target_id)) return EMIT_PlayerSystemChat(playerid, -1, "Invalid target_id");
    if(faction_id >= Faction::MAX_FACTION) return EMIT_PlayerSystemChat(playerid, -1, "Invalid Faction ID");
   
    SetPlayerFaction(target_id, faction_id);
    SetPlayerFactionLevel(target_id, GetFactionMaxLevel(faction_id)-1);
    return 1;
}

CMD:asetfaclevel(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_MANAGE_FACTION)) return 0;
    new target_id;
    new eFaction:faction_id;
    new level;
    if(sscanf(params, "iii", target_id, faction_id, level)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /asetfaclevel [playerid][faction_id][level]");
    if(!IsPlayerConnected(target_id)) return EMIT_PlayerSystemChat(playerid, -1, "Invalid target_id");
    if(faction_id >= Faction::MAX_FACTION) return EMIT_PlayerSystemChat(playerid, -1, "Invalid Faction ID");
    if(level < 0 || level > GetFactionMaxLevel(faction_id)) return EMIT_PlayerSystemChat(playerid, -1, "Invalid level");
    
    SetPlayerFactionLevel(target_id, level);
    EMIT_PlayerSystemChat(playerid, -1, sprintf("You have set %s's faction level to %d.", GetName(target_id), level));
    EMIT_PlayerSystemChat(target_id, -1, sprintf("You have been set to faction level %d.", level));
    return 1;
}

CMD:maptp(playerid, params[]) {
    if(!AdminSystem::IsAdmin(playerid)) return 0;
    new activate;
    if(sscanf(params, "i", activate)) return 0;
    AdminSystem::SetMapTP(playerid, activate);
    return 0;
}
