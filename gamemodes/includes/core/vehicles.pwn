#include <pp-hooks>
public OnGameModeInit() {
    printf("[Vehicle] Gamemode Init");

    VehicleFactory::factories[0][VehicleFactory::position][0] = 2077.3508;
    VehicleFactory::factories[0][VehicleFactory::position][1] = -2046.6071;
    VehicleFactory::factories[0][VehicleFactory::position][2] = 13.5469;
    VehicleFactory::factories[0][VehicleFactory::vehSpawnPos][0] = 2079.3928;
    VehicleFactory::factories[0][VehicleFactory::vehSpawnPos][1] = -2046.6224;
    VehicleFactory::factories[0][VehicleFactory::vehSpawnPos][2] = 13.2521;
    VehicleFactory::factories[0][VehicleFactory::vehSpawnAngle] = 270.5075;

    VehicleFactory::factories[1][VehicleFactory::position][0] = 2077.3508;
    VehicleFactory::factories[1][VehicleFactory::position][1] = -2033.2239;
    VehicleFactory::factories[1][VehicleFactory::position][2] = 13.5469;
    VehicleFactory::factories[1][VehicleFactory::vehSpawnPos][0] = 2080.3499;
    VehicleFactory::factories[1][VehicleFactory::vehSpawnPos][1] = -2033.3513;
    VehicleFactory::factories[1][VehicleFactory::vehSpawnPos][2] = 13.2513;
    VehicleFactory::factories[1][VehicleFactory::vehSpawnAngle] = 270.5515;

    VehicleFactory::factories[2][VehicleFactory::position][0] = 2077.3508;
    VehicleFactory::factories[2][VehicleFactory::position][1] = -2019.9965;
    VehicleFactory::factories[2][VehicleFactory::position][2] = 13.5469;
    VehicleFactory::factories[2][VehicleFactory::vehSpawnPos][0] = 2080.5801;
    VehicleFactory::factories[2][VehicleFactory::vehSpawnPos][1] = -2020.6073;
    VehicleFactory::factories[2][VehicleFactory::vehSpawnPos][2] = 13.2525;
    VehicleFactory::factories[2][VehicleFactory::vehSpawnAngle] = 269.1874;

    VehicleFactory::factories[3][VehicleFactory::position][0] = 2077.3508;
    VehicleFactory::factories[3][VehicleFactory::position][1] = -2006.9128;
    VehicleFactory::factories[3][VehicleFactory::position][2] = 13.5469;
    VehicleFactory::factories[3][VehicleFactory::vehSpawnPos][0] = 2080.1719;
    VehicleFactory::factories[3][VehicleFactory::vehSpawnPos][1] = -2006.9746;
    VehicleFactory::factories[3][VehicleFactory::vehSpawnPos][2] = 13.2523;
    VehicleFactory::factories[3][VehicleFactory::vehSpawnAngle] = 268.2116;

    VehicleFactory::CreatePickupLabel();

    Vehicle::list = map_new();
    VehicleStorage::map = map_new();
    mysql_tquery(MainConn, "SELECT * FROM `vehicle`", "OnAllVehicleLoaded");
    mysql_tquery(MainConn, "SELECT * FROM `vehicle_storage` ORDER BY 'id' DESC LIMIT 1", "OnGetLastStorageID");

#if defined VEH_OnGameModeInit
  return VEH_OnGameModeInit();
#else
  return 1;
#endif
}
#if defined _ALS_OnGameModeInit
#undef OnGameModeInit
#else
#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit VEH_OnGameModeInit
#if defined VEH_OnGameModeInit
    forward VEH_OnGameModeInit();
#endif

Vehicle::deInit() {
    new vData[Vehicle::e_Data];
    for_map(i : Vehicle::list) {
        iter_get_arr(i, vData);
        Vehicle::Update(vData);
    }
    return 1; 
}

hook OnPlayerConnect(playerid) {
    VehicleFactory::SetFactoryID(playerid, -1);
  // =================================
}

hook OnPlayerDisconnect(playerid) {
    if(VehicleStorage::IsAccessing(playerid)) {
        new vid = VehicleStorage::AccessID(playerid);
        VehicleStorage::SetUsed(vid, 0);
    }
}


hook OnPlayerEnterDynArea(playerid, areaid) {
    for(new i=0;i<4;i++) {
        if(areaid == VehicleFactory::factories[i][VehicleFactory::areaid]) {
            if(VehicleFactory::factories[i][VehicleFactory::used]) {
                EMIT_PlayerSystemChat(playerid, -1, "Vehicle Factory is still used by other players.\nUse other factory or wait them to finish.");
                return 1;
            }
            VehicleFactory::SetUsingFactory(playerid, true);
            VehicleFactory::SetFactoryID(playerid, i);
            cef_emit_event(playerid, "vehfac:open");
            EMIT_PlayerSystemChat(playerid, -1, "Opening Vehicle Factory Window");
            VehicleFactory::factories[i][VehicleFactory::used] = true;
            if(!isPlayerUIInteractable[playerid]) {
                isPlayerUIInteractable[playerid] = true;
                cef_focus_browser(playerid, GET_BROWSER_ID(playerid), true);
            }
            return 1;
        }
    }
    return 0;
}


public OnGotRedisEvent(const eventName[], Node:data) {
    Logger_Dbg("vehicle", "redis handler", Logger_S("event", eventName));
    if(strcmp(eventName, "vehfac_takebp") == 0) {
        new characterId;
        JsonGetInt(data, "cid",characterId);
        
        new pid = Vehicle::Redis_EventValidate(characterId, "vehfac_rm_bp");
        
        if(pid == INVALID_PLAYER_ID) return 1;
        new slot;
        JsonGetInt(data, "idx", slot);
        new ret = TakePlayerItem(pid, slot, 1);
        
        new Node:redis_event = JsonObject();
        JsonSetString(redis_event, "event", sprintf("vehfac_rm_bp_%i",characterId));
        new Node:payload = JsonObject();
        if(ret == 1) {
            JsonSetBool(payload, "success", true);
            JsonSetString(payload, "msg", sprintf("Item has been taken from player."));  
        } else {
            JsonSetBool(payload, "success", false);
            JsonSetString(payload, "msg", sprintf("Failed to take playeritem"));
        }
        JsonSetObject(redis_event, "data", payload);
        szRedisEvent[0] = 0;
        JsonStringify(redis_event,szRedisEvent);
        Redis_Publish(redisClientPubSub, "frm.pwn", szRedisEvent);
        return 1; 
    }

    if(strcmp(eventName, "vehfac_takeitem") == 0) {
        new characterId;
        JsonGetInt(data, "cid",characterId);
        new pid = Vehicle::Redis_EventValidate(characterId, "vehfac_on_takeitem");
        if(pid == INVALID_PLAYER_ID) return 1;
        new slot;
        JsonGetInt(data, "slot", slot);
        new ret = TakePlayerItem(pid, slot, 1);
        
        new Node:redis_event = JsonObject();
        JsonSetString(redis_event, "event", sprintf("vehfac_on_takeitem_%i",characterId));
        new Node:payload = JsonObject();
        if(ret == 1) {
            JsonSetBool(payload, "success", true);
            JsonSetString(payload, "msg", sprintf("Item has been taken from player."));
        } else {
            JsonSetBool(payload, "success", false);
            JsonSetString(payload, "msg", sprintf("Failed to take player item."));
        }
            
        JsonSetObject(redis_event, "data", payload);
        szRedisEvent[0] = 0;
        JsonStringify(redis_event,szRedisEvent);
        Redis_Publish(redisClientPubSub, "frm.pwn", szRedisEvent);
        return 1; 
    }

    
    if(strcmp(eventName, "vehfac_spawnvehicle") == 0) {
        new characterId;
        JsonGetInt(data, "cid",characterId);
        new pid = Vehicle::Redis_EventValidate(characterId, "vehfac_on_vehiclespawn");
        if(pid == INVALID_PLAYER_ID) return 1;

        new modelId;
        JsonGetInt(data, "modelId", modelId);
        new fid = VehicleFactory::FactoryID(pid);
        new vid = Vehicle::create(modelId, fid, pid);
        
        PutPlayerInVehicle(pid, vid, 0);
        
        new Node:redis_event = JsonObject();
        JsonSetString(redis_event, "event", sprintf("vehfac_on_vehiclespawn_%i",characterId));
        new Node:payload = JsonObject();
        JsonSetBool(payload, "success", true);
        JsonSetString(payload, "msg", sprintf("Vehicle Spawned"));
            
        JsonSetObject(redis_event, "data", payload);
        szRedisEvent[0] = 0;
        JsonStringify(redis_event,szRedisEvent);
        Redis_Publish(redisClientPubSub, "frm.pwn", szRedisEvent);
        return 1;
    }
#if defined Veh_OnGotRedisEvent
    return Veh_OnGotRedisEvent(eventName,data);
#else
    return 1;
#endif
}

#if defined _ALS_OnGotRedisEvent
#undef OnGotRedisEvent
#else
#define _ALS_OnGotRedisEvent
#endif
#define OnGotRedisEvent Veh_OnGotRedisEvent
#if defined Veh_OnGotRedisEvent
forward Veh_OnGotRedisEvent(const eventName[], Node:data);
#endif

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER && oldstate == PLAYER_STATE_ONFOOT) {
        Vehicle::EMIT_EnterEvent(playerid);
    }
    if(newstate == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_DRIVER) {
        Vehicle::EMIT_ExitEvent(playerid);
    }
#if defined Veh_OnPlayerStateChange 
    return Veh_OnPlayerStateChange(playerid, newstate, oldstate);
#else 
    return 1;
#endif
}
#if defined _ALS_OnPlayerStateChange 
#undef OnPlayerStateChange
#else 
#define _ALS_OnPlayerStateChange 
#endif
#define OnPlayerStateChange Veh_OnPlayerStateChange
#if defined Veh_OnPlayerStateChange
forward Veh_OnPlayerStateChange(playerid, newstate, oldstate);
#endif

public OnPlayerExitVehicle(playerid, vehicleid)
{
    if(map_has_key(Vehicle::list, vehicleid)) {
        new vData[Vehicle::e_Data];
        map_get_arr(Vehicle::list, vehicleid, vData);
        Vehicle::Update(vData);
    }
#if defined Veh_OnPlayerExitVehicle
    return Veh_OnPlayerExitVehicle(playerid,vehicleid);
#else
    return 1;
#endif
}
#if defined _ALS_OnPlayerExitVehicle
#undef OnPlayerExitVehicle
#else
#define _ALS_OnPlayerExitVehicle
#endif
#define OnPlayerExitVehicle Veh_OnPlayerExitVehicle
#if defined Veh_OnPlayerExitVehicle
forward Veh_OnPlayerExitVehicle(playerid,vehicleid);
#endif

// ===================== Functions ==================================

VehicleFactory::CreatePickupLabel() {
    for(new i=0;i<4;i++) {
        VehicleFactory::factories[i][VehicleFactory::pickupid] = CreateDynamicPickup(
            1318,
            1,
            VehicleFactory::factories[i][VehicleFactory::position][0],
            VehicleFactory::factories[i][VehicleFactory::position][1],
            VehicleFactory::factories[i][VehicleFactory::position][2]
        );

        VehicleFactory::factories[i][VehicleFactory::textid] = CreateDynamic3DTextLabel(
            sprintf("VEHICLE FACTORY #%i", i+1),
            -1,
            VehicleFactory::factories[i][VehicleFactory::position][0],
            VehicleFactory::factories[i][VehicleFactory::position][1],
            VehicleFactory::factories[i][VehicleFactory::position][2],
            50.0
        );

        VehicleFactory::factories[i][VehicleFactory::areaid] = CreateDynamicCircle(
            VehicleFactory::factories[i][VehicleFactory::position][0],
            VehicleFactory::factories[i][VehicleFactory::position][1],
            1.0
        );
    }
    return 1; 
}


Vehicle::create(modelid,factoryid,playerid) {
    new vid = CreateVehicle(
        modelid,
        VehicleFactory::factories[factoryid][VehicleFactory::vehSpawnPos][0],
        VehicleFactory::factories[factoryid][VehicleFactory::vehSpawnPos][1],
        VehicleFactory::factories[factoryid][VehicleFactory::vehSpawnPos][2],
        VehicleFactory::factories[factoryid][VehicleFactory::vehSpawnAngle],
        140,
        140,
        -1
    );

    new vData[Vehicle::e_Data];
    vData[VehicleData::id] = map_size(Vehicle::list) + 1;
    vData[VehicleData::vehicleid] = vid;
    vData[VehicleData::modelid] = modelid;
    
    vData[VehicleData::fuel] = Vehicle::MODEL_FUEL[modelid-MIN_VEHICLE_MODEL];
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
    vData[VehicleData::color][0] = 140;
    vData[VehicleData::color][1] = 140;
    vData[VehicleData::engineType] = 1;

    vData[VehicleData::odo_m] = 0;
    vData[VehicleData::odo_km] = 0;
    vData[VehicleData::serial] = random(999999)+1;
    vData[VehicleData::key_attached] = 0;
    
    vData[VehicleData::spawned] = true;
    
    format(vData[VehicleData::plateNumber], 10, "NO_PLATE");
    
    map_add_arr(Vehicle::list, vData[VehicleData::vehicleid], vData);
    Vehicle::applyEngine(vData);
    Vehicle::Save(vData);

    new keyItem[Inv::eItem];
    keyItem[Item::id] = ITEM_KEY_VEHICLE_MASTER;
    keyItem[Item::amount] = 1;
    keyItem[Item::durability] = 0;
    keyItem[Item::power] = 0;
    keyItem[Item::addon1] = vData[VehicleData::serial];
    keyItem[Item::addon2] = 0;
    keyItem[Item::addon3] = 0;
    GivePlayerItem(playerid, keyItem);
    GUI_Emit_InventoryItems(playerid);
    return vid;
}

Vehicle::applyEngine(const vData[Vehicle::e_Data]) {
    if(!IsValidVehicle(vData[VehicleData::vehicleid])) return 0;
    new engineType = vData[VehicleData::engineType];
    new modelid = GetVehicleModel(vData[VehicleData::vehicleid]);
    new Float:modelSpeed;
    GetModelHandlingFloat(modelid, HANDL_TR_FMAXVELOCITY, modelSpeed);
    SetVehicleHandlingFloat(
        vData[VehicleData::vehicleid], 
        HANDL_TR_FMAXVELOCITY, 
        modelSpeed*Vehicle::engines[engineType][VehicleHandling::top_speed]
    );
    new Float:modelAcc;
    GetModelHandlingFloat(modelid,HANDL_TR_FENGINEACCELERATION, modelAcc);
    SetVehicleHandlingFloat(
        vData[VehicleData::vehicleid],
        HANDL_TR_FENGINEACCELERATION,
        modelAcc*Vehicle::engines[engineType][VehicleHandling::acceleration]
    );
    new Float:ngnInertia;
    GetModelHandlingFloat(modelid, HANDL_TR_FENGINEINERTIA, ngnInertia);
    SetVehicleHandlingFloat(
        vData[VehicleData::vehicleid],
        HANDL_TR_FENGINEINERTIA,
        ngnInertia*Vehicle::engines[engineType][VehicleHandling::inertia]
    );
    return 1;
}


// Only Called when Vehicle Created
Vehicle::Save(const vData[Vehicle::e_Data]) {
    szMiscArray[0] = 0;
    DB::MakeInsertQuery("vehicle", Vehicle::Schema, sizeof(Vehicle::Schema));
    DB::PopulateInsertQuery(Vehicle::Schema, sizeof(Vehicle::Schema), vData);
    mysql_tquery(MainConn,szQuery);
    return 1;
}

Vehicle::Update(vData[Vehicle::e_Data]) {
    new vehParams = Vehicle::MakeParams(vData);
    new tsnow = gettime();
    new diff = tsnow - vData[VehicleData::lastUpdate];
    printf("Update diff: %i", diff);
    if(diff < 3) return 1; // Return if vehicle recently updated
    
    new vid = vData[VehicleData::vehicleid];
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
    vData[VehicleData::params] = vehParams;
    szMiscArray[0] = 0;
    DB::MakeUpdateQuery("vehicle", Vehicle::Schema, sizeof(Vehicle::Schema));
    DB::PopulateUpdateQuery(Vehicle::Schema, sizeof(Vehicle::Schema), vData);

    mysql_tquery(MainConn,szQuery);
    printf("Updating vehicle");
  
    vData[VehicleData::lastUpdate] = gettime();
    map_set_arr(Vehicle::list, vid, vData);
    return 1;
}

stock Vehicle::SaveComponent(vehicleid, slot) {
    //TODO: Save vehicle component feature
    return 1; 
}

Vehicle::MakeParams(const vData[Vehicle::e_Data]) {
  if(IsValidVehicle(vData[VehicleData::vehicleid])){
    new
    bool:engine, bool:lights, bool:alarm, bool:doors, bool:bonnet, bool:boot, bool:objective;
    GetVehicleParamsEx(vData[VehicleData::vehicleid],
                       engine,lights,alarm,doors,bonnet,boot,objective);
    new paramflag = 0;
    if(engine)    paramflag   = (paramflag  | VEH_PARAM_ENGINE);
    if(lights)    paramflag   = (paramflag  | VEH_PARAM_LIGHTS);
    if(alarm)     paramflag   = (paramflag  | VEH_PARAM_ALARM);
    if(doors)     paramflag   = (paramflag  | VEH_PARAM_DOORS);
    if(bonnet)    paramflag   = (paramflag  | VEH_PARAM_BONNET);
    if(boot)      paramflag   = (paramflag  | VEH_PARAM_BOOT);
    if(objective) paramflag   = (paramflag  | VEH_PARAM_OBJECTIVE);
    return paramflag;
  }
  return 0;
}

Vehicle::ApplyParams(const vData[Vehicle::e_Data]) {
    new bool:engine, bool:lights, bool:alarm, bool:doors, bool:bonnet, bool:boot, bool:objective;
    new paramflag = vData[VehicleData::params];
    engine    = bool:(paramflag & VEH_PARAM_ENGINE);
    lights    = bool:((paramflag & VEH_PARAM_LIGHTS) >>> 1);
    alarm     = bool:((paramflag & VEH_PARAM_ALARM) >>> 2);
    doors     = bool:((paramflag & VEH_PARAM_DOORS) >>> 3);
    bonnet    = bool:((paramflag & VEH_PARAM_BONNET) >>> 4);
    boot      = bool:((paramflag & VEH_PARAM_BOOT) >>> 5);
    objective = bool:((paramflag & VEH_PARAM_OBJECTIVE) >>> 6);
    SetVehicleParamsEx(vData[VehicleData::vehicleid],
                     engine,lights,alarm,doors,bonnet,boot,objective);
    return 1;
}

Vehicle::EMIT_EnterEvent(playerid) {
    new vid = GetPlayerVehicleID(playerid);
    new vData[Vehicle::e_Data];
    new hasValid = false;
    if(map_has_key(Vehicle::list, vid) && !hasValid) {
        map_get_arr(Vehicle::list, vid, vData);
        hasValid = true;
    }
    // if(map_has_key(FactionVehicle::list, vid) && !hasValid) {
    //     https://download.visualstudio.microsoft.com/download/pr/d4b71fac-a2fd-4516-ac58-100fb09d796a/e79d6c2a8040b59bf49c0d167ae70a7b/dotnet-sdk-5.0.408-linux-arm64.tar.gzprintf("This is Faction Vehicle");
    //     map_get_arr(FactionVehicle::list, vid, vData);
    //     hasValid = true;
    // }
    if(!hasValid) return 0;
    new noKey = false;
    if(vData[VehicleData::faction_id] > 0) {
        if(IsPlayerInFaction(playerid, eFaction:vData[VehicleData::faction_id])) {
            noKey = true;
        }
    }
    new Node:node = JsonObject();
    JsonSetInt(node, "serial", vData[VehicleData::serial]);
    JsonSetInt(node, "vid", vid);
    JsonSetFloat(node, "fuel", vData[VehicleData::fuel]);
    JsonSetFloat(node, "max_fuel", vData[VehicleData::max_fuel]);
    JsonSetInt(node, "odo_m", vData[VehicleData::odo_m]);
    JsonSetInt(node, "odo_km", vData[VehicleData::odo_km]);
    JsonSetInt(node, "key_attached", vData[VehicleData::key_attached]);
    JsonSetInt(node, "faction_id", vData[VehicleData::faction_id]);
    JsonSetInt(node, "no_key", noKey);
    new l_str[2048];
    JsonStringify(node,l_str);
   
    Logger_Dbg("vehicle", "vehicle enter", Logger_S("node", l_str));
    cef_emit_event(playerid, "veh:on_enter", CEFSTR(l_str));
    return 1;
}

Vehicle::EMIT_ExitEvent(playerid) {
    new Node:node_action = JsonObject();
    new l_str[512];
    JsonStringify(node_action,l_str);
    // printf("[DEBUG] player inventory \n%s", l_str);
    cef_emit_event(playerid, "veh:on_exit", CEFSTR(l_str));
    return 1; 
}

Vehicle::EMIT_Update(playerid) {
    new vid = GetPlayerVehicleID(playerid);
    new vData[Vehicle::e_Data];
    new hasValid = false;
    if(map_has_key(Vehicle::list, vid) && !hasValid) {
        map_get_arr(Vehicle::list, vid, vData);
        hasValid = true;
    }
    // if(map_has_key(FactionVehicle::list, vid) && !hasValid) {
    //     map_get_arr(FactionVehicle::list, vid, vData);
    //     hasValid = true;
    // }
    if(!hasValid) return 0;
    new noKey = false;
    if(vData[VehicleData::faction_id] > 0) {
        if(IsPlayerInFaction(playerid, eFaction:vData[VehicleData::faction_id])) {
            noKey = true;
        }
    }   
    new Node:node = JsonObject();
    JsonSetInt(node, "serial", vData[VehicleData::serial]);
    JsonSetInt(node, "vid", vid);
    JsonSetFloat(node, "fuel", vData[VehicleData::fuel]);
    JsonSetFloat(node, "max_fuel", vData[VehicleData::max_fuel]);
    JsonSetInt(node, "odo_m", vData[VehicleData::odo_m]);
    JsonSetInt(node, "odo_km", vData[VehicleData::odo_km]);
    JsonSetInt(node, "key_attached", vData[VehicleData::key_attached]);
    JsonSetInt(node, "faction_id", vData[VehicleData::faction_id]);
    JsonSetInt(node, "no_key", noKey);
    new l_str[2048];
    JsonStringify(node,l_str);
    
    cef_emit_event(playerid, "veh:update", CEFSTR(l_str));
    return 1;
}
// ==================== FUNCTION END =================================


// ======================= CALLBACKS ==============================
callback OnAllVehicleLoaded() {
    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields);
    
    Logger_Log("spawning vehicle", Logger_S("module", "vehicle"), Logger_I("count", rows));
    new vData[Vehicle::e_Data];
    if(rows > 0) {
        for(new i=0;i<rows;i++) {
            DB::LoadCacheSchema(i, Vehicle::Schema,sizeof(Vehicle::Schema), vData);
            new vid = CreateVehicle(
                vData[VehicleData::modelid],
                vData[VehicleData::spawnPos][0],
                vData[VehicleData::spawnPos][1],
                vData[VehicleData::spawnPos][2],
                vData[VehicleData::zAngle],
                vData[VehicleData::color][0],
                vData[VehicleData::color][1],
                -1 
            );
            SetVehicleNumberPlate(vid, vData[VehicleData::plateNumber]);
            SetVehicleToRespawn(vid);
            UpdateVehicleDamageStatus(vid,
                                        vData[VehicleData::dmgStat][VehicleDmgStat::panels],
                                        vData[VehicleData::dmgStat][VehicleDmgStat::doors],
                                        vData[VehicleData::dmgStat][VehicleDmgStat::lights],
                                        vData[VehicleData::dmgStat][VehicleDmgStat::tires]
            );
            SetVehicleHealth(vid, vData[VehicleData::health]);
            vData[VehicleData::vehicleid] = vid;
            vData[VehicleData::spawned] = true;
            Vehicle::applyEngine(vData);
            Vehicle::ApplyParams(vData);
            vData[VehicleData::lastUpdate] = gettime();
            printf("Spawned vehicle with id: %i", vid);
            Vehicle::DebugData(vData);
            map_add_arr(Vehicle::list, vid, vData);
        }
    }
    printf("[VEHICLE] All Vehicle Spawned");
}

callback VehicleOnPutKey(player_id, const arguments[]) {
    printf("[VehicleOnPutKey] playerid: %i, args: %s", player_id, arguments);
    new l_slot;
    if(!IsPlayerInAnyVehicle(player_id)) return 1;
    new vid = GetPlayerVehicleID(player_id);
    if(!map_has_key(Vehicle::list, vid)) return 1;
    
    if(sscanf(arguments,"i", l_slot)) return 1;
    
    new l_item[CharacterInv::eInfo];
    list_get_arr(PlayerInventoryList[player_id], l_slot, l_item);
    new keyID = l_item[CharacterInv::item][Item::id];
    if(TakePlayerItem(player_id, l_slot, 1) == -1) return 1;

    new vData[Vehicle::e_Data];
    map_get_arr(Vehicle::list, vid, vData);
    vData[VehicleData::key_attached] = keyID;
    map_set_arr(Vehicle::list, vid, vData);
    cef_emit_event(player_id, "veh:key_put");
    return 1; 
}


callback VehicleOnTakeKey(player_id, const arguments[]) {
    if(!IsPlayerInAnyVehicle(player_id)) return 1;
    new vid = GetPlayerVehicleID(player_id);
    if(!map_has_key(Vehicle::list, vid)) return 1;
    new vData[Vehicle::e_Data];
    map_get_arr(Vehicle::list, vid, vData);
    if(vData[VehicleData::key_attached] == 0) return 1;
    
    new l_item[Inv::eItem];
    l_item[Item::id] = vData[VehicleData::key_attached];
    l_item[Item::amount] = 1;
    l_item[Item::addon1] = vData[VehicleData::serial];
    vData[VehicleData::key_attached] = 0;
    map_set_arr(Vehicle::list, vid, vData);
    GivePlayerItem(player_id, l_item);
    GUI_Emit_InventoryItems(player_id);
    SetVehicleEngineState(vid, 0);
    SetVehicleLightsState(vid, 0);

    Vehicle::EMIT_Update(player_id);
    return 1;
}

callback VehicleOnOdoUpdate(player_id, const arguments[]) {
    if(!IsPlayerInAnyVehicle(player_id)) return 1;
    new vid = GetPlayerVehicleID(player_id);
    new hasValid = false;
    new vData[Vehicle::e_Data];
    if(map_has_key(Vehicle::list, vid) && !hasValid) {
        map_get_arr(Vehicle::list, vid, vData);
        hasValid = true;
    }
    // if(map_has_key(FactionVehicle::list, vid) && !hasValid) {
    //     map_get_arr(FactionVehicle::list, vid, vData);
    //     hasValid = true;
    // }
    if(!hasValid) return 0;
    new odo_km, odo_m;
    if(sscanf(arguments, "ii", odo_km, odo_m)) return 1;
    vData[VehicleData::odo_km] = odo_km;
    vData[VehicleData::odo_m] = odo_m;

    
    // if(vData[VehicleData::faction_id] > 0) {
    //     map_set_arr(FactionVehicle::list,vid,vData);
    // } else {
    // }
    
    map_set_arr(Vehicle::list,vid,vData);
    Vehicle::EMIT_Update(player_id);
    return 1; 
}

callback EngineTick() {
    for_map(i : Vehicle::list) {
        if(!iter_valid(i)) continue;
        new vData[Vehicle::e_Data];
        new bool:isDirty = false;
        iter_get_arr_safe(i, vData);
        if(!vData[VehicleData::spawned]) continue;
        new vid = vData[VehicleData::vehicleid];
        if(IsEngineOn(vid)) {
            new Float: vehSpeed = GetVehicleSpeed(vid);
            if(vehSpeed < 0.0001) {
                vehSpeed = 1.0;
            }
            new Float:fuelConsumption = vehSpeed / 1000.0;
            vData[VehicleData::fuel] -= fuelConsumption;
            isDirty = true;

            if(vData[VehicleData::fuel] < 0.0) {
                vData[VehicleData::fuel] = 0;
                SetVehicleEngineState(vid, 0);
            }
        }

        if(isDirty)  {
            iter_set_arr(i, vData);
        }
    }
    
    // for_map(i : FactionVehicle::list) {
    //     new vData[Vehicle::e_Data];
    //     new bool:isDirty = false;
    //     iter_get_arr_safe(i, vData);
    //     if(!vData[VehicleData::spawned]) continue;
    //     new vid = vData[VehicleData::vehicleid];
    //     if(IsEngineOn(vid)) {
    //         new Float: vehSpeed = GetVehicleSpeed(vid);
    //         if(vehSpeed < 0.0001) {
    //             vehSpeed = 1.0;
    //         }
    //         new Float:fuelConsumption = vehSpeed / 1000.0;
    //         vData[VehicleData::fuel] -= fuelConsumption;
    //         isDirty = true;
    //
    //         if(vData[VehicleData::fuel] < 0.0) {
    //             vData[VehicleData::fuel] = 0;
    //             SetVehicleEngineState(vid, 0);
    //         }
    //     }
    //
    //     if(isDirty)  {
    //         iter_set_arr(i, vData);
    //     }
    // }
    return 1;
}

callback OnGetLastStorageID() {
    new rows;
    new fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields);
    if(rows > 0) {
        new lastid;
        cache_get_value_name_int(0, "id", lastid);
        VehicleStorage::LastItemID = lastid;
    } else {
        VehicleStorage::LastItemID = 0;
    }

    printf("[VEHICLE STORAGE] LAST ID: %i", VehicleStorage::LastItemID);
    return 1;
}

// =========================== CALLBACKS END ================================

// UTILS 
Vehicle::Redis_EventValidate(characterId, const cbstr[]) {
    printf("Character ID: %i", characterId);
    new pid = INVALID_PLAYER_ID;
    for(new i=0;i<MAX_PLAYERS;i++) {
        if(CharacterInfo[i][CharacterInfo::id] == characterId) {
            pid = i;
        }
    }
    if(pid == INVALID_PLAYER_ID || !IsPlayerConnected(pid)) {
        new Node:redis_event = JsonObject();
        JsonSetString(redis_event, "event", sprintf("%s_%i",cbstr, characterId));
        new Node:payload = JsonObject();
        JsonSetBool(payload, "success", false);
        JsonSetString(payload, "msg", sprintf("Player is not logged in."));
        
        JsonSetObject(redis_event, "data", payload);
        szRedisEvent[0] = 0;
        JsonStringify(redis_event,szRedisEvent);
        Redis_Publish(redisClientPubSub, "frm.pwn", szRedisEvent);
        return INVALID_PLAYER_ID;
    }
    return pid;
}

Vehicle::DebugData(const vData[Vehicle::e_Data]) {
    Logger_Dbg("vehicle", "vehicle data",
               Logger_I("id", vData[VehicleData::id]),
               Logger_I("vid", vData[VehicleData::vehicleid]),
               Logger_I("model_id", vData[VehicleData::modelid]),
               Logger_F("fuel", vData[VehicleData::fuel]),
               Logger_F("max_fuel", vData[VehicleData::max_fuel]),
               Logger_F("health", vData[VehicleData::health]),
               Logger_F("spawn_x", vData[VehicleData::spawnPos][X]),
               Logger_F("spawn_y", vData[VehicleData::spawnPos][Y]),
               Logger_F("spawn_z", vData[VehicleData::spawnPos][Z]),
               Logger_I("color1", vData[VehicleData::color][X]),
               Logger_I("color2", vData[VehicleData::color][Y]),
               Logger_I("odo_km", vData[VehicleData::odo_km]),
               Logger_I("odo_m", vData[VehicleData::odo_m]),
               Logger_I("serial", vData[VehicleData::serial]),
               Logger_I("faction_id", vData[VehicleData::faction_id])
               );
    return 1;
}
