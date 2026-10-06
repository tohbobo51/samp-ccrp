callback OnLSPDLockerItemsLoaded() {
    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields);
    
    if(rows > 0) {
        new l_item[eLSPDLockerItem];
        for(new i=0;i<rows;i++) {
            DB::LoadCacheSchema(i, LSPDLocker::Schema, sizeof(LSPDLocker::Schema), l_item);
            l_item[LSPDLockerItem::list_idx] = list_size(LSPD::LockerItems);
            if(l_item[LSPDLockerItem::id] > LSPD::LastLockerID) LSPD::LastLockerID = l_item[LSPDLockerItem::id];
            list_add_arr(LSPD::LockerItems, l_item);
        }
    }
    printf("LSPD Locker Last lockerid = %i", LSPD::LastLockerID);
    
    return 1;
}

LSPD::GetLockerItemIndex(itemid) {
    new l_lockeritem[eLSPDLockerItem];
    new idx = -1;
    for_list(it : LSPD::LockerItems) {
        iter_get_arr(it, l_lockeritem);
        idx++;
        if(l_lockeritem[LSPDLockerItem::item][Item::id] == itemid) return idx;

    }
    return -1;
}

LSPD::InsertLockerItem(const p_item[Inv::eItem]) {
    new l_lockeritem[eLSPDLockerItem];
    new l_itemDef[eItemDef];
    GetItemDefinition(p_item[Item::id], l_itemDef);
    new c_idx = LSPD::GetLockerItemIndex(p_item[Item::id]);
    if(c_idx != -1) {
        list_get_arr(LSPD::LockerItems, c_idx, l_lockeritem);
        new amt_tb_added = l_lockeritem[LSPDLockerItem::item][Item::amount] + p_item[Item::amount];
        if(amt_tb_added >= l_itemDef[ItemDef::max_amount]) {
            new n_lockeritem[eLSPDLockerItem];
            LSPD::LastLockerID++;
            n_lockeritem[LSPDLockerItem::id] = LSPD::LastLockerID;
            n_lockeritem[LSPDLockerItem::list_idx] = list_size(LSPD::LockerItems);
            COPY_ARRAY(p_item, n_lockeritem[LSPDLockerItem::item], Inv::eItem)
            new l_remain_amt = l_itemDef[ItemDef::max_amount] - l_lockeritem[LSPDLockerItem::item][Item::amount]; // how much we can store in the same slot
            l_lockeritem[LSPDLockerItem::item][Item::amount] += l_remain_amt; // add that to the current slot
            n_lockeritem[LSPDLockerItem::item][Item::amount] = p_item[Item::amount] - l_remain_amt; // give the remaining to the new slot
            list_set_arr(LSPD::LockerItems, c_idx, l_lockeritem);

            
            printf("Updating Locker DB");
            DB::MakeUpdateQuery("lspd_locker", LSPDLocker::Schema, sizeof(LSPDLocker::Schema));
            DB::PopulateUpdateQuery(LSPDLocker::Schema, sizeof(LSPDLocker::Schema), l_lockeritem);
            mysql_tquery(MainConn,szQuery);
            
            list_add_arr(LSPD::LockerItems, n_lockeritem);
           
            printf("Inserting new locker item");
            DB::MakeInsertQuery("lspd_locker", LSPDLocker::Schema, sizeof(LSPDLocker::Schema),true);
            DB::PopulateInsertQuery(LSPDLocker::Schema, sizeof(LSPDLocker::Schema), n_lockeritem, true);
            mysql_tquery(MainConn,szQuery);
        } else {
            l_lockeritem[LSPDLockerItem::item][Item::amount] += p_item[Item::amount];
            list_set_arr(LSPD::LockerItems, l_lockeritem[LSPDLockerItem::list_idx], l_lockeritem);

            printf("Updating Locker DB");
            DB::MakeUpdateQuery("lspd_locker", LSPDLocker::Schema, sizeof(LSPDLocker::Schema));
            DB::PopulateUpdateQuery(LSPDLocker::Schema, sizeof(LSPDLocker::Schema), l_lockeritem);
            mysql_tquery(MainConn,szQuery);
        }
    } else {
        LSPD::LastLockerID++;
        l_lockeritem[LSPDLockerItem::id] = LSPD::LastLockerID;
        l_lockeritem[LSPDLockerItem::list_idx] = list_size(LSPD::LockerItems);
        COPY_ARRAY(p_item, l_lockeritem[LSPDLockerItem::item], Inv::eItem)
        list_add_arr(LSPD::LockerItems, l_lockeritem);
        DB::MakeInsertQuery("lspd_locker", LSPDLocker::Schema, sizeof(LSPDLocker::Schema), true);
        DB::PopulateInsertQuery(LSPDLocker::Schema, sizeof(LSPDLocker::Schema), l_lockeritem, true);
        mysql_tquery(MainConn,szQuery);
    }
    return 1;
}

LSPD::OnLockerStoreReq(playerid, const p_req[ItemCont::EStoreReq]) {
    if(p_req[ItemCont::amt] < 1) return 0;
 
    new l_item[Inv::eItem];
    new l_slot = p_req[ItemCont::slot];
    if(l_slot > (list_size(PlayerInventoryList[playerid])-1)) return 0;
    new l_cinv[CharacterInv::eInfo];
    list_get_arr(PlayerInventoryList[playerid], l_slot, l_cinv);
    COPY_ARRAY(l_cinv[CharacterInv::item], l_item, Inv::eItem)
    l_item[Item::amount] = p_req[ItemCont::amt];
    if(TakePlayerItem(playerid, l_slot, p_req[ItemCont::amt]) == -1) {
        printf("[ERROR] Can't take player item in LSPD::OnLockerStoreReq()");
        return -1;
    }
    Item::Print(l_item);
    LSPD::InsertLockerItem(l_item);
    GUI_Emit_InventoryItems(playerid);
    LSPD::GUI_Emit_ContainerList(playerid);
    return 1;
}

LSPD::TakeLockerItem(index, p_amount) {
    if(index >= list_size(LSPD::LockerItems)) return 0;
    new l_lockeritem[eLSPDLockerItem];
    list_get_arr(LSPD::LockerItems, index, l_lockeritem);
    if(l_lockeritem[LSPDLockerItem::item][Item::amount] < p_amount) return 0;
    if(l_lockeritem[LSPDLockerItem::item][Item::amount] == p_amount) {
        DB::MakeDeleteRow("lspd_locker", l_lockeritem[LSPDLockerItem::id]);
        mysql_tquery(MainConn,szQuery);
        list_remove(LSPD::LockerItems, index);
        new idx = 0; 
        for_list(it: LSPD::LockerItems) {
            iter_set_cell(it, LSPDLockerItem::list_idx, idx);
            idx++;
        }
    } else {
        l_lockeritem[LSPDLockerItem::item][Item::amount] -= p_amount;
        list_set_arr(LSPD::LockerItems, index, l_lockeritem);

        printf("Updating Locker DB");
        DB::MakeUpdateQuery("lspd_locker", LSPDLocker::Schema, sizeof(LSPDLocker::Schema));
        DB::PopulateUpdateQuery(LSPDLocker::Schema, sizeof(LSPDLocker::Schema), l_lockeritem);
        mysql_tquery(MainConn,szQuery);
    }
    return 1;
}

LSPD::OnLockerTakeReq(playerid, const p_req[ItemCont::ETakeReq]) {
    if(p_req[ItemCont::amt] < 1) return 0;
    new l_lockeritem[eLSPDLockerItem];
    
    if(!list_get_arr(LSPD::LockerItems, p_req[ItemCont::idx],l_lockeritem)) {
        return 0;
    }
    new l_item[Inv::eItem];
    COPY_ARRAY(l_lockeritem[LSPDLockerItem::item], l_item, Inv::eItem)
    Item::Print(l_item);
    l_item[Item::amount] = p_req[ItemCont::amt];
    if(LSPD::TakeLockerItem(p_req[ItemCont::idx], p_req[ItemCont::amt])) {
        GivePlayerItem(playerid, l_item);
    }
    GUI_Emit_InventoryItems(playerid);
    LSPD::GUI_Emit_ContainerList(playerid);
    return 1;
}

LSPD::ShowLockerToPlayer(playerid) {
    cef_emit_event(playerid, "chat:closeinput");
    GUI_Emit_InventoryItems(playerid);
    new Node:node = JsonObject();
    JsonSetString(node, "name", sprintf("LSPD Locker"));
    JsonSetString(node, "type", sprintf("lspd"));
    JsonSetInt(node, "id", 1);
    new l_str[2048];
    JsonStringify(node,l_str);
    cef_emit_event(playerid, "itemcontainer:show", CEFSTR(l_str));
    await task_ms(100); 
    cef_emit_event(playerid, "inventory:open");
    LSPD::GUI_Emit_ContainerList(playerid);
    return 1;
}

LSPD::GUI_Emit_ContainerList(playerid) {
    new Node:node_items_arr;
    JsonToggleGC(node_items_arr, false);
    new foundCount = 0; 
    new l_item[eLSPDLockerItem];
    for_list(it : LSPD::LockerItems) {
        if(!iter_get_arr_safe(it, l_item)) continue;
        new Node:l_itemList= JsonObject();
        JsonSetInt(l_itemList, "idx", l_item[LSPDLockerItem::list_idx]);
        JsonSetInt(l_itemList, "id", l_item[LSPDLockerItem::item][Item::id]);
        JsonSetInt(l_itemList, "amt", l_item[LSPDLockerItem::item][Item::amount]);
        JsonSetInt(l_itemList, "dur", l_item[LSPDLockerItem::item][Item::durability]);
        JsonSetInt(l_itemList, "pwr", l_item[LSPDLockerItem::item][Item::power]);
        JsonSetInt(l_itemList, "add1", l_item[LSPDLockerItem::item][Item::addon1]);
        JsonSetInt(l_itemList, "add2", l_item[LSPDLockerItem::item][Item::addon2]);
        JsonSetInt(l_itemList, "add3", l_item[LSPDLockerItem::item][Item::addon3]);
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
