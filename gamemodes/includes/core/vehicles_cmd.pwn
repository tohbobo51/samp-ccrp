// ============================== CMD =======================================
CMD:engine(playerid, params[]) {
    if(!IsPlayerInAnyVehicle(playerid)) return EMIT_PlayerSystemChat(playerid, -1, "You're not inside any vehicle");
    new vehId = GetPlayerVehicleID(playerid);
    new vData[Vehicle::e_Data];
    new hasValid = false;
    if(map_has_key(Vehicle::list, vehId) && !hasValid) {
        map_get_arr(Vehicle::list, vehId, vData);
        hasValid = true;
    }
    
    if(!hasValid) {
        // TODO: Handle RENT Vehicle
        printf("Non Crafted Vehicle.");
        ToggleVehicleEngine(vehId);
        return 1;
    }
    if(vData[VehicleData::faction_id] == 0) {
        if(vData[VehicleData::key_attached] == 0) {
            return EMIT_PlayerSystemChat(playerid, -1, "This vehicle has no key attached.");
        }
        ToggleVehicleEngine(vehId);
        return 1;
    }

    if(vData[VehicleData::faction_id] != 0 && IsPlayerInFaction(playerid, eFaction:vData[VehicleData::faction_id])) {
        ToggleVehicleEngine(vehId);
        return 1;
    }
    printf("END OF ENGINE FUNCTION REACHED");
    return 1;
}

CMD:lights(playerid, params[]) {
    if(!IsPlayerInAnyVehicle(playerid)) return EMIT_PlayerSystemChat(playerid, -1, "Kamu tidak didalam kendaraan.");
    new vehId = GetPlayerVehicleID(playerid);
    new vData[Vehicle::e_Data];
    new hasValid = false;
    if(map_has_key(Vehicle::list, vehId) && !hasValid) {
        map_get_arr(Vehicle::list, vehId, vData);
        hasValid = true;
    }
    
    if(!hasValid) {
        printf("Non Crafted Vehicle.");
        return 1;
    }
    ToggleVehicleLights(vehId);
    return 1;
}

CMD:hood(playerid, params[]) {
    if(!IsPlayerInAnyVehicle(playerid)) return EMIT_PlayerSystemChat(playerid, -1, "Kamu tidak didalam kendaraan.");
    new vehId = GetPlayerVehicleID(playerid);
    new vData[Vehicle::e_Data];
    new hasValid = false;
    if(map_has_key(Vehicle::list, vehId) && !hasValid) {
        map_get_arr(Vehicle::list, vehId, vData);
        hasValid = true;
    }
    
    if(!hasValid) {
        printf("Non Crafted Vehicle.");
        return 1;
    }
    ToggleVehicleHood(vehId);
    return 1;
}

CMD:trunk(playerid, params[]) {
    if(!IsPlayerInAnyVehicle(playerid)) {
        new l_vid = GetNearbyVehicle(playerid);
        if(l_vid == INVALID_VEHICLE_ID) {
            return 0;
        }
        new vData[Vehicle::e_Data];
        new hasdata = false;
        new isfacveh = false;
        if(map_has_key(Vehicle::list, l_vid) && !hasdata) {
            map_get_arr(Vehicle::list, l_vid, vData);
            hasdata = true;
            if(vData[VehicleData::faction_id] != 0) isfacveh = true;
        }
        
        if(!hasdata) return 0;
        if(isfacveh && !IsPlayerInFaction(playerid, eFaction:vData[VehicleData::faction_id])) return 0;
        if(!isfacveh) {
            if(!CharacterInv::HasVehicleKey(playerid, vData[VehicleData::serial])) return 0;
        }
        new Float:trunkPos[3];
        GetPosNearVehiclePart(l_vid,VEH_PART_TRUNK,trunkPos[X], trunkPos[Y], trunkPos[Z], 0.25);
        new Float:pPos[3];
        GetPlayerPos(playerid, pPos[X], pPos[Y], pPos[Z]);
        new Float:dist = GetDistance(pPos, trunkPos);
        if(dist < 1.5) {
            ToggleVehicleTrunk(l_vid);
        }
    } else {
        new vehId = GetPlayerVehicleID(playerid);
        new vData[Vehicle::e_Data];
        new hasValid = false;
        if(map_has_key(Vehicle::list, vehId) && !hasValid) {
            map_get_arr(Vehicle::list, vehId, vData);
            hasValid = true;
        }
        
        if(!hasValid) {
            printf("Non Crafted Vehicle.");
            return 1;
        }
        ToggleVehicleTrunk(vehId);    
    }
    return 1; 
}

CMD:vstorage(playerid, params[]) {
    new l_vid = GetNearbyVehicle(playerid);
    if(l_vid == INVALID_VEHICLE_ID) {
        return 0;
    }
    new vData[Vehicle::e_Data];
    new hasdata = false;
    // new isfacveh = false;
    if(map_has_key(Vehicle::list, l_vid) && !hasdata) {
        map_get_arr(Vehicle::list, l_vid, vData);
        hasdata = true;
        // if(vData[VehicleData::faction_id] != 0) isfacveh = true;
    }
    if(!hasdata) return 0;
    // if(isfacveh && !IsPlayerInFaction(playerid, eFaction:vData[VehicleData::faction_id])) return 0;
    // if(!isfacveh) {
    //     if(!CharacterInv::HasVehicleKey(playerid, vData[VehicleData::serial])) {
    //         EMIT_PlayerSystemChat(playerid, -1, "Kamu tidak membawa kunci kendaraan ini.");
    //         return 0;
    //     }
    // }
    new Float:trunkPos[3];
    GetPosNearVehiclePart(l_vid,VEH_PART_TRUNK,trunkPos[X], trunkPos[Y], trunkPos[Z], 0.25);
    new Float:pPos[3];
    GetPlayerPos(playerid, pPos[X], pPos[Y], pPos[Z]);
    new Float:dist = GetDistance(pPos, trunkPos);
    if(dist > 1.5) {
        return 0;
    }
    if(!IsTrunkOpen(l_vid)) return 0;
    if(VehicleStorage::IsUsed(l_vid)) {
        EMIT_PlayerSystemChat(playerid, -1, "STORAGE: Sedang diakses oleh pemain lain.");
        return 0;
    }
    EMIT_PlayerSystemChat(playerid, -1, "Mengakses bagasi kendaraan.");
    new loaded = await VehicleStorage::LoadStorage(l_vid);
    if(!loaded) {
        EMIT_PlayerSystemChat(playerid, -1, "Terjadi kesalahan saat mengambil storage.");
        return 0;
    }
    VehicleStorage::ShowToPlayer(l_vid, playerid);
    VehicleStorage::SetAccessing(playerid, 1);
    VehicleStorage::SetAccessID(playerid, l_vid);
    VehicleStorage::SetUsed(l_vid, 1);
    return 1;
}
alias:vstorage("vstor")

CMD:detach(playerid, params[]) {
    if(!IsPlayerInAnyVehicle(playerid)) return 1;
    new vehId = GetPlayerVehicleID(playerid);
    DetachTrailerFromVehicle(vehId);
    return 1; 
}

// ===================================== CMD END ===================================

// =========================== CMD DEBUG ===================================
#if defined DEBUG_MODE
CMD:gotovehfac(playerid, params[]) {
    SetPlayerPos(playerid,
                VehicleFactory::factories[0][VehicleFactory::position][0],
                VehicleFactory::factories[0][VehicleFactory::position][1],
                VehicleFactory::factories[0][VehicleFactory::position][2]
    );
    return 1; 
}

CMD:givebpitem(playerid, params[]) {
    new modelId;
    if(sscanf(params,"i", modelId)) return EMIT_PlayerSystemChat(playerid, -1, "/givebpitem [vehicle_model_id]");

    new l_itemData[Inv::eItem];
    l_itemData[Item::id] = 75;
    l_itemData[Item::amount] = 1;
    l_itemData[Item::addon1] = modelId;
    
    GivePlayerItem(playerid, l_itemData);
    return 1;
}

CMD:gethandling(playerid, params[]) {
    if(!IsPlayerInAnyVehicle(playerid)) {
        return 1;
    }
    new vehicleid = GetPlayerVehicleID(playerid);
    new Float:maxvel, Float:acceleration, Float:inertia;
    GetVehicleHandlingFloat(vehicleid, HANDL_TR_FMAXVELOCITY, maxvel);
    GetVehicleHandlingFloat(vehicleid, HANDL_TR_FENGINEACCELERATION, acceleration);
    GetVehicleHandlingFloat(vehicleid, HANDL_TR_FENGINEINERTIA, inertia);
    EMIT_PlayerSystemChat(playerid, -1, sprintf("Vehicle Max Speed: %f", maxvel));
    EMIT_PlayerSystemChat(playerid, -1, sprintf("Vehicle Acceleration: %f", acceleration));
    EMIT_PlayerSystemChat(playerid, -1, sprintf("Vehicle Inertia: %f", inertia));
    return 1;
}



CMD:veh(playerid, params[]) {
    new vehId;
    if(sscanf(params, "i", vehId)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /veh [vehicleid]");

    new Float:posX, Float:posY, Float:posZ, Float:angle;
    GetPlayerPos(playerid, posX, posY, posZ);
    GetPlayerFacingAngle(playerid,angle);

    new createId = CreateVehicle(vehId, posX,posY,posZ+2.0,angle,0,0,-1,false);
    PutPlayerInVehicle(playerid, createId, 0);
    return 1;
}

CMD:setvehspeed(playerid, params[]) {
    new Float:speed;
    if(sscanf(params, "f", speed)) {
        return EMIT_PlayerSystemChat(playerid, -1, "[/setvehspeed [Float:speed]]");
    }
    if(!IsPlayerInAnyVehicle(playerid)) {
        return EMIT_PlayerSystemChat(playerid, -1, "You must at any vehicle to use this cmd");
    }
    new vid = GetPlayerVehicleID(playerid);
    SetVehicleHandlingFloat(vid,HANDL_TR_FMAXVELOCITY,speed);
    return 1;
}

CMD:setvehacc(playerid, params[]) {
    new Float:speed;
    if(sscanf(params, "f", speed)) {
        return EMIT_PlayerSystemChat(playerid, -1, "[/setvehspeed [Float:speed]]");
    }
    if(!IsPlayerInAnyVehicle(playerid)) {
        return EMIT_PlayerSystemChat(playerid, -1, "You must at any vehicle to use this cmd");
    }
    new vid = GetPlayerVehicleID(playerid);
    SetVehicleHandlingFloat(vid,HANDL_TR_FENGINEACCELERATION,speed);
    return 1;
}

CMD:setvehmass(playerid, params[]) {
    new Float:speed;
    if(sscanf(params, "f", speed)) {
        return EMIT_PlayerSystemChat(playerid, -1, "[/setvehspeed [Float:speed]]");
    }
    if(!IsPlayerInAnyVehicle(playerid)) {
        return EMIT_PlayerSystemChat(playerid, -1, "You must at any vehicle to use this cmd");
    }
    new vid = GetPlayerVehicleID(playerid);
    SetVehicleHandlingFloat(vid,HANDL_FMASS,speed);
    return 1;
}
CMD:setvehinertia(playerid, params[]) {
    new Float:inertia;
    if(sscanf(params, "f", inertia)) {
        return EMIT_PlayerSystemChat(playerid, -1, "[/setvehinertia [Float:inertia]]");
    }
    if(!IsPlayerInAnyVehicle(playerid)) {
        return EMIT_PlayerSystemChat(playerid, -1, "You must at any vehicle to use this cmd");
    }
    new vid = GetPlayerVehicleID(playerid);
    SetVehicleHandlingFloat(vid,HANDL_TR_FENGINEINERTIA,inertia);
    return 1;
}

CMD:refillveh(playerid, params[]) {
    if(!IsPlayerInAnyVehicle(playerid)) return 1;
    new vid = GetPlayerVehicleID(playerid);
    if(!map_has_key(Vehicle::list, vid)) return 1;
    new vData[Vehicle::e_Data];
    map_get_arr(Vehicle::list, vid, vData);
    vData[VehicleData::fuel] = vData[VehicleData::max_fuel];
    map_set_arr(Vehicle::list, vid, vData);
    return 1;
}

CMD:repairveh(playerid, params[]) {
    if(!IsPlayerInAnyVehicle(playerid)) return 1;
    new vid = GetPlayerVehicleID(playerid);
    RepairVehicle(vid);
    return 1;
}

#endif

// ============================== CMD DEBUG END ==============================
