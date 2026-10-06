#include <pp-hooks>
hook OnPlayerConnect(playerid)
{
    Weapon::ResetUsingInfo(playerid);
    Weapon::ResetWeaponSkill(playerid);
}


hook OnPlayerDisconnect(playerid, reason)
{

}


hook OnPlayerUpdate(playerid)
{
    if(!isSpawned[playerid]) {
        return 0;
    }
    Weapon::Checks(playerid);
    return 0;
}

hook OnPlayerShootDynObject(playerid, weaponid, objectid, Float:x, Float:y, Float:z) {
    new l_ammo = GetPlayerAmmo(playerid);
    new l_weapon = GetPlayerWeapon(playerid);
    Weapon::player_use[playerid][Weapon::current_ammo] -= 1;
    if(Weapon::player_use[playerid][Weapon::current_ammo] <= 0) {
        SetPlayerAmmo(playerid, l_weapon, 1);
        SetPlayerArmedWeapon(playerid, l_weapon);
        Weapon::player_use[playerid][Weapon::current_ammo] = 0;
        return 0;
    }
    if(l_ammo != Weapon::player_use[playerid][Weapon::current_ammo] && Weapon::player_use[playerid][Weapon::current_ammo] != 0) {
        SetPlayerAmmo(playerid, l_weapon, Weapon::player_use[playerid][Weapon::current_ammo]);
    }
    return 0;
}
hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
    new l_ammo = GetPlayerAmmo(playerid);
    new l_weapon = GetPlayerWeapon(playerid);
    Weapon::player_use[playerid][Weapon::current_ammo] -= 1;
    if(Weapon::player_use[playerid][Weapon::current_ammo] <= 0) {
        SetPlayerAmmo(playerid, l_weapon, 1);
        SetPlayerArmedWeapon(playerid, l_weapon);
        Weapon::player_use[playerid][Weapon::current_ammo] = 0;
        return 0;
    }
    if(l_ammo != Weapon::player_use[playerid][Weapon::current_ammo] && Weapon::player_use[playerid][Weapon::current_ammo] != 0) {
        SetPlayerAmmo(playerid, l_weapon, Weapon::player_use[playerid][Weapon::current_ammo]);
    }
    if(hittype == BULLET_HIT_TYPE_PLAYER) {
        if(!IsPlayerConnected(hitid)) return 0;
        if(IsPlayerNPC(hitid)) return 0;
        if(l_weapon == 23 && WeaponSystem::UsingTazer(playerid) && !Character::Tazed(hitid)) {
            new text[256];
            TogglePlayerControllable(hitid, false);
            ApplyAnimation(hitid,"CRACK","crckdeth2",4.1,1,1,1,1,1);
            new tazetimer = SetTimerEx("OnTazedEnd", 10000, 0, "d", hitid);
            WeaponSystem::SetTazeTimer(hitid, tazetimer);
            format(text, sizeof(text), "%s has been tazed by %s.", GetName(hitid), GetName(playerid));
            SendProximityAction(30.0, playerid, "rp", "me", text, COLOR_ORCHID);
            EMIT_PlayerSystemChat(hitid, -1, "Kamu sedang tidak dapat bergerak. (TAZED)");
            Character::SetTazed(hitid, true);
            return 0;
        }
        
        // TODO: Handle damage
        return 0;
    }
    if(hittype == BULLET_HIT_TYPE_VEHICLE) {
    }
    
    // if(l_weapon == 23 && WeaponSystem::UsingTazer(playerid)) {
    //     new text[256];
    //     TogglePlayerControllable(playerid, false);
    //     ApplyAnimation(playerid,"CRACK","crckdeth2",4.1,1,1,1,1,1);
    //     new tazetimer = SetTimerEx("OnTazedEnd", 10000, 0, "d", playerid);
    //     WeaponSystem::SetTazeTimer(playerid, tazetimer);
    //     format(text, sizeof(text), "%s has been tazed by %s.", GetName(playerid), GetName(playerid));
    //     SendProximityAction(30.0, playerid, "rp", "me", text, COLOR_ORCHID);
    //     Character::SetTazed(playerid, true);    
    // }
    return 0;
}

callback OnTazedEnd(playerid) {
    Character::SetTazed(playerid, false);
    TogglePlayerControllable(playerid, true);
    ClearAnimations(playerid);
    new tazetimer = WeaponSystem::GetTazeTimer(playerid);
    if(tazetimer != 0) {
        KillTimer(tazetimer);
    }
    EMIT_PlayerSystemChat(playerid, -1, "Kamu dapat bergerak kembali.");
    return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart) {
    Character::SetHealth(playerid, Character::GetHealth(playerid) - amount);
    return 1;
}

Weapon::IsValidWeapon(weaponid) {
    return Weapon::list[weaponid][Weapon::valid];
}

Weapon::IsUsingAnyWeapon(playerid) {
    return Weapon::player_use[playerid][Weapon::active];
}

new Weapon::WeaponData[MAX_PLAYERS][12][2];
Weapon::Checks(playerid) {
    for(new i=0;i<12;i++) {
        GetPlayerWeaponData(playerid, i, Weapon::WeaponData[playerid][i][0], Weapon::WeaponData[playerid][i][1]);
        if(!Weapon::IsValidWeapon(Weapon::WeaponData[playerid][i][0])) {
            AdminSystem::Kick(playerid, "Posession of Invalid Weapon.");
        }
    }
    new l_wepid = GetPlayerWeapon(playerid);
    if(Weapon::player_use[playerid][Weapon::active]) {
        if(Weapon::player_use[playerid][Weapon::id] != l_wepid) {
            printf("Active WeaponID: %i", Weapon::player_use[playerid][Weapon::id]);
            printf("Player Weapon: %i", l_wepid);
            ResetPlayerWeapons(playerid);
            new l_ammo = Weapon::player_use[playerid][Weapon::current_ammo];
            if(l_ammo < 1) {
                l_ammo = 1;
            }
            GivePlayerWeapon(playerid, 
                             Weapon::player_use[playerid][Weapon::id],
                             l_ammo);
            SetPlayerArmedWeapon(playerid, Weapon::player_use[playerid][Weapon::id]);
            if(l_wepid == 23 && Weapon::player_use[playerid][Weapon::ext] == 1) { // UsingTazer
                WeaponSystem::SetUsingTazer(playerid, true);
            }
        }
    }
}

Weapon::ResetUsingInfo(playerid) {
    Weapon::player_use[playerid][Weapon::active] = false;
    Weapon::player_use[playerid][Weapon::id] = 0;
    Weapon::player_use[playerid][Weapon::current_ammo] = 0;
    return 1;
}

Weapon::ResetWeaponSkill(playerid) {
    for(new i=0;i<11;i++) {
        SetPlayerSkillLevel(playerid, i, 0);
    }
}

Weapon::GetInfoFromItemID(itemid, weaponInfo[Weapon::Info]) {
    if(itemid == ITEM_WEAPON_TAZER) { // Tazer
        new i = 23;
        weaponInfo[Weapon::id] = Weapon::list[i][Weapon::id];
        weaponInfo[Weapon::valid] = Weapon::list[i][Weapon::valid];
        format(weaponInfo[Weapon::name], sizeof(weaponInfo[Weapon::name]), "Tazer Gun");
        weaponInfo[Weapon::slot] = Weapon::list[i][Weapon::slot];
        weaponInfo[Weapon::itemId] = Weapon::list[i][Weapon::itemId];
        weaponInfo[Weapon::model] = Weapon::list[i][Weapon::model];
        weaponInfo[Weapon::clip_size] = Weapon::list[i][Weapon::clip_size];
        weaponInfo[Weapon::ammo_type] = Weapon::list[i][Weapon::ammo_type];
        weaponInfo[Weapon::base_dmg] = Weapon::list[i][Weapon::base_dmg];
        return 1;
    }
    for(new i=0;i<sizeof(Weapon::list);i++) {
        if(Weapon::list[i][Weapon::itemId] == itemid) {
            weaponInfo[Weapon::id] = Weapon::list[i][Weapon::id];
            weaponInfo[Weapon::valid] = Weapon::list[i][Weapon::valid];
            format(weaponInfo[Weapon::name], sizeof(weaponInfo[Weapon::name]), "%s", Weapon::list[i][Weapon::name]);
            weaponInfo[Weapon::slot] = Weapon::list[i][Weapon::slot];
            weaponInfo[Weapon::itemId] = Weapon::list[i][Weapon::itemId];
            weaponInfo[Weapon::model] = Weapon::list[i][Weapon::model];
            weaponInfo[Weapon::clip_size] = Weapon::list[i][Weapon::clip_size];
            weaponInfo[Weapon::ammo_type] = Weapon::list[i][Weapon::ammo_type];
            weaponInfo[Weapon::base_dmg] = Weapon::list[i][Weapon::base_dmg];
            return 1;
        }
    }
    return 0;
}

Weapon::GetAmmoTypeItem(Weapon::AmmoType:ammo_type) {
    switch(ammo_type) {
        case AmmoType::9MM: {
            return ITEM_AMMO_9MM;
        }
        case AmmoType::556MM: {
            return ITEM_AMMO_556MM;
        }
        case AmmoType::762MM: {
            return ITEM_AMMO_762MM;
        }
        case AmmoType::45ACP: {
            return ITEM_AMMO_45ACP;
        }
        case AmmoType::SGSHELL: {
            return ITEM_AMMO_SGSHELL;
        }
        case AmmoType::BATTERY: {
            return ITEM_AMMO_BATTERY;
        }
    }
    return -1;
}

Weapon::DisarmPlayer(playerid) {
    new l_wepId = Weapon::player_use[playerid][Weapon::id];
    new l_itemData[Inv::eItem];
    l_itemData[Item::id] = Weapon::list[l_wepId][Weapon::itemId];
    if(l_wepId == 23) {
        l_itemData[Item::id] = ITEM_WEAPON_TAZER;
        WeaponSystem::SetUsingTazer(playerid, false);
    }
    l_itemData[Item::amount] = 1;
    l_itemData[Item::addon1] = Weapon::player_use[playerid][Weapon::current_ammo];
    GivePlayerItem(playerid, l_itemData);
    Weapon::player_use[playerid][Weapon::active] = false;
    Weapon::player_use[playerid][Weapon::id] = 0;
    Weapon::player_use[playerid][Weapon::current_ammo] = 0;
    Weapon::player_use[playerid][Weapon::ext] = 0;
    ResetPlayerWeapons(playerid);
    return 1;
}


#if defined DEBUG_MODE
CMD:getwep(playerid, params[]) {
    EMIT_PlayerSystemChat(playerid, -1, sprintf("WeaponID: %i", GetPlayerWeapon(playerid)));
    return 1;
}
CMD:wepdata(playerid, params[]) {
    new szDbg[1024];
    szDbg[0] = 0;
    EMIT_PlayerSystemChat(playerid, -1, "WeaponData");
    for(new i=0;i<12;i++) {
        format(szDbg,sizeof(szDbg), "%sSLOT: %i Weapon:%i, Ammo: %i\n",szDbg, i, Weapon::WeaponData[playerid][i][0], Weapon::WeaponData[playerid][i][1]);
    }
    EMIT_PlayerSystemChat(playerid, -1, szDbg);
    return 1;
}

CMD:givewep(playerid, params[]) {
    new l_wepid, l_ammo;
    if(sscanf(params, "ii", l_wepid, l_ammo)) return EMIT_PlayerSystemChat(playerid, -1, "/givewep [weaponid][ammo]");
    if(l_wepid < 1 || l_wepid > 46) return EMIT_PlayerSystemChat(playerid, -1, "Invalid WeaponID");
    GivePlayerWeapon(playerid, l_wepid, l_ammo);
    return 1;
}
#endif

CMD:disarm(playerid, params[]) {
    Weapon::DisarmPlayer(playerid);
    return 1;
}
