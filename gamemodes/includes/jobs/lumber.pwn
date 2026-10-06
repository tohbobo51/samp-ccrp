// NOTE: Maybe need to refactor Lumber Tick Function?
// Considering the amount of the trees existing on the server later
#include <pp-hooks>
hook OnGameModeInit() {
    printf("[JOB LJ] Gamemode Init");

    JobLumber::LoadMap();
}


hook OnPlayerConnect(playerid) {
    // Remove Building
    JobLumber::RemoveObject(playerid);
    JobLumber::SetTreeID(playerid, -1);
}


hook OnPlayerDisconnect(playerid, reason) {
    printf("[JobLJ] OnPlayerDisconnect");
    JobLumber::CancelCut(playerid);
}

hook OnPlayerEnterDynArea(playerid, areaid) {
    if(Streamer_HasIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_LUMBER_ID))) {
        new strm_lumber_id = Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_LUMBER_ID));
        printf("Streamer Lumber ID %i", strm_lumber_id);
        JobLumber::SetTreeID(playerid, strm_lumber_id);
    }
}


hook OnPlayerLeaveDynArea(playerid, areaid) {
    if(JobLumber::GetTreeID(playerid) != -1) {
        JobLumber::SetTreeID(playerid, -1);
    }
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(PRESSED(KEY_FIRE)) {
        if(
            JobLumber::IsUsingCS(playerid) == 1 && 
            JobLumber::IsCuttingTree(playerid) == 0
        ) {
            if(JobLumber::GetTreeID(playerid) == -1) return 1;
            new l_tree[JobLumber::e_Tree];
            list_get_arr(JobLumber::list_tree, JobLumber::GetTreeID(playerid), l_tree);
            if(l_tree[LJTree::id] == 0) return 1;

            if(!l_tree[LJTree::isDown]) {
                new l_tslot = CharacterInv::GetSlotFromID(playerid, ITEM_TOOLS_CHAINSAW); // Chainsaw ID
                if(l_tslot == -1) return 1;
                new l_item[CharacterInv::eInfo];
                list_get_arr(PlayerInventoryList[playerid], l_tslot, l_item);
                if(l_item[CharacterInv::item][Item::durability] < 5) {
                    EMIT_PlayerSystemChat(playerid, -1, "[ITEMS] Low item durability. You need to repair the item first.");
                    return 1;
                }

                if(CharacterData[playerid][p_stamina] < 2) {
                    EMIT_PlayerSystemChat(playerid, -1, "[STAMINA] Cannot do this action. Low Stamina. Eat something to increase stamina.");
                    return 1;
                }
                new pCutPower = l_item[CharacterInv::item][Item::power];
                printf("Player is near tree: %i", l_tree[LJTree::id]);
                new str[128];
                format(str,sizeof(str), "You're near tree: %i", l_tree[LJTree::id]);
                EMIT_PlayerSystemChat(playerid, -1, str);
                JobLumber::SetCuttingTree(playerid, 1);
                JobLumber::SetCuttingTreeID(playerid, l_tree[LJTree::id]);
                JobLumber::SetCutPower(playerid, pCutPower);
                l_tree[LJTree::cutPwr] += pCutPower;
                list_add(l_tree[LJTree::cutPlayers],playerid);
                ApplyAnimation(playerid, "CHAINSAW","CSAW_G", 4.1,true,true,true,true,0,1);
                PlayerAction::Set(playerid, "Cutting Tree", 100, PlayerAction::CUT_TREE);
                list_set_arr(JobLumber::list_tree, JobLumber::GetTreeID(playerid), l_tree);
                return 1;
            }

            if(l_tree[LJTree::isDown] && !l_tree[LJTree::isHarvested]) {
                if(l_tree[LJTree::harvestPlayer] != INVALID_PLAYER_ID) {
                    EMIT_PlayerSystemChat(playerid, -1, "Another Player is already harvesting the Tree.");
                    return 1; 
                }
                new l_tslot = CharacterInv::GetSlotFromID(playerid, 2); // Chainsaw ID
                if(l_tslot == -1) return 1;
                new l_item[CharacterInv::eInfo];
                list_get_arr(PlayerInventoryList[playerid], l_tslot, l_item);
                if(l_item[CharacterInv::item][Item::durability] < 5) {
                    EMIT_PlayerSystemChat(playerid, -1, "[ITEMS] Low item durability. You need to repair the item first.");
                    return 1;
                }

                if(CharacterData[playerid][p_stamina] < 5) {
                    EMIT_PlayerSystemChat(playerid, -1, "[STAMINA] Cannot do this action. Low Stamina. Eat something to increase stamina");
                    return 1; 
                } 
                new pCutPower = l_item[CharacterInv::item][Item::power];
                EMIT_PlayerSystemChat(playerid, -1, "Starting Harvesting Tree");
                JobLumber::SetHarvestingTree(playerid, 1);
                JobLumber::SetHarvestingTreeID(playerid, l_tree[LJTree::id]);
                JobLumber::SetHarvestPower(playerid, 10);
                l_tree[LJTree::harvestPwr] += pCutPower;
                l_tree[LJTree::harvestPlayer] = playerid;
                list_add(l_tree[LJTree::cutPlayers],playerid);
                ApplyAnimation(playerid, "CHAINSAW","CSAW_G", 4.1,true,true,true,true,0,1);
                PlayerAction::Set(playerid, "Harvesting Tree", 100, PlayerAction::HARVEST_TREE);
                list_set_arr(JobLumber::list_tree, JobLumber::GetTreeID(playerid), l_tree);
                return 1;
            }
        }
    }
    return 0;
}


JobLumber::Init() {
  JobLumber::list_tree = list_new();
  // Tumbal Tree, Because of list is started from 0 and database id from 1. 
  new tumbalTree[JobLumber::e_Tree];
  tumbalTree[LJTree::id] = 0;
  tumbalTree[LJTree::cutPlayers] = list_new();
  tumbalTree[LJTree::pos][X] = 0.0;
  tumbalTree[LJTree::pos][Y] = 0.0;
  tumbalTree[LJTree::pos][Z] = -1000.0;
  tumbalTree[LJTree::objectId] = INVALID_STREAMER_ID;
  tumbalTree[LJTree::areaId] = INVALID_STREAMER_ID;
  tumbalTree[LJTree::state] = TREE_STATE_ALIVE; // Initialize state
  list_add_arr(JobLumber::list_tree, tumbalTree);
   
  JobLumber::LoadTrees();
}

JobLumber::deInit() {
  for_list(i : JobLumber::list_tree) {
    if(!iter_valid(i)) continue;
    new l_tree[JobLumber::e_Tree];
    iter_get_arr(i, l_tree);
    JobLumber::UpdateTree(l_tree);
  }
  list_delete(JobLumber::list_tree);
}

callback JobLumberOnTreesLoaded() {
    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields); 
  
    new l_tree[JobLumber::e_Tree];
    if(rows > 0) {
        for(new i=0;i<rows;i++) {
            DB::LoadCacheSchema(i, JobLumber::Schema, sizeof(JobLumber::Schema), l_tree);
            new l_handle = CreateDynamicObject(LJ_TREE_MODEL_ID, 
                                                l_tree[LJTree::pos][X],
                                                l_tree[LJTree::pos][Y],
                                                l_tree[LJTree::pos][Z],0.0,0.0,0.0);
            new l_area = CreateDynamicCircle(l_tree[LJTree::pos][X],l_tree[LJTree::pos][Y],2.0);

            l_tree[LJTree::isDown] = false;
            l_tree[LJTree::isHarvested] = false;
            l_tree[LJTree::respawnTimer] = 0;
            l_tree[LJTree::state] = TREE_STATE_ALIVE; // Initialize state machine

            l_tree[LJTree::objectId] = l_handle;
            l_tree[LJTree::areaId]  = l_area;
            
            l_tree[LJTree::cutPlayers] = list_new();
            l_tree[LJTree::cutPerc] = 0;
            l_tree[LJTree::cutPwr] = 0;
            l_tree[LJTree::harvestPwr] = 0;
            l_tree[LJTree::harvestPerc] = 0;
            l_tree[LJTree::harvestDrop] = 0;
            l_tree[LJTree::harvestDropTreshold] = 20;
            l_tree[LJTree::harvestPlayer] = INVALID_PLAYER_ID;
            new l_index = list_size(JobLumber::list_tree);
            Streamer_SetIntData(STREAMER_TYPE_AREA, l_tree[LJTree::areaId], E_STREAMER_CUSTOM(E_STREAMER_LUMBER_ID), l_index);
            list_add_arr(JobLumber::list_tree, l_tree);
        }
        printf("[JOBLUMBER] Loaded %i trees", rows);
        // JobLumber::PrintAllTrees();
    }
}

JobLumber::LoadTrees() {
  mysql_tquery(MainConn,"SELECT * from `jb_lumber_tree`", "JobLumberOnTreesLoaded");
  return 1;
}

JobLumber::UpdateTree(const p_tree[JobLumber::e_Tree]) {
    DB::MakeUpdateQuery("jb_lumber_tree", JobLumber::Schema, sizeof(JobLumber::Schema));
    DB::PopulateUpdateQuery(JobLumber::Schema, sizeof(JobLumber::Schema), p_tree);
    mysql_tquery(MainConn, szQuery);
    return 1; 
}

JobLumber::SaveTree(const p_tree[JobLumber::e_Tree]) {
    DB::MakeInsertQuery("jb_lumber_tree", JobLumber::Schema, sizeof(JobLumber::Schema), true);
    DB::PopulateInsertQuery(JobLumber::Schema, sizeof(JobLumber::Schema), p_tree, true);
    mysql_tquery(MainConn, szQuery);
    return 1;
}

stock JobLumber::PrintTree(const tree[JobLumber::e_Tree]) {
  printf("\
TreeID %i\n\
IsDown %i\n\
cutPwr %i\n\
cutPerc %i\n\
harvestPwr %i\n\
harvestPerc %i\n\n\
objectId %i\n\
areaId %i\n\
",
  tree[LJTree::id],
  tree[LJTree::isDown],
  tree[LJTree::cutPwr],
  tree[LJTree::cutPerc],
  tree[LJTree::harvestPwr],
  tree[LJTree::harvestPerc],
  tree[LJTree::objectId],
  tree[LJTree::areaId]
  );

  for_list(p : tree[LJTree::cutPlayers]) {
    new pID = iter_get(p);
    printf("Player %i cutting the tree.", pID);
  }
  printf("");
  return 1;
}

JobLumber::CutWorker(Iter: i, tree[JobLumber::e_Tree]) {
    tree[LJTree::cutPerc] += tree[LJTree::cutPwr];
    for_list(p : tree[LJTree::cutPlayers]) {
        new pID = iter_get(p);
        printf("Player %i is Cutting Tree %i cutPerc: %i",pID,tree[LJTree::id],tree[LJTree::cutPerc]);
        CharacterData[pID][p_stamina] -= 2;
        if(CharacterData[pID][p_stamina] < 0) {
            printf("[DEBUG] Player %i stamina exhausted.", pID);
            EMIT_PlayerSystemChat(pID, -1, "[STAMINA] Stamina exhausted. Action cancelled.");
            // TODO: Check if Player still cutting the tree
            CharacterData[pID][p_stamina] = 0;
            new pCutPower = JobLumber::GetCutPower(pID);
            JobLumber::SetCuttingTree(pID, 0);
            JobLumber::SetCuttingTreeID(pID, -1);
            JobLumber::SetCutPower(pID, 0);
            PlayerAction::Finish(pID);
            ClearAnimations(pID);
            new pIndex = list_find(tree[LJTree::cutPlayers], pID);
            tree[LJTree::cutPwr] -= pCutPower;
            if(pIndex != -1) {
                list_remove(tree[LJTree::cutPlayers], pIndex);
            }
            iter_set_arr(i, tree);
        } else {
            PlayerAction::Update(pID, tree[LJTree::cutPerc]);
        }
    }
}

JobLumber::CancelCut(playerid) {
    if(JobLumber::IsCuttingTree(playerid) == 1) {
        new tree[JobLumber::e_Tree];
        new treeId = JobLumber::CuttingTreeID(playerid);
        list_get_arr(JobLumber::list_tree, treeId, tree);
        new pIndex = list_find(tree[LJTree::cutPlayers], playerid);
        new pCutPower = JobLumber::GetCutPower(playerid);
        tree[LJTree::cutPwr] -= pCutPower;
        if(pIndex != -1) {
            list_remove(tree[LJTree::cutPlayers], pIndex);
        }
        list_set_arr(JobLumber::list_tree, treeId, tree);
        JobLumber::SetCuttingTree(playerid, 0);
        JobLumber::SetCuttingTreeID(playerid, -1);
        JobLumber::SetCutPower(playerid, 0);
        ClearAnimations(playerid);
    }

    if(JobLumber::IsHarvestingTree(playerid) == 1) {
        new tree[JobLumber::e_Tree];
        new treeId = JobLumber::GetHarvestingTreeID(playerid);
        list_get_arr(JobLumber::list_tree, treeId, tree);
        new pCutPower = JobLumber::GetHarvestPower(playerid);
        tree[LJTree::harvestPwr] -= pCutPower;
        tree[LJTree::harvestPlayer] = INVALID_PLAYER_ID;
        list_set_arr(JobLumber::list_tree, treeId, tree);
        JobLumber::SetHarvestingTree(playerid, 0);
        JobLumber::SetHarvestingTreeID(playerid,-1);
        JobLumber::SetHarvestPower(playerid,0);
        ClearAnimations(playerid);
    }
    
    PlayerAction::Finish(playerid);
    return 1;
}

// State machine helper functions
JobLumber::HandleAliveState(Iter:i, tree[JobLumber::e_Tree]) {
    // Handling tree cutting
    if(tree[LJTree::cutPwr] > 0) {
        iter_acquire(i);
        JobLumber::CutWorker(i, tree);
        iter_release(i);
    }
    
    // Check for transition to FALLEN state
    if(tree[LJTree::cutPerc] >= 100) {
        // Handle players who were cutting
        for_list(p : tree[LJTree::cutPlayers]) {
            new pID = iter_get(p);
            JobLumber::SetCuttingTree(pID, 0);
            JobLumber::SetCuttingTreeID(pID, -1);
            JobLumber::SetCutPower(pID, 0);
            PlayerAction::Finish(pID);
            GivePlayerEXP(pID, 5);
            
            // Handle tool durability
            new l_tslot = CharacterInv::GetSlotFromID(pID, ITEM_TOOLS_CHAINSAW);
            if(l_tslot != -1) {
                new l_item[CharacterInv::eInfo];
                list_get_arr(PlayerInventoryList[pID], l_tslot, l_item);
                l_item[CharacterInv::item][Item::durability] -= 5;
                if(l_item[CharacterInv::item][Item::durability] < 0) {
                    l_item[CharacterInv::item][Item::durability] = 0;
                }
                list_set_cell(PlayerInventoryList[pID], l_tslot, _:CharacterInv::item + _:Item::durability, l_item[CharacterInv::item][Item::durability]);
                list_set_cell(PlayerInventoryList[pID], l_tslot, _:CharacterInv::isDirty, true);
            }
            
            ClearAnimations(pID);
        }
        
        // Transition to FALLEN state
        JobLumber::CuttingFinish(tree);
        tree[LJTree::state] = TREE_STATE_FALLEN;
        printf("Tree Cutting Finished - Transitioned to FALLEN state");
    }
    
    return 1;
}

JobLumber::HandleFallenState(tree[JobLumber::e_Tree]) {
    // Handle harvesting logic
    if(tree[LJTree::harvestPwr] > 0) {
        tree[LJTree::harvestPerc] += tree[LJTree::harvestPwr];
        tree[LJTree::harvestDrop] += tree[LJTree::harvestPwr];
        
        new pID = tree[LJTree::harvestPlayer];
        if(pID == INVALID_PLAYER_ID) {
            printf("[ERROR] Invalid playerid. this shouldn't be happened");
            return 0;
        }
        
        // Handle player stamina
        CharacterData[pID][p_stamina] -= 2;
        if(CharacterData[pID][p_stamina] < 0) {
            printf("[DEBUG] Player %i stamina exhausted.", pID);
            EMIT_PlayerSystemChat(pID, -1, "[STAMINA] Stamina exhausted. Action cancelled.");
            CharacterData[pID][p_stamina] = 0;
            JobLumber::SetHarvestingTree(pID, 0);
            JobLumber::SetHarvestingTreeID(pID,-1);
            JobLumber::SetHarvestPower(pID,0);
                
            ClearAnimations(pID);
            tree[LJTree::harvestPwr] = 0;
            tree[LJTree::harvestPlayer] = INVALID_PLAYER_ID;
            PlayerAction::Finish(pID);
            return 0;
        } else {
            PlayerAction::Update(pID, tree[LJTree::harvestPerc]);
        }
        
        Logger_Dbg("lumber", "player harvesting tree", 
                   Logger_I("playerid", pID), 
                   Logger_I("tree_id", tree[LJTree::id]),
                   Logger_I("harvest_perc", tree[LJTree::harvestPerc]),
                   Logger_I("harvest_drop", tree[LJTree::harvestDrop]),
                   Logger_I("harvest_treshold", tree[LJTree::harvestDropTreshold])
                   );
        
        // Handle wood drops
        if(tree[LJTree::harvestDrop] > tree[LJTree::harvestDropTreshold]) {
            JobLumber::DropWoodLog(tree);
            tree[LJTree::harvestDrop] = 0;
        }
    }

    // Check for transition to HARVESTED state
    if(tree[LJTree::harvestPerc] >= 100) {
        new pID = tree[LJTree::harvestPlayer];
        
        // Handle tool durability
        new l_tslot = CharacterInv::GetSlotFromID(pID, 2);
        if(l_tslot != -1) {
            new l_item[CharacterInv::eInfo];
            list_get_arr(PlayerInventoryList[pID], l_tslot, l_item);
            l_item[CharacterInv::item][Item::durability] -= 5;
            if(l_item[CharacterInv::item][Item::durability] < 0) {
                l_item[CharacterInv::item][Item::durability] = 0;
            }
            list_set_cell(PlayerInventoryList[pID], l_tslot, _:CharacterInv::item + _:Item::durability, l_item[CharacterInv::item][Item::durability]);
            list_set_cell(PlayerInventoryList[pID], l_tslot, _:CharacterInv::isDirty, true);
        }
        
        // Reset player state
        JobLumber::SetHarvestingTree(pID, 0);
        JobLumber::SetHarvestingTreeID(pID,-1);
        JobLumber::SetHarvestPower(pID,0);
        PlayerAction::Finish(pID);
        GivePlayerEXP(pID,5);
        ClearAnimations(pID);
        
        // Reset tree state
        tree[LJTree::harvestPlayer] = INVALID_PLAYER_ID;
        tree[LJTree::harvestPwr] = 0; 
        tree[LJTree::harvestPerc] = 0;
        tree[LJTree::cutPwr] = 0;
        tree[LJTree::isHarvested] = true;
        tree[LJTree::harvestDrop] = 0;
        
        // Cleanup visual objects
        if(IsValidDynamicObject(tree[LJTree::objectId])) {
            DestroyDynamicObject(tree[LJTree::objectId]);
        }
        tree[LJTree::objectId] = INVALID_STREAMER_ID;
        
        if(IsValidDynamicArea(tree[LJTree::areaId])) {
            DestroyDynamicArea(tree[LJTree::areaId]);
        }
        tree[LJTree::areaId] = INVALID_STREAMER_ID;
        
        // Set respawn timer
        tree[LJTree::respawnTimer] = JobLumber::DEFAULT_SPAWN_TIME;
        
        // Transition to HARVESTED state
        tree[LJTree::state] = TREE_STATE_HARVESTED;
        printf("Tree Harvesting Finished - Transitioned to HARVESTED state");
    }
    
    return 1;
}

JobLumber::HandleHarvestedState(tree[JobLumber::e_Tree], list_index) {
    if(tree[LJTree::id] == 0) return 0;
    
    // Update respawn timer
    tree[LJTree::respawnTimer] -= 1;

    // Check for transition to ALIVE state
    if(tree[LJTree::respawnTimer] <= 0) {
        // Reset tree state
        tree[LJTree::isDown] = false;
        tree[LJTree::isHarvested] = false;
        
        // Create new tree object and area
        new l_handle = CreateDynamicObject(LJ_TREE_MODEL_ID, 
                                          tree[LJTree::pos][X],
                                          tree[LJTree::pos][Y],
                                          tree[LJTree::pos][Z],
                                          0.0, 0.0, 0.0);
        new l_area = CreateDynamicCircle(tree[LJTree::pos][X],
                                         tree[LJTree::pos][Y],
                                         2.0);
        
        // Update tree properties
        tree[LJTree::objectId] = l_handle;
        tree[LJTree::areaId] = l_area;
        Streamer_SetIntData(STREAMER_TYPE_AREA, 
                           tree[LJTree::areaId], 
                           E_STREAMER_CUSTOM(E_STREAMER_LUMBER_ID), 
                           list_index);
        
        // Transition to ALIVE state
        tree[LJTree::state] = TREE_STATE_ALIVE;
        printf("Tree Respawned - Transitioned to ALIVE state");
    }
    
    return 1;
}

JobLumber::DropWoodLog(const tree[JobLumber::e_Tree]) {
    // Generate random position near tree
    new Float:randX, Float:randY;
    randX = float(random(3) - 1) + 0.1;
    randY = float(random(3) - 1) + 0.1;
    new Float:range = float(random(2) + 1);
    randX += range;
    randY += range;
    
    // Create wood log item
    new dropItem[Inv::eItem];
    dropItem[Item::id] = ITEM_RES_WOOD_LOG; // Wood Log
    dropItem[Item::amount] = 1;
    
    // Set drop position
    new Float:dropPos[3];
    dropPos[0] = tree[LJTree::pos][X] + randX;
    dropPos[1] = tree[LJTree::pos][Y] + randY;
    dropPos[2] = tree[LJTree::pos][Z];
    
    // Create the drop
    CreateDropItem(dropPos, dropItem);
    
    return 1;
}

// Main Tick function using state machine
JobLumber::Tick() {
    new tree[JobLumber::e_Tree];
    new list_index = -1;
    
    for_list(i : JobLumber::list_tree) {
        list_index++;
        if(!iter_valid(i)) continue;
        
        iter_get_arr(i, tree);
        
        // Process tree based on its current state
        switch(tree[LJTree::state]) {
            case TREE_STATE_ALIVE: {
                // For backward compatibility
                if(tree[LJTree::isDown]) {
                    if(tree[LJTree::isHarvested]) {
                        tree[LJTree::state] = TREE_STATE_HARVESTED;
                    } else {
                        tree[LJTree::state] = TREE_STATE_FALLEN;
                    }
                } else {
                    JobLumber::HandleAliveState(i, tree);
                }
            }
            
            case TREE_STATE_FALLEN: {
                // For backward compatibility
                if(!tree[LJTree::isDown]) {
                    tree[LJTree::state] = TREE_STATE_ALIVE;
                } else if(tree[LJTree::isHarvested]) {
                    tree[LJTree::state] = TREE_STATE_HARVESTED;
                } else {
                    JobLumber::HandleFallenState(tree);
                }
            }
            
            case TREE_STATE_HARVESTED: {
                // For backward compatibility
                if(!tree[LJTree::isDown]) {
                    tree[LJTree::state] = TREE_STATE_ALIVE;
                } else if(!tree[LJTree::isHarvested]) {
                    tree[LJTree::state] = TREE_STATE_FALLEN;
                } else {
                    JobLumber::HandleHarvestedState(tree, list_index);
                }
            }
            
            default: {
                // Determine proper state based on isDown and isHarvested flags
                if(!tree[LJTree::isDown]) {
                    tree[LJTree::state] = TREE_STATE_ALIVE;
                } else if(!tree[LJTree::isHarvested]) {
                    tree[LJTree::state] = TREE_STATE_FALLEN;
                } else {
                    tree[LJTree::state] = TREE_STATE_HARVESTED;
                }
            }
        }
        
        // Save changes
        iter_set_arr(i, tree);
    }
    
    return 1;
}

#if defined DEBUG_MODE
public OnPlayerEditDynamicObject(playerid, STREAMER_TAG_OBJECT:objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
  // printf("[DEBUG] Lumber OnPlayerEditDynamicObject");
    if(!JobLumber::IsEditingTree(playerid)) {
#if defined JB_LJ_OnPlayerEditDynObject
        return JB_LJ_OnPlayerEditDynObject(playerid,objectid,response,x,y,z,rx,ry,rz);
#else
        return 1;
#endif
    }
    new EditTreeID = JobLumber::GetEditTreeID(playerid);
    if(EditTreeID == -1) {
#if defined JB_LJ_OnPlayerEditDynObject
        return JB_LJ_OnPlayerEditDynObject(playerid,objectid,response,x,y,z,rx,ry,rz);
#else
        return 1;
#endif
    }

    if(response == 1) {
        Logger_Dbg("lumber", "object edited", 
                   Logger_I("tree_id", EditTreeID), 
                   Logger_I("object_id", objectid),
                   Logger_I("response", response)
                   );
        Logger_Dbg("lumber", "object edited", 
                   Logger_F("posX", x),
                   Logger_F("posY", y),
                   Logger_F("posZ", z)
                   );
        Logger_Dbg("lumber", "object edited", 
                   Logger_F("rotX", rx),
                   Logger_F("rotY", ry),
                   Logger_F("rotZ", rz)
                   );
        new l_tree[JobLumber::e_Tree];
        list_get_arr(JobLumber::list_tree, EditTreeID, l_tree);

        l_tree[LJTree::pos][X] = x;
        l_tree[LJTree::pos][Y] = y;
        l_tree[LJTree::pos][Z] = z;

        if(IsValidDynamicArea(l_tree[LJTree::areaId])) {
            DestroyDynamicArea(l_tree[LJTree::areaId]);
        }

        l_tree[LJTree::areaId] = CreateDynamicCircle(x,y,2.0);

        list_set_arr(JobLumber::list_tree, EditTreeID, l_tree);
        JobLumber::SetEditingTree(playerid, 0);
        JobLumber::SetEditTreeID(playerid, -1);   
        JobLumber::SaveTree(l_tree);
    }
#if defined JB_LJ_OnPlayerEditDynObject
    return JB_LJ_OnPlayerEditDynObject(playerid,objectid,response,x,y,z,rx,ry,rz);
#else
    return 1;
#endif
}
#if defined _ALS_OnPlayerEditDynamicObject
#undef OnPlayerEditDynamicObject
#else
#define _ALS_OnPlayerEditDynamicObject
#endif
#define OnPlayerEditDynamicObject JB_LJ_OnPlayerEditDynObject 
#if defined JB_LJ_OnPlayerEditDynObject
forward JB_LJ_OnPlayerEditDynObject(playerid, STREAMER_TAG_OBJECT:objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
#endif



CMD:gotolumber(playerid, params[]) {
  SetPlayerPos(playerid, -1968.6321,-2446.3931,30.6250);
  return 1;
}

JobLumber::CuttingFinish(tree[JobLumber::e_Tree]) {
  // new tree[JobLumber::e_Tree];
  // list_get_arr(JobLumber::list_tree, treeId, tree);
  //
  // printf("DEBUG Tree is Cut");
  // JobLumber::PrintTree(tree);

  if(IsValidDynamicObject(tree[LJTree::objectId])) {
    DestroyDynamicObject(tree[LJTree::objectId]);
  }
  tree[LJTree::objectId] = INVALID_STREAMER_ID;
  if(IsValidDynamicArea(tree[LJTree::areaId])) {
    DestroyDynamicArea(tree[LJTree::areaId]);
  }
  tree[LJTree::objectId] = INVALID_STREAMER_ID;

  new physObj = CreateObject(
    LJ_TREE_MODEL_ID,
    tree[LJTree::pos][X],
    tree[LJTree::pos][Y],
    tree[LJTree::pos][Z]+0.5,
    0.0,
    0.0,
    0.0,
    150.0
  );
  PHY_InitObject(
    physObj,
    LJ_TREE_MODEL_ID,30.0);
  new Float:randX,Float:randY;
  randX = float(random(3) - 1) + 0.1;
  randY = float(random(3) - 1) + 0.3;
  // printf("RandX: %f RandY: %f",randX,randY);

  new Float:fallSpeed = 10.0;

  PHY_SetObjectVelocity(physObj,(randX*fallSpeed),(randY*fallSpeed),0.0);
  PHY_RollObject(physObj,1,PHY_ROLLING_MODE_DEFAULT);
  PHY_SetObjectFriction(physObj, 0.8);
  PHY_SetObjectAirResistance(physObj,0.1);
  PHY_SetObjectGravity(physObj, 9.8);
  new Float:zBound;
  CA_FindZ_For2DCoord(tree[LJTree::pos][X], tree[LJTree::pos][Y], zBound);
  PHY_SetObjectZBound(physObj,zBound,_,0.3);
  SvrPhysObj[physObj][epo_posX] = tree[LJTree::pos][X];
  SvrPhysObj[physObj][epo_posY] = tree[LJTree::pos][Y];
  SvrPhysObj[physObj][epo_posZ] = tree[LJTree::pos][Z];
  SvrPhysObj[physObj][epo_lastX] = tree[LJTree::pos][X];
  SvrPhysObj[physObj][epo_lastY] = tree[LJTree::pos][Y];
  SvrPhysObj[physObj][epo_lastZ] = tree[LJTree::pos][Z];
  SvrPhysObj[physObj][epo_treeId] = tree[LJTree::id];
  SvrPhysObj[physObj][epo_checked] = false;
  SvrPhysObj[physObj][epo_valid] = true;

  tree[LJTree::isDown] = true;
  // Update state machine state
  tree[LJTree::state] = TREE_STATE_FALLEN;
  tree[LJTree::cutPwr] = 0;
  tree[LJTree::cutPerc] = 0;
  list_clear(tree[LJTree::cutPlayers]);
   
  // list_set_arr(JobLumber::list_tree,tree[LJTree::id],tree);
  // printf("Done Cut Tree");
  return 1;
}

CMD:spawntree(playerid, params[]) {
    new Float:l_pX, Float:l_pY, Float:l_pZ,
        Float: l_pAngle,
        Float: l_dist;

    GetPlayerPos(playerid, l_pX,l_pY,l_pZ);

    GetPlayerFacingAngle(playerid, l_pAngle);

    l_dist = 3.0;
    GetXYInFrontOfPoint(l_pX,l_pY,l_pAngle, l_dist);

    CA_FindZ_For2DCoord(l_pX,l_pY,l_pZ);
    
    new l_handle = CreateDynamicObject(LJ_TREE_MODEL_ID, l_pX,l_pY,l_pZ-0.7,0.0,0.0,0.0);
    new l_area = CreateDynamicCircle(l_pX,l_pY,2.0);

    new tree[JobLumber::e_Tree];

    new l_treeId = list_size(JobLumber::list_tree);
    tree[LJTree::id] = l_treeId;

    tree[LJTree::pos][X] = l_pX;
    tree[LJTree::pos][Y] = l_pY;
    tree[LJTree::pos][Z] = l_pZ;
    tree[LJTree::isDown] = false;
    tree[LJTree::respawnTimer] = JobLumber::DEFAULT_SPAWN_TIME;
    tree[LJTree::state] = TREE_STATE_ALIVE; // Initialize state

    tree[LJTree::objectId] = l_handle;
    tree[LJTree::areaId] = l_area;
    tree[LJTree::cutPlayers] = list_new();
    tree[LJTree::harvestPlayer] = INVALID_PLAYER_ID;
    tree[LJTree::harvestDropTreshold] = 20;
    new l_index = list_size(JobLumber::list_tree);
    Streamer_SetIntData(STREAMER_TYPE_AREA, tree[LJTree::areaId], E_STREAMER_CUSTOM(E_STREAMER_LUMBER_ID), l_index);
    list_add_arr(JobLumber::list_tree, tree);

    JobLumber::SetEditingTree(playerid, 1);
    JobLumber::SetEditTreeID(playerid, l_treeId);

    EditDynamicObject(playerid, l_handle);
    return 1;
}

stock JobLumber::PrintAllTrees() {
  for_list(i: JobLumber::list_tree) {
    if(!iter_valid(i)) continue;
    new l_tree[JobLumber::e_Tree];
    iter_get_arr(i, l_tree);
    JobLumber::PrintTree(l_tree);
  }
  return 1;
}

CMD:listtree(playerid, params[]) {
  JobLumber::PrintAllTrees();
  return 1;
}


public PHY_OnObjectUpdate(objectid) {
  if(!SvrPhysObj[objectid][epo_valid]) return 1;
  new Float:oR[3], Float:oP[3];
  GetObjectRot(objectid, oR[0],oR[1],oR[2]);
  GetObjectPos(objectid,oP[0],oP[1],oP[2]);
  if(PHY_IsObjectMoving(objectid)) {
    if(
      (oR[0] > 0 && oR[0] < 78) ||
      (oR[0] > 271 && oR[0] < 360)

    ) {
      if(!SvrPhysObj[objectid][epo_checked]) {
        SvrPhysObj[objectid][epo_checked] = true;
      }
    } 
    else {
      if(SvrPhysObj[objectid][epo_checked]) {
        PHY_SetObjectVelocity(objectid,0.0,0.0);
      }
    }

    // if((oR[2] > -46.0 && oR[2] < -44.0)) {
    //    new Float:l_speed;
    //    PHY_GetObjectSpeed(objectid,l_speed);
    //    PHY_ApplyRotation(objectid, l_speed, -40.0);
    // }

    // printf("oid: %i rx: %f ry: %f rz: %f",objectid, oR[0],oR[1],oR[2]);

    if(!IsPointInRangeOfPoint2D(3.0,oP[0],oP[1],SvrPhysObj[objectid][epo_posX],SvrPhysObj[objectid][epo_posY])) {
      SetObjectPos(objectid,SvrPhysObj[objectid][epo_lastX],SvrPhysObj[objectid][epo_lastY],oP[2]);
    } else {
      SvrPhysObj[objectid][epo_lastX] = oP[0];
      SvrPhysObj[objectid][epo_lastY] = oP[1];
      SvrPhysObj[objectid][epo_lastZ] = oP[2];
    }
  } else {
   
    new tree[JobLumber::e_Tree];
    list_get_arr(JobLumber::list_tree,SvrPhysObj[objectid][epo_treeId], tree);
    DebugPhysObject(objectid);
    
    if(tree[LJTree::id] == 0) return 1;
    tree[LJTree::objectId] = CreateDynamicObject(LJ_TREE_DEAD_MODEL_ID,
                                                 oP[0],oP[1],oP[2],
                                                 0.0,0.0,oR[2]
                                                 );
    tree[LJTree::areaId] = CreateDynamicCircle(oP[0],oP[1], 2.0);
        
    Streamer_SetIntData(STREAMER_TYPE_AREA, tree[LJTree::areaId], E_STREAMER_CUSTOM(E_STREAMER_LUMBER_ID), tree[LJTree::id]);

    // Update state machine state
    tree[LJTree::state] = TREE_STATE_FALLEN;
    
    list_set_arr(JobLumber::list_tree,SvrPhysObj[objectid][epo_treeId], tree);
     
    DeletePhysObj(objectid);
    foreach(new i : Player) {
      if(IsPlayerInRangeOfPoint(i, 50.0,
                                oP[0],
                                oP[1],
                                oP[2]
                                )) {
        Streamer_Update(i, 0);
      }
    }
  }
  return 1;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
  if (response == EDIT_RESPONSE_FINAL)
  {
    EMIT_PlayerSystemChat(playerid, -1, "Attached object edition saved.");

    ao[playerid][index][ao_x] = fOffsetX;
    ao[playerid][index][ao_y] = fOffsetY;
    ao[playerid][index][ao_z] = fOffsetZ;
    ao[playerid][index][ao_rx] = fRotX;
    ao[playerid][index][ao_ry] = fRotY;
    ao[playerid][index][ao_rz] = fRotZ;
    ao[playerid][index][ao_sx] = fScaleX;
    ao[playerid][index][ao_sy] = fScaleY;
    ao[playerid][index][ao_sz] = fScaleZ;

    printf("ox: %f\noy:%f\noz:%f\nrx:%f\nry:%f\nrz:%f",
           fOffsetX,
           fOffsetY,
           fOffsetZ,
           fRotX,
           fRotY,
           fRotZ
           );
  }
  else if (response == EDIT_RESPONSE_CANCEL)
  {
    EMIT_PlayerSystemChat(playerid, -1, "Attached object edition not saved.");

    new i = index;
    SetPlayerAttachedObject(playerid, index, modelid, boneid, ao[playerid][i][ao_x], ao[playerid][i][ao_y], ao[playerid][i][ao_z], ao[playerid][i][ao_rx], ao[playerid][i][ao_ry], ao[playerid][i][ao_rz], ao[playerid][i][ao_sx], ao[playerid][i][ao_sy], ao[playerid][i][ao_sz]);
  }
  return 1;
}


CMD:animcs(playerid, params[]) {
  new lib[32], anim[64];
  if(sscanf(params, "s[32]s[64]", lib,anim)) return -1;
  ApplyAnimation(playerid, lib,anim, 4.1,true,true,true,true,1,1);
  return 1;
}

CMD:stopanim(playerid, params[]) {
  ClearAnimations(playerid);
  return 1;
}

#endif
