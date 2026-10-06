public OnCharacterInventoryLoaded(playerid) {
    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields);
    PlayerInventoryWeight[playerid] = 0;
    PlayerMaximumWeight[playerid] = CharacterData[playerid][p_inv_weight];
    if(rows > 0) {
        invInitialized[playerid] = true;
        for(new i=0;i<rows;i++) {
            new l_slotIndex;
            cache_get_value_name_int(i, "slot", l_slotIndex);
            new l_itemId;
            cache_get_value_name_int(i, "item_id", l_itemId);
            new l_itemDef[eItemDef];
            GetItemDefinition(l_itemId, l_itemDef);
            new l_itemWeight = l_itemDef[ItemDef::weight];
            new l_itemAmt;
            cache_get_value_name_int(i, "item_amt", l_itemAmt);
            new l_sumWeight = l_itemWeight * l_itemAmt;
            new l_currWeight = PlayerInventoryWeight[playerid];
            PlayerInventoryWeight[playerid] = l_currWeight + l_sumWeight;

            // TODO: optimize this section
            new l_slotEnabled;
            cache_get_value_name_int(i, "slot_enabled", l_slotEnabled);

            cache_get_value_name_int(i, "durability", PlayerInventory[playerid][l_slotIndex][Item::durability]);
            cache_get_value_name_int(i, "power", PlayerInventory[playerid][l_slotIndex][Item::power]);

            cache_get_value_name_int(i, "addon1", PlayerInventory[playerid][l_slotIndex][Item::addon1]);
            cache_get_value_name_int(i, "addon2", PlayerInventory[playerid][l_slotIndex][Item::addon2]);
            cache_get_value_name_int(i, "addon3", PlayerInventory[playerid][l_slotIndex][Item::addon3]);

            PlayerInventory[playerid][l_slotIndex][Item::id] = l_itemId;
            PlayerInventory[playerid][l_slotIndex][Item::amount] = l_itemAmt;
            PlayerInventory[playerid][l_slotIndex][Item::enabled] = l_slotEnabled;

            GUI_Emit_InventoryItems(playerid);
        }
    } else {
        invInitialized[playerid] = false;
    }
}


SavePlayerInventorySlot(playerid, slotId) {
    if(authSuccess[playerid]){
        if(slotId > MAX_PLAYERS_ITEM_SLOT) {
            printf("Invalid slot ID");
            return -1;
        }
        new l_characterId = CharacterInfo[playerid][cinfo_id];
        new l_itemId = PlayerInventory[playerid][slotId][Item::id];
        new l_itemAmt = PlayerInventory[playerid][slotId][Item::amount];
        new l_slotEnabled = PlayerInventory[playerid][slotId][Item::enabled];
        new l_durability = PlayerInventory[playerid][slotId][Item::durability];
        new l_power = PlayerInventory[playerid][slotId][Item::power];
        new l_addon1 = PlayerInventory[playerid][slotId][Item::addon1];
        new l_addon2 = PlayerInventory[playerid][slotId][Item::addon2];
        new l_addon3 = PlayerInventory[playerid][slotId][Item::addon3];
        if(invInitialized[playerid]) {
            // TODO: Refactor This
            mysql_format(MainConn, szMiscArray,sizeof(szMiscArray),
                         "UPDATE `character_inventory` \
SET `item_id`='%i', \
`item_amt`='%i', \
`slot_enabled`='%i', \
`durability`='%i', \
`power`='%i', \
`addon1`='%i', \
`addon2`='%i', \
`addon3`='%i' \
WHERE `slot`='%i' AND `characterId`='%i'",
                         l_itemId, l_itemAmt, l_slotEnabled, l_durability,
                         l_power, l_addon1, l_addon2, l_addon3,
                         slotId, l_characterId
                         );
            mysql_tquery(MainConn, szMiscArray);
        } else {
            // TODO: Refactor this 
            mysql_format(MainConn, szMiscArray,sizeof(szMiscArray),
                         "INSERT INTO `character_inventory` \
(`item_id`, \
`item_amt`, \
`slot_enabled`, \
`durability`, \
`power`, \
`addon1`, \
`addon2`, \
`addon3`, \
`slot`, `characterId`) VALUES \
('%i','%i','%i','%i',\
'%i','%i','%i','%i', \
'%i', '%i')",
                         l_itemId, l_itemAmt, l_slotEnabled, l_durability,
                         l_power, l_addon1, l_addon2, l_addon3,
                         slotId, l_characterId
                         );
            mysql_tquery(MainConn, szMiscArray);
        }
    }
    return -1;
}

SaveAllPlayerInventory(playerid) {
    for(new i=0;i<MAX_PLAYERS_ITEM_SLOT;i++) {
        SavePlayerInventorySlot(playerid, i);
    }
    invInitialized[playerid] = true;
    return 1;
}

ResetPlayerItems(playerid) {
    for(new i=0;i<MAX_PLAYERS_ITEM_SLOT;i++) {

        PlayerInventory[playerid][i][Item::id] = -1;
        PlayerInventory[playerid][i][Item::amount] = 0;
        PlayerInventory[playerid][i][Item::enabled] = 1;
        PlayerInventory[playerid][i][Item::durability] = 0;
        PlayerInventory[playerid][i][Item::power] = 0;
        PlayerInventory[playerid][i][Item::addon1] = 0;
        PlayerInventory[playerid][i][Item::addon2] = 0;
        PlayerInventory[playerid][i][Item::addon3] = 0;

        // TODO: Dynamic setting slot enabled
        if(i > 15) {
            PlayerInventory[playerid][i][Item::enabled] = 0;
        }
    }
}

CheckItemInInventory(playerid, p_itemID) {
    for(new i;i<MAX_PLAYERS_ITEM_SLOT;i++) {
        if(PlayerInventory[playerid][i][Item::enabled] == 0) continue;
        if(PlayerInventory[playerid][i][Item::id] == p_itemID) return i;
    }
    return -1;
}

FindEmptyInventorySlot(playerid) {
    for(new i;i<MAX_PLAYERS_ITEM_SLOT;i++) {
        if(PlayerInventory[playerid][i][Item::enabled] == 0) continue;
        if(PlayerInventory[playerid][i][Item::id] == -1) return i;
    }
    return -1;
}

_DoGiveItem(playerid, p_slot, const p_itemData[Inv::eItem], amount=0) {
    PlayerInventory[playerid][p_slot] = p_itemData;
    new l_itemDef[eItemDef];
    GetItemDefinition(p_itemData[Item::id],l_itemDef);
    GUI_EMIT_ItemAdded(playerid, p_itemData[Item::id], amount);
    return 1;
}

stock TestGivePlayerItem(playerid, const p_itemData[Inv::eItem]) {
    new l_itemDef[eItemDef];
    if(!GetItemDefinition(p_itemData[Item::id], l_itemDef)) return -1;

    new l_itemWeight = l_itemDef[ItemDef::weight];
    new l_tbaWeight = l_itemWeight * p_itemData[Item::amount];
    new l_currPlayerWeight = PlayerInventoryWeight[playerid];
    new l_newWeight = l_currPlayerWeight + l_tbaWeight;

    if(l_newWeight > PlayerMaximumWeight[playerid]) {
        return 0;
    }
    new l_currentSlot = CheckItemInInventory(playerid, p_itemData[Item::id]);
    if(l_currentSlot == -1) {
        new l_freeSlot = FindEmptyInventorySlot(playerid);
        if(l_freeSlot == -1) {
            return 0;
        }
        return 1;
    } else {
        new l_itemMaxAmount = l_itemDef[ItemDef::max_amount];
        new l_currAmount = PlayerInventory[playerid][l_currentSlot][Item::amount];
        new l_newAmount = l_currAmount + p_itemData[Item::amount];
        if(l_newAmount > l_itemMaxAmount) {
            new l_freeSlot = FindEmptyInventorySlot(playerid);
            if(l_freeSlot == -1) {
                return 0;
            }
            return 1;
        } else {
            return 1;
        } 
    }
}

CharacterInv::HasVehicleKey(playerid, serial) {
    for(new i=0;i<MAX_PLAYERS_ITEM_SLOT;i++) {
        if(!PlayerInventory[playerid][i][Item::enabled]) continue;
        if(PlayerInventory[playerid][i][Item::addon1] == serial) {
            return true;
        }
    }
    return false;
}

GivePlayerItem(playerid, p_itemData[Inv::eItem]) {
    new l_itemDef[eItemDef];
    if(!GetItemDefinition(p_itemData[Item::id], l_itemDef)) return -1;

    new l_itemWeight = l_itemDef[ItemDef::weight];
    new l_tbaWeight = l_itemWeight * p_itemData[Item::amount];
    new l_currPlayerWeight = PlayerInventoryWeight[playerid];
    new l_newWeight = l_currPlayerWeight + l_tbaWeight;
    new giveAmount = p_itemData[Item::amount];

    if(l_newWeight > PlayerMaximumWeight[playerid]) {
        EMIT_PlayerSystemChat(playerid, -1, "Failed to receive item. Maximum weight exceed.");
        new Float:l_Pos[3];
        GetPlayerPos(playerid, l_Pos[0],l_Pos[1],l_Pos[2]);
        l_Pos[2] -= 0.6;
        CreateDropItem(l_Pos, p_itemData);
        EMIT_PlayerSystemChat(playerid, -1, "[ITEMS] Maximum inventory weight reached. Item dropped");
        return -1;
    }

    new l_currentSlot = CheckItemInInventory(playerid, p_itemData[Item::id]);
    if(l_currentSlot == -1) {
        // Player doesn't have items in inventory, so add in new slot
        new l_freeSlot = FindEmptyInventorySlot(playerid);
        if(l_freeSlot == -1) {
            new Float:l_Pos[3];
            GetPlayerPos(playerid, l_Pos[0],l_Pos[1],l_Pos[2]);
            l_Pos[2] -= 0.6;
            CreateDropItem(l_Pos, p_itemData);
            EMIT_PlayerSystemChat(playerid, -1, "[ITEMS] Item slot is full. Item dropped");
            return -1;
        }
        PlayerInventoryWeight[playerid] = l_newWeight;
        p_itemData[Item::enabled] = 1;
        _DoGiveItem(playerid, l_freeSlot, p_itemData, giveAmount);
        return 1;
    } else {
        // Player has item, add the amount if possible
        // new l_itemMaxAmount = mget(ItemMaxAmount, p_itemID);
        new l_itemMaxAmount = l_itemDef[ItemDef::max_amount];
        new l_currAmount = PlayerInventory[playerid][l_currentSlot][Item::amount];
        new l_newAmount = l_currAmount + p_itemData[Item::amount];
        if(l_newAmount > l_itemMaxAmount) {
            // TODO: Subtract item and give item in the new slot
            new l_freeSlot = FindEmptyInventorySlot(playerid);
            if(l_freeSlot == -1) {
                new Float:l_Pos[3];
                GetPlayerPos(playerid, l_Pos[0],l_Pos[1],l_Pos[2]);
                l_Pos[2] -= 0.6;
                CreateDropItem(l_Pos, p_itemData);
                EMIT_PlayerSystemChat(playerid, -1, "[ITEMS] Item slot is full. Item dropped");
                return -1;
            }
            PlayerInventoryWeight[playerid] = l_newWeight;
            p_itemData[Item::enabled] = 1;
            _DoGiveItem(playerid, l_freeSlot, p_itemData, giveAmount);
            return 1;
        } else {
            PlayerInventoryWeight[playerid] = l_newWeight;
            p_itemData[Item::amount] = l_newAmount;
            p_itemData[Item::enabled] = 1;
            _DoGiveItem(playerid, l_currentSlot, p_itemData,giveAmount);
            return 1;
        } 
    } 
}


TakePlayerItem(playerid, slot, p_amount) {
    if(p_amount < 1) {
        printf("[ERROR] TakePlayerItem amount should be greater than 0");
        return -1;
    }
    if(!PlayerInventory[playerid][slot][Item::enabled]) {
        printf("[ERROR] TakePlayerItem inventory slot is not enabled");
        return -1;
    }
    if(p_amount > PlayerInventory[playerid][slot][Item::amount]) {
        printf("[ERROR] TakePlayerItem amount is greater than inventory amount");
        printf("Slot %i", slot);
        printf("Take Amt: %i | Inventory Amt: %i ", p_amount, PlayerInventory[playerid][slot][Item::amount]);
        return -1;
    }

    if(Character::IsUsingTools(playerid)) {
        if(Character::GetToolsSlot(playerid) == slot) {
            printf("[ERROR] Player trying to drop item that currently used");
            EMIT_PlayerSystemChat(playerid, -1, "[ERROR] Cannot drop item while using it.");
            return -1;
        }
    }

    new l_itemDef[eItemDef];
    new l_itemID = PlayerInventory[playerid][slot][Item::id];
    GetItemDefinition(l_itemID, l_itemDef);

    new l_itemWeight = l_itemDef[ItemDef::weight];
    new l_totalWeigth = l_itemWeight * p_amount;

    printf("[DEBUG] TakePlayerItem W: %i, Total W: %i", l_itemWeight,l_totalWeigth);

    PlayerInventoryWeight[playerid] -= l_totalWeigth;

    if(PlayerInventory[playerid][slot][Item::amount] == p_amount) {
        PlayerInventory[playerid][slot][Item::id] = -1;
        PlayerInventory[playerid][slot][Item::amount] = 0;
        PlayerInventory[playerid][slot][Item::durability] = 0;
        PlayerInventory[playerid][slot][Item::power] = 0;
        PlayerInventory[playerid][slot][Item::addon1] = 0;
        PlayerInventory[playerid][slot][Item::addon2] = 0;
        PlayerInventory[playerid][slot][Item::addon3] = 0;
    } else {
        PlayerInventory[playerid][slot][Item::amount] -= p_amount;
    }

    GUI_Emit_InventoryItems(playerid);
    GUI_EMIT_ItemReduced(playerid, l_itemID, p_amount);
    return 1;
}

CharacterInv::GetSlotFromID(playerid, itemId) {
    for(new i=0;i<MAX_PLAYERS_ITEM_SLOT;i++) {
        if(PlayerInventory[playerid][i][Item::id] == itemId) {
            return i;
        }
    }
    return -1;
}
