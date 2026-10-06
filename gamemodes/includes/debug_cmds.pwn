#if defined DEBUG_MODE
// DEBUG CMDS DELETE THIS
CMD:reviveme(playerid, params[]) {
    if(CharacterData[playerid][p_injured]) {
        CharacterData[playerid][p_injured] = false;
        CharacterData[playerid][p_health] = 20.0;
        Character::SetHealth(playerid, 20.0);
        TogglePlayerControllable(playerid, true);
        ClearAnimations(playerid);
        SetCameraBehindPlayer(playerid);
        DeathSystem::removePlayer(playerid);
    }
    return 1;
}


CMD:gimmeitem(playerid, params[]) {
    new p_itemID;
    new p_amount;

    if(sscanf(params, "ii", p_itemID,p_amount)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /gimmeitem [itemID][amount]");

    new l_itemData[Inv::eItem];
    l_itemData[Item::id] = p_itemID;
    l_itemData[Item::amount] = p_amount;

    GivePlayerItem(playerid, l_itemData);
    return 1;
}


CMD:gimmeitemex(playerid, params[]) {
    new p_itemID;
    new p_amount;
    new addon1, addon2, addon3;

    if(sscanf(params, "iiiii", p_itemID,p_amount,addon1, addon2, addon3)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /gimmeitem [itemID][amount][add1][add2][add3]");

    new l_itemData[Inv::eItem];
    l_itemData[Item::id] = p_itemID;
    l_itemData[Item::amount] = p_amount;
    l_itemData[Item::addon1] = addon1;
    l_itemData[Item::addon2] = addon2;
    l_itemData[Item::addon3] = addon3;
    GivePlayerItem(playerid, l_itemData);
    return 1;
}

CMD:givephone(playerid, params[]) {
    new number;
    if(sscanf(params, "i", number)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /givephone [number]");
    new phoneItem[Inv::eItem];
    phoneItem[Item::id] = ITEM_TOOLS_PHONE;
    phoneItem[Item::amount] = 1;
    phoneItem[Item::durability] = 0;
    phoneItem[Item::power] = 0;
    phoneItem[Item::addon1] = number;
    phoneItem[Item::addon2] = 0;
    phoneItem[Item::addon3] = 0;
    GivePlayerItem(playerid, phoneItem);
    EMIT_PlayerSystemChat(playerid, -1, sprintf("DEBUG: You got phone with N: %i", number));
    return 1;
}

CMD:dbgtext(playerid, params[]) {

    new color = 0xFFFFFFFF;
    new color2 = RGB::AdjustColorLuminance(color, 1.0);
    new color3 = RGB::AdjustColorLuminance(color, 0.5);
    EMIT_PlayerSystemChat(playerid,color2, "TEST MESSAGE");
    EMIT_PlayerSystemChat(playerid,color3, "TEST MESSAGE");
    return 1;
}

CMD:setcash(playerid, params[]) {
    new cash;
    if(sscanf(params,"i", cash)) return -1;

    GivePlayerMoney(playerid,cash);
    return 1;
}

CMD:foodbuff(playerid, params[]) {
    new duration;
    if(sscanf(params, "i", duration)) return -1;

    Buff::GivePlayerBuff(playerid, BuffType::FOOD, duration, 0);
    return 1;
}

CMD:gotospawn(playerid, params[]) {
    SetPlayerPos(playerid,
                 svSpawnPos[TRAIN_STATION_1][se_posX],
                 svSpawnPos[TRAIN_STATION_1][se_posY],
                 svSpawnPos[TRAIN_STATION_1][se_posZ]
                 );
    return 1;
}

CMD:setstamina(playerid, params[]) {
    new stamina;
    if(sscanf(params, "i", stamina)) return 1;
    if(stamina < 1) return 1;
    CharacterData[playerid][p_stamina] = stamina;
    return 1;
}

CMD:killme(playerid, params[]) {
    SetPlayerHealth(playerid, 0);
    return 1;
}

CMD:gotobank(playerid, params[]) {
    SetPlayerPos(playerid,1402.0828,-1680.2263,940.0469);
    SetPlayerFacingAngle(playerid, 352.9665);
    SetCameraBehindPlayer(playerid);
    return 1;
}

CMD:openfcd1(playerid, params[]) {
    if(!flecca1_vaultDoorOpen) {
        MoveDynamicObject(flecca1_vaultDoor, flecca1_vd[X], flecca1_vd[Y], flecca1_vd[Z]-5.0, 2.0);
        flecca1_vaultDoorOpen = true;
    } else {
        MoveDynamicObject(flecca1_vaultDoor, flecca1_vd[X], flecca1_vd[Y], flecca1_vd[Z], 2.0);
        flecca1_vaultDoorOpen = false;
    }
    return 1;
}

CMD:gotosan1(playerid, params[]) {
    SetPlayerPos(playerid, 1567.983276, 1450.870361, 909.828613);
    return 1;
}

CMD:gotosan2(playerid, params[]) {
    SetPlayerPos(playerid, 2090.767578, 2498.626708, 1023.896240);
    return 1;
}

CMD:gotoasgh1(playerid, params[]) {
    SetPlayerPos(playerid, 1353.770996, 1567.516479, 809.820312);
    return 1;
}

CMD:gotoasgh2(playerid, params[]) {
    SetPlayerPos(playerid,1517.995361, 1606.448242, 709.820312);
    return 1;
}

CMD:gotoasgh3(playerid, params[]) {
    SetPlayerPos(playerid, 1167.73950, -1297.10168, 13.33970);
    return 1;
}

CMD:selobj(playerid, params[]) {
    SelectObject(playerid);
    return 1;
}

CMD:forward(playerid, params[]) {
    new Float:l_pos[3], Float:l_angle;
    GetPlayerPos(playerid, VEC3_UNWRAP(l_pos));
    GetPlayerFacingAngle(playerid, l_angle);
    GetXYInFrontOfPoint(l_pos[X], l_pos[Y], l_angle, 1.0);
    SetPlayerPos(playerid, VEC3_UNWRAP(l_pos));
    return 1;
}

CMD:goup(playerid, params[]) {
    new Float:l_pos[3];
    GetPlayerPos(playerid, VEC3_UNWRAP(l_pos));
    l_pos[Z] += 1.0;
    SetPlayerPos(playerid, VEC3_UNWRAP(l_pos));
}

CMD:alocker(playerid, params[]) {
    new factionid;
    if(sscanf(params, "i", factionid)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /alocker [factionid]");

    if(factionid < 0 && factionid > _:Faction::MAX_FACTION) return 0;
    FactionLocker::ShowToPlayer(playerid, eFaction:factionid);
    return 1;
}

CMD:ciggy(playerid, params[]) {
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
    return 1;
}

CMD:clearaction(playerid, params[]) {
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    return 1;
}

CMD:setarmor(playerid, params[]) {
    new Float:amount;
    if(sscanf(params, "f", amount)) return 0;
    Character::SetArmor(playerid, amount);
    return 1;
}
#endif
