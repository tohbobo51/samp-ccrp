SetupFactionGOV() {
    CreateDynamicPickup(
        1239, 1,
        GOV::InfoCheckpoint[X],
        GOV::InfoCheckpoint[Y],
        GOV::InfoCheckpoint[Z],
        .worldid=0,
        .interiorid = 3
    );
    new str[128];
    format(str,sizeof(str), "INFORMASI\n/info untuk mengakses informasi");
    CreateDynamic3DTextLabel(
        str, -1, 
        GOV::InfoCheckpoint[X],
        GOV::InfoCheckpoint[Y],
        GOV::InfoCheckpoint[Z], 10.0, .testlos=1, .interiorid=3);
    return 1;
}

stock bool:IsPlayerGOV(playerid) {
    return IsPlayerInFaction(playerid, Faction::GOV);
}

CMD:info(playerid, params[]) {
    if(IsPlayerInRangeOfPointVec(playerid, 1.5, GOV::InfoCheckpoint)) {
        UnfocusCEF(playerid);
        
        static info_menu[] = "Buat KTP\n";
        await Dialog::ShowAsyncDialog(playerid, Dialog::LIST, "Menu Informasi", info_menu, "Pilih", "Batal");
        new a_res = Dialog::Response[playerid][DialogResponse::response];
        new a_listitem = Dialog::Response[playerid][DialogResponse::listitem];
        if(!a_res) {
            return false;
        }
        switch(a_listitem) {
            case 0: {
                if(CharacterData[playerid][p_has_id]) {
                    EMIT_PlayerSystemChat(playerid, -1, "KTP: Kamu sudah memiliki KTP");
                    return 0;
                }
                CharacterData[playerid][p_has_id] = true;
                EMIT_PlayerSystemChat(playerid, -1, "KTP: Pembuatan KTP berhasil. Kamu dapat menunjukan identitasmu sekarang.");
                return 1;
            }
        }
    }
    return 1;
}
