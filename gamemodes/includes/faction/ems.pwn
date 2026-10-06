// AddPlayerClass(23,1154.9333,-1305.6702,17.9123,71.9415,0,0,0,0,0,0); // ems faction pickup
// AddPlayerClass(23,1160.8408,-1309.3265,14.4256,95.7146,0,0,0,0,0,0); // asgh int coord
// AddPlayerClass(23,1173.5848,-1323.4875,15.1953,270.4112,0,0,0,0,0,0); // asgh outside coord

SetupFactionEMS() {
    EMS::heal_request = map_new();

    CreateDynamicPickup(
        1318, 1,
        EMS::locker_position[X],
        EMS::locker_position[Y],
        EMS::locker_position[Z]
    );
    new str[128];
    format(str,sizeof(str), "EMS Locker\n/locker untuk mengakses loker item\n/duty untuk duty");
    CreateDynamic3DTextLabel(
        str, -1, 
        EMS::locker_position[X],
        EMS::locker_position[Y],
        EMS::locker_position[Z], 10.0, .testlos=1, .interiorid=0);
}

IsPlayerEMS(playerid) {
    return IsPlayerInFaction(playerid, Faction::EMS);
}

EMS::AcceptHeal(playerid) {
    if(!map_has_key(EMS::heal_request, playerid)) EMIT_PlayerSystemChat(playerid, -1, "HEAL: Kamu tidak memiliki penawaran pengobatan dari EMS");
    new l_heal_req[eHealRequest];
    map_get_arr(EMS::heal_request, playerid, l_heal_req);
    if(CharacterData[playerid][p_cash] < l_heal_req[EMSHealRequest::price]) return EMIT_PlayerSystemChat(playerid, -1, "HEAL: Kamu tidak memiliki cukup uang.");
    
    if(!IsPlayerConnected(l_heal_req[EMSHealRequest::issuer_id])) return EMIT_PlayerSystemChat(playerid, -1, "HEAL: Penawaran kadaluarsa.");
    new Float:tPos[3];
    GetPlayerPos(l_heal_req[EMSHealRequest::issuer_id], VEC3_UNWRAP(tPos));
    if(!IsPlayerInRangeOfPoint(playerid, 5.0, VEC3_UNWRAP(tPos))) return EMIT_PlayerSystemChat(playerid, -1, "HEAL: Terlalu jauh dari pemberi.");
    Character::SetHealth(playerid, 100.0);
    Character::TakeCash(playerid, l_heal_req[EMSHealRequest::price]);
    Character::GiveCash(l_heal_req[EMSHealRequest::issuer_id], l_heal_req[EMSHealRequest::price]);
    EMIT_PlayerSystemChat(playerid, -1, 
                          sprintf("HEAL: Kamu menerima pengobatan dengan biaya $%.2f dari %s", 
                                  FromCents(l_heal_req[EMSHealRequest::price]), 
                                  GetName(l_heal_req[EMSHealRequest::issuer_id])
                                  ));
    EMIT_PlayerSystemChat(l_heal_req[EMSHealRequest::issuer_id], -1, 
                          sprintf("HEAL: Kamu mendapatkan pembayaran dari jasa heal sebesar $%.2f", FromCents(l_heal_req[EMSHealRequest::price])));
    return 1;
}

EMS::Duty(playerid) {
    new szList[2048];
    szList[0] = 0;
    for(new i=0;i<sizeof(EMS::Uniform);i++) {
        format(szList,sizeof(szList), "%s%s\n", szList, EMS::Uniform[i][EMSUniform::name]);
    }
    new Task:ret = Dialog::ShowAsyncDialog(playerid, Dialog::LIST, "Pilih Seragam", szList, "Pilih", "Batal");
    await task_ms(100);
    if(isPlayerUIInteractable[playerid]) {
        HideCEFUI(playerid); 
    }
    await ret;
    new a_res = Dialog::Response[playerid][DialogResponse::response];
    new a_listitem = Dialog::Response[playerid][DialogResponse::listitem];
    if(!a_res) {
        return 0;
    }
    SetPlayerSkin(playerid, EMS::Uniform[a_listitem][EMSUniform::skin_id]);
    EMS::SetOnDuty(playerid, true);
    SetPlayerColor(playerid, COLOR_LSPD_BLUE);
    EMIT_PlayerSystemChat(playerid, -1, "DUTY: Kamu sekarang bertugas sebagai Paramedic.");
    return 1;
}

EMS::OffDuty(playerid) {
    if(!EMS::IsOnDuty(playerid)) {
        return 1;
    }
    SetPlayerSkin(playerid, CharacterData[playerid][p_skinId]);
    EMS::SetOnDuty(playerid, false);
    SetPlayerColor(playerid, COLOR_WHITE);
    EMIT_PlayerSystemChat(playerid, -1, "DUTY: Kamu mengakhiri tugas sebagai Paramedic.");
    return 1;
}
