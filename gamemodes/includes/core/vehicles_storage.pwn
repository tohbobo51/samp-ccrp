VehicleStorage::ShowToPlayer(vehicle_id, playerid) {
    new vstor_map[eVehicleStorageMap];
    map_get_arr(VehicleStorage::map, vehicle_id, vstor_map);
    cef_emit_event(playerid, "chat:closeinput");
    GUI_Emit_InventoryItems(playerid);
    VehicleStorage::EmitUpdate(vehicle_id, vstor_map, playerid);
    await task_ms(100);
    cef_emit_event(playerid, "inventory:open");
    return 1;
}

VehicleStorage::EmitUpdate(vehicle_id, const vstor_map[eVehicleStorageMap], playerid) {
    new Node:node = JsonObject();
    JsonSetString(node, "name", sprintf("Vehicle Storage"));
    JsonSetString(node, "type", sprintf("veh"));
    JsonSetInt(node, "max_capacity", vstor_map[VehicleStorage::max_capacity]);
    JsonSetInt(node, "current_capacity", vstor_map[VehicleStorage::current_capacity]);
    JsonSetInt(node, "id", vehicle_id);
    new l_str[2048];
    JsonStringify(node, l_str);
    cef_emit_event(playerid, "itemcontainer:show", CEFSTR(l_str));
    VehicleStorage::EmitContainer(vstor_map, playerid);
    return 1;
}

VehicleStorage::GetItemIndex(List:list, itemid) {
    new l_storageitem[eVehicleStorageItem];
    new itemDef[eItemDef];
    GetItemDefinition(itemid, itemDef);
    new idx = -1;
    for_list(it : list) {
        iter_get_arr(it, l_storageitem);
        idx++;
        if(l_storageitem[VehStorageItem::item][Item::id] == itemid) {
            if(l_storageitem[VehStorageItem::item][Item::amount] < itemDef[ItemDef::max_amount]) return idx;
        }
    }
    return -1;
}

VehicleStorage::TakeItem(vehicle_id, vstore[eVehicleStorageMap], index, p_amount) {
    if(index >= list_size(vstore[VehicleStorage::items])) return 0;
    new l_storageitem[eVehicleStorageItem];
    list_get_arr(vstore[VehicleStorage::items], index, l_storageitem);
    new l_itemDef[eItemDef];
    GetItemDefinition(l_storageitem[VehStorageItem::item][Item::id], l_itemDef);
    if(l_storageitem[VehStorageItem::item][Item::amount] < p_amount) return 0;
    if(l_storageitem[VehStorageItem::item][Item::amount] == p_amount) {
        DB::MakeDeleteRow("vehicle_storage", l_storageitem[VehStorageItem::id]);
        mysql_tquery(MainConn, szQuery);
        list_remove(vstore[VehicleStorage::items], index);
        new idx = 0;
        for_list(it: vstore[VehicleStorage::items]) {
            iter_set_cell(it, VehStorageItem::list_idx, idx);
            idx++;
        }
    } else {
        l_storageitem[VehStorageItem::item][Item::amount] -= p_amount;
        list_set_arr(vstore[VehicleStorage::items], index, l_storageitem);
        DB::MakeUpdateQuery("vehicle_storage", VehicleStorage::Schema, sizeof(VehicleStorage::Schema));
        DB::PopulateUpdateQuery(VehicleStorage::Schema, sizeof(VehicleStorage::Schema), l_storageitem);
        mysql_tquery(MainConn,szQuery);
    }
    vstore[VehicleStorage::current_capacity] -= p_amount * l_itemDef[ItemDef::weight];
    map_set_arr(VehicleStorage::map, vehicle_id, vstore);
    return 1;
}

VehicleStorage::OnTakeReq(playerid, const p_req[ItemCont::ETakeReq]) {
    if(p_req[ItemCont::amt] < 1) return 0;
    new vid = p_req[ItemCont::id];
    new vstor_map[eVehicleStorageMap];
    if(!map_get_arr(VehicleStorage::map, vid, vstor_map)) return 0;
    
    new l_storageitem[eVehicleStorageItem];
    if(!list_get_arr(vstor_map[VehicleStorage::items], p_req[ItemCont::idx], l_storageitem)) {
        return 0;
    }
    new l_item[Inv::eItem];
    COPY_ARRAY(l_storageitem[VehStorageItem::item], l_item, Inv::eItem)
    l_item[Item::amount] = p_req[ItemCont::amt];
    if(VehicleStorage::TakeItem(vid, vstor_map, p_req[ItemCont::idx], p_req[ItemCont::amt])) {
        GivePlayerItem(playerid, l_item);
    }
    GUI_Emit_InventoryItems(playerid);
    VehicleStorage::EmitUpdate(vid, vstor_map, playerid);
    return 1; 
}

VehicleStorage::StoreItem(vehicle_id, vstore[eVehicleStorageMap], const p_item[Inv::eItem]) {
    new l_storageitem[eVehicleStorageItem];
    new l_itemDef[eItemDef];
    GetItemDefinition(p_item[Item::id], l_itemDef);
    new vData[Vehicle::e_Data];
    map_get_arr(Vehicle::list, vehicle_id, vData);
    new c_idx = VehicleStorage::GetItemIndex(vstore[VehicleStorage::items], p_item[Item::id]);
    if(c_idx != -1) { // existing storage item
        list_get_arr(vstore[VehicleStorage::items], c_idx, l_storageitem);
        new amt_tb_added = l_storageitem[VehStorageItem::item][Item::amount] + p_item[Item::amount];
        if(amt_tb_added >= l_itemDef[ItemDef::max_amount]) { // slot full add to new
            new n_storageitem[eVehicleStorageItem];
            VehicleStorage::LastItemID++;
            n_storageitem[VehStorageItem::id] = VehicleStorage::LastItemID;
            n_storageitem[VehStorageItem::list_idx] = list_size(vstore[VehicleStorage::items]);
            n_storageitem[VehStorageItem::vehicle_id] = vData[VehicleData::id];
            
            COPY_ARRAY(p_item, n_storageitem[VehStorageItem::item], Inv::eItem)
            new l_remain_amt = l_itemDef[ItemDef::max_amount] - l_storageitem[VehStorageItem::item][Item::amount];
            l_storageitem[VehStorageItem::item][Item::amount] += l_remain_amt;
            n_storageitem[VehStorageItem::item][Item::amount] = p_item[Item::amount] - l_remain_amt;
            list_set_arr(vstore[VehicleStorage::items], c_idx, l_storageitem);

            DB::MakeUpdateQuery("vehicle_storage", VehicleStorage::Schema, sizeof(VehicleStorage::Schema));
            DB::PopulateUpdateQuery(VehicleStorage::Schema, sizeof(VehicleStorage::Schema), l_storageitem);
            mysql_tquery(MainConn, szQuery);

            list_add_arr(vstore[VehicleStorage::items], n_storageitem);
            DB::MakeInsertQuery("vehicle_storage", VehicleStorage::Schema, sizeof(VehicleStorage::Schema));
            DB::PopulateInsertQuery(VehicleStorage::Schema, sizeof(VehicleStorage::Schema), n_storageitem);
            mysql_tquery(MainConn,szQuery);
        } else {
            l_storageitem[VehStorageItem::item][Item::amount] += p_item[Item::amount];
            list_set_arr(vstore[VehicleStorage::items], l_storageitem[VehStorageItem::list_idx], l_storageitem);
            
            DB::MakeUpdateQuery("vehicle_storage", VehicleStorage::Schema, sizeof(VehicleStorage::Schema));
            DB::PopulateUpdateQuery(VehicleStorage::Schema, sizeof(VehicleStorage::Schema), l_storageitem);
            mysql_tquery(MainConn, szQuery);
        }
    } else { // new storage item
        VehicleStorage::LastItemID++;
        l_storageitem[VehStorageItem::id] = VehicleStorage::LastItemID;
        l_storageitem[VehStorageItem::list_idx] = list_size(vstore[VehicleStorage::items]);
        l_storageitem[VehStorageItem::vehicle_id] = vData[VehicleData::id];
        COPY_ARRAY(p_item, l_storageitem[VehStorageItem::item], Inv::eItem)
    
        list_add_arr(vstore[VehicleStorage::items], l_storageitem);
        DB::MakeInsertQuery("vehicle_storage", VehicleStorage::Schema, sizeof(VehicleStorage::Schema));
        DB::PopulateInsertQuery(VehicleStorage::Schema, sizeof(VehicleStorage::Schema), l_storageitem);
        mysql_tquery(MainConn,szQuery);
    }
    vstore[VehicleStorage::current_capacity] += p_item[Item::amount] * l_itemDef[ItemDef::weight];
    map_set_arr(VehicleStorage::map, vehicle_id, vstore);
    return 1;
}



VehicleStorage::OnStoreReq(playerid, const p_req[ItemCont::EStoreReq]) {
    if(p_req[ItemCont::amt] < 1) return 0;
    new vid = p_req[ItemCont::id];
    new vstor_map[eVehicleStorageMap];
    if(!map_get_arr(VehicleStorage::map, vid, vstor_map)) return 0;
    
    new l_item[Inv::eItem];
    new l_slot = p_req[ItemCont::slot];
    if(l_slot > (list_size(PlayerInventoryList[playerid])-1)) return 0;
    new l_cinv[CharacterInv::eInfo];
    list_get_arr(PlayerInventoryList[playerid], l_slot, l_cinv);
    COPY_ARRAY(l_cinv[CharacterInv::item], l_item, Inv::eItem)
    l_item[Item::amount] = p_req[ItemCont::amt];
  
    new l_itemDef[eItemDef];
    GetItemDefinition(l_item[Item::id], l_itemDef);
    new cCap = vstor_map[VehicleStorage::current_capacity];
    new mCap = vstor_map[VehicleStorage::max_capacity];
    new addedCap = cCap + (l_item[Item::amount] * l_itemDef[ItemDef::weight]);
    if(addedCap > mCap) {
        EMIT_PlayerSystemChat(playerid, -1, "STORAGE: Tidak bisa menambahkan item, kapasitas penuh.");
        return 0;
    }
    if(TakePlayerItem(playerid, l_slot, p_req[ItemCont::amt]) == -1) {
        printf("[ERROR] Can't take player item in VehicleStorage::OnStoreReq");
        return 0;
    }
    VehicleStorage::StoreItem(vid, vstor_map, l_item);
    GUI_Emit_InventoryItems(playerid);
    VehicleStorage::EmitUpdate(vid, vstor_map, playerid);
    return 1;
}

Task:VehicleStorage::LoadStorage(vehicle_id) {
    new Task:task_load = task_new();
    new vData[Vehicle::e_Data];
    if(!map_has_key(Vehicle::list, vehicle_id)) {
        printf("Load Storage error, invalid vehicle %i", vehicle_id);
        task_set_result_ms(task_load, false, 100);
        return task_load;
    }
    map_get_arr(Vehicle::list, vehicle_id, vData);
    mysql_format(MainConn, szQuery, sizeof(szQuery), "SELECT * FROM `vehicle_storage` WHERE vehicle_id='%i'", vData[VehicleData::id]);
    printf(szQuery);
    mysql_tquery(MainConn, szQuery, "OnVehicleStorageLoaded", "ii", vehicle_id, _:task_load);
    return task_load;
}

callback OnVehicleStorageLoaded(vehicle_id, task_load) {
    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields);
    new vData[Vehicle::e_Data];
    map_get_arr(Vehicle::list, vehicle_id, vData);

    new storage_item[eVehicleStorageItem];
    new l_itemDef[eItemDef];
    new vstor_map[eVehicleStorageMap];
    new List:item_list;
    if(!map_has_key(VehicleStorage::map, vehicle_id)) {
        item_list = list_new();
        vstor_map[VehicleStorage::max_capacity] = Vehicle::MODEL_STORAGE[vData[VehicleData::modelid]-MIN_VEHICLE_MODEL] * 1000;
        vstor_map[VehicleStorage::items] = item_list;
        vstor_map[VehicleStorage::current_capacity] = 0;
        vstor_map[VehicleStorage::is_dirty] = false;
        if(rows > 0) {
            for(new i=0;i<rows;i++) {
                DB::LoadCacheSchema(i, VehicleStorage::Schema, sizeof(VehicleStorage::Schema), storage_item);
                GetItemDefinition(storage_item[VehStorageItem::item][Item::id], l_itemDef);
                storage_item[VehStorageItem::list_idx] = list_size(item_list);
                storage_item[VehStorageItem::vehicle_id] = vData[VehicleData::id];
                vstor_map[VehicleStorage::current_capacity] += l_itemDef[ItemDef::weight] * storage_item[VehStorageItem::item][Item::amount];
                list_add_arr(item_list, storage_item);
            }
        }
        map_add_arr(VehicleStorage::map, vehicle_id, vstor_map);
    } else {
        printf("Storage already loaded");
    }
    task_set_result(Task:task_load, true);
    printf("Vehicle Storage Loaded! id: %i | rows: %i", vData[VehicleData::id], rows);
    return 1;
}

stock VehicleStorage::EmitContainer(const vstor_map[eVehicleStorageMap], playerid) {
    new Node:node_items_arr;
    JsonToggleGC(node_items_arr, false);
    new foundCount = 0; 
    new l_item[eVehicleStorageItem];
    for_list(it : vstor_map[VehicleStorage::items]) {
        if(!iter_get_arr_safe(it, l_item)) continue;
        new Node:l_itemList= JsonObject();
        JsonSetInt(l_itemList, "idx", l_item[VehStorageItem::list_idx]);
        JsonSetInt(l_itemList, "id", l_item[VehStorageItem::item][Item::id]);
        JsonSetInt(l_itemList, "amt", l_item[VehStorageItem::item][Item::amount]);
        JsonSetInt(l_itemList, "dur", l_item[VehStorageItem::item][Item::durability]);
        JsonSetInt(l_itemList, "pwr", l_item[VehStorageItem::item][Item::power]);
        JsonSetInt(l_itemList, "add1", l_item[VehStorageItem::item][Item::addon1]);
        JsonSetInt(l_itemList, "add2", l_item[VehStorageItem::item][Item::addon2]);
        JsonSetInt(l_itemList, "add3", l_item[VehStorageItem::item][Item::addon3]);
        if(foundCount == 0) {
            node_items_arr = JsonArray(l_itemList);
        } else {
            node_items_arr = JsonAppend(node_items_arr, JsonArray(l_itemList));
        } 
        foundCount++;
    }
    if(foundCount == 0) {
        node_items_arr = JsonArray();
    }
    new Node:node_player_inv = JsonObject("items", node_items_arr);
    new l_str[2048];
    JsonStringify(node_player_inv,l_str);
    cef_emit_event(playerid, "itemcontainer:got_item_list", CEFSTR(l_str));
    JsonToggleGC(node_items_arr,true);
}
