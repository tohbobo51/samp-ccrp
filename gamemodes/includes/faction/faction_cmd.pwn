// Faction Commands
CMD:factionsetlevel(playerid, params[]) {
    new eFaction:pFaction = CharacterData[playerid][p_faction];
    if(pFaction == Faction::NONE) return 0;
    new pLevel = CharacterData[playerid][p_faction_level];
    if(pLevel < (GetFactionMaxLevel(pFaction) - 1)) return 0;
    new tID;
    new tLevel;
    if(sscanf(params, "ii", tID,tLevel)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /(fac)tion(setlevel) [target_id][rank_level]");
    if(tID == playerid) return EMIT_PlayerSystemChat(playerid, -1, "Error: Cannot change faction for yourself.");
    if(!IsPlayerConnected(tID)) return EMIT_PlayerSystemChat(playerid, -1, "Error: Cannot find players (might be offline)");
    if(CharacterData[tID][p_faction] != pFaction) return EMIT_PlayerSystemChat(playerid, -1, "Error: Different Faction");
    if(CharacterData[tID][p_faction_level] == tLevel) return EMIT_PlayerSystemChat(playerid, -1, "Error: Player already on that Rank"); 
    SetPlayerFactionLevel(tID, tLevel);
    EMIT_PlayerSystemChat(playerid, -1, "FACTION: Player Faction Rank set");
    return 1;
}
alias:factionsetlevel("facsetlevel")

CMD:fac(playerid, params[]) {
    if(!IsPlayerInAnyFaction(playerid)) return 0;
    new eFaction:faction = CharacterData[playerid][p_faction];
    new text[256];
    new message[512];
    if(!isSpawned[playerid]) return -1;
    if(sscanf(params, "s[256]", text)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /fac [text]");
    new rankName[Faction::MAX_NAME];
    GetPlayerFactionRankName(playerid,rankName);
    format(message,sizeof(message), "[%s %s] %s: %s", Faction::NAME[faction], rankName , GetName(playerid), text);
    Faction::SendChat(faction, message);
    return 1;
}
alias:fac("f")

CMD:facinvite(playerid, params[]) {
    if(!IsPlayerInAnyFaction(playerid)) return 0;
    new eFaction:pFaction = CharacterData[playerid][p_faction];
    new pLevel = CharacterData[playerid][p_faction_level];
    if(pLevel < (GetFactionMaxLevel(pFaction) - 1)) return 0;
    new targetid;
    if(sscanf(params, "i", targetid)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE:invitefac [targetid]");
    if(!IsPlayerConnected(targetid)) return EMIT_PlayerSystemChat(playerid, -1, "ERROR: Target is not connected.");
    
    if(IsPlayerInAnyFaction(targetid)) return EMIT_PlayerSystemChat(playerid, -1, "ERROR: Player already in faction.");
    EMIT_PlayerSystemChat(targetid, -1, sprintf("%s mengundangmu untuk bergabung ke Faction %s", GetName(playerid), Faction::NAME[pFaction]));
    EMIT_PlayerSystemChat(targetid, -1, "Ketik '/accept faction' untuk menerima tawaran.");
    Faction::SetFactionInvite(targetid, true);
    Faction::SetFactionInviteID(targetid, pFaction);
    EMIT_PlayerSystemChat(playerid, -1, sprintf("Pemain %s diundang ke faction.", GetName(targetid)));
    return 1;
}


CMD:badge(playerid, params[]) {
    new l_targetid;
    if(sscanf(params, "i", l_targetid)){
        EMIT_PlayerSystemChat(playerid, -1, "USAGE: /badge [target]");
        EMIT_PlayerSystemChat(playerid, -1, "   Show badge to specific player.");
        return 1;
    } 
    
    if(IsPlayerLSPD(playerid)) {
        
    }
    // TODO: Implement
    return 1;
}

CMD:locker(playerid, params[]) {
    if(IsPlayerLSPD(playerid)) {
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, VEC3_UNWRAP(LSPD::locker_position))) return 0;
        EMIT_PlayerSystemChat(playerid, -1, "Accessing Locker");
        FactionLocker::ShowToPlayer(playerid, Faction::LSPD);
        return 1;
    }
    if(IsPlayerEMS(playerid)) {
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, VEC3_UNWRAP(EMS::locker_position))) return 0;
        EMIT_PlayerSystemChat(playerid, -1, "Accessing Locker");
        FactionLocker::ShowToPlayer(playerid, Faction::EMS);
    }
    return 1;
}

CMD:duty(playerid, params[]) {
    if(IsPlayerLSPD(playerid)) {
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, VEC3_UNWRAP(LSPD::locker_position))) return 0;
        LSPD::Duty(playerid);
        return 1;
    }
    if(IsPlayerEMS(playerid)) {
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, VEC3_UNWRAP(EMS::locker_position))) return 0;
        EMS::Duty(playerid);
        return 1;
    }
    return 1;
}

CMD:offduty(playerid, params[]) {
    if(IsPlayerLSPD(playerid)) {
        LSPD::OffDuty(playerid);
        return 1;
    }
    if(IsPlayerEMS(playerid)) {
        EMS::OffDuty(playerid);
        return 1;
    }
    return 1;
}

#if defined DEBUG_MODE
CMD:createfacveh(playerid, params[]) {
    new l_facid, l_modelid;
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_MANAGE_FACTION)) return 0;

    if(!IsPlayerInAnyVehicle(playerid)) return EMIT_PlayerSystemChat(playerid, -1, "Harus berada didalam kendaraan");

    new l_vid = GetPlayerVehicleID(playerid);
    l_modelid = GetVehicleModel(l_vid);
    
    if(sscanf(params, "i", l_facid)) {
        EMIT_PlayerSystemChat(playerid, -1, "USAGE: /createfacveh [factionid]");
        EMIT_PlayerSystemChat(playerid, -1, "  Faction List:");
        for(new i=1;i<_:Faction::MAX_FACTION;i++) {
            EMIT_PlayerSystemChat(playerid, -1, sprintf("   - %i (%s)", i, Faction::NAME[eFaction:i]));
        }
        return 0;
    }

    printf("Creating Faction Vehicle with ID: %i", l_modelid);

    new Float:l_pos[3], Float:l_angle;
    GetVehiclePos(l_vid, l_pos[X], l_pos[Y], l_pos[Z]);
    GetVehicleZAngle(l_vid, l_angle);

    DestroyVehicle(l_vid);
    new vid = CreateVehicle(
        l_modelid,
        l_pos[X],
        l_pos[Y],
        l_pos[Z],
        l_angle,
        -1,
        -1,
        -1
    );

    new vData[Vehicle::e_Data];
    vData[VehicleData::id] = map_size(Vehicle::list) + 1;
    vData[VehicleData::vehicleid] = vid;
    vData[VehicleData::modelid] = l_modelid;
    
    vData[VehicleData::fuel] = Vehicle::MODEL_FUEL[l_modelid-MIN_VEHICLE_MODEL];
    vData[VehicleData::max_fuel] = vData[VehicleData::fuel];
    GetVehicleHealth(vid, vData[VehicleData::health]);
    GetVehiclePos(vid, 
        vData[VehicleData::spawnPos][0],
        vData[VehicleData::spawnPos][1],
        vData[VehicleData::spawnPos][2]
    );
    GetVehicleZAngle(vid, vData[VehicleData::zAngle]);
    GetVehicleDamageStatus(
        vid,
        vData[VehicleData::dmgStat][VehicleDmgStat::panels],
        vData[VehicleData::dmgStat][VehicleDmgStat::doors],
        vData[VehicleData::dmgStat][VehicleDmgStat::lights],
        vData[VehicleData::dmgStat][VehicleDmgStat::tires]
    );
    vData[VehicleData::color][0] = -1;
    vData[VehicleData::color][1] = -1;
    vData[VehicleData::engineType] = 1;

    vData[VehicleData::odo_m] = 0;
    vData[VehicleData::odo_km] = 0;
    vData[VehicleData::serial] = random(999999)+1;
    vData[VehicleData::key_attached] = 0;
    vData[VehicleData::faction_id] = l_facid;
    
    vData[VehicleData::spawned] = true;
    
    format(vData[VehicleData::plateNumber], 10, sprintf("%s", Faction::NAME[eFaction:l_facid]));
    Vehicle::DebugData(vData); 
    map_add_arr(Vehicle::list, vData[VehicleData::vehicleid], vData);
    Vehicle::applyEngine(vData);
    Vehicle::Save(vData);

    // new keyItem[Inv::eItem];
    // keyItem[Item::id] = ITEM_KEY_VEHICLE_MASTER;
    // keyItem[Item::amount] = 1;
    // keyItem[Item::durability] = 0;
    // keyItem[Item::power] = 0;
    // keyItem[Item::addon1] = vData[VehicleData::serial];
    // keyItem[Item::addon2] = 0;
    // keyItem[Item::addon3] = 0;
    // GivePlayerItem(playerid, keyItem);
    // GUI_Emit_InventoryItems(playerid);
    return vid;
}
#endif
