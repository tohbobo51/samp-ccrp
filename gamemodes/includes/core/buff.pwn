ResetCharacterBuff(playerid) {
    for(new i=0;i<MAX_BUFF_SLOT;i++){
        CharacterBuff[playerid][i][Buff::isActive] = false;
        CharacterBuff[playerid][i][Buff::type] = BuffType::NONE;
        CharacterBuff[playerid][i][Buff::duration] = 0;
        CharacterBuff[playerid][i][Buff::value] = 0;
    }
    return 1;
}

BuffSystemTick() {
    foreach(new i : Player) {
        if(!isSpawned[i]) continue;
        for(new j=0;j<MAX_BUFF_SLOT;j++) {
            if(!CharacterBuff[i][j][Buff::isActive]) continue;
            CharacterBuff[i][j][Buff::duration] -= 1;
            Buff::Apply(i, j);
            if(CharacterBuff[i][j][Buff::duration] == 0) {
                CharacterBuff[i][j][Buff::isActive] = false;
                CharacterBuff[i][j][Buff::value] = 0;
                CharacterBuff[i][j][Buff::type] = BuffType::NONE;
            }
        }
        Buff::GUI_UpdateBuffData(i);
    }
    return 1;
}

Buff::Apply(playerid, buff_index) {
    new l_value = CharacterBuff[playerid][buff_index][Buff::value];
    switch(CharacterBuff[playerid][buff_index][Buff::type]) {
        case BuffType::JOINT: {
            if(CharacterData[playerid][p_armor] < 100.0) {
                CharacterData[playerid][p_armor] += float(l_value);
                Character::ResetArmor(playerid);
            }
        }
    }
    return 1;
}

Buff::isBuffActive(playerid, Buff::TYPE:buff_type_id) {
    for(new i=0;i<MAX_BUFF_SLOT;i++) {
        if(!CharacterBuff[playerid][i][Buff::isActive]) continue;
        if(CharacterBuff[playerid][i][Buff::type] == buff_type_id) {
            return CharacterBuff[playerid][i][Buff::value];
        }
    } 
    return -1;
}

Buff::GetFreeBuffSlot(playerid) {
    new l_slot = 0;
    for(new i=0;i<MAX_BUFF_SLOT;i++) {
        if(!CharacterBuff[playerid][i][Buff::isActive]) return i;
    }
    return l_slot;
}

Buff::GetActiveBuffSlot(playerid, Buff::TYPE:buff_type_id) {
    for(new i=0;i<MAX_BUFF_SLOT;i++) {
        if(
            CharacterBuff[playerid][i][Buff::isActive] && 
            CharacterBuff[playerid][i][Buff::type] == buff_type_id
        ) return i;
    }
    return -1;
}

Buff::GivePlayerBuff(
        playerid, 
        Buff::TYPE:buff_type_id, 
        duration,
        value
    ) {
    new l_buffSlot = Buff::GetActiveBuffSlot(playerid, buff_type_id);
    if(l_buffSlot > -1) {
        CharacterBuff[playerid][l_buffSlot][Buff::duration] = duration;
    } else {
        l_buffSlot = Buff::GetFreeBuffSlot(playerid);
        CharacterBuff[playerid][l_buffSlot][Buff::isActive] = true;
        CharacterBuff[playerid][l_buffSlot][Buff::type] = buff_type_id;
        CharacterBuff[playerid][l_buffSlot][Buff::duration] = duration;
        CharacterBuff[playerid][l_buffSlot][Buff::value] = value;
    }
    return 1;
}

Buff::GUI_UpdateBuffData(playerid) {
    new Node:node_buffs_arr;
    JsonToggleGC(node_buffs_arr, false);
    for(new i=0;i<MAX_BUFF_SLOT;i++) {
        new Node:l_buffList= JsonObject();
        JsonSetInt(l_buffList, "slot", i );
        JsonSetBool(l_buffList, "active", CharacterBuff[playerid][i][Buff::isActive]);
        JsonSetInt(l_buffList, "type", CharacterBuff[playerid][i][Buff::type]);
        JsonSetInt(l_buffList, "duration", CharacterBuff[playerid][i][Buff::duration]);
        if(i == 0) {
            node_buffs_arr = JsonArray(l_buffList);
        } else {
            node_buffs_arr = JsonAppend(node_buffs_arr, JsonArray(l_buffList));
        } 
    }
    new Node:node_payload = JsonObject("buffs", node_buffs_arr);
    new l_str[512];
    JsonStringify(node_payload,l_str);
    // printf("[DEBUG] player inventory \n%s", l_str);
    cef_emit_event(playerid, "pdata:update_buff", CEFSTR(l_str));
    JsonToggleGC(node_buffs_arr,true);
    return 1;
}
