InitializeMap() {
    printf("[MAP] ColAndreas MAP Initalizing");
    CA_RemoveBarriers();
    MapAndreas_Init(MAP_ANDREAS_MODE_FULL,"scriptfiles/SAFull.hmap");
    CA_Init();
}

InitializeGamemode() {
    mysql_format(MainConn,szQuery,sizeof(szQuery), "%i", 0);
    SetGameModeText(SERVER_GM_TEXT);
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
    ShowNameTags(0);
    SetNameTagDrawDistance(30.0);
    LimitPlayerMarkerRadius(35.0);
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(false);
    ManualVehicleEngineAndLights();
    AllowInteriorWeapons(true);
    InitializeInteriorData();
    CreatePortalObject();

    // Inventory System Item Definition
    task_req_item_def = task_new();
    LoadAllItemsDef();
    //Colandreas

    InitializeMap();
    // AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
    print("\n-------------------------------------------");
    print("Capitol City Roleplay\n");
    print("Copyright (C) Yaaruu");
    print("All Rights Reserved");
    print("-------------------------------------------\n");
    print("Successfully initiated the gamemode...");



    cef_subscribe("gui:escape", "OnCEFGUIEscape");
    cef_subscribe("gui:ready", "OnCEFGUIReady");
    cef_subscribe("gui:play_character", "OnCEFGUIPlayCharacter");

    cef_subscribe("gui:cursorclick", "OnGetUserCursorClick");

    // Inventory
    cef_subscribe("inv:drop_item", "OnGUIPlayerDropItem");
    cef_subscribe("inv:take_item", "OnGUIPlayerTakeItem");
    cef_subscribe("inv:use_item", "OnGUIPlayerInventoryUse");

    // Public sawmill
    cef_subscribe("crft:takeitem", "CrftStorageTakeItem");
    cef_subscribe("crft:storeitem", "CrftStorageStoreItem");
    cef_subscribe("crft:craftitem", "OnCraftItem");

    // Fishing
    cef_subscribe("fishing:started", "OnPlayerFishingStarted");
    cef_subscribe("fishing:success", "OnPlayerFishingSuccess");
    cef_subscribe("fishing:failed", "OnPlayerFishingFailed");
    cef_subscribe("fishing:takefish", "OnPlayerTakeFish");
    cef_subscribe("fishing:releasefish", "OnPlayerReleaseFish");


    // Vehicle
    cef_subscribe("veh:on_put_key", "VehicleOnPutKey");
    cef_subscribe("veh:on_take_key", "VehicleOnTakeKey");
    cef_subscribe("veh:odo_update", "VehicleOnOdoUpdate");

    //Chat
    cef_subscribe("chat:onplayertext", "CEFOnPlayerText");

    //RadMenu
    cef_subscribe("radmenu:on_close", "CEFOnRadMenuClose");
    cef_subscribe("radmenu:on_select", "CEFOnRadMenuSelect");

    // Bank
    cef_subscribe("bank:teller_quit", "CEFBankTellerOnQuit");

    // Item Container
    cef_subscribe("itemcontainer:take_item", "CEFOnItemContTakeItem");
    cef_subscribe("itemcontainer:store_item", "CEFOnItemContStoreItem");

    //admin
    cef_subscribe("admin:get_player_list", "CEFOnGetPlayerlist");

    //market
    cef_subscribe("market:sell_item", "CEFOnMarketSellItem");
    cef_subscribe("market:buy_item", "CEFOnMarketBuyItem");

    //farming
    cef_subscribe("farm:harvest", "CEFOnPlantHarvest");
    cef_subscribe("farm:fertilize", "CEFOnPlantFertilize");
     
    cef_subscribe("action:cancel", "CEFOnActionCancel");

    //misc
    //


    // Setup Interval
    // TODO: Move interval to separate system ?
    SetTimer("SecondInterval", 1000, true);
    SetTimer("AuthProcess", 1000, true);
    SetTimer("MinuteInterval", 1000*60, true);

    SetTimer("HungerInterval", 1000*15, true);
    SetTimer("CraftingTick", 1000, true);
    SetTimer("EngineTick", 1000, true);

    SetTimer("POITick", 500, true);

    SetTimer("InventoryCheckTick", 1000, true);

    FactionSetup();
    InitSystem();

    // Init Job
    JobLumber::Init();
    JobMiner::Init();

    Farming::Init();

    BankTeller::Init();

    Gates::Init();

    auth_queue = list_new();
    canAcceptConnection = true;

#if defined DEBUG_MODE
    printf("[WARNING] DEBUG MODE IS ENABLED! Please make sure this is not Production Server");
#endif
    return 1;
}

deinitGamemode() {
    printf("Game Mode de init");
    foreach(new p : Player) {
        SaveCharacterData(p);
    }

    JobLumber::deInit();
    JobMiner::deInit();
    Farming::deInit();

    BankTeller::deInit();

    // TODO: free itemMap;

    Vehicle::deInit();

    Gates::deInit();

    FactionCleanup();

    ShutdownSystem();
    list_delete(auth_queue);
}
