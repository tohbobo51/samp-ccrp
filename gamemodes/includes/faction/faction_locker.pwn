FactionLocker::LoadLockers() {
    for(new i=1;i<_:Faction::MAX_FACTION;i++) {
        szQuery[0] = 0;
        FactionLocker::LockerItems[eFaction:i] = list_new();
        mysql_format(MainConn, szQuery, sizeof(szQuery), "SELECT * FROM faction_locker WHERE `faction_id`='%i'", i);
        mysql_tquery(MainConn, szQuery, "OnFactionLockerLoaded", "d", i);
    }
}

FactionLocker::Cleanup() {
    for(new i=1;i<_:Faction::MAX_FACTION;i++) {
        list_delete(FactionLocker::LockerItems[eFaction:i]);
    }
    return 1;
}

callback OnFactionLockerLoaded(factionid) {
    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields);
    new l_item[eLockerItem];
    if(rows > 0) {
        for(new i=0;i<rows;i++) {
            DB::LoadCacheSchema(i, FactionLocker::Schema, sizeof(FactionLocker::Schema), l_item);
            l_item[FactionLockerItem::list_idx] = list_size(FactionLocker::LockerItems[eFaction:factionid]);
            list_add_arr(FactionLocker::LockerItems[eFaction:factionid], l_item);
        }
    }
    return 1;
}

FactionLocker::GetLockerItemIndex(eFaction:factionid, itemid) {
    new l_lockeritem[eLockerItem];
    new itemDef[eItemDef];
    GetItemDefinition(itemid, itemDef);
    new idx = -1;
    for_list(it : FactionLocker::LockerItems[factionid]) {
        iter_get_arr(it, l_lockeritem);
        idx++;
        if(l_lockeritem[FactionLockerItem::item][Item::id] == itemid) {
            if(l_lockeritem[FactionLockerItem::item][Item::amount] < itemDef[ItemDef::max_amount]) return idx;
        }
    }
    return -1;
}

FactionLocker::InsertItem(eFaction:factionid, const p_item[Inv::eItem]) {
    new l_lockeritem[eLockerItem];
    new l_itemDef[eItemDef];
    GetItemDefinition(p_item[Item::id], l_itemDef);
    new c_idx = FactionLocker::GetLockerItemIndex(factionid, p_item[Item::id]);
    if(c_idx != -1) {
        list_get_arr(FactionLocker::LockerItems[factionid], c_idx, l_lockeritem);
        new amt_tb_added = l_lockeritem[FactionLockerItem::item][Item::amount] + p_item[Item::amount];
        if(amt_tb_added >= l_itemDef[ItemDef::max_amount]) {
            new n_lockeritem[eLockerItem];
            COPY_ARRAY(p_item, n_lockeritem[FactionLockerItem::item], Inv::eItem)
            new l_remain_amt = l_itemDef[ItemDef::max_amount] - l_lockeritem[FactionLockerItem::item][Item::amount]; // how much we can store in the same slot
            l_lockeritem[FactionLockerItem::item][Item::amount] += l_remain_amt; // add that to the current slot
            n_lockeritem[FactionLockerItem::item][Item::amount] = p_item[Item::amount] - l_remain_amt; // give the remaining to the new slot
            n_lockeritem[FactionLockerItem::faction_id] = factionid;
            
            printf("Inserting new locker item");
            DB::MakeInsertQuery("faction_locker", FactionLocker::Schema, sizeof(FactionLocker::Schema));
            DB::PopulateInsertQuery(FactionLocker::Schema, sizeof(FactionLocker::Schema), n_lockeritem);
            
            new Task:insert_task = task_new();
            mysql_tquery(MainConn,szQuery, "OnLockerItemInserted", "iaii", factionid, n_lockeritem, sizeof(n_lockeritem), _:insert_task);
            await insert_task;
            
            printf("Updating Locker DB");
            DB::MakeUpdateQuery("faction_locker", FactionLocker::Schema, sizeof(FactionLocker::Schema));
            DB::PopulateUpdateQuery(FactionLocker::Schema, sizeof(FactionLocker::Schema), l_lockeritem);
            mysql_tquery(MainConn,szQuery);
            list_set_arr(FactionLocker::LockerItems[factionid], c_idx, l_lockeritem);
        } else {
            l_lockeritem[FactionLockerItem::item][Item::amount] += p_item[Item::amount];
            list_set_arr(FactionLocker::LockerItems[factionid], l_lockeritem[FactionLockerItem::list_idx], l_lockeritem);

            printf("Updating Locker DB");
            DB::MakeUpdateQuery("faction_locker", FactionLocker::Schema, sizeof(FactionLocker::Schema));
            DB::PopulateUpdateQuery(FactionLocker::Schema, sizeof(FactionLocker::Schema), l_lockeritem);
            mysql_tquery(MainConn,szQuery);
        }
    } else {
        COPY_ARRAY(p_item, l_lockeritem[FactionLockerItem::item], Inv::eItem)
        DB::MakeInsertQuery("faction_locker", FactionLocker::Schema, sizeof(FactionLocker::Schema), true);
        DB::PopulateInsertQuery(FactionLocker::Schema, sizeof(FactionLocker::Schema), l_lockeritem, true);
        new Task:insert_task = task_new();
        mysql_tquery(MainConn,szQuery, "OnLockerItemInserted", "iaii", factionid, l_lockeritem, sizeof(l_lockeritem), _:insert_task);
        await insert_task;
    }
    return 1;
}

callback OnLockerItemInserted(eFaction:factionid, n_lockeritem[eLockerItem], arr_size, task) {
    new l_insert_id = cache_insert_id();
    n_lockeritem[FactionLockerItem::id] = l_insert_id;
    n_lockeritem[FactionLockerItem::list_idx] = list_size(FactionLocker::LockerItems[factionid]);
    list_add_arr(FactionLocker::LockerItems[factionid], n_lockeritem);
    task_set_result(Task:task, true);
    return 1;
}

FactionLocker::OnStoreReq(playerid, const p_req[ItemCont::EStoreReq]) {
    if(p_req[ItemCont::amt] < 1) return 0;
    new eFaction:factionid = eFaction:p_req[ItemCont::id];
    new l_item[Inv::eItem];
    new l_slot = p_req[ItemCont::slot];
    if(l_slot > (list_size(PlayerInventoryList[playerid])-1)) return 0;
    new l_cinv[CharacterInv::eInfo];
    list_get_arr(PlayerInventoryList[playerid], l_slot, l_cinv);
    COPY_ARRAY(l_cinv[CharacterInv::item], l_item, Inv::eItem)
    l_item[Item::amount] = p_req[ItemCont::amt];
    if(TakePlayerItem(playerid, l_slot, p_req[ItemCont::amt]) == -1) {
        Logger_Err("failed to take player item", 
                   Logger_S("module", "FactionLocker"), 
                   Logger_I("playerid", playerid),
                   Logger_I("factionid", factionid)
                   );
        return -1;
    }
    Item::Print(l_item);
    FactionLocker::InsertItem(factionid, l_item);
    GUI_Emit_InventoryItems(playerid);
    FactionLocker::GUI_Emit_List(playerid, factionid);
    return 1;
}

FactionLocker::TakeItem(eFaction:factionid, index, p_amount) {
    if(index >= list_size(FactionLocker::LockerItems[factionid])) return 0;
    new l_lockeritem[eLockerItem];
    list_get_arr(FactionLocker::LockerItems[factionid], index, l_lockeritem);
    if(l_lockeritem[FactionLockerItem::item][Item::amount] < p_amount) return 0;
    if(l_lockeritem[FactionLockerItem::item][Item::amount] == p_amount) {
        DB::MakeDeleteRow("faction_locker", l_lockeritem[FactionLockerItem::id]);
        mysql_tquery(MainConn,szQuery);
        list_remove(FactionLocker::LockerItems[factionid], index);
        new idx = 0; 
        for_list(it: FactionLocker::LockerItems[factionid]) {
            iter_set_cell(it, FactionLockerItem::list_idx, idx);
            idx++;
        }
    } else {
        l_lockeritem[FactionLockerItem::item][Item::amount] -= p_amount;
        list_set_arr(FactionLocker::LockerItems[factionid], index, l_lockeritem);

        Logger_Dbg("locker", "updating locker db", Logger_I("faction", factionid));
        DB::MakeUpdateQuery("faction_locker", FactionLocker::Schema, sizeof(FactionLocker::Schema));
        DB::PopulateUpdateQuery(FactionLocker::Schema, sizeof(FactionLocker::Schema), l_lockeritem);
        mysql_tquery(MainConn,szQuery);
    }
    return 1;
}

FactionLocker::OnTakeReq(playerid, const p_req[ItemCont::ETakeReq]) {
    if(p_req[ItemCont::amt] < 1) return 0;
    new eFaction:factionid = eFaction:p_req[ItemCont::id];
    new l_lockeritem[eLockerItem];
    if(!list_get_arr(FactionLocker::LockerItems[factionid], p_req[ItemCont::idx],l_lockeritem)) {
        return 0;
    }
    new l_item[Inv::eItem];
    COPY_ARRAY(l_lockeritem[FactionLockerItem::item], l_item, Inv::eItem)
    Item::Print(l_item);
    l_item[Item::amount] = p_req[ItemCont::amt];
    if(FactionLocker::TakeItem(factionid, p_req[ItemCont::idx], p_req[ItemCont::amt])) {
        GivePlayerItem(playerid, l_item);
    }
    GUI_Emit_InventoryItems(playerid);
    FactionLocker::GUI_Emit_List(playerid, factionid);
    return 1;
}


FactionLocker::ShowToPlayer(playerid, eFaction:factionid) {
    cef_emit_event(playerid, "chat:closeinput");
    GUI_Emit_InventoryItems(playerid);
    new Node:node = JsonObject();
    JsonSetString(node, "name", sprintf("%s Locker", Faction::NAME[eFaction:factionid]));
    JsonSetString(node, "type", sprintf("faction"));
    JsonSetInt(node, "id", factionid);
    new l_str[2048];
    JsonStringify(node,l_str);
    cef_emit_event(playerid, "itemcontainer:show", CEFSTR(l_str));
    await task_ms(100); 
    cef_emit_event(playerid, "inventory:open");
    FactionLocker::GUI_Emit_List(playerid, factionid);
    return 1;
}

FactionLocker::GUI_Emit_List(playerid, eFaction:factionid) {
    new Node:node_items_arr;
    JsonToggleGC(node_items_arr, false);
    new foundCount = 0; 
    new l_item[eLockerItem];
    for_list(it : FactionLocker::LockerItems[factionid]) {
        if(!iter_get_arr_safe(it, l_item)) continue;
        new Node:l_itemList= JsonObject();
        JsonSetInt(l_itemList, "idx", l_item[FactionLockerItem::list_idx]);
        JsonSetInt(l_itemList, "id", l_item[FactionLockerItem::item][Item::id]);
        JsonSetInt(l_itemList, "amt", l_item[FactionLockerItem::item][Item::amount]);
        JsonSetInt(l_itemList, "dur", l_item[FactionLockerItem::item][Item::durability]);
        JsonSetInt(l_itemList, "pwr", l_item[FactionLockerItem::item][Item::power]);
        JsonSetInt(l_itemList, "add1", l_item[FactionLockerItem::item][Item::addon1]);
        JsonSetInt(l_itemList, "add2", l_item[FactionLockerItem::item][Item::addon2]);
        JsonSetInt(l_itemList, "add3", l_item[FactionLockerItem::item][Item::addon3]);
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
