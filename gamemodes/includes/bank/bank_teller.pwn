#include <pp-hooks>
hook ret OnPlayerEnterDynArea(&ret, playerid, areaid) {
    new l_teller[BankTeller::e_Teller];
    new l_tellerId = BankTeller::GetIndexFromAreaId(areaid, l_teller);
    if (l_tellerId == -1) {
        return 0;
    }
    
    if(!l_teller[BankTeller::used] && !BankTeller::IsUsingTeller(playerid)) {
        BankTeller::PlayerUse(playerid, l_tellerId, l_teller);
    } else {
        new str[128];
        format(str, sizeof(str), "Teller Sedang digunakan player lain");
        EMIT_PlayerSystemChat(playerid, -1, str);
    }
    return 1;
}

public OnGotRedisEvent(const eventName[], Node:data) {
    printf("[REDIS HANDLER Bank] Event: %s",eventName);
    if(strcmp(eventName, "bank_addmoney") == 0) { 
        new characterId;
        JsonGetInt(data, "cid",characterId);
        new pid = BankTeller::Redis_EventValidate(characterId, "bank_on_addmoney");
        if(pid == INVALID_PLAYER_ID) return 1;
        new wd_amount;
        JsonGetInt(data, "amount", wd_amount);
        new ret = Character::GiveCash(pid, wd_amount);
        new Node:redis_event = JsonObject();
        JsonSetString(redis_event, "event", sprintf("bank_on_addmoney_%i",characterId));
        new Node:payload = JsonObject();
        if(ret == 1) {
            JsonSetBool(payload, "success", true);
            JsonSetString(payload, "msg", sprintf("Money has been given"));  
        } else {
            JsonSetBool(payload, "success", false);
            JsonSetString(payload, "msg", sprintf("Failed to give player money"));
        }
        JsonSetObject(redis_event, "data", payload);
        szRedisEvent[0] = 0;
        JsonStringify(redis_event,szRedisEvent);
        Redis_Publish(redisClientPubSub, "frm.pwn", szRedisEvent);
        return 1; 
    }
    if(strcmp(eventName, "bank_takemoney") == 0) {
        new characterId;
        JsonGetInt(data, "cid", characterId);
        new pid = BankTeller::Redis_EventValidate(characterId, "bank_on_takemoney");
        if(pid == INVALID_PLAYER_ID) return 1;
        new dp_amount;
        JsonGetInt(data, "amount", dp_amount);
        new ret = Character::TakeCash(pid, dp_amount);
        new Node:redis_event = JsonObject();
        JsonSetString(redis_event, "event", sprintf("bank_on_takemoney_%i",characterId));
        new Node:payload = JsonObject();
        if(ret == 1) {
            JsonSetBool(payload, "success", true);
            JsonSetString(payload, "msg", sprintf("Money has been taken"));
        } else {
            JsonSetBool(payload, "success", false);
            JsonSetString(payload, "msg", sprintf("Failed to take player money"));
        }
        JsonSetObject(redis_event, "data", payload);
        szRedisEvent[0] = 0;
        JsonStringify(redis_event, szRedisEvent);
        Redis_Publish(redisClientPubSub, "frm.pwn", szRedisEvent);
        return 1;
    }
    if(strcmp(eventName, "bank_transfer") == 0) {
        new characterId;
        JsonGetInt(data, "cid", characterId);
        new ret;
        new fromName[MAX_PLAYER_NAME];
        ret = JsonGetString(data, "from", fromName);
        if(ret) {
            printf("BANK_TRANSFER EVENT FAILED to GET NAME");
            return 1;
        }
        new amount;
        JsonGetInt(data, "amount", amount);
        new pid = BankTeller::Redis_EventValidate(characterId, "bank_on_transfer_notify");
        if(pid == INVALID_PLAYER_ID) return 1;
        new Node:node = JsonObject();
        JsonSetString(node, "type", sprintf("transfer"));
        JsonSetString(node, "msg", sprintf("Kamu mendapatkan transfer sebesar $%i dari %s", amount, fromName));
        new l_str[2048];
        JsonStringify(node,l_str);
        cef_emit_event(pid, "notify:banks", CEFSTR(l_str));
        return 1;
    }
#if defined Bank_OnGotRedisEvent
  return Bank_OnGotRedisEvent(eventName,data);
#else
  return 1;
#endif
}

#if defined _ALS_OnGotRedisEvent
#undef OnGotRedisEvent
#else
#define _ALS_OnGotRedisEvent
#endif
#define OnGotRedisEvent Bank_OnGotRedisEvent
#if defined Bank_OnGotRedisEvent
forward Bank_OnGotRedisEvent(const eventName[], Node:data);
#endif


BankTeller::Init() {
    BankTeller::teller_list = list_new();
    BankTeller::LoadAll();
    return 1;
}

BankTeller::deInit() {
    list_delete(BankTeller::teller_list);
    return 1;
}

BankTeller::LoadAll() {
    mysql_tquery(MainConn, "SELECT * from `bank_teller`", "BankTellerOnLoadAll");
    return 1;
}

callback BankTellerOnLoadAll() {
    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields);

    new l_teller[BankTeller::e_Teller];
    if (rows > 0) {
        for (new i = 0; i < rows; i++) {
            DB::LoadCacheSchema(i, BankTeller::Schema, sizeof(BankTeller::Schema), l_teller);
            BankTeller::Spawn(l_teller);
        }
    }
    printf("[BANK TELLER] Loaded %i teller", rows);
    return 1;
}


callback CEFBankTellerOnQuit(player_id, const arguments[]) {
    if(BankTeller::IsUsingTeller(player_id)) {
        new teller_id = BankTeller::GetTellerID(player_id);
        if(teller_id == -1) return 1;
        BankTeller::SetUsingTeller(player_id, false);
        BankTeller::SetTellerID(player_id, -1);
        new l_teller[BankTeller::e_Teller];
        list_get_arr(BankTeller::teller_list, teller_id, l_teller);
        new str[128];
        format(str,sizeof(str), "Bank Teller\nSedang Melayani: NONE");
        UpdateDynamic3DTextLabelText(l_teller[BankTeller::textId], -1, str);
        l_teller[BankTeller::used] = false;
        list_set_arr(BankTeller::teller_list, teller_id, l_teller);
        cef_focus_browser(player_id, GET_BROWSER_ID(player_id), false);
    }
    return 0;
}

BankTeller::GetIndexFromAreaId(areaId, p_teller[BankTeller::e_Teller]) {
    new gotIndex = -1;
    for_list(i : BankTeller::teller_list) {
        gotIndex++;
        iter_get_arr(i, p_teller);
        if (p_teller[BankTeller::areaId] == areaId) {
            printf("Teller Area ID %i", p_teller[BankTeller::areaId]);
            return gotIndex;
        }
    }
    return -1;
}

BankTeller::Save(const p_teller[BankTeller::e_Teller]) {
    DB::MakeInsertQuery("bank_teller", BankTeller::Schema, sizeof(BankTeller::Schema), true);
    DB::PopulateInsertQuery(BankTeller::Schema, sizeof(BankTeller::Schema), p_teller, true);
    mysql_tquery(MainConn, szQuery);
    // mysql_tquery(MainConn, 
    //     sprintf("INSERT INTO `bank_teller` \
    //         (`id`,`posX`,`posY`,`posZ`, `interior`, `vw`) VALUES \
    //         ('%i','%f','%f','%f', '%i', '%i')",
    //             p_teller[BankTeller::id],
    //             p_teller[BankTeller::pos][X],
    //             p_teller[BankTeller::pos][Y],
    //             p_teller[BankTeller::pos][Z],
    //             p_teller[BankTeller::intId],
    //             p_teller[BankTeller::vwId]
    // ));
    return 1;
}

BankTeller::Create(const Float:pos[3], interior, vw) {
    new l_teller[BankTeller::e_Teller];
    l_teller[BankTeller::id] = list_size(BankTeller::teller_list) + 1;
    l_teller[BankTeller::pos][X] = pos[X];
    l_teller[BankTeller::pos][Y] = pos[Y];
    l_teller[BankTeller::pos][Z] = pos[Z];
  
    l_teller[BankTeller::intId] = interior;
    l_teller[BankTeller::vwId] = vw;
    l_teller[BankTeller::used] = false; 

    l_teller[BankTeller::areaId] = CreateDynamicCircle(
        l_teller[BankTeller::pos][X], l_teller[BankTeller::pos][Y], 1.0);
    new str[128];
    format(str,sizeof(str), "Teller Bank\nSedang Melayani: NONE");
    l_teller[BankTeller::textId] = CreateDynamic3DTextLabel(
        str, -1, 
        l_teller[BankTeller::pos][X], 
        l_teller[BankTeller::pos][Y],
        l_teller[BankTeller::pos][Z], 10.0, .testlos=1);
    l_teller[BankTeller::pickupId] = CreateDynamicPickup(
        1318, 1, 
        l_teller[BankTeller::pos][X],
        l_teller[BankTeller::pos][Y],
        l_teller[BankTeller::pos][Z]
    );
    
    BankTeller::Save(l_teller);
    list_add_arr(BankTeller::teller_list, l_teller);
    return 1;
}

BankTeller::Spawn(p_teller[BankTeller::e_Teller]) { 
    p_teller[BankTeller::areaId] = CreateDynamicCircle(
        p_teller[BankTeller::pos][X], p_teller[BankTeller::pos][Y], 1.0);

    new str[128];
    format(str, sizeof(str), "Teller Bank\nSedang Melayani: NONE");
    p_teller[BankTeller::textId] = CreateDynamic3DTextLabel(
        str, -1, 
        p_teller[BankTeller::pos][X], 
        p_teller[BankTeller::pos][Y],
        p_teller[BankTeller::pos][Z], 30.0);
    p_teller[BankTeller::pickupId] = CreateDynamicPickup(
        1318, 1, 
        p_teller[BankTeller::pos][X],
        p_teller[BankTeller::pos][Y],
        p_teller[BankTeller::pos][Z]
    );
    
    list_add_arr(BankTeller::teller_list, p_teller);
    return 1; 
}

BankTeller::PlayerUse(playerid, teller_id, p_teller[BankTeller::e_Teller]) {
    BankTeller::SetUsingTeller(playerid, true);
    BankTeller::SetTellerID(playerid, teller_id);
    cef_emit_event(playerid, "bank:teller_access");
    cef_focus_browser(playerid, GET_BROWSER_ID(playerid), true);

    new str[128];
    format(str,sizeof(str), "Bank Teller\nSedang Melayani: %s", GetName(playerid));
    UpdateDynamic3DTextLabelText(p_teller[BankTeller::textId], -1, str);
    p_teller[BankTeller::used] = true;
    list_set_arr(BankTeller::teller_list, teller_id, p_teller);
    return 1;
}

#if defined DEBUG_MODE
CMD:create_teller(playerid, params[]) {
    new Float:pPos[3];
    new interior = GetPlayerInterior(playerid);
    new vw = GetPlayerVirtualWorld(playerid);
    GetPlayerPos(playerid, VEC3_UNWRAP(pPos));
    BankTeller::Create(pPos, interior, vw);
    return 1;
}
#endif


BankTeller::Redis_EventValidate(characterId, const cbstr[]) {
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
