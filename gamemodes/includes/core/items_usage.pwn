public OnGUIPlayerInventoryUse(playerid,
    const arguments[]) {
    new l_slot;
    if (sscanf(arguments, "i", l_slot)) {
        printf("[ERROR] Malformed Event inv:use_item\n%s", arguments);
        return -1;
    }

    if(list_size(PlayerInventoryList[playerid]) < l_slot) return -1;
    new l_item[CharacterInv::eInfo];
    list_get_arr(PlayerInventoryList[playerid], l_slot, l_item);
    new itemData[Inv::eItem];
    COPY_ARRAY(l_item[CharacterInv::item], itemData, Inv::eItem)
    new itemDef[eItemDef];
    GetItemDefinition(itemData[Item::id], itemDef);

    printf("Player %i want to use item at slot %i", playerid, l_slot);
    printf("ItemID: %i", itemData[Item::id]);
    printf("Item name %s, cat: %s", itemDef[ItemDef::name], itemDef[ItemDef::cat]);
    printf("UsingTools: %i", Character::IsUsingTools(playerid));

    switch (itemData[Item::id]) {
        case ITEM_TOOLS_CHAINSAW: {
            printf("Chainsaw Check %i", (!JobLumber::IsUsingCS(playerid) && !Character::IsUsingTools(playerid)));
            if (JobLumber::IsUsingCS(playerid)) {
                RemovePlayerAttachedObject(playerid, 0);
                JobLumber::SetUsingCS(playerid, 0);
                Character::UpdateTools(playerid, 0, -1);
                return 1;
            }
            if (!JobLumber::IsUsingCS(playerid) && !Character::IsUsingTools(playerid)) {
                printf("Using tools chainsaw");
                SetPlayerAttachedObject(playerid, 0, MODELS_TOOLS_CHAINSAW, 6,
                    JobLumber::AO_CS_DATA[ao_x],
                    JobLumber::AO_CS_DATA[ao_y],
                    JobLumber::AO_CS_DATA[ao_z],
                    JobLumber::AO_CS_DATA[ao_rx],
                    JobLumber::AO_CS_DATA[ao_ry],
                    JobLumber::AO_CS_DATA[ao_rz]);
                JobLumber::SetUsingCS(playerid, 1);
                Character::UpdateTools(playerid, ITEM_TOOLS_CHAINSAW, l_slot);
                return 1;
            } else {
                EMIT_PlayerSystemChat(playerid, -1, "[TOOLS] Can't equipt tools. You're currenly using another one.");
            }
            return 1;
        }
        case ITEM_TOOLS_FISHINGROD: {
            printf("FishingRod Check %i", (!JobLumber::IsUsingCS(playerid) && !Character::IsUsingTools(playerid)));
            if (Fishing::IsUsingRod(playerid)) {
                RemovePlayerAttachedObject(playerid, 0);
                Fishing::SetIsUsingRod(playerid, 0);
                Character::UpdateTools(playerid, 0, -1);
                return 1;
            }
            if (!Fishing::IsUsingRod(playerid) && !Character::IsUsingTools(playerid)) {
                printf("Using tools fishing rod");
                SetPlayerAttachedObject(playerid, 0, MODELS_TOOLS_FISHINGROD, 6,
                    Fishing::AO_ROD_DATA[ao_x],
                    Fishing::AO_ROD_DATA[ao_y],
                    Fishing::AO_ROD_DATA[ao_z],
                    Fishing::AO_ROD_DATA[ao_rx],
                    Fishing::AO_ROD_DATA[ao_ry],
                    Fishing::AO_ROD_DATA[ao_rz]);
                Fishing::SetIsUsingRod(playerid, 1);
                Character::UpdateTools(playerid, ITEM_TOOLS_FISHINGROD, l_slot);
                return 1;
            } else {
                EMIT_PlayerSystemChat(playerid, -1, "[TOOLS] Can't equipt tools. You're currenly using another one.");
            }
            return 1;
        }
        case ITEM_BLUEPRINT_SAWMILL: { // Blueprint Sawmill
            EMIT_PlayerSystemChat(playerid, -1, "Place the building.");
            // new cID = CharacterInfo[playerid][CharacterInfo::id];
            new mapName[64];
            format(mapName, 64, "map_sawmill_uc");
            new Float: l_pX, Float: l_pY, Float: l_pZ,
                Float: l_pAngle,
                Float: l_dist;

            GetPlayerPos(playerid, l_pX, l_pY, l_pZ);
            printf("[DEBUG] Player posX: %f posY: %f posZ: %f", l_pX, l_pY, l_pZ);

            GetPlayerFacingAngle(playerid, l_pAngle);

            l_dist = 10.0;
            GetXYInFrontOfPoint(l_pX, l_pY, l_pAngle, l_dist);

            printf("[DEBUG] Object posX: %f posY: %f posZ: %f", l_pX, l_pY, l_pZ);

            CA_FindZ_For2DCoord(l_pX, l_pY, l_pZ);

            EMIT_PlayerSystemChat(playerid, -1, "Spawning map");

            new Float: l_spawnPos[3];
            l_spawnPos[0] = l_pX;
            l_spawnPos[1] = l_pY;
            l_spawnPos[2] = l_pZ;

            Building::SetIsPlacingBlueprint(playerid, 1);
            new mapID = await DynMap::spawn_prefab(playerid, l_spawnPos, mapName);
            printf("Building Placed with ID %i", mapID);
            // Building::create(cID,BuildingType::CRAFTING_STATION, -1);
            return 1;
        }
        case ITEM_TOOLS_SLEDGEHAMMER: {
            printf("SledgeHammer Check %i", (!JobMiner::IsUsingSH(playerid) && !Character::IsUsingTools(playerid)));
            if (JobMiner::IsUsingSH(playerid)) {
                RemovePlayerAttachedObject(playerid, 0);
                JobMiner::SetUsingSH(playerid, 0);
                Character::UpdateTools(playerid, 0, -1);
                return 1;
            }
            if (!JobMiner::IsUsingSH(playerid) && !Character::IsUsingTools(playerid)) {
                printf("Using tools SledgeHammer");
                SetPlayerAttachedObject(playerid, 0, MODELS_TOOLS_SLEDGEHAMMER, 6,
                    JobMiner::AO_CS_DATA[ao_x],
                    JobMiner::AO_CS_DATA[ao_y],
                    JobMiner::AO_CS_DATA[ao_z],
                    JobMiner::AO_CS_DATA[ao_rx],
                    JobMiner::AO_CS_DATA[ao_ry],
                    JobMiner::AO_CS_DATA[ao_rz]);
                JobMiner::SetUsingSH(playerid, 1);
                Character::UpdateTools(playerid, ITEM_TOOLS_SLEDGEHAMMER, l_slot);
                return 1;
            } else {
                EMIT_PlayerSystemChat(playerid, -1, "[TOOLS] Can't equipt tools. You're currenly using another one.");
            }
            return 1;
        }

        case ITEM_TOOLS_PHONE: {
            // TODO: Handle Phone usage
            new Node:node = JsonObject();
            JsonSetString(node, "number", sprintf("%i",itemData[Item::addon1]));
            new l_str[2048];
            JsonStringify(node,l_str);
            cef_emit_event(playerid, "phone:open", CEFSTR(l_str));
            return 1;
        }

        case 301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,318: { // Using Weapons
            EMIT_PlayerSystemChat(playerid, -1, "Using Weapon");
            if(Weapon::IsUsingAnyWeapon(playerid)) {
                Weapon::DisarmPlayer(playerid);
                await task_ms(100);
            }
            if(TakePlayerItem(playerid, l_slot, itemData[Item::amount]) == -1) {
                printf("[ERROR] Failed to use weapon. TakePlayerItem failed");
                return -1;
            }
            new wepInfo[Weapon::Info];
            if( Weapon::GetInfoFromItemID(itemData[Item::id], wepInfo) == 0) {
                EMIT_PlayerSystemChat(playerid, -1, "Error: While getting weapon info");
                return 1;
            }
            Weapon::player_use[playerid][Weapon::active] = true;
            Weapon::player_use[playerid][Weapon::id] = wepInfo[Weapon::id];
            Weapon::player_use[playerid][Weapon::current_ammo] = itemData[Item::addon1];
            return 1;
        }

        case 320: {// Using Tazer 
            if(TakePlayerItem(playerid, l_slot, itemData[Item::amount]) == -1) {
                return -1;
            }
            new wepInfo[Weapon::Info];
            if( Weapon::GetInfoFromItemID(itemData[Item::id], wepInfo) == 0) {
                EMIT_PlayerSystemChat(playerid, -1, "Error: While getting weapon info");
                return 1;
            }
            Weapon::player_use[playerid][Weapon::active] = true;
            Weapon::player_use[playerid][Weapon::id] = wepInfo[Weapon::id];
            Weapon::player_use[playerid][Weapon::current_ammo] = itemData[Item::addon1];
            Weapon::player_use[playerid][Weapon::ext] = 1;
            WeaponSystem::SetUsingTazer(playerid, true);
        }
        
        case ITEM_SEED_WEED,
            ITEM_SEED_WHEAT
            : {

            // TODO: Land Renting
            if(Farming::LandID(playerid) == -1) {
                EMIT_PlayerSystemChat(playerid, -1, "PLANT: Hanya dapat digunakan di area farming.");
                return 0;
            }
            if(Farming::PlantID(playerid) != -1) {
                EMIT_PlayerSystemChat(playerid, -1, "PLANT: Tidak dapat menanam. Sudah terdapat tanaman disekitar kamu.");
                return 0;
            }
            if (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_DUCK) {
                if(TakePlayerItem(playerid, l_slot, 1) == -1) {
                    printf("[ERROR] Failed to use plant. TakePlayerItem failed");
                    return -1;
                }
                Farming::PlantSeed(playerid, itemData[Item::id]);
            } else {
                EMIT_PlayerSystemChat(playerid, -1, "PLANT: Harus dalam keadaan jongkok untuk menanam.");
            }
        }
        case ITEM_RES_JOINT: {
            if(TakePlayerItem(playerid, l_slot, 1) == -1) {
                printf("[ERROR] Failed to use weapon. TakePlayerItem failed");
                return -1;
            }
            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
            Character::SetJointLeft(playerid, 5);
            EMIT_PlayerSystemChat(playerid, -1, "Kamu menggunakan Joint. Klik untuk menghisap.");
        }
        default: {
            return 1;
        }
    }
    return 1;
}
