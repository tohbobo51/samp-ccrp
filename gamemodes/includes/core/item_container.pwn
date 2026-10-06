stock ItemCont::debug_store_req(p_req[ItemCont::EStoreReq]) {
    printf("type:   %s", p_req[ItemCont::type]);
    printf("id:     %i", p_req[ItemCont::id]);
    printf("slot:   %i", p_req[ItemCont::slot]);
    printf("amt:    %i", p_req[ItemCont::amt]);
    return 1;
}

stock ItemCont::debug_take_req(p_req[ItemCont::ETakeReq]) {
    printf("type:   %s", p_req[ItemCont::type]);
    printf("idx:     %i", p_req[ItemCont::idx]);
    printf("id:   %i", p_req[ItemCont::id]);
    printf("amt:    %i", p_req[ItemCont::amt]);
    return 1;
}

callback CEFOnItemContTakeItem(playerid, const arguments[]) {
    new l_req[ItemCont::ETakeReq];
    if(sscanf(arguments, "s[16]iii", 
              l_req[ItemCont::type], 
              l_req[ItemCont::id], 
              l_req[ItemCont::idx], 
              l_req[ItemCont::amt])
    ) {
        printf("Malformed itemcontainer:take_item event arguments");
        printf("\t args: %s", arguments);
        return 0;
    }
    ItemCont::debug_take_req(l_req);
    if(strcmp(l_req[ItemCont::type], "faction") == 0) {
        FactionLocker::OnTakeReq(playerid, l_req);
    }
    if(strcmp(l_req[ItemCont::type], "veh") == 0) {
        VehicleStorage::OnTakeReq(playerid, l_req);
    }
    return 1;
}

callback CEFOnItemContStoreItem(playerid, const arguments[]) {
    new l_req[ItemCont::EStoreReq];
    if(sscanf(arguments, "s[16]iii", 
              l_req[ItemCont::type], 
              l_req[ItemCont::id], 
              l_req[ItemCont::slot], 
              l_req[ItemCont::amt])
    ) {
        printf("Malformed itemcontainer:store_item event arguments");
        printf("\t args: %s", arguments);
        return 0;
    }
    
    ItemCont::debug_store_req(l_req);
    if(strcmp(l_req[ItemCont::type], "faction") == 0) {
        FactionLocker::OnStoreReq(playerid, l_req);
    }
    if(strcmp(l_req[ItemCont::type], "veh") == 0) {
        VehicleStorage::OnStoreReq(playerid, l_req);
    }
    return 1;
}

