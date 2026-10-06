#include <pp-hooks>

hook OnPlayerConnect(playerid) {
    Logger_Log("Player connected", Logger_S("module", "items"), Logger_I("playerid", playerid));
    PlayerInventoryList[playerid] = list_new();
}

hook OnPlayerDisconnect(playerid) {
    list_delete_deep(PlayerInventoryList[playerid]);
}

callback InventoryCheckTick() {
    foreach(new p : Player) {
        if(!IsPlayerConnected(p)) continue;
        new updated = CharacterInv::UpdateDB(p);
        if(updated) {
            return 1; // wait next tick for next players
        }
    }
    return 1;
}

// ITEMS
LoadAllItemsDef(){ 
    map_itemDef = map_new();
    RequestJSON(
        httpClient,
        "all-items-pawn",
        HTTP_METHOD_GET,
        "OnGetListItems",
        .headers = RequestHeaders()
    );
}

public OnGetListItems(Request:id, E_HTTP_STATUS:status, Node:node) {
    task_set_result(task_req_item_def, true);
    new ret;
    new Node:items;
    new itemLength;
    ret = JsonGetArray(node, "items", items);
    if(ret) {
        printf("Failed to get item list %d", ret);
        return 1;
    }
    ret = JsonArrayLength(items, itemLength);
    if(ret){ 
        printf("Failed to get array length: %d", ret);
        return 1;
    }

    if(itemLength > 0) {
        Feat_ItemInitialized=true;
        Feat_ItemLoaded = itemLength;
    }

    if(!Feat_ItemInitialized) {
        printf("Cannot initialized Item System.");
        return 1;
    }

    for(new i;i<itemLength;i++){
        new Node:item;
        new l_itemDef[eItemDef];
        ret = JsonArrayObject(items, i, item);
        if(ret){ 
            return 1;
        }

        new l_itemId;
        ret = JsonGetInt(item, "id", l_itemId);
        if(ret) {
            return 1;
        }
        // mset(ItemID, i, l_itemId);
        l_itemDef[ItemDef::id] = l_itemId;

        new l_itemName[MAX_ITEMS_NAME]; 
        ret = JsonGetString(item, "name", l_itemName);
        if(ret) {
            printf("Error Getting item name %d", ret);
            return 1;
        }
        // msets(ItemName, l_itemId*MAX_ITEMS_NAME, l_itemName, true);
        memcpy(l_itemDef[ItemDef::name],l_itemName,0,MAX_ITEMS_NAME,MAX_ITEMS_NAME);

        new l_itemCat[MAX_ITEMS_NAME];
        ret = JsonGetString(item, "cat", l_itemCat);
        if(ret) {
            printf("Error getting item cat %d", ret);
            return 1;
        }
        memcpy(l_itemDef[ItemDef::cat],l_itemCat,0,MAX_ITEMS_NAME,MAX_ITEMS_NAME);

        new l_itemMaxAmount;
        ret = JsonGetInt(item, "max_amount", l_itemMaxAmount);
        if(ret) { 
            printf("Error getting item max_amount %s", l_itemName);
            return 1;
        }
        l_itemDef[ItemDef::max_amount] = l_itemMaxAmount;

        new l_itemWeight;
        ret = JsonGetInt(item, "weight", l_itemWeight);
        if(ret) {
            printf("Error getting item weight on item %s", l_itemName);
            return 1;
        }
        l_itemDef[ItemDef::weight] = l_itemWeight;

        new bool:l_isItemUsable;
        ret = JsonGetBool(item, "usable", l_isItemUsable);
        if(ret) { 
            printf("Error getting is item usable %s", l_itemName);
            return 1;
        }
        l_itemDef[ItemDef::usable] = l_isItemUsable;
        
        new l_plantTime;
        ret = JsonGetInt(item, "plant_time", l_plantTime);
        if(ret) {
            
        }
        l_itemDef[ItemDef::plant_time] = l_plantTime;
        map_add_arr(map_itemDef,l_itemId, l_itemDef);
    }
    printf("[ITEMS] Got total items : %d", itemLength);

    if(Feat_ItemLoaded > 0) {
#if defined DEBUG_MODE
        printf("[DEBUG] Listing all item definition");
#endif
    }

    DropItem::list_dropped = list_new();

    return 1;
}

GetItemDefinition(p_key, p_itemDef[eItemDef]) {
    if(!map_has_key(map_itemDef, p_key)) {
        return 0;
    }
    map_get_arr_safe(map_itemDef, p_key, p_itemDef);
    return 1;
}


Task:LoadPlayerInventory(playerid) {
    new Task:item_loaded = task_new();
    new l_characterId = CharacterInfo[playerid][cinfo_id];
    mysql_format(MainConn, szMiscArray, sizeof(szMiscArray),
                 "SELECT * FROM `character_inventory`\
WHERE `characterId` = '%d'", l_characterId
                 );
    mysql_tquery(MainConn, szMiscArray, "OnCharacterInventoryLoaded", "ii", playerid, _:item_loaded);
    return item_loaded;
}

public OnCharacterInventoryLoaded(playerid, task_id) {
    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields);
    list_clear(PlayerInventoryList[playerid]);
    PlayerInventoryWeight[playerid] = 0;
    PlayerMaximumWeight[playerid] = CharacterData[playerid][p_inv_weight];
    if(rows > 0) {
        invInitialized[playerid] = true;
        new l_item[CharacterInv::eInfo];
        for(new i=0;i<rows;i++) {
            DB::LoadCacheSchema(i, CharacterInv::Schema, sizeof(CharacterInv::Schema), _:l_item);
            new l_itemDef[eItemDef];
            GetItemDefinition(l_item[CharacterInv::item][Item::id], l_itemDef);
            new l_itemWeight = l_itemDef[ItemDef::weight];
            new l_sumWeight = l_itemWeight * l_item[CharacterInv::item][Item::amount];
            new l_currWeight = PlayerInventoryWeight[playerid];
            PlayerInventoryWeight[playerid] = l_currWeight + l_sumWeight;
            l_item[CharacterInv::list_idx] = list_size(PlayerInventoryList[playerid]);
            list_add_arr(PlayerInventoryList[playerid], l_item);
            // GUI_Emit_InventoryItems(playerid);
        }
    } else {
        invInitialized[playerid] = false;
    }
    task_set_result(Task:task_id, true);
}


CheckItemInInventory(playerid, p_itemID) {
    new l_cinv[CharacterInv::eInfo];
    new i = 0;
    new itemDef[eItemDef];
    GetItemDefinition(p_itemID, itemDef);
    for_list(it: PlayerInventoryList[playerid]) {
    // for(new i;i<MAX_PLAYERS_ITEM_SLOT;i++) {
        iter_get_arr(it, l_cinv);
        if(l_cinv[CharacterInv::item][Item::id] == p_itemID) {
            if(l_cinv[CharacterInv::item][Item::amount] < itemDef[ItemDef::max_amount]) {
                return i;
            }
        }
        i++;
    }
    return -1;
}


_DoGiveItem(playerid, p_slot, const p_itemData[Inv::eItem], amount=0) {
    new l_item[CharacterInv::eInfo];
    if(p_slot == -1) {
        l_item[CharacterInv::char_id] = CharacterData[playerid][p_ID];
        l_item[CharacterInv::item] = p_itemData;
        DB::MakeInsertQuery("character_inventory", CharacterInv::Schema, sizeof(CharacterInv::Schema));
        DB::PopulateInsertQuery(CharacterInv::Schema, sizeof(CharacterInv::Schema), l_item);
        new Task:insert_task = task_new();
        mysql_tquery(MainConn, szQuery, "OnCharacterInvInserted", "iaii", playerid, l_item, sizeof(l_item), _:insert_task);
        await insert_task;
    } else {
        list_get_arr(PlayerInventoryList[playerid], p_slot, l_item);
        l_item[CharacterInv::item] = p_itemData;
        l_item[CharacterInv::isDirty] = true; 
        list_set_arr(PlayerInventoryList[playerid], p_slot, l_item);
    }
    new l_itemDef[eItemDef];
    GetItemDefinition(p_itemData[Item::id],l_itemDef);
    if(amount > 0) {
        GUI_EMIT_ItemAdded(playerid, p_itemData[Item::id], amount);
    }
    return 1;
}

callback OnCharacterInvInserted(playerid, l_item[CharacterInv::eInfo], arr_size, task) {
    new l_insert_id = cache_insert_id();
    l_item[CharacterInv::id] = l_insert_id;
    l_item[CharacterInv::list_idx] = list_size(PlayerInventoryList[playerid]);
    list_add_arr(PlayerInventoryList[playerid], l_item);
    task_set_result(Task:task, true);
    return 1;
}


CharacterInv::HasVehicleKey(playerid, serial) {
    new l_item[CharacterInv::eInfo];
    for_list(it: PlayerInventoryList[playerid]) {
    // for(new i=0;i<MAX_PLAYERS_ITEM_SLOT;i++) {
        iter_get_arr(it, l_item);
        if(l_item[CharacterInv::item][Item::addon1] == serial) {
            return true;
        }
    }
    return false;
}

GivePlayerItem(playerid, p_itemData[Inv::eItem], drop = true) {
    new l_itemDef[eItemDef];
    if(!GetItemDefinition(p_itemData[Item::id], l_itemDef)) { 
        Logger_Err("get item definition failed", Logger_S("module","items"), Logger_I("item_id", p_itemData[Item::id]));
        return -1;
    }

    new l_itemWeight = l_itemDef[ItemDef::weight];
    new l_tbaWeight = l_itemWeight * p_itemData[Item::amount];
    new l_currPlayerWeight = PlayerInventoryWeight[playerid];
    new l_newWeight = l_currPlayerWeight + l_tbaWeight;
    new giveAmount = p_itemData[Item::amount];

    if(l_newWeight > PlayerMaximumWeight[playerid]) {
        EMIT_PlayerSystemChat(playerid, -1, "Failed to receive item. Maximum weight exceed.");
        if(drop) {
            new Float:l_Pos[3];
            GetPlayerPos(playerid, VEC3_UNWRAP(l_Pos));
            l_Pos[2] -= 0.6;
            CreateDropItem(l_Pos, p_itemData);
            EMIT_PlayerSystemChat(playerid, -1, "[ITEMS] Maximum inventory weight reached. Item dropped");    
            return 1;
        }
        return -1;
    }

    new l_currentSlot = CheckItemInInventory(playerid, p_itemData[Item::id]);
    if(l_currentSlot == -1) {
        _DoGiveItem(playerid, -1, p_itemData, giveAmount);
        return 1;
    } else {
        new l_item[CharacterInv::eInfo];
        list_get_arr(PlayerInventoryList[playerid], l_currentSlot, l_item);
        new l_itemMaxAmount = l_itemDef[ItemDef::max_amount];
        new l_currAmount = l_item[CharacterInv::item][Item::amount];
        new l_newAmount = l_currAmount + p_itemData[Item::amount];
        if(l_newAmount > l_itemMaxAmount) {
            new l_addAmount = l_newAmount - l_itemMaxAmount;
            PlayerInventoryWeight[playerid] = l_newWeight;
            p_itemData[Item::amount] = l_itemMaxAmount;
            _DoGiveItem(playerid, l_currentSlot, p_itemData);
            p_itemData[Item::amount] = l_addAmount;
            _DoGiveItem(playerid, -1, p_itemData, l_addAmount);
            return 1;
        } else {
            PlayerInventoryWeight[playerid] = l_newWeight;
            p_itemData[Item::amount] = l_newAmount;
            _DoGiveItem(playerid, l_currentSlot, p_itemData,giveAmount);
            return 1;
        } 
    } 
}


TakePlayerItem(playerid, slot, p_amount) {
    if(p_amount < 1) {
        printf("[ERROR] TakePlayerItem amount should be greater than 0");
        return -1;
    }

    if(list_size(PlayerInventoryList[playerid]) < slot) {
        printf("[ERROR] TakePlayerItem inventory wrong index");
        return -1;
    }
    new l_item[CharacterInv::eInfo];
    list_get_arr(PlayerInventoryList[playerid], slot, l_item);
    
    if(p_amount > l_item[CharacterInv::item][Item::amount]) {
        printf("[ERROR] TakePlayerItem amount is greater than inventory amount");
        printf("Slot %i", slot);
        printf("Take Amt: %i | Inventory Amt: %i ", p_amount, l_item[CharacterInv::item][Item::amount]);
        printf("ItemID: %i", l_item[CharacterInv::item][Item::id]);
        return -1;
    }

    if(Character::IsUsingTools(playerid)) {
        if(Character::GetToolsSlot(playerid) == slot) {
            printf("[ERROR] Player trying to drop item that currently used");
            EMIT_PlayerSystemChat(playerid, -1, "[ERROR] Cannot drop item while using it.");
            return -1;
        }
    }

    new l_itemDef[eItemDef];
    new l_itemID = l_item[CharacterInv::item][Item::id];
    GetItemDefinition(l_itemID, l_itemDef);

    new l_itemWeight = l_itemDef[ItemDef::weight];
    new l_totalWeigth = l_itemWeight * p_amount;

    printf("[DEBUG] TakePlayerItem W: %i, Total W: %i", l_itemWeight,l_totalWeigth);

    PlayerInventoryWeight[playerid] -= l_totalWeigth;
    

    if(l_item[CharacterInv::item][Item::amount] == p_amount) {
        CharacterInv::DeleteItem(playerid, l_item);
    } else {
        l_item[CharacterInv::item][Item::amount] -= p_amount;
        l_item[CharacterInv::isDirty] = true;
        list_set_arr(PlayerInventoryList[playerid], slot, l_item);
    }
    CharacterInv::RecalculateIndex(playerid);
    GUI_Emit_InventoryItems(playerid);
    GUI_EMIT_ItemReduced(playerid, l_itemID, p_amount);
    return 1;
}



CharacterInv::GetSlotFromID(playerid, itemId) {
    new l_item[CharacterInv::eInfo];
    new i=0;
    for_list(it: PlayerInventoryList[playerid]) {
        iter_get_arr(it, l_item);
        if(l_item[CharacterInv::item][Item::id] == itemId) {
            return i;
        }
        i++;
    }
    return -1;
}

stock CharacterInv::GetAmountFromID(playerid, itemId) {
    new l_item[CharacterInv::eInfo];
    new l_amt = 0;
    for_list(it: PlayerInventoryList[playerid]) {
        iter_get_arr(it, l_item);
        if(l_item[CharacterInv::item][Item::id] == itemId) {
            l_amt += l_item[CharacterInv::item][Item::amount];
        }
    }
    return l_amt;
}

stock CharacterInv::WeightCheck(playerid, item_id, p_amount) {
    new l_itemDef[eItemDef];
    GetItemDefinition(l_itemID, l_itemDef);
    new l_itemWeight = l_itemDef[ItemDef::weight];
    new l_totalWeigth = l_itemWeight * p_amount;
    new l_nextWeight = PlayerInventoryWeight[playerid] + l_totalWeigth;
    if(l_nextWeight > PlayerMaximumWeight[playerid]) {
        return 0;
    }
    return 1;
}

CharacterInv::RecalculateIndex(playerid) {
    new l_item[CharacterInv::eInfo];
    new it_index = 0;
    for_list(it: PlayerInventoryList[playerid]) {
        iter_get_arr(it, l_item);
        iter_set_cell(it, _:CharacterInv::list_idx, it_index);
        it_index++;
    }
    return 1;
}

CharacterInv::DeleteItem(playerid, p_item[CharacterInv::eInfo]) {
    szQuery[0] = 0;
    new char_id = CharacterData[playerid][p_ID];
    mysql_format(MainConn, szQuery, sizeof(szQuery), "delete from `character_inventory` where `characterId`='%i' and `id`='%i'", char_id, p_item[CharacterInv::id]);
    mysql_tquery(MainConn, szQuery);
    list_remove(PlayerInventoryList[playerid], p_item[CharacterInv::list_idx]);
    return 1;
}

CharacterInv::UpdateDB(playerid) {
    new is_updated = false;
    new l_item[CharacterInv::eInfo];
    for_list(it: PlayerInventoryList[playerid]) {
        iter_get_arr(it, l_item);
        if(l_item[CharacterInv::isDirty]) {
            DB::MakeUpdateQuery("character_inventory", CharacterInv::Schema, sizeof(CharacterInv::Schema));
            DB::PopulateUpdateQuery(CharacterInv::Schema, sizeof(CharacterInv::Schema), l_item);
            mysql_tquery(MainConn,szQuery);
            iter_set_cell(it, CharacterInv::isDirty, false);
            is_updated = true;
        }
    }
    return is_updated;
}

GUI_Emit_InventoryItems(playerid) {
    new Node:node_items_arr;
    JsonToggleGC(node_items_arr, false);
    new l_item[CharacterInv::eInfo];
    if(list_size(PlayerInventoryList[playerid]) == 0) {
        node_items_arr = JsonArray();
        new Node:node_player_inv = JsonObject("items", node_items_arr);
        JsonSetInt(node_player_inv, "max_w", PlayerMaximumWeight[playerid]);
        new l_str[2048];
        JsonStringify(node_player_inv,l_str);
        // printf("[DEBUG] player inventory \n%s", l_str);
        cef_emit_event(playerid, "pinven:gotInvList", CEFSTR(l_str));
        JsonToggleGC(node_items_arr,true);   
    }
    new i = 0;
    for_list(it: PlayerInventoryList[playerid]) {
        if(!iter_get_arr(it, l_item)) continue;
    // for(new i=0;i<MAX_PLAYERS_ITEM_SLOT;i++) {
        new Node:l_itemList= JsonObject();
        JsonSetInt(l_itemList, "slot", l_item[CharacterInv::list_idx]);
        JsonSetInt(l_itemList, "id", l_item[CharacterInv::item][Item::id]);
        JsonSetInt(l_itemList, "amt", l_item[CharacterInv::item][Item::amount]);
        JsonSetInt(l_itemList, "dur", l_item[CharacterInv::item][Item::durability]);
        JsonSetInt(l_itemList, "pwr", l_item[CharacterInv::item][Item::power]);
        JsonSetInt(l_itemList, "add1", l_item[CharacterInv::item][Item::addon1]);
        JsonSetInt(l_itemList, "add2", l_item[CharacterInv::item][Item::addon2]);
        JsonSetInt(l_itemList, "add3", l_item[CharacterInv::item][Item::addon3]);
        if(i == 0) {
            node_items_arr = JsonArray(l_itemList);
        } else {
            node_items_arr = JsonAppend(node_items_arr, JsonArray(l_itemList));
        } 
        i++;
    }
    
    new Node:node_player_inv = JsonObject("items", node_items_arr);
    JsonSetInt(node_player_inv, "max_w", PlayerMaximumWeight[playerid]);
    new l_str[2048];
    JsonStringify(node_player_inv,l_str);
    // printf("[DEBUG] player inventory \n%s", l_str);
    cef_emit_event(playerid, "pinven:gotInvList", CEFSTR(l_str));
    JsonToggleGC(node_items_arr,true);
    return 1;
}

GUI_EMIT_ItemReduced(playerid, item_id, amount) {
    new Node:node_payload = JsonObject();
    JsonSetInt(node_payload,"item_id", item_id);
    JsonSetInt(node_payload, "amount", amount);
    new szPayload[1024];
    szPayload[0] = 0;
    JsonStringify(node_payload,szPayload);
    cef_emit_event(playerid, "pinven:reduce-item", CEFSTR(szPayload));
    return 1;
}

GUI_EMIT_ItemAdded(playerid, item_id, amount) {
    new Node:node_payload = JsonObject();
    JsonSetInt(node_payload,"item_id", item_id);
    JsonSetInt(node_payload, "amount", amount);
    new szPayload[1024];
    szPayload[0] = 0;
    JsonStringify(node_payload,szPayload);
    cef_emit_event(playerid, "pinven:got-item", CEFSTR(szPayload));
}


#if defined DEBUG_MODE
CMD:getiw(playerid, params[]) {
    new str[128];
    format(str,sizeof(str), "Actual Inven Weight: %i", PlayerInventoryWeight[playerid]);
    EMIT_PlayerSystemChat(playerid, -1, str);
    return 1;
}
#endif
Item::Print(item[Inv::eItem]) {
    printf("item_id: %i", item[Item::id]);
    printf("item_amt: %i", item[Item::amount]);
}

