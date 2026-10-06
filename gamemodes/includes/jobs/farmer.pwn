#include <pp-hooks>

hook OnPlayerConnect(playerid) {
    Farming::SetLandID(playerid, -1);
    Farming::SetPlantID(playerid, -1);
}
hook OnPlayerEnterDynArea(playerid, areaid) {
    if(Streamer_HasIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_LAND_ID))) {
        new strm_land_id = Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_LAND_ID));
        Logger_Dbg("farming", "player enter land", Logger_I("playerid", playerid), Logger_I("areaid", areaid), Logger_I("land_id", strm_land_id));
        await task_ms(100);
        Farming::SetLandID(playerid, strm_land_id);
    }
    if(Streamer_HasIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_PLANT_ID))) {
        new strm_plant_id = Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_PLANT_ID));
        Logger_Dbg("farming", "player enter plant", Logger_I("playerid", playerid), Logger_I("areaid", areaid), Logger_I("plant_id", strm_plant_id));
        await task_ms(100);
        Farming::SetPlantID(playerid, strm_plant_id);
    }
}

hook OnPlayerLeaveDynArea(playerid, areaid) {
    if(Streamer_HasIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_LAND_ID))) {
        new strm_land_id = Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_LAND_ID));
        if(Farming::LandID(playerid) == strm_land_id) {
            Farming::SetLandID(playerid, -1);
        }
    }
    
    if(Streamer_HasIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_PLANT_ID))) {
        new strm_plant_id = Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_PLANT_ID));
        if(Farming::PlantID(playerid) == strm_plant_id) {
            Farming::SetPlantID(playerid, -1);
        }
    }
}

callback CEFOnPlantHarvest(playerid, arguments[]) {
    new plant_idx;
    if(sscanf(arguments, "i", plant_idx)) {
        Logger_Err("cef_plant_harvest. invalid args", Logger_S("args", arguments));
        return 0;
    }
    Farming::Harvest(playerid, plant_idx); 
    return 1;
}

callback CEFOnPlantFertilize(playerid, arguments[]) {
    new plant_idx;
    if(sscanf(arguments, "i", plant_idx)) {
        Logger_Err("cef_plant_fertilize failed. invalid args", Logger_S("args", arguments));
        return 0;
    }
    Farming::Fertilize(playerid, plant_idx); 
    return 1;
}

Farming::Tick() {
    new plant[ePlant];
    for_list(it : Farming::plant_list) {
        iter_get_arr(it, plant);
        if(!plant[Plant::can_harvest]) {
            plant[Plant::current_time]++;
            if(plant[Plant::current_time] >= plant[Plant::harvest_time]) {
                plant[Plant::can_harvest] = 1;
                plant[Plant::current_time] = plant[Plant::harvest_time];
            }
            iter_set_arr(it, plant);
        }
    }
    return 1;
}

Farming::Harvest(playerid, plant_idx) {
    new plant[ePlant];
    new l_list_size = list_size(Farming::plant_list);
    if(l_list_size < plant_idx) {
        Logger_Err("invalid list index", Logger_S("module", "farming"), Logger_I("plant_idx", plant_idx), Logger_I("list_size", l_list_size));
        return 0;
    }
    list_get_arr(Farming::plant_list, plant_idx, plant);
    if(plant[Plant::character_id] != CharacterData[playerid][p_ID]) {
        EMIT_PlayerSystemChat(playerid, -1, "HARVEST: Bukan tanaman milikmu");
        return 0;
    }
    if(!plant[Plant::can_harvest]) {
        EMIT_PlayerSystemChat(playerid, -1, "HARVEST: Belum waktu panen.");
        return 0;
    }
    new harvest_idx = Farming::GetHarvestIndex(plant[Plant::seed_id]);
    if(harvest_idx == -1) {
        Logger_Err("invalid harvest info", Logger_S("module", "farming"), Logger_I("seed_id", plant[Plant::seed_id]));
        return 0;
    }
    
    new l_item[Inv::eItem];
    l_item[Item::id] = Farming::HarvestInfo[harvest_idx][Plant::harvest_item_id];
    l_item[Item::amount] = Farming::HarvestInfo[harvest_idx][Plant::harvest_amount];
    GivePlayerItem(playerid, l_item, false);
    Plant::Destroy(plant);
    return 1;
}

Farming::Fertilize(playerid, plant_idx) {
    new plant[ePlant];
    new l_list_size = list_size(Farming::plant_list);
    if(l_list_size < plant_idx) {
        Logger_Err("invalid list_index", Logger_S("module", "farming"), Logger_I("plant_idx", plant_idx), Logger_I("list_size", l_list_size));
        return 0;
    }
    list_get_arr(Farming::plant_list, plant_idx, plant);
    if(plant[Plant::character_id] != CharacterData[playerid][p_ID]) {
        EMIT_PlayerSystemChat(playerid, -1, "Fertilize: Bukan tanaman milikmu.");
        return 0;
    } 
    if(plant[Plant::fertilized]) {
        EMIT_PlayerSystemChat(playerid, -1, "Fertilize: Tanaman sudah di pupuk");
        return 0;
    }
    new fertilizer_idx = CheckItemInInventory(playerid, ITEM_RES_FERTILIZER);
    if(fertilizer_idx == -1) {
        EMIT_PlayerSystemChat(playerid, -1, "Kamu tidak memiliki 'Fertilizer'");
        return 0;
    }
    if(TakePlayerItem(playerid, fertilizer_idx, 1)) {
        new reduced_time = plant[Plant::harvest_time] / 2;
        list_set_cell(Farming::plant_list, plant_idx, Plant::fertilized, 1);
        list_set_cell(Farming::plant_list, plant_idx, Plant::harvest_time, reduced_time);
        EMIT_PlayerSystemChat(playerid, -1, "Berhasil menggunakan fertilizer untuk tanaman");
        return 1;
    }
    return 1;
}

Farming::GetHarvestIndex(seed_id) {
    for(new i=0;i<sizeof(Farming::HarvestInfo);i++) {
        if(Farming::HarvestInfo[i][Plant::plant_seed_id] == seed_id) {
            return i;
        }
    }
    return -1;
}

Farming::Init() {
    Farming::plant_list = list_new();
    Farming::land_list = list_new();
    szQuery[0] = 0;
    mysql_format(MainConn, szQuery, sizeof(szQuery), "SELECT * FROM `farm_plant`");
    mysql_tquery(MainConn, szQuery, "OnPlantLoaded");
    szQuery[0] = 0;
    mysql_format(MainConn, szQuery, sizeof(szQuery), "SELECT * FROM `farm_land`");
    mysql_tquery(MainConn, szQuery, "OnLandLoaded");
    return 1;
}

Farming::deInit() {
    Plant::UpdateAll();
    return 1;
}
// PLANTS
callback OnPlantLoaded() {
    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields);
    Logger_Log("spawning plants", Logger_S("module", "farming"), Logger_I("count", rows));
    new l_Plant[ePlant];
    if(rows > 0) {
        for(new i=0;i<rows;i++) {
            DB::LoadCacheSchema(i, Plant::Schema,sizeof(Plant::Schema), l_Plant);
            Plant::Spawn(l_Plant);
        }
    }
    return 1;
}

Farming::PlantSeed(playerid, seed_id) {
    
    new Float:pPos[3], Float:pAngle;
    GetPlayerPos(playerid, VEC3_UNWRAP(pPos));
    
    new l_Plant[ePlant];
    l_Plant[Plant::character_id] = CharacterData[playerid][p_ID];
    l_Plant[Plant::seed_id] = seed_id;
    
    GetPlayerFacingAngle(playerid,pAngle);
    new Float:l_dist = 0.5;
    GetXYInFrontOfPoint(pPos[X],pPos[Y],pAngle, l_dist);
    CA_FindZ_For2DCoord(pPos[X], pPos[Y], pPos[Z]);
    pPos[Z] += 0.35;
    VEC3_COPY(pPos,l_Plant[Plant::pos]);
    new itemDef[eItemDef];
    GetItemDefinition(seed_id, itemDef);
    if(itemDef[ItemDef::plant_time] == 0) {
        Logger_Err("cannot plant, invalid plant_time", Logger_I("plant_time", itemDef[ItemDef::plant_time]), Logger_I("seed_id", seed_id));
        return 0;
    }
    l_Plant[Plant::harvest_time] = itemDef[ItemDef::plant_time];
    await Plant::DBSaveAndSpawn(l_Plant);
    return 1;
}

Plant::Spawn(plant[ePlant]) {
    new Float:l_rot[3];
    plant[Plant::object_id] = CreateDynamicObject(
        PLANT_OBJ_MODEL,
        VEC3_UNWRAP(plant[Plant::pos]),
        VEC3_UNWRAP(l_rot),
        0,
        0,
        .streamdistance = 100
    );
     
    plant[Plant::area_id] = CreateDynamicSphere(
        VEC3_UNWRAP(plant[Plant::pos]),
        1.5
    );
    new idx = list_size(Farming::plant_list);
    plant[Plant::list_idx] = idx;
    Streamer_SetIntData(STREAMER_TYPE_AREA, plant[Plant::area_id], E_STREAMER_CUSTOM(E_STREAMER_PLANT_ID), idx);
    list_add_arr(Farming::plant_list, plant);
    return 1;
}

Task:Plant::DBSaveAndSpawn(plant[ePlant]) {
    new Task:save_task = task_new();
    DB::MakeInsertQuery("farm_plant", Plant::Schema, sizeof(Plant::Schema));
    DB::PopulateInsertQuery(Plant::Schema, sizeof(Plant::Schema), plant);
    mysql_tquery(MainConn,szQuery, "OnPlantInserted", "aii", plant, sizeof(plant), _:save_task);
    return save_task;
}
callback OnPlantInserted(plant[ePlant], size, Task:task) {
    plant[Plant::id] = cache_insert_id();
    Plant::Spawn(plant);
    task_set_result(Task:task, true);
}

Plant::Update(const plant[ePlant]) {
    DB::MakeUpdateQuery("farm_plant", Plant::Schema, sizeof(Plant::Schema));
    DB::PopulateUpdateQuery(Plant::Schema, sizeof(Plant::Schema), plant);
    mysql_tquery(MainConn, szQuery);
    return 1;
}

Plant::UpdateAll() {
    new plant[ePlant];
    for_list(it : Farming::plant_list) {
        iter_get_arr(it, plant);
        Plant::Update(plant);
    }
    return 1;
}

Plant::Destroy(const plant[ePlant]) {
    if(IsValidDynamicObject(plant[Plant::object_id])) {
        DestroyDynamicObject(plant[Plant::object_id]);
    }
    if(IsValidDynamicArea(plant[Plant::area_id])) {
        DestroyDynamicArea(plant[Plant::area_id]);
    }
    list_remove(Farming::plant_list, plant[Plant::list_idx]);
    Plant::DBDestroy(plant);
    Plant::RecalculateIndex();
    return 1;
}

Plant::DBDestroy(const plant[ePlant]) {
    DB::MakeDeleteRow("farm_plant", plant[Plant::id]);
    mysql_tquery(MainConn,szQuery);
    return 1;
}

Plant::RecalculateIndex() {
    new l_plant[ePlant];
    new it_index = 0;
    for_list(it: Farming::plant_list) {
        iter_get_arr(it, l_plant);
        iter_set_cell(it, _:Plant::list_idx, it_index);
        it_index++;
    }
    return 1;
}

// LANDS
callback OnLandLoaded() {
    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields);

    Logger_Log("spawning lands", Logger_S("module", "farming"), Logger_I("count", rows));
    new l_land[eLandPlotInfo];
    if(rows > 0) {
        for(new i=0;i<rows;i++) {
            DB::LoadCacheSchema(i, LandInfo::Schema, sizeof(LandInfo::Schema), l_land);
            Land::Load(l_land);
        }
    }
}

Land::Load(land_info[eLandPlotInfo]) {
    DB::DataDebug("farm_land", LandInfo::Schema, sizeof(LandInfo::Schema), land_info); 
    // land[Land::area_id] = CreateDynamicRectangle(
    //     VEC2_UNWRAP(land[Land::min_coord]),
    //     VEC2_UNWRAP(land[Land::max_coord])
    // );
    new coord_str[10][10];
    new Float:f_coord[10];
    strexplode(coord_str, land_info[LandInfo::coord_str]);
    for(new i=0;i<10;i++) {
        f_coord[i] = floatstr(coord_str[i]);
        printf("coord %i: %f", i, f_coord[i]);
    }
     
    new l_plot[eLandPlot];
    l_plot[Land::id] = land_info[LandInfo::id];
    l_plot[Land::owner_id] = land_info[LandInfo::owner_id];
    l_plot[Land::permission] = map_new();
    if(strlen(land_info) > 0) {
        
    }
    format(l_plot[Land::name], 64, "%s", land_info[LandInfo::name]);
    l_plot[Land::base_price] = land_info[LandInfo::base_price];
    l_plot[Land::rent_price] = land_info[LandInfo::rent_price];
    l_plot[Land::rental_balance] = land_info[LandInfo::rental_balance];
    l_plot[Land::area_id] = CreateDynamicPolygon(f_coord);
    new idx = list_size(Farming::land_list);
    Streamer_SetIntData(STREAMER_TYPE_AREA, l_plot[Land::area_id], E_STREAMER_CUSTOM(E_STREAMER_LAND_ID), idx);
    list_add_arr(Farming::land_list, l_plot);
    return 1;
}



CMD:harvest(playerid, params[]) {
    new plant_idx = Farming::PlantID(playerid);
    if(plant_idx == -1) return 0;
    Farming::Harvest(playerid, plant_idx);
    return 1;
}

CMD:fertilize(playerid, params[]) {
    new plant_idx = Farming::PlantID(playerid);
    if(plant_idx == -1) return 0;
    Farming::Fertilize(playerid, plant_idx);
    return 1;
}


#if defined DEBUG_MODE
CMD:plantcheck(playerid, params[]) {
    new id;
    if(sscanf(params, "i", id)) return 0;
    new plant[ePlant];
    DB::Select("farm_plant", Plant::Schema, sizeof(Plant::Schema), id, plant, sizeof(plant));
    DB::DataDebug("farm_plant", Plant::Schema, sizeof(Plant::Schema), plant);
    return 1;
}
#endif
