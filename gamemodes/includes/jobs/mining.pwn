#include <pp-hooks>
hook OnGameModeInit() {
    printf("[JOB MNR] Gamemode Init");
    JobMiner::LoadMap();
}


hook OnPlayerConnect(playerid) {
    // Remove Building
    JobMiner::RemoveObject(playerid);
    JobMiner::SetRockID(playerid, -1);
    // =================================
}

hook OnPlayerEnterDynArea(playerid, areaid) {
    if(Streamer_HasIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_ROCK_ID))) {
        new strm_rock_id = Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_ROCK_ID));
        JobMiner::SetRockID(playerid, strm_rock_id);
    }
}


hook OnPlayerLeaveDynArea(playerid, areaid) {
    
    if(Streamer_HasIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_ROCK_ID))) {
        new strm_rock_id = Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_ROCK_ID));
        new cRockID = JobMiner::GetRockID(playerid);
        if(cRockID != -1 && cRockID == strm_rock_id) {
            JobMiner::SetRockID(playerid, -1);
        }
    }
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(PRESSED(KEY_FIRE)) {
        if(JobMiner::IsUsingSH(playerid) == 0) {
            return 0; 
        }
        if(!IsPlayerInAnyDynamicArea(playerid)) {
            return 0;
        }
        new l_rock[JobMiner::e_Rock];
        new p_rockId = JobMiner::GetRockID(playerid);
        if(p_rockId == -1) return 0;
        if(list_size(JobMiner::list_rock) < p_rockId) return 1;
        list_get_arr(JobMiner::list_rock, p_rockId, l_rock);
        if(l_rock[MNRRock::hp] < 1) return 1;
        new l_tslot = CharacterInv::GetSlotFromID(playerid, ITEM_TOOLS_SLEDGEHAMMER); // Hammer ID
        new l_item[CharacterInv::eInfo];
        list_get_arr(PlayerInventoryList[playerid], l_tslot, l_item);
        if(l_item[CharacterInv::item][Item::durability] < 5) {
            EMIT_PlayerSystemChat(playerid, -1, "[ITEMS] Low item durability. You need to repair the item first.");
            return 1;
        }
        l_item[CharacterInv::item][Item::durability] -= 5;
        if(l_item[CharacterInv::item][Item::durability] < 0) {
            l_item[CharacterInv::item][Item::durability] = 0;
        }
        list_set_cell(PlayerInventoryList[playerid], l_tslot, _:CharacterInv::item + _:Item::durability, l_item[CharacterInv::item][Item::durability]);
        list_set_cell(PlayerInventoryList[playerid], l_tslot, _:CharacterInv::isDirty, true);
        
        if(CharacterData[playerid][p_stamina] < 10) {
            EMIT_PlayerSystemChat(playerid, -1, "[STAMINA] Cannot do this action. Low Stamina. Eat something to increase stamina.");
            return 1;
        }
        CharacterData[playerid][p_stamina] -= 2;
        GivePlayerEXP(playerid,2);
        
        new pCutPower = l_item[CharacterInv::item][Item::power];
        l_rock[MNRRock::hp] -= pCutPower;
        if(l_rock[MNRRock::hp] <= 0) {
            new Float:randX,Float:randY;
            new dropItem[Inv::eItem];
            new Float:dropPos[3];
            for(new di=0;di<3;di++) {
                randX = float(random(3) - 1) + 0.1;
                randY = float(random(3) - 1) + 0.1;
                new Float:range = float(random(2) + 1);
                randX += range;
                randY += range;
                dropItem[Item::id] = SelectWeightedRandom(JobMiner::rewards, sizeof(JobMiner::rewards));
                dropItem[Item::amount] = 1;
                dropPos[X] = l_rock[MNRRock::pos][X] + randX;
                dropPos[Y] = l_rock[MNRRock::pos][Y] + randY;
                dropPos[Z] = l_rock[MNRRock::pos][Z];
                CreateDropItem(dropPos, dropItem);    
            }

            foreach(new i : Player) {
                if(IsPlayerInRangeOfPoint(i, 50.0,
                                            dropPos[X],
                                            dropPos[Y],
                                            dropPos[Z]
                                            )) {
                    Streamer_Update(i, 0);
                }
            }
            EMIT_PlayerSystemChat(playerid, -1, "Stone Crushed");
            DestroyDynamicArea(l_rock[MNRRock::areaId]);
            DestroyDynamicObject(l_rock[MNRRock::objectId]);
            l_rock[MNRRock::respawnTimer] = JobMiner::DEFAULT_SPAWN_TIME;
        }
        ApplyAnimation(playerid, "BASEBALL", "Bat_1", 4.1, 0, 1, 1, 0, 1000, 1);
        new Float:Pa = SetPlayerFacingAngleToPoint(playerid, l_rock[MNRRock::pos][X], l_rock[MNRRock::pos][Y]);
        SetPlayerFacingAngle(playerid, Pa);
        
        while(JobMiner::list_locked) {
            wait_ms(10);
        }
        JobMiner::list_locked = 1;
        list_set_arr(JobMiner::list_rock, p_rockId, l_rock);
        JobMiner::list_locked = 0;
    }
    return 0;
}


JobMiner::Init() {
  JobMiner::list_rock = list_new();
  new tumbalRock[JobMiner::e_Rock];
  tumbalRock[MNRRock::id] = 0;
  tumbalRock[MNRRock::pos][X] = 0;
  tumbalRock[MNRRock::pos][Y] = 0;
  tumbalRock[MNRRock::pos][Z] = -1000.0;
  tumbalRock[MNRRock::objectId] = INVALID_STREAMER_ID;
  tumbalRock[MNRRock::areaId] = INVALID_STREAMER_ID;
   
  list_add_arr(JobMiner::list_rock, tumbalRock);

  JobMiner::LoadRocks();
  return 1; 
}

JobMiner::deInit() {
  return 1; 
}

JobMiner::Tick() {
    new l_rock[JobMiner::e_Rock];
    new l_index = -1;
    for_list(it : JobMiner::list_rock) {
        l_index++;
        iter_get_arr(it, l_rock);
        if(l_rock[MNRRock::id] == 0) continue; // skip batu tumbal
        if(l_rock[MNRRock::respawnTimer] > 0) {
            l_rock[MNRRock::respawnTimer] -= 1;
            if(l_rock[MNRRock::respawnTimer] <= 0) {
                new l_handle = CreateDynamicObject(JobMiner::ROCK_MODEL, 
                                                    l_rock[MNRRock::pos][X],
                                                    l_rock[MNRRock::pos][Y],
                                                    l_rock[MNRRock::pos][Z],0.0,0.0,0.0);
                new l_area = CreateDynamicCircle(l_rock[MNRRock::pos][X],l_rock[MNRRock::pos][Y],3.0);
                l_rock[MNRRock::objectId] = l_handle;
                l_rock[MNRRock::areaId] = l_area;
                l_rock[MNRRock::hp] = 100;
                l_rock[MNRRock::respawnTimer] = 0;
                Streamer_SetIntData(STREAMER_TYPE_AREA, l_rock[MNRRock::areaId], E_STREAMER_CUSTOM(E_STREAMER_ROCK_ID), l_index);
            }
            iter_set_arr(it, l_rock);
            continue;
        } 
        iter_set_arr(it, l_rock);
    }
    return 1; 
}


JobMiner::LoadRocks() {
  mysql_tquery(MainConn,"SELECT * from `jb_miner_rock`", "JobMinerOnRocksLoaded");
  return 1;
}

JobMiner::SaveRock(const p_rock[JobMiner::e_Rock]) {
    DB::MakeInsertQuery("jb_miner_rock", JobMiner::Schema, sizeof(JobMiner::Schema), true);
    DB::PopulateInsertQuery(JobMiner::Schema, sizeof(JobMiner::Schema), p_rock, true);
    mysql_tquery(MainConn, szQuery);
    return 1; 
}

callback JobMinerOnRocksLoaded() {
    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields); 
    
    new l_rock[JobMiner::e_Rock];
    if(rows > 0) {
        for(new i=0;i<rows;i++) {
            DB::LoadCacheSchema(i, JobMiner::Schema, sizeof(JobMiner::Schema), l_rock);
            new l_handle = CreateDynamicObject(JobMiner::ROCK_MODEL, 
                                                l_rock[MNRRock::pos][X],
                                                l_rock[MNRRock::pos][Y],
                                                l_rock[MNRRock::pos][Z],0.0,0.0,0.0);
            new l_area = CreateDynamicCircle(l_rock[MNRRock::pos][X],l_rock[MNRRock::pos][Y],3.0);
            l_rock[MNRRock::objectId] = l_handle;
            l_rock[MNRRock::areaId] = l_area;
            l_rock[MNRRock::hp] = 100;
            l_rock[MNRRock::respawnTimer] = 0;
            new l_index = list_size(JobMiner::list_rock);
            Streamer_SetIntData(STREAMER_TYPE_AREA, l_rock[MNRRock::areaId], E_STREAMER_CUSTOM(E_STREAMER_ROCK_ID), l_index);
            list_add_arr(JobMiner::list_rock, l_rock);
        }
        printf("[JOBMINER] Loaded %i rocks", rows);
    }
}

#if defined DEBUG_MODE
hook OnPlayerEditDynObject(playerid, STREAMER_TAG_OBJECT:objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
    // printf("[DEBUG] Lumber OnPlayerEditDynamicObject");
    if(!JobMiner::IsEditingRock(playerid)) {
        return 0;
    }
    
    new EditRockID = JobMiner::GetEditRockID(playerid);
    if(EditRockID == -1) {
        return 1;
    }

    if(response == 1) {
        printf("[DEBUG] Object edited" );
        printf("RockID: %i ObjID:%i res:%i",EditRockID, objectid, response);
        printf("Pos %f %f %f", x,y,z);
        printf("Rot %f %f %f", rx,ry,rz);
        new l_rock[JobMiner::e_Rock];
        list_get_arr(JobMiner::list_rock, EditRockID, l_rock);

        l_rock[MNRRock::pos][X] = x;
        l_rock[MNRRock::pos][Y] = y;
        l_rock[MNRRock::pos][Z] = z;
        
        l_rock[MNRRock::rot][X] = rx;
        l_rock[MNRRock::rot][Y] = ry;
        l_rock[MNRRock::rot][Z] = rz;

        if(IsValidDynamicArea(l_rock[MNRRock::areaId])) {
            DestroyDynamicArea(l_rock[MNRRock::areaId]);
        }
        l_rock[MNRRock::areaId] = CreateDynamicCircle(x,y, 2.0);
        Streamer_SetIntData(STREAMER_TYPE_AREA, l_rock[MNRRock::areaId], E_STREAMER_CUSTOM(E_STREAMER_ROCK_ID), EditRockID);
        list_set_arr(JobMiner::list_rock, EditRockID, l_rock);
        JobMiner::SetEditingRock(playerid, 0);
        JobMiner::SetEditRockID(playerid, -1);   
        JobMiner::SaveRock(l_rock);
    }
    return 1;
}


#if defined DEBUG_MODE

CMD:usehammer(playerid, params[]) {
  printf("Using tools chainsaw");
  SetPlayerAttachedObject(playerid,0,19631,6,
                  JobMiner::AO_CS_DATA[ao_x],
                  JobMiner::AO_CS_DATA[ao_y],
                  JobMiner::AO_CS_DATA[ao_z],
                  JobMiner::AO_CS_DATA[ao_rx],
                  JobMiner::AO_CS_DATA[ao_ry],
                  JobMiner::AO_CS_DATA[ao_rz]);
  return 1;
}

CMD:gotomining(playerid, params[]) {
  SetPlayerPos(playerid, 590.4846,869.5508,-42.4973);
  SetPlayerFacingAngle(playerid,183.6048);
  return 1;
}

CMD:spawnrock(playerid, params[]) {
    UnfocusCEF(playerid);
    new Float:l_pX, Float:l_pY, Float:l_pZ,
        Float: l_pAngle,
        Float: l_dist;

    GetPlayerPos(playerid, l_pX,l_pY,l_pZ);
    printf("[DEBUG] Player posX: %f posY: %f posZ: %f", l_pX,l_pY,l_pZ);

    GetPlayerFacingAngle(playerid, l_pAngle);

    l_dist = 3.0;
    GetXYInFrontOfPoint(l_pX,l_pY,l_pAngle, l_dist);

    printf("[DEBUG] Object posX: %f posY: %f posZ: %f", l_pX,l_pY,l_pZ);
    

    CA_FindZ_For2DCoord(l_pX,l_pY,l_pZ);
    
    new l_handle = CreateDynamicObject(JobMiner::ROCK_MODEL, l_pX,l_pY,l_pZ-0.4,0.0,0.0,0.0);
    new l_area = CreateDynamicCircle(l_pX,l_pY,2.0);

    new rock[JobMiner::e_Rock];

    new l_rockId = list_size(JobMiner::list_rock);
    rock[MNRRock::id] = l_rockId;

    rock[MNRRock::pos][X] = l_pX;
    rock[MNRRock::pos][Y] = l_pY;
    rock[MNRRock::pos][Z] = l_pZ;
    rock[MNRRock::respawnTimer] = JobMiner::DEFAULT_SPAWN_TIME;

    rock[MNRRock::objectId] = l_handle;
    rock[MNRRock::areaId] = l_area;

    rock[MNRRock::hp] = 100;
    
    new l_index = list_size(JobMiner::list_rock);
    Streamer_SetIntData(STREAMER_TYPE_AREA, rock[MNRRock::areaId], E_STREAMER_CUSTOM(E_STREAMER_ROCK_ID), l_index);
    list_add_arr(JobMiner::list_rock, rock);

    JobMiner::SetEditingRock(playerid, 1);
    JobMiner::SetEditRockID(playerid, l_rockId);

    EditDynamicObject(playerid, l_handle);
    return 1;
}

#endif
