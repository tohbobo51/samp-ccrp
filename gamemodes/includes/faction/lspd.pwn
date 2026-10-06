SetupFactionLSPD() {
    CreateDynamicPickup(
        1318, 1,
        LSPD::locker_position[X],
        LSPD::locker_position[Y],
        LSPD::locker_position[Z]
    );
    new str[128];
    format(str,sizeof(str), "LSPD Locker\n/locker untuk mengakses loker item\n/duty untuk duty");
    CreateDynamic3DTextLabel(
        str, -1, 
        LSPD::locker_position[X],
        LSPD::locker_position[Y],
        LSPD::locker_position[Z], 10.0, .testlos=1, .interiorid=6);

    // LSPD::LockerItems = list_new();
    // mysql_tquery(MainConn,"SELECT * from `lspd_locker`", "OnLSPDLockerItemsLoaded");

    CreateDynamicPickup(
        1318,1,
        LSPD::JailLocation[X],
        LSPD::JailLocation[Y],
        LSPD::JailLocation[Z]
    );
    format(str,sizeof(str), "LSPD Jail Point\n/jail untuk melakukan jail kepada suspect.");
    CreateDynamic3DTextLabel(
        str, -1,
        LSPD::JailLocation[X],
        LSPD::JailLocation[Y],
        LSPD::JailLocation[Z],
        10.0, .testlos=1);
    return 1;
}

IsPlayerLSPD(playerid) {
    return IsPlayerInFaction(playerid, Faction::LSPD);
}

stock bool:IsLSPDVehicle(vehicleid) {
    return false;
}

LSPD::GiveTicket(issuer_id, target_id, amount, const reason[]) {
    new l_ticket[eLSPDTicket];
    l_ticket[LSPDTicket::issued_to] = target_id;
    l_ticket[LSPDTicket::issued_by] = issuer_id;
    l_ticket[LSPDTicket::amount] = amount;
    format(l_ticket[LSPDTicket::reason], 254, "%s", reason);
    printf("Ticket Reason: %s", l_ticket[LSPDTicket::reason]); 
    DB::MakeInsertQuery("char_crime_tickets", LSPDTicket::Schema, sizeof(LSPDTicket::Schema));
    printf("LSPD Ticket Insert");
    DB::PopulateInsertQuery(LSPDTicket::Schema, sizeof(LSPDTicket::Schema), l_ticket);
    mysql_tquery(MainConn, szQuery);
    return 1;
}

LSPD::AddSuspect(char_issuer_id, char_target_id, const reason[]) {
    new l_suspect[eLSPDSuspect];
    l_suspect[LSPDSuspect::character_id] = char_target_id;
    l_suspect[LSPDSuspect::issued_by] = char_issuer_id;
    format(l_suspect[LSPDSuspect::crime], 254, "%s", reason);
    DB::MakeInsertQuery("lspd_suspect", LSPDSuspect::Schema, sizeof(LSPDSuspect::Schema));
    printf("LSPD Suspect Insert");
    DB::PopulateInsertQuery(LSPDSuspect::Schema, sizeof(LSPDSuspect::Schema), l_suspect);
    mysql_tquery(MainConn, szQuery);
    return 1;
}

LSPD::FindSuspect(character_id) {
    new Task:task_find = task_new();
    mysql_format(MainConn, szQuery, sizeof(szQuery), "SELECT * FROM `lspd_suspect` WHERE character_id='%i'", character_id);
    mysql_tquery(MainConn, szQuery, "OnFindSuspectFinished", "i", _:task_find);
    await task_find;
    new result = task_get_result(task_find);
    if(result > 0) {
        return 1;
    }
    return 0;
}

LSPD::ClearSuspect(character_id) {
    mysql_format(MainConn, szQuery, sizeof(szQuery), "DELETE FROM `lspd_suspect` WHERE character_id='%i'", character_id);
    mysql_tquery(MainConn, szQuery);
    return 1;
}

callback OnFindSuspectFinished(task_find) {
    task_set_result(Task:task_find, cache_num_rows());
}

LSPD::RadioBroadcast(const msg[]) {
    foreach(new i : Player) {
        if(CharacterData[i][p_faction] == Faction::LSPD) {
            EMIT_RadioChat(i, "LSPD Broadcast", msg);
        }
    }
    return 1;
}

LSPD::Duty(playerid) {
    if(LSPD::IsOnDuty(playerid)) {
        EMIT_PlayerSystemChat(playerid, -1, "DUTY: Already on duty. /offduty to go off duty.");
        return 1;
    }
    new szList[2048];
    szList[0] = 0;
    for(new i=0;i<_:sizeof(LSPD::Uniform);i++) {
        format(szList,sizeof(szList), "%s%s\n", szList, LSPD::Uniform[eLSPDUniform:i][LSPDUniform::name]);
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
    SetPlayerSkin(playerid, LSPD::Uniform[a_listitem][LSPDUniform::skin_id]);
    LSPD::SetOnDuty(playerid, true);
    SetPlayerColor(playerid, COLOR_LSPD_BLUE);
    EMIT_PlayerSystemChat(playerid, -1, "DUTY: Kamu sekarang bertugas sebagai LSPD.");
    return 1;
}

LSPD::OffDuty(playerid) {
    if(!LSPD::IsOnDuty(playerid)) {
        return 1;
    }
    SetPlayerSkin(playerid, CharacterData[playerid][p_skinId]);
    LSPD::SetOnDuty(playerid, false);
    SetPlayerColor(playerid, COLOR_WHITE);
    EMIT_PlayerSystemChat(playerid, -1, "DUTY: Kamu mengakhiri tugas sebagai LSPD.");
    return 1;
}
