#include <pp-hooks>


hook OnPlayerConnect(playerid) {
    // printf("[CHAR] OnPlayerConnect\n");
    if(!IsPlayerNPC(playerid)) {
        isSpawned[playerid] = false;
        invInitialized[playerid] = false;
        isPlayerUIInteractable[playerid] = false;
        SetSpawnInfo(playerid, NO_TEAM,	123,
                     823.2658,-1362.3666,-0.5078,317.7056,
                     0,0,	0,0,	0,0);
        ResetPlayerCharacterInfo(playerid);
        ResetCharacterData(playerid);
        ResetCharacterBuff(playerid);
    }
}

hook OnPlayerDisconnect(playerid, reason) {
    // printf("[CHAR] OnPlayerDisconnect");
    if(!IsPlayerNPC(playerid)) {
        // SaveAllPlayerInventory(playerid);

        cef_destroy_browser(playerid, GET_BROWSER_ID(playerid));
        SavePlayer(playerid);	
        ResetCharacterData(playerid);
        
        if( isSpawned[playerid] ) {
            new Node:redis_event = JsonObject();
            JsonSetString(redis_event, "event", sprintf("OnPlayerDisconnect"));
            new Node:payload = JsonObject();
            JsonSetInt(payload, "cid", CharacterInfo[playerid][CharacterInfo::id]);
            JsonSetInt(payload, "pid", playerid);
            JsonSetObject(redis_event, "data", payload);
            szRedisEvent[0] = 0;
            JsonStringify(redis_event,szRedisEvent);
            Redis_Publish(redisClientPubSub, "frm.pwn", szRedisEvent);    
        }
    }
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(PRESSED(KEY_FIRE)) {
        if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_SMOKE_CIGGY) {
            Buff::GivePlayerBuff(playerid, BuffType::JOINT, 10, 1);
            Character::SetJointLeft(playerid, Character::JointLeft(playerid) - 1);
            if(Character::JointLeft(playerid) == 0) {
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
                EMIT_PlayerSystemChat(playerid, -1, "CIGARETTE: Rokokmu telah habis.");
            }
        }
    }
}



// CALLBACKS
public OnCEFGUIPlayCharacter(playerid, const arguments[]) {
    new characterId;
    if(sscanf(arguments, "i", characterId)) {
        return printf("[DEBUG] CEFGUI: Failed to get character ID");
    }
    printf("Player %d wants to player character %i", playerid, characterId);

    CharacterInfo[playerid][CharacterInfo::id] = characterId;
    new ORM:ormid = CharacterInfo[playerid][CharacterInfo::ORM_ID] = orm_create("character");
    orm_addvar_int(ormid, CharacterInfo[playerid][CharacterInfo::id], "id");
    orm_addvar_string(ormid, CharacterInfo[playerid][CharacterInfo::firstName], 10, "first_name");
    orm_addvar_string(ormid, CharacterInfo[playerid][CharacterInfo::lastName], 10, "last_name");
    orm_addvar_int(ormid, CharacterInfo[playerid][CharacterInfo::isEverSpawn], "is_ever_spawn");
    orm_addvar_int(ormid, CharacterInfo[playerid][CharacterInfo::gender], "gender");
    orm_addvar_int(ormid, CharacterInfo[playerid][CharacterInfo::accountId], "userId");
    orm_addvar_int(ormid, CharacterInfo[playerid][CharacterInfo::dataId], "dataId");
    orm_setkey(ormid, "id");
    new ret = orm_select(ormid, "OnCharacterLoaded", "d", playerid);
    if(ret) {
        return 1;
    } else {
        printf("Failed to load character");
    }
    return 1;
}

public OnCharacterLoaded(playerid) {
    new rename[MAX_PLAYER_NAME+1];
    format(rename,sizeof(rename), "%s_%s",
        CharacterInfo[playerid][CharacterInfo::firstName],
        CharacterInfo[playerid][CharacterInfo::lastName]
    );
    printf("Loaded Character %s", 
        rename);
    SetPlayerName(playerid, rename);
    cef_emit_event(playerid, "udata:setplayername", CEFSTR(rename));

    CharacterData[playerid][p_ID] = CharacterInfo[playerid][CharacterInfo::dataId];
    printf("[DEBUG] Character id %d", CharacterData[playerid][p_ID]);
    new ORM:ormid = CharacterData[playerid][ORM_ID] = orm_create("character_data", MainConn);
    orm_addvar_int(ormid, CharacterData[playerid][p_ID], "id");
    orm_addvar_int(ormid, CharacterData[playerid][p_level], "level");
    orm_addvar_int(ormid, CharacterData[playerid][p_cash], "cash");
    orm_addvar_int(ormid, CharacterData[playerid][p_exp], "exp");
    orm_addvar_int(ormid, CharacterData[playerid][p_playtime], "playtime");

    orm_addvar_float(ormid, CharacterData[playerid][p_health], "health");
    orm_addvar_float(ormid, CharacterData[playerid][p_armor], "armor");
    orm_addvar_int(ormid, CharacterData[playerid][p_skinId], "skinId");

    // orm_addvar_int(ormid, CharacterData[playerid][p_statStr], "stat_str");
    // orm_addvar_int(ormid, CharacterData[playerid][p_statInt], "stat_int");
    orm_addvar_int(ormid, CharacterData[playerid][p_hunger], "hunger");
    orm_addvar_int(ormid, CharacterData[playerid][p_stamina], "stamina");
    
    orm_addvar_int(ormid, CharacterData[playerid][p_injured], "injured");
    orm_addvar_int(ormid, CharacterData[playerid][p_injured_time], "injured_time");

    orm_addvar_int(ormid, CharacterData[playerid][p_has_id], "has_id");

    orm_addvar_int(ormid, CharacterData[playerid][p_inv_weight], "inv_weight");

    orm_addvar_float(ormid, CharacterData[playerid][p_posX], "posX");
    orm_addvar_float(ormid, CharacterData[playerid][p_posY], "posY");
    orm_addvar_float(ormid, CharacterData[playerid][p_posZ], "posZ");
    orm_addvar_float(ormid, CharacterData[playerid][p_angle], "angle");
    orm_addvar_int(ormid, CharacterData[playerid][p_interior], "interior");
    orm_addvar_int(ormid, CharacterData[playerid][p_vw], "vw");
    orm_addvar_int(ormid, CharacterData[playerid][p_sweeper_timer], "job_sweeper_timer");
    orm_addvar_int(ormid, CharacterData[playerid][p_driversbus_timer], "job_driverbus_timer");

    orm_addvar_int(ormid, CharacterData[playerid][p_faction], "faction");
    orm_addvar_int(ormid, CharacterData[playerid][p_faction_level], "faction_level");

    orm_addvar_int(ormid, CharacterData[playerid][p_jailed], "jailed");
    orm_addvar_int(ormid, CharacterData[playerid][p_jail_time], "jail_time");
    orm_addvar_int(ormid, CharacterData[playerid][p_jail_type], "jail_type");

    orm_addvar_int(ormid, Weapon::player_use[playerid][Weapon::active], "wep_use_active");
    orm_addvar_int(ormid, Weapon::player_use[playerid][Weapon::id], "wep_use_id");
    orm_addvar_int(ormid, Weapon::player_use[playerid][Weapon::current_ammo], "wep_use_ammo");
    orm_addvar_int(ormid, Weapon::player_use[playerid][Weapon::ext], "wep_use_ext");

    orm_setkey(ormid, "id");
    new ret = orm_select(ormid, "OnCharacterDataLoaded", "d", playerid);
    if(ret) {
    } else {
        printf("failed to load character data");
    }
}

public OnCharacterDataLoaded(playerid) {
    invInitialized[playerid] = false;
    printf("Success loaded character data");
  
    SetPlayerColor(playerid, 0xFFFFFFFF);
    if(!CharacterInfo[playerid][CharacterInfo::isEverSpawn]) {
        printf("New character setup info");
        SetPlayerPos(playerid,
            svSpawnPos[TRAIN_STATION_1][se_posX],
            svSpawnPos[TRAIN_STATION_1][se_posY],
            svSpawnPos[TRAIN_STATION_1][se_posZ]
        );
        SetPlayerFacingAngle(playerid, svSpawnPos[TRAIN_STATION_1][se_angle]);
        SetCameraBehindPlayer(playerid);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        isSpawned[playerid] = true;
        authSuccess[playerid] = true;
        SetPlayerSkin(playerid, CharacterData[playerid][p_skinId]);
        CharacterInfo[playerid][CharacterInfo::isEverSpawn] = true;
        cef_emit_event(playerid, "login:spawned");
        cef_focus_browser(playerid, GET_BROWSER_ID(playerid), false);
        invInitialized[playerid] = false;
        PlayerInventoryWeight[playerid] = 0;
        PlayerMaximumWeight[playerid] = 10000;
        wait_ms(3000);
        TogglePlayerControllable(playerid, true);
        Character::GiveCash(playerid, 2500);
    } else { 
        printf("Already played character");
        SetPlayerPos(playerid,
            CharacterData[playerid][p_posX],
            CharacterData[playerid][p_posY],
            CharacterData[playerid][p_posZ]
        );
        SetPlayerFacingAngle(playerid, CharacterData[playerid][p_angle]);
        SetPlayerInterior(playerid,CharacterData[playerid][p_interior]);
        SetPlayerVirtualWorld(playerid, CharacterData[playerid][p_vw]);
        SetPlayerSkin(playerid, CharacterData[playerid][p_skinId]);
        SetPlayerHealth(playerid, CharacterData[playerid][p_health]);
        SetPlayerArmour(playerid, CharacterData[playerid][p_armor]);
        
        SetCameraBehindPlayer(playerid);
        isSpawned[playerid] = true;
        authSuccess[playerid] = true;
        cef_emit_event(playerid, "login:spawned");
        cef_focus_browser(playerid, GET_BROWSER_ID(playerid), false);
        wait_ms(3000);
        TogglePlayerControllable(playerid, true);
        
        if(CharacterData[playerid][p_injured]) {
            Character::applyDeath(playerid);
        }
        if(CharacterData[playerid][p_jailed]) {
            JailSystem::JailPlayer(playerid, JailSystem::e_Type:CharacterData[playerid][p_jail_type], CharacterData[playerid][p_jail_time]);
        }
        
        await LoadPlayerInventory(playerid);
    }
    new Node:redis_event = JsonObject();
    JsonSetString(redis_event, "event", sprintf("OnPlayerConnect"));
    new Node:payload = JsonObject();
    JsonSetInt(payload, "cid", CharacterInfo[playerid][CharacterInfo::id]);
    JsonSetInt(payload, "pid", playerid);
    JsonSetObject(redis_event, "data", payload);
    szRedisEvent[0] = 0;
    JsonStringify(redis_event,szRedisEvent);
    Redis_Publish(redisClientPubSub, "frm.pwn", szRedisEvent);
}
// END CALLBACKS

// FUNCTION FUNCTIONS
ResetPlayerCharacterInfo(playerid) {
    CharacterInfo[playerid][CharacterInfo::id] = 0;
    CharacterInfo[playerid][CharacterInfo::firstName][0] = 0;
    CharacterInfo[playerid][CharacterInfo::lastName][0] = 0;
    CharacterInfo[playerid][CharacterInfo::isEverSpawn] = false;
    CharacterInfo[playerid][CharacterInfo::accountId] = 0;
    CharacterInfo[playerid][CharacterInfo::dataId] = 0;
    return 1;
}

SavePlayerCharacterInfo(playerid) {
    if(CharacterInfo[playerid][CharacterInfo::id] == 0)
        return 1;
    orm_update(CharacterInfo[playerid][CharacterInfo::ORM_ID]);
    return 1;
}


ResetCharacterData(playerid) {
    CharacterData[playerid][p_ID] = 0;
    CharacterData[playerid][p_level] = 1;
    CharacterData[playerid][p_exp] = 0;
    CharacterData[playerid][p_playtime] = 0;
    CharacterData[playerid][p_cash] = 0;
    CharacterData[playerid][p_health] = 100.0;
    CharacterData[playerid][p_armor] = 0.0;
    CharacterData[playerid][p_skinId] = 23;

    // CharacterData[playerid][p_statStr] = 0;
    // CharacterData[playerid][p_statInt] = 0;
    CharacterData[playerid][p_hunger] = 100;
    CharacterData[playerid][p_stamina] = 100;
    CharacterData[playerid][p_injured] = false;
    CharacterData[playerid][p_injured_time] = 0;
    
    CharacterData[playerid][p_has_id] = false;

    CharacterData[playerid][p_inv_weight] = 10000;

    CharacterData[playerid][p_posX] = svSpawnPos[TRAIN_STATION_1][se_posX];
    CharacterData[playerid][p_posY] = svSpawnPos[TRAIN_STATION_1][se_posY];
    CharacterData[playerid][p_posZ] = svSpawnPos[TRAIN_STATION_1][se_posZ];
    CharacterData[playerid][p_angle] = svSpawnPos[TRAIN_STATION_1][se_angle];
    CharacterData[playerid][p_interior] = 0;
    CharacterData[playerid][p_vw] = 0;
    CharacterData[playerid][p_sweeper_timer] = 0;
    CharacterData[playerid][p_driversbus_timer] = 0;

    CharacterData[playerid][p_jailed] = false;
    CharacterData[playerid][p_jail_time] = 0;
    CharacterData[playerid][p_jail_type] = 0;
    return 1;
}

SaveCharacterData(playerid) {
    if(CharacterData[playerid][p_ID] == 0)
        return 1;
    GetPlayerPos(playerid,
                 CharacterData[playerid][p_posX],
                 CharacterData[playerid][p_posY],
                 CharacterData[playerid][p_posZ]
                 );
    GetPlayerFacingAngle(playerid, CharacterData[playerid][p_angle]);
    GetPlayerHealth(playerid, CharacterData[playerid][p_health]);
    GetPlayerArmour(playerid, CharacterData[playerid][p_armor]);
    CharacterData[playerid][p_interior] = GetPlayerInterior(playerid);
    CharacterData[playerid][p_vw] = GetPlayerVirtualWorld(playerid);

    orm_update(CharacterData[playerid][ORM_ID]);
    return 1;
}

SavePlayer(playerid) {
    SavePlayerCharacterInfo(playerid);
    SaveCharacterData(playerid);
}

TickPlayTime() {
    foreach(new i: Player) {
        if(!isSpawned[i]) continue;
        CharacterData[i][p_playtime] += 1;
    }
}

// Hunger System
ReduceHunger() {
    foreach(new i : Player) {
        if(!isSpawned[i]) continue;

        if(Buff::isBuffActive(i,BuffType::FOOD) > -1) continue;

        if(CharacterData[i][p_hunger] > 0) {
            CharacterData[i][p_hunger] -= 1;
        }
        if(CharacterData[i][p_hunger] == 0) {
            // TODO: Do something when hunger bar reach 0
        }
    }
}

GivePlayerEXP(playerid, got_exp) {
    new currLevel = CharacterData[playerid][p_level];
    CharacterData[playerid][p_exp] += got_exp;

    new levelUpTreshold = currLevel * CHARACTER_LEVEL_MULT;

    if(CharacterData[playerid][p_exp] > levelUpTreshold) {
        CharacterData[playerid][p_level] += 1;
        new expDiff = CharacterData[playerid][p_exp] - levelUpTreshold;
        CharacterData[playerid][p_exp] = expDiff;
        new str[128];
        format(str,sizeof(str), "[LEVEL UP] You've been leveled up to %i",CharacterData[playerid][p_level]);
        EMIT_PlayerSystemChat(playerid, -1, str);
    }
    return 1;
}

GUI_Emit_PlayerData(playerid) {
    if(IsPlayerNPC(playerid)) return 1;
    if(!IsPlayerConnected(playerid)) return 1;
    if(playerid == INVALID_PLAYER_ID) return 1;
    new Node:pdata_object = JsonObject();
    JsonSetInt(pdata_object, "hunger", CharacterData[playerid][p_hunger]);
    JsonSetInt(pdata_object, "stamina", CharacterData[playerid][p_stamina]);
    JsonSetInt(pdata_object, "level", CharacterData[playerid][p_level]);
    JsonSetInt(pdata_object, "exp", CharacterData[playerid][p_exp]);
    JsonSetInt(pdata_object, "injured", CharacterData[playerid][p_injured]);
    JsonSetInt(pdata_object, "injured_time", CharacterData[playerid][p_injured_time]);
    
    new l_wepId = Weapon::player_use[playerid][Weapon::id];
    JsonSetInt(pdata_object, "wep_use_active", Weapon::player_use[playerid][Weapon::active]);
    JsonSetInt(pdata_object, "wep_use_id", Weapon::list[l_wepId][Weapon::itemId]);
    JsonSetInt(pdata_object, "wep_use_ammo", Weapon::player_use[playerid][Weapon::current_ammo]);
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, CharacterData[playerid][p_cash]);
    new l_str[1028];
    JsonStringify(pdata_object,l_str);
    // printf("[DEBUG] player inventory \n%s", l_str);
    cef_emit_event(playerid, "pdata:update", CEFSTR(l_str));
    return 1;
}

Character::UpdateTools(playerid, tools_id, slot_index) {
    new Node:ptools_object = JsonObject();
    JsonSetInt(ptools_object, "usedTools", tools_id);
    JsonSetInt(ptools_object, "usedSlot", slot_index);

    Character::SetUsingTools(playerid, tools_id);
    Character::SetToolsSlot(playerid, slot_index);

    new l_str[512];
    JsonStringify(ptools_object,l_str);
    // printf("[DEBUG] player inventory \n%s", l_str);
    cef_emit_event(playerid, "ptools:updatetools", CEFSTR(l_str));
    return 1;
}

Character::applyDeath(playerid) {
    TogglePlayerControllable(playerid, false);
    wait_ms(100);
    SetPlayerCameraPos(playerid, 
                       CharacterData[playerid][p_posX],
                       CharacterData[playerid][p_posY],
                       CharacterData[playerid][p_posZ]+3.0);
    SetPlayerCameraLookAt(playerid, 
                          CharacterData[playerid][p_posX],
                          CharacterData[playerid][p_posY],
                          CharacterData[playerid][p_posZ]);
    ApplyAnimation(playerid, "CRACK", "crckidle2", 4.0, 0, 0, 0, 1, 0, 1); 
    DeathSystem::pushPlayer(playerid);
}

Character::RePosition(playerid) {
    SetPlayerPos(playerid, 
                 CharacterData[playerid][p_posX],
                 CharacterData[playerid][p_posY],
                 CharacterData[playerid][p_posZ]
                 );
    SetPlayerFacingAngle(playerid, CharacterData[playerid][p_angle]);
    return 1;
}

Character::Revive(playerid) {
    if(!CharacterData[playerid][p_injured]) return 0;
    CharacterData[playerid][p_injured] = false;
    CharacterData[playerid][p_health] = 20.0;
    Character::SetHealth(playerid, 20.0);
    TogglePlayerControllable(playerid, true);
    ClearAnimations(playerid);
    SetCameraBehindPlayer(playerid);
    DeathSystem::removePlayer(playerid);
    return 1;
}

Character::GiveCash(playerid, amount) {
    CharacterData[playerid][p_cash] += amount;
    new cMoney = GetPlayerMoney(playerid);
    new diff = CharacterData[playerid][p_cash] - cMoney;
    GivePlayerMoney(playerid, diff);
    // TODO: do someting ? Logging or else
    return 1;
}

Character::TakeCash(playerid, amount) {
    if(CharacterData[playerid][p_cash] < amount) {
        return -1;
    }
    CharacterData[playerid][p_cash] -= amount;
    new cMoney = GetPlayerMoney(playerid);
    new diff = CharacterData[playerid][p_cash] - cMoney;
    GivePlayerMoney(playerid, diff);
    return 1;
}

Float:Character::GetHealth(playerid) {
    return CharacterData[playerid][p_health];
}

Character::SetHealth(playerid, Float:amount) {
    CharacterData[playerid][p_health] = amount;
    SetPlayerHealth(playerid, amount);
    return 1;
}
Character::ResetHealth(playerid) {
    SetPlayerHealth(playerid, CharacterData[playerid][p_health]);
}

Character::HealthCheck(playerid) {
    if(!IsPlayerConnected(playerid)) return 0;
    new Float:checker = CharacterData[playerid][p_health]-1.0;
    SetPlayerHealth(playerid, checker);
    await task_ms(500);
    new Float:l_pHealth;
    GetPlayerHealth(playerid, l_pHealth);
    Logger_Log("player health check", Logger_I("playerid",playerid), Logger_F("health", l_pHealth), Logger_F("checker", checker));
    if(l_pHealth != checker) {
        // TODO: Send Admin notification
        Logger_Log("player health anomaly", Logger_I("playerid", playerid), Logger_F("p_health", l_pHealth), Logger_F("checker", checker));
    }
    Character::ResetHealth(playerid);
    return 1;
}

Character::SetArmor(playerid, Float:amount) {
    CharacterData[playerid][p_armor] = amount;
    SetPlayerArmour(playerid, amount);
    return 1;
}

Character::ResetArmor(playerid) {
    SetPlayerArmour(playerid, CharacterData[playerid][p_armor]);
    return 1;
}

Character::TakeDamage(playerid, Float:amount) {
    Character::SetHealth(playerid, Character::GetHealth(playerid) = amount);
    return 1;
}
// END FUNCTION
