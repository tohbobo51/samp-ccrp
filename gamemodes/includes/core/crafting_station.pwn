#include <pp-hooks>

hook OnGameModeInit() {
    Logger_Log("Initalizing Crafting Station", Logger_S("module", "crafting"));
    CraftingStation::list = list_new();
    
    Logger_Log("Crafting Station initialized", Logger_S("module", "crafting"));
}

hook OnPlayerEnterDynArea(playerid, areaid) {
    if(Streamer_HasIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_CRFTSTATION_ID))) {
        if(Crafting::IsUsingStation(playerid)) return 0;
        new strm_ext_id = Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_CRFTSTATION_ID));
        Logger_Dbg("crafting", "player enter station", 
                   Logger_I("playerid", playerid),
                   Logger_I("areaid", areaid));
        CraftingStation::SetUsedByPlayer(strm_ext_id, playerid);
        return 1;
    }
    return 0;
}

hook OnPlayerConnect(playerid) {
    Crafting::SetStationID(playerid, -1);
    Crafting::SetUsingStation(playerid, 0);
}

callback CraftingTick() {
    new l_station[CraftingStation::eInfo];
    new it_idx = -1;
    for_list(it : CraftingStation::list) {
        it_idx++;
        iter_get_arr(it, l_station);
        if(!l_station[CraftingStation::isCrafting]) continue; 
        CraftingStation::debug(l_station);
        new pID = l_station[CraftingStation::usedByPlayerId];
        if(!IsPlayerConnected(pID)) {
            CraftingStation::SetFree(it_idx);
            printf("Player not connected in crafting station");
            Logger_Err("player not connected in craft tick", Logger_I("playerid", pID));
            continue;
        }

        printf("Crafting Progress playerid: %i", pID);
        Logger_Dbg("crafting-tick", "tick", 
                   Logger_I("station_id", it_idx),
                   Logger_I("playerid", pID)
                   );

        l_station[CraftingStation::craftingTime] += 1;
        if(l_station[CraftingStation::craftingTime] >= l_station[CraftingStation::craftingFinishTime]) {
            PlayerAction::Finish(pID);
            new station_type = _:l_station[CraftingStation::type];
            new craftingStation[Crafting::e_Station];
            map_get_arr(Crafting::stations, station_type, craftingStation);

            new l_recipeId = l_station[CraftingStation::craftingRecipe];
            new recipe[Crafting::e_Recipe];
            map_get_arr(craftingStation[CraftingStation::recipes], l_recipeId, recipe);
            for_list(z : recipe[CraftingRecipe::input]) {
                new inputItem[Crafting::e_Item];
                iter_get_arr(z, inputItem);
                new idx = CraftingStorage::FindIndexForItem(l_station[CraftingStation::storage], inputItem[CraftingItem::id]);
                if(idx != -1) {
                    CraftingStorage::StorageTakeItem(l_station[CraftingStation::storage], idx, inputItem[CraftingItem::amt]);
                }
            }

            for_list(z : recipe[CraftingRecipe::output]) {
                new inputItem[Crafting::e_Item];
                iter_get_arr(z, inputItem);
                CraftingStorage::StorageAddItem(l_station[CraftingStation::storage], inputItem[CraftingItem::id], inputItem[CraftingItem::amt]);
            }
            CraftingStorage::EMIT_Storage(pID, l_station[CraftingStation::storage]);

            l_station[CraftingStation::isCrafting] = false;
            l_station[CraftingStation::craftingRecipe] = -1;
            l_station[CraftingStation::craftingFinishTime] = 0;
            l_station[CraftingStation::craftingTime] = 0;
            iter_set_arr(it, l_station);
            PlayerAction::Update(pID,l_station[CraftingStation::craftingTime]);
            continue;
        }
        Logger_Dbg("crafting-tick", "tick end", 
                   Logger_I("station_id", it_idx),
                   Logger_B("is_crafting", bool:l_station[CraftingStation::isCrafting]),
                   Logger_I("recipe", l_station[CraftingStation::craftingRecipe]),
                   Logger_I("time", l_station[CraftingStation::craftingTime]),
                   Logger_I("finish_time", l_station[CraftingStation::craftingFinishTime])
                   );
        iter_set_arr(it, l_station);
        PlayerAction::Update(pID,l_station[CraftingStation::craftingTime]);
    }
    return 1;
}

Crafting::LoadAllStation() {
    return 1;
}

CraftingStation::Create(CraftingStation::TYPE:p_type, const Float:p_pos[3], const p_name[56], p_id = -1, p_static = false, p_int = 0, world = 0) {
    new l_station[CraftingStation::eInfo];
    l_station[CraftingStation::id] = p_id;
    l_station[CraftingStation::type] = p_type;
    format(l_station[CraftingStation::name], 56, "%s", p_name);
    l_station[CraftingStation::pos][X] = p_pos[X];
    l_station[CraftingStation::pos][Y] = p_pos[Y];
    l_station[CraftingStation::pos][Z] = p_pos[Z];
    l_station[CraftingStation::isStatic] = p_static;

    l_station[CraftingStation::pickupId] = CreateDynamicPickup(1318, 1, p_pos[X],p_pos[Y],p_pos[Z], .interiorid=p_int, .worldid=world);

    l_station[CraftingStation::areaId] = CreateDynamicCircle(p_pos[X],p_pos[Y],1.0, .interiorid=p_int, .worldid=world);
    new l_index = list_size(CraftingStation::list);
    Streamer_SetIntData(STREAMER_TYPE_AREA, l_station[CraftingStation::areaId], E_STREAMER_CUSTOM(E_STREAMER_CRFTSTATION_ID), l_index);
    new str[128];
    format(str,sizeof(str), "%s\nUsed by: NONE", p_name);
    l_station[CraftingStation::textId] = CreateDynamic3DTextLabel(str, -1, p_pos[X],p_pos[Y],p_pos[Z],30.0);

    l_station[CraftingStation::storage] = list_new();
    list_add_arr(CraftingStation::list, l_station);
    return 1;
}

CraftingStation::OnCraftItem(playerid, l_recipeId) {
    new l_stationId = Crafting::GetStationID(playerid);
    if(l_stationId == -1) {
        printf("[ERROR] Player %i is not using crafting station but got the event.",playerid);
        return 1;
    }

    new l_station[CraftingStation::eInfo];
    list_get_arr(CraftingStation::list, l_stationId, l_station);

    new type = l_station[CraftingStation::type];

    new craftingStation[Crafting::e_Station];
    map_get_arr(Crafting::stations, _:type, craftingStation);

    new recipe[Crafting::e_Recipe];
    map_get_arr(craftingStation[CraftingStation::recipes], l_recipeId, recipe);


    if(l_station[CraftingStation::isCrafting]) {
        printf("[ERROR] Crafting station is still crafting other items");
        return 1;
    }

    Crafting::PrintRecipe(recipe);
    l_station[CraftingStation::isCrafting] = true;
    l_station[CraftingStation::craftingRecipe] = recipe[CraftingRecipe::id];
    l_station[CraftingStation::craftingFinishTime] = recipe[CraftingRecipe::duration];
    l_station[CraftingStation::craftingTime] = 0;
    PlayerAction::Set(playerid, "Crafting", recipe[CraftingRecipe::duration]);
    list_set_arr(CraftingStation::list, l_stationId, l_station); 
    return 1;
}

CraftingStation::SetUsedByPlayer(station_id, playerid) {
    printf("PlayerID: %i is using crafting station: %i", playerid, station_id);
    new l_station[CraftingStation::eInfo];
    list_get_arr(CraftingStation::list, station_id, l_station);
    
    l_station[CraftingStation::used] = true;
    l_station[CraftingStation::usedByPlayerId] = playerid;

    new str[128];
    format(str,sizeof(str), "%s\nUsed by: %s", l_station[CraftingStation::name],GetName(playerid));
    UpdateDynamic3DTextLabelText(l_station[CraftingStation::textId], -1, str);

    Crafting::SetStationID(playerid, station_id);
    Crafting::SetUsingStation(playerid, 1);

    GUI_Emit_InventoryItems(playerid);

    new Node:node_crafting = JsonObject();
    JsonSetInt(node_crafting, "stationId", _:l_station[CraftingStation::type]);

    new l_str[512];
    JsonStringify(node_crafting,l_str);
    printf("[DEBUG] JSON crft:usingstation\n%s", l_str);
    cef_emit_event(playerid, "crft:usingstation", CEFSTR(l_str));

    CraftingStorage::EMIT_Storage(playerid, l_station[CraftingStation::storage]);

    isPlayerUIInteractable[playerid] = true;
    cef_focus_browser(playerid, GET_BROWSER_ID(playerid), true);
    list_set_arr(CraftingStation::list, station_id, l_station);
    return 1;
}

CraftingStation::SetFree(station_id) {
    if(station_id > (list_size(CraftingStation::list)-1) ) {
        return 0;
    }
    new l_station[CraftingStation::eInfo];
    new pID = l_station[CraftingStation::usedByPlayerId]; 
    list_get_arr(CraftingStation::list, station_id, l_station);
    Logger_Dbg("crafting", "player exit station",
               Logger_I("playerid", pID),
               Logger_I("station_id", station_id)
               );
    l_station[CraftingStation::used] = false;
    l_station[CraftingStation::usedByPlayerId] = INVALID_PLAYER_ID;

    if(l_station[CraftingStation::isCrafting]) {
        l_station[CraftingStation::isCrafting] = false;
        l_station[CraftingStation::craftingRecipe] = -1;
        l_station[CraftingStation::craftingFinishTime] = 0;
        l_station[CraftingStation::craftingTime] = 0;
    }

    new str[128];
    format(str,sizeof(str), "%s\nUsed by: NONE", l_station[CraftingStation::name]);
    UpdateDynamic3DTextLabelText(l_station[CraftingStation::textId], -1, str);

    Crafting::SetStationID(pID, -1);
    Crafting::SetUsingStation(pID, 0);
    new Node:node_crafting = JsonObject();
    JsonSetInt(node_crafting, "stationId", -1);

    new l_str[512];
    JsonStringify(node_crafting,l_str);
    cef_emit_event(pID, "crft:usingstation", CEFSTR(l_str));
    cef_focus_browser(pID, GET_BROWSER_ID(pID), false);
    list_set_arr(CraftingStation::list, station_id, l_station);
    return 1;
}

callback CrftStorageTakeItem(playerid, const arguments[]) {
    new l_slot, l_amount;
    Logger_Dbg("crafting", "cef player take item",
               Logger_I("playerid", playerid),
               Logger_S("args", arguments)
               );
    if(sscanf(arguments, "ii", l_slot,l_amount)) {
        Logger_Err("argument missmatch", Logger_S("module", "crafting"), Logger_S("args", arguments));
        return 1;
    }
    new l_stationId = Crafting::GetStationID(playerid);
    if(l_stationId == -1) {
        Logger_Err("invalid station_id", Logger_S("module", "crafting"), Logger_I("playerid", playerid), Logger_I("stationid", l_stationId));
        return 1;
    }
    CraftingStorage::TakeItem(playerid, l_stationId, l_slot, l_amount);
    return 1;
}

callback CrftStorageStoreItem(playerid, const arguments[]) {
    new l_slot, l_amount;
    Logger_Dbg("crafting", "cef player store item", 
                Logger_I("playerid", playerid),
                Logger_S("args", arguments)
               );
    if(sscanf(arguments, "ii", l_slot,l_amount)) {
        printf("[ERROR] CraftingStoreItem\nArgument mismatch\n%s",arguments);
        return 1;
    }
    new l_stationId = Crafting::GetStationID(playerid);
    if(l_stationId == -1) {
        printf("[ERROR] Player %i is not using station but got the event.",playerid);
        return 1;
    }
    CraftingStorage::StoreItem(playerid, l_stationId, l_slot, l_amount);
    return 1;
}

CraftingStorage::TakeItem(playerid, station_id, slot, amount) {
    if(station_id > (list_size(CraftingStation::list)-1)) {
        return 0;
    }
    new l_station[CraftingStation::eInfo];
    list_get_arr(CraftingStation::list, station_id, l_station);
    new l_item[Crafting::e_Item];
    list_get_arr(l_station[CraftingStation::storage], slot, l_item);
    new l_itemId = l_item[CraftingItem::id];
    new l_currAmount = l_item[CraftingItem::amt];
    if(l_itemId == -1) {
        printf("[ERROR] Taking item invalid item_id");
        return 1;
    }
    if(l_currAmount < amount) {
        printf("[ERROR] Invalid item amount. maybe event has been modified ?");
        return 1;
    }
    new l_itemData[Inv::eItem];
    l_itemData[Item::id] = l_itemId;
    l_itemData[Item::amount] = amount;

    if(GivePlayerItem(playerid, l_itemData) != -1) {
        CraftingStorage::StorageTakeItem(l_station[CraftingStation::storage],slot,amount);
        CraftingStorage::EMIT_Storage(playerid, l_station[CraftingStation::storage]);
        GUI_Emit_InventoryItems(playerid);
    } else {
        EMIT_PlayerSystemChat(playerid, -1, "Cannot take item. Your inventory is full.");
        return 1;
    }
    return 1; 
}

CraftingStorage::StorageTakeItem(List:station_storage, slot, amount) {
    new l_item[Crafting::e_Item];
    list_get_arr(station_storage, slot, l_item);
    if(l_item[CraftingItem::amt] == amount) {
        list_remove(station_storage, slot);
    } else {
        new n_amount = l_item[CraftingItem::amt] - amount;
        list_set_cell(station_storage, slot, CraftingItem::amt, n_amount);
    }
    return 1;
}

CraftingStorage::StoreItem(playerid, station_id, slot, amount) {
    if(slot > (list_size(PlayerInventoryList[playerid])-1)) return -1;
    new l_item[CharacterInv::eInfo];
    list_get_arr(PlayerInventoryList[playerid], slot, l_item);
    new l_pinv_itemId = l_item[CharacterInv::item][Item::id];
    new l_station[CraftingStation::eInfo];
    list_get_arr(CraftingStation::list, station_id, l_station);
    new ret = CraftingStorage::StorageAddItem(l_station[CraftingStation::storage], l_pinv_itemId, amount);
    if(ret > -1) {
        if(TakePlayerItem(playerid, slot, amount) != -1) {
            CraftingStorage::EMIT_Storage(playerid, l_station[CraftingStation::storage]);
            return 1;
        } else {
            CraftingStorage::StorageTakeItem(l_station[CraftingStation::storage], ret, amount);
        }
    }
    return 1;
}

CraftingStorage::StorageAddItem(List:station_storage, item_id, amount) {
    new idx = CraftingStorage::FindIndexForItem(station_storage, item_id);
    printf("StorageItem has item_id: %i index id: %i", item_id, idx);
    if(idx == -1) {
        new l_item[Crafting::e_Item];
        l_item[CraftingItem::id] = item_id;
        l_item[CraftingItem::amt] = amount;
        list_add_arr(station_storage, l_item);
    } else {
        new l_item[Crafting::e_Item];
        list_get_arr(station_storage, idx, l_item);
        new l_itemDef[eItemDef];
        GetItemDefinition(item_id, l_itemDef);
        new n_amt = l_item[CraftingItem::amt] + amount;
        if(n_amt > l_itemDef[ItemDef::max_amount]) {
            new s_amt = n_amt - l_itemDef[ItemDef::max_amount];
            list_set_cell(station_storage, idx, CraftingItem::amt, l_itemDef[ItemDef::max_amount]);
            new n_item[Crafting::e_Item];
            n_item[CraftingItem::id] = item_id;
            n_item[CraftingItem::amt] = s_amt;
            list_add_arr(station_storage, n_item);
        } else {
            list_set_cell(station_storage, idx, CraftingItem::amt, n_amt);
        }
    }
    return 1;
}

CraftingStorage::FindIndexForItem(List:storage, item_id) {
    printf("Finding Index for Item: %i in Storrage", item_id);
    new l_item[Crafting::e_Item];
    new itemDef[eItemDef];
    GetItemDefinition(item_id, itemDef);
    new itx = -1;
    for_list(it : storage) {
        itx++;
        iter_get_arr(it, l_item);
        if(l_item[CraftingItem::id] == item_id) {
            if(l_item[CraftingItem::amt] < itemDef[ItemDef::max_amount]) {
                return itx;
            }
        }
    }
    return -1;
}

CraftingStorage::EMIT_Storage(playerid, List:station_storage) {
    new Node:node_items_arr;
    JsonToggleGC(node_items_arr, false);
    new l_item[Crafting::e_Item];
    new idx = 0;
    if(list_size(station_storage) < 1) {
        node_items_arr = JsonArray();
    } else {
        for_list(it : station_storage) {
            iter_get_arr(it, l_item);
            new Node:l_itemList= JsonObject();
            JsonSetInt(l_itemList, "slot",  idx);
            JsonSetInt(l_itemList, "id", l_item[CraftingItem::id]);
            JsonSetInt(l_itemList, "amt", l_item[CraftingItem::amt]);
            if(idx == 0) {
                node_items_arr = JsonArray(l_itemList);
            } else {
                node_items_arr = JsonAppend(node_items_arr, JsonArray(l_itemList));
            } 
            idx++;
        }
    }
    new Node:node_sawmill_item = JsonObject("items", node_items_arr);
    JsonSetInt(node_sawmill_item, "max_w", 10000);
    new l_str[2048];
    JsonStringify(node_sawmill_item,l_str);
    cef_emit_event(playerid, "crft:gotStationItems", CEFSTR(l_str));
    JsonToggleGC(node_items_arr,true);
    return 1;
}

CraftingStation::debug(const p_station[CraftingStation::eInfo]) {
    Logger_Dbg("crafting", "Station Info",
               Logger_S("name", p_station[CraftingStation::name]),
               Logger_B("used", bool:p_station[CraftingStation::used]),
               Logger_I("usedBy", p_station[CraftingStation::usedByPlayerId]),
               Logger_B("is_crafting", bool:p_station[CraftingStation::isCrafting]),
               Logger_I("crafting_recipe", p_station[CraftingStation::craftingRecipe]),
               Logger_I("crafting_time", p_station[CraftingStation::craftingTime]),
               Logger_I("finish_time", p_station[CraftingStation::craftingFinishTime]),
               Logger_B("is_static", bool:p_station[CraftingStation::isStatic])
               );
    return 1;
}
