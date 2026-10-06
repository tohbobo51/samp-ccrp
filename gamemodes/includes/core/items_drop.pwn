TickDroppedItem() {
    if(!Feat_ItemInitialized) return 0;
    new index = -1;
    new l_drop[DropItem::e_DroppedItem];
    for_list(it : DropItem::list_dropped) {
        index++;
        if(!iter_valid(it)) {
            printf("DROPTICK Invalid Iterator\n");
            continue;
        }
        if(!iter_get_arr_safe(it, l_drop)) {
            continue; 
        }
        if (l_drop[DropItem::time_elapsed] == DROP_ITEM_EXPIREDTIME) {
            DestroyDropItem(l_drop);
            continue;
        }
        l_drop[DropItem::time_elapsed] += 1;
        iter_set_arr(it, l_drop);
    }
    return 1;
}

CreateDropItem(const Float:p_pos[3], const p_itemData[Inv::eItem]) {
    static l_index = 0;
    l_index++;
    printf("Dropped item with index %i", l_index);

    // p_pos[2] -= 0.6;
    new l_drop[DropItem::e_DroppedItem];
    
    DropItem::counter++;
    l_drop[DropItem::id] = DropItem::counter;
    l_drop[DropItem::index] = l_index+1;
    l_drop[DropItem::valid] = true;
    l_drop[DropItem::posX] = p_pos[X];
    l_drop[DropItem::posY] = p_pos[Y];
    l_drop[DropItem::posZ] = p_pos[Z];
    l_drop[DropItem::item_id] = p_itemData[Item::id];
    l_drop[DropItem::item_amount] = p_itemData[Item::amount];
    l_drop[DropItem::durability] = p_itemData[Item::durability];
    l_drop[DropItem::power] = p_itemData[Item::power];
    l_drop[DropItem::addon1] = p_itemData[Item::addon1];
    l_drop[DropItem::addon2] = p_itemData[Item::addon2];
    l_drop[DropItem::addon3] = p_itemData[Item::addon3];
    l_drop[DropItem::time_elapsed] = 0;

    l_drop[DropItem::pickupId] = CreateDynamicPickup(
        GetDropItemModelId(p_itemData[Item::id]),
        1,p_pos[0],p_pos[1],p_pos[2]);


    l_drop[DropItem::textId] = CreateDynamic3DTextLabel(
        "Dropped Item",
        COLOR_DARKGOLDENROD,
        p_pos[X],
        p_pos[Y],
        p_pos[Z],
        30.0,
        .testlos=1
    );

    list_add_arr(DropItem::list_dropped, l_drop);

    foreach(new i: Player) {
        if(IsPlayerInRangeOfPoint(i, 1.5,
                                  p_pos[0],
                                  p_pos[1],
                                  p_pos[2]
                                  )) {
            if(isPlayerUIInteractable[i]) {
                EMIT_GetNearbyDroppedItem(i);
            }
            Streamer_Update(i);
        }
    }
    return 1;
}

DestroyDropItem(const item[DropItem::e_DroppedItem]) {
    if(IsValidDynamic3DTextLabel(item[DropItem::textId])) {
        DestroyDynamic3DTextLabel(item[DropItem::textId]);
    }
    if(IsValidDynamicPickup(item[DropItem::pickupId])) {
        printf("Pickup valid and destroyed %d", item[DropItem::pickupId]);
        DestroyDynamicPickup(item[DropItem::pickupId]);
    }
    new removedIndex = list_find_arr(DropItem::list_dropped, item);
    printf("Destroying droppitem index %i\n", removedIndex);
    list_remove(DropItem::list_dropped, removedIndex);
    RecalculateDropItemIndex();
    new Float:l_pos[3];
    l_pos[X] = item[DropItem::posX];
    l_pos[Y] = item[DropItem::posY];
    l_pos[Z] = item[DropItem::posZ];
    foreach(new i: Player) {
        if(IsPlayerInRangeOfPoint(i, 1.5,
                                  l_pos[X],
                                  l_pos[Y],
                                  l_pos[Z]
                                  )) {
            if(isPlayerUIInteractable[i]) {
                EMIT_GetNearbyDroppedItem(i);
            }
            Streamer_Update(i);
        }
    }
    return 1;
}

FindDropItemListIndex(p_index) {
    new l_drop[DropItem::e_DroppedItem];
    new index = -1;
    for_list(it : DropItem::list_dropped) {
        index++;
        iter_get_arr(it, l_drop);
        if(l_drop[DropItem::index] == p_index) {
            break; 
        }
    }
    return index; 
}

public OnGUIPlayerDropItem(playerid, const arguments[]) {
    new l_slot, l_amt;
    printf("[DEBUG] DropItem Event playerid: %d args: %s", playerid, arguments);
    if(sscanf(arguments, "ii", l_slot, l_amt)) {
        printf("[ERROR] Malformed Events inv:drop_item\n => %s", arguments);
        return -1;
    }
    
    if(l_slot > (list_size(PlayerInventoryList[playerid])-1)) {
        
        return -1;
    }
    new l_item[CharacterInv::eInfo];
    list_get_arr(PlayerInventoryList[playerid], l_slot, l_item);
    new zDropItem[Inv::eItem];
    COPY_ARRAY(l_item[CharacterInv::item], zDropItem, Inv::eItem)
    zDropItem[Item::amount] = l_amt;

    if(TakePlayerItem(playerid, l_slot, l_amt) == -1) {
        printf("[ERROR] Failed to drop. TakePlayerItem failed");
        return -1;
    }
    new Float:l_Pos[3];
    GetPlayerPos(playerid, l_Pos[0],l_Pos[1],l_Pos[2]);

    l_Pos[2] -= 0.6;

    CreateDropItem(l_Pos, zDropItem);
    return 1;
}

public OnGUIPlayerTakeItem(playerid, const arguments[]) {
    new l_index;
    if(sscanf(arguments, "i", l_index)) {
        printf("[ERROR] Malfored Events inv:take_item\n => %s", arguments);
        return -1;
    }
    printf("Taking item with index: %i\n", l_index);
    new l_droppedItem[DropItem::e_DroppedItem];

    new listIndex = FindDropItemListIndex(l_index); 
    if(!list_get_arr_safe(DropItem::list_dropped, listIndex, l_droppedItem)) {
        printf("[ERROR] Events inv:take_item\n => Failed to get item in list\n");
        return -1; 
    }

    new Float:l_pos[3];
    l_pos[X] = l_droppedItem[DropItem::posX];
    l_pos[Y] = l_droppedItem[DropItem::posY];
    l_pos[Z] = l_droppedItem[DropItem::posZ];
    if(!IsPlayerInRangeOfPoint(playerid, 2.0,
                                  l_pos[X],
                                  l_pos[Y],
                                  l_pos[Z]
                                  )) {
        printf("[ERROR] Events inv:take_item\n => Too Far item, Item index maybe already changed\n");
        EMIT_PlayerSystemChat(playerid, -1, "Gagal mengambil item. coba lagi");
        return -1; 
    }
    new l_itemData[Inv::eItem]; 

    l_itemData[Item::id] = l_droppedItem[DropItem::item_id];
    l_itemData[Item::amount] = l_droppedItem[DropItem::item_amount];
    l_itemData[Item::durability] = l_droppedItem[DropItem::durability];
    l_itemData[Item::power] = l_droppedItem[DropItem::power];
    l_itemData[Item::addon1] = l_droppedItem[DropItem::addon1];
    l_itemData[Item::addon2] = l_droppedItem[DropItem::addon2];
    l_itemData[Item::addon3] = l_droppedItem[DropItem::addon3];
    GivePlayerItem(playerid, l_itemData);
    DestroyDropItem(l_droppedItem);
    GUI_Emit_InventoryItems(playerid);
    return 1;
}

GetNearbyDroppedItems(playerid, List:p_list) {
    if(!list_valid(p_list)) return 0;
    new l_drop[DropItem::e_DroppedItem];
    for_list(it: DropItem::list_dropped) {
        if(!iter_get_arr_safe(it, l_drop)) continue;
        if(IsPlayerInRangeOfPoint(playerid,
                                  2.0,
                                  l_drop[DropItem::posX],
                                  l_drop[DropItem::posY],
                                  l_drop[DropItem::posZ]
                                  )) {
            list_add_arr(p_list, l_drop);
        }
    }
    return 1;
}

EMIT_GetNearbyDroppedItem(playerid) {
    new Node:node_items_arr;
    JsonToggleGC(node_items_arr, false);
    new foundCount = 0; 

    new l_drop[DropItem::e_DroppedItem];
    for_list(it : DropItem::list_dropped) {
        if(!iter_get_arr_safe(it, l_drop)) continue;
        if(IsPlayerInRangeOfPoint(playerid,
                                  1.5,
                                  l_drop[DropItem::posX],
                                  l_drop[DropItem::posY],
                                  l_drop[DropItem::posZ]
                                  )) {
            new Node:l_itemList= JsonObject();
            JsonSetInt(l_itemList, "idx", l_drop[DropItem::index] );
            JsonSetInt(l_itemList, "id", l_drop[DropItem::item_id]);
            JsonSetInt(l_itemList, "amt", l_drop[DropItem::item_amount]);
            if(foundCount == 0) {
                node_items_arr = JsonArray(l_itemList);
            } else {
                node_items_arr = JsonAppend(node_items_arr, JsonArray(l_itemList));
            } 
            foundCount++;
        }
    }
    if(foundCount == 0) {
        node_items_arr = JsonArray();
    }
    new Node:node_player_inv = JsonObject("items", node_items_arr);
    new l_str[512];
    JsonStringify(node_player_inv,l_str);
    cef_emit_event(playerid, "pinven:got_dropped_item_list", CEFSTR(l_str));
    JsonToggleGC(node_items_arr,true);
    return 1;
}

RecalculateDropItemIndex() {
    new l_drop[DropItem::e_DroppedItem];
    new it_index = 0;
    for_list(it : DropItem::list_dropped) {
        iter_get_arr(it, l_drop);
        iter_set_cell(it, _:DropItem::index, it_index);
        it_index++;
    }
    return 1;
}

GetDropItemModelId(itemId, defaultModelId = DROP_ITEM_MODELID) {
    switch (itemId) {
        case 21: // Wood Log
            return 19793;
        case 2: // chainsaw
            return 341;

        // Mining Ore
        // case 31:
        //     return 1207;
        // case 33:
        //     return 1207;
        // case 35:
        //     return 1207;
        // case 37:
        //     return 1207;

        default:
            return defaultModelId;
    }
    return defaultModelId;
}
