GET_BROWSER_ID(playerid) {
    return playerid + 0x17;
}

public OnCEFGUIEscape(player_id, const arguments[]) {
    HideCEFUI(player_id); 
    return 1;
}

stock UnfocusCEF(player_id) {
    cef_focus_browser(player_id, GET_BROWSER_ID(player_id), false);
    isPlayerUIInteractable[player_id] = false;
    return 1;
}

stock HideCEFUI(player_id) {
    cef_focus_browser(player_id, GET_BROWSER_ID(player_id), false);
    isPlayerUIInteractable[player_id] = false;
    if(Crafting::IsUsingStation(player_id)) {
        new stationId = Crafting::GetStationID(player_id);
        printf("HIDE GUI Craft StationID %i", stationId);
        CraftingStation::SetFree(stationId);
    }
    // if(Sawmill::IsUsingSawmill(player_id)) {
    //     new sawmillId = Sawmill::GetSawmillID(player_id);
    //     Sawmill::SetFree(sawmillId);
    // }
    // if(Smelter::IsUsingSmelter(player_id)) {
    //     new smelterId = Smelter::GetSmelterID(player_id);
    //     Smelter::SetFree(smelterId);
    // }
    if(VehicleFactory::IsUsingFactory(player_id)) {
        VehicleFactory::SetUsingFactory(player_id, 0);
        new facID = VehicleFactory::FactoryID(player_id);
        VehicleFactory::SetFactoryID(player_id, -1);

        VehicleFactory::factories[facID][VehicleFactory::used] = false;
    }

    if(VehicleStorage::IsAccessing(player_id)) {
        new l_vid = VehicleStorage::AccessID(player_id);
        VehicleStorage::SetAccessID(player_id, 0);
        VehicleStorage::SetAccessing(player_id, 0);
        VehicleStorage::SetUsed(l_vid, 0);
    }
    
    if(Fishing::IsFishing(player_id)) {
        Fishing::SetIsFishing(player_id, 0);
        Fishing::SetGotFishID(player_id,-1);
        cef_focus_browser(player_id, GET_BROWSER_ID(player_id), false);
        TogglePlayerControllable(player_id,true);
        ClearAnimations(player_id);
    }
    cef_emit_event(player_id, "ui:escape");
}

public OnCEFGUIReady(player_id, const arguments[]) {
    printf("[DEBUG CEF]: GUI READY for player %i", player_id);
    checkPlayerLoginToken(player_id);
}

public OnCefInitialize(player_id, success) {
    printf("CEF CALLBACK: player %i %d",player_id, success);
    if(!IsPlayerNPC(player_id)) {
        list_add(auth_queue, player_id);
        SendClientMessage(player_id, -1, "[AUTENTIKASI]: Sedang memeriksa akun.");
        SendClientMessage(player_id, -1, "[AUTENTIKASI]: Mohon menunggu...");    
    }
    if (success == 1) {
        // cef_create_browser(player_id, GET_BROWSER_ID(player_id), INTERFACE_BROWSER_URL, false, false);
    }
}

new PlayerBrowserID[MAX_PLAYERS];
public OnCefBrowserCreated(player_id, browser_id, status_code) {
    printf("[DEBUG CEF] Browser Created for %i id %i", player_id, browser_id);
    PlayerBrowserID[player_id] = browser_id;
}

CMD:dton(player_id, params[]) {
    printf("Showing Web Dev tools");
    cef_toggle_dev_tools(player_id, PlayerBrowserID[player_id], true);
}

CMD:dtoff(player_id, params[]) {
    printf("Closing Web Dev tools");
    cef_toggle_dev_tools(player_id, PlayerBrowserID[player_id], false);
}


