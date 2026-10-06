callback POITick() {
    foreach(new p : Player) {
        if(IsPlayerNPC(p)) continue;
        if(!IsPlayerConnected(p)) continue;
        if(!isSpawned[p]) continue;
        POI::Get(p);
    }
    return 1;
}


POI::Get(playerid) {
    new Node:node_items_arr;
    new List:p_poi = list_new();
    JsonToggleGC(node_items_arr, false);
    new Float:l_pPos[3];
    GetPlayerPos(playerid, l_pPos[X], l_pPos[Y], l_pPos[Z]);

    new List:l_dropped_item_list = list_new();
    new l_dropped_item_ret = GetNearbyDroppedItems(playerid, l_dropped_item_list);
    
    new l_drop[DropItem::e_DroppedItem];
    new a_poi[POI::eInfo];
    if(l_dropped_item_ret) {
        for_list(it: l_dropped_item_list) {
            iter_get_arr(it, l_drop);
            a_poi[POI::type] = POI_DROPITEM;
            format(a_poi[POI::title], 56, "Pickup");
            a_poi[POI::id] = l_drop[DropItem::id];
            a_poi[POI::px] = l_drop[DropItem::posX];
            a_poi[POI::py] = l_drop[DropItem::posY];
            a_poi[POI::pz] = l_drop[DropItem::posZ] + 0.5;
            a_poi[POI::ext1] = l_drop[DropItem::index];
            a_poi[POI::ext2] = l_drop[DropItem::item_id];
            a_poi[POI::ext3] = l_drop[DropItem::item_amount];
            list_add_arr(p_poi, a_poi);
        }
    }

    new l_marketplace[Marketplace::eInfo];
    for_list(it: Marketplace::list) {
        iter_get_arr(it, l_marketplace);
        if(!l_marketplace[Marketplace::with_actor]) continue;
        
        if(IsPlayerInRangeOfPoint(playerid, 5.0,
                                  VEC3_UNWRAP(l_marketplace[Marketplace::pos]))) {
            a_poi[POI::type] = POI_SHOP;
            format(a_poi[POI::title], 56, "Shop");
            a_poi[POI::id] = l_marketplace[Marketplace::id];
            a_poi[POI::px] = l_marketplace[Marketplace::pos][X];
            a_poi[POI::py] = l_marketplace[Marketplace::pos][Y];
            a_poi[POI::pz] = l_marketplace[Marketplace::pos][Z] + 0.5;
            a_poi[POI::ext1] = l_marketplace[Marketplace::id];
            a_poi[POI::ext2] = 0;
            a_poi[POI::ext3] = 0;
            list_add_arr(p_poi, a_poi);
        }
    }

    new l_plant[ePlant];
    for_list(it : Farming::plant_list) {
        iter_get_arr(it, l_plant);
        if(IsPlayerInRangeOfPoint(playerid, 3.0, VEC3_UNWRAP(l_plant[Plant::pos]))) {
            a_poi[POI::type] = POI_PLANT;
            format(a_poi[POI::title], 56, "Plant");
            a_poi[POI::id] = l_plant[Plant::list_idx];
            a_poi[POI::px] = l_plant[Plant::pos][X];
            a_poi[POI::py] = l_plant[Plant::pos][Y];
            a_poi[POI::pz] = l_plant[Plant::pos][Z] + 0.5;
            a_poi[POI::ext1] = l_plant[Plant::seed_id];
            a_poi[POI::ext2] = GetTS() + l_plant[Plant::harvest_time] - l_plant[Plant::current_time];
            a_poi[POI::ext3] = l_plant[Plant::fertilized];
            list_add_arr(p_poi, a_poi);
        }
    }

    
    if(list_size(p_poi) > 0) {
        new idx=0;
        for_list(it: p_poi) {
            new l_poi[POI::eInfo];
            new Node:l_itemList= JsonObject();
            iter_get_arr(it, l_poi);
            JsonSetInt(l_itemList, "id", l_poi[POI::id]);
            JsonSetInt(l_itemList, "type", l_poi[POI::type]);
            JsonSetFloat(l_itemList, "px", l_poi[POI::px]);
            JsonSetFloat(l_itemList, "py", l_poi[POI::py]);
            JsonSetFloat(l_itemList, "pz", l_poi[POI::pz]);
            JsonSetInt(l_itemList, "ext1", l_poi[POI::ext1]);
            JsonSetInt(l_itemList, "ext2", l_poi[POI::ext2]);
            JsonSetInt(l_itemList, "ext3", l_poi[POI::ext3]);
            JsonSetString(l_itemList, "title", sprintf("%s",l_poi[POI::title]));
            if(idx == 0) {
                node_items_arr = JsonArray(l_itemList);
            } else {
                node_items_arr = JsonAppend(node_items_arr, JsonArray(l_itemList));
            }
            idx++;
        }
    } else {
        node_items_arr = JsonArray();
    }
    
    new Node:payload = JsonObject("items", node_items_arr);
    new l_str[4096];
    JsonStringify(payload,l_str);
    cef_emit_event(playerid, "poi:list", CEFSTR(l_str));
    JsonToggleGC(node_items_arr,true);
    list_delete(p_poi);
    list_delete(l_dropped_item_list);
    return 1;
}
