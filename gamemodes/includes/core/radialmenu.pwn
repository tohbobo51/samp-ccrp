callback CEFOnOpenRadialMenu(playerid_id, const arguments[]) {
    return 1;
}

callback CEFOnRadMenuClose(player_id, const arguments[]) {
  isPlayerUIInteractable[player_id] = false;
  cef_focus_browser(player_id, GET_BROWSER_ID(player_id), false);
  return 1; 
}

callback CEFOnRadMenuSelect(player_id, const arguments[]) {
    new bool:nextUIState = false;

    if(strcmp(arguments, "veh-engine") == 0) {
        PC_EmulateCommand(player_id, "/engine");
    }

    if(strcmp(arguments, "veh-lights") == 0) {
        PC_EmulateCommand(player_id, "/lights");
    }

    if(strcmp(arguments, "veh-trunk") == 0) {
        PC_EmulateCommand(player_id, "/trunk");
    }

    if(strcmp(arguments, "veh-hood") == 0) {
        PC_EmulateCommand(player_id, "/hood");
    }
    if(strcmp(arguments, "veh-storage") == 0) {
        PC_EmulateCommand(player_id, "/vstorage");
        nextUIState = true;
    }
    isPlayerUIInteractable[player_id] = nextUIState;
    cef_focus_browser(player_id, GET_BROWSER_ID(player_id), nextUIState);
    printf("Player %i select radialmenu: %s", player_id, arguments);
    return 1;
}
