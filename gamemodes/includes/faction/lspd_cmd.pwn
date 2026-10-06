// LSPD Cmds

CMD:suspect(playerid, params[]) {
    if(!IsPlayerLSPD(playerid)) return 0;
    new targetid, reason[254];
    if(sscanf(params, "p<|>rs[254]", targetid, reason)) return EMIT_PlayerSystemChat(playerid, -1, "/(sus)pect (name/id)|(crime)");
    if(!IsPlayerConnected(targetid)) return EMIT_PlayerSystemChat(playerid, -1, "ERROR: Player not connected.");
   
    new l_char_target = CharacterData[targetid][p_ID];
    new l_char_issued_by = CharacterData[playerid][p_ID];
    LSPD::AddSuspect(l_char_issued_by, l_char_target, reason);
    EMIT_PlayerSystemChat(playerid, -1, sprintf("Kamu melaporkan %s sebagai tersangka (%s)", GetName(targetid), reason));
    new szStr[1024];
    format(szStr, sizeof(szStr), "LAPORAN TERSANGKA DARI OFFICER %s\nTersangka: %s\nKejahatan: %s", GetName(playerid), GetName(targetid), reason);
    LSPD::RadioBroadcast(szStr);
    return 1;
}
alias:suspect("sus")

CMD:ticket(playerid, params[]) {
    if(!IsPlayerLSPD(playerid)) return 0;
    new targetid, s_price[12], reason[254];
    if(sscanf(params, "p<|>rs[12]s[254]", targetid, s_price, reason)) return EMIT_PlayerSystemChat(playerid, -1, "/ticket (name/id)|(price)|(crime)");
    new Float:price = floatstr(s_price);
    if(!IsPlayerConnected(targetid)) return EMIT_PlayerSystemChat(playerid, -1, "ERROR: Player not connected.");
    if(!IsPlayerInRangeOfPlayer(playerid, targetid, 5.0)) {
        EMIT_PlayerSystemChat(playerid, -1, "Kamu tidak berada disekitar target");
        return 0;
    }
    new amount = floatround(price*100);
    if(amount < 1) return EMIT_PlayerSystemChat(playerid, -1, sprintf("ERROR: Invalid amount (%.2f)", price));
    EMIT_PlayerSystemChat(playerid, -1, sprintf("Memberikan tiket ke %s $%.2f alasan: %s", GetName(targetid), price, reason));
    EMIT_PlayerSystemChat(targetid, -1, sprintf("Kamu diberikan tiket oleh %s | Senilai: $%.2f (%s)", GetName(playerid), price, reason));
    EMIT_PlayerSystemChat(targetid, -1, "   Kamu dapat membayar ticket di bank / atm terdekat.");
    EMIT_PlayerSystemChat(targetid, -1, "   ** Semakin banyak jumlah tiket yang belum dibayar akan dikenakan denda progresif.");
    new issued_by = CharacterData[playerid][p_ID];
    new issued_to = CharacterData[targetid][p_ID];
    LSPD::GiveTicket(issued_by, issued_to, amount, reason);
    return 1;
}

CMD:cuff(playerid, params[]) {
    if(!IsPlayerLSPD(playerid)) return 0;
    new l_targetid;
    if(sscanf(params, "i", l_targetid)){
        EMIT_PlayerSystemChat(playerid, -1, "USAGE: /cuff [targetid]");
        EMIT_PlayerSystemChat(playerid, -1, "   - Pastikan target sedang dalam posisi tazed untuk melakukan cuff");
        return 0;
    }
    if(!IsPlayerConnected(l_targetid)) return EMIT_PlayerSystemChat(playerid, -1, "Player tidak terhubung");
    if(!IsPlayerInRangeOfPlayer(playerid, l_targetid, 5.0)) return EMIT_PlayerSystemChat(playerid, -1, "Kamu tidak berada disekitar target");

    if(!Character::Tazed(l_targetid)) return EMIT_PlayerSystemChat(playerid, -1, "Player sedang tidak dalam keadaan TAZED.");
    if(IsPlayerCuffed(l_targetid)) return EMIT_PlayerSystemChat(playerid, -1, "Player sudah terborgol");

    SetPlayerCuffed(l_targetid);
    return 1;
}

CMD:uncuff(playerid, params[]) {
    if(!IsPlayerLSPD(playerid)) return 0;
    new l_targetid;
    if(sscanf(params, "i", l_targetid)) {
        EMIT_PlayerSystemChat(playerid, -1, "USAGE: /uncuff [targetid]");
        return 0;
    }
    if(!IsPlayerConnected(l_targetid)) return EMIT_PlayerSystemChat(playerid, -1, "Player tidak terhubung");
    if(!IsPlayerInRangeOfPlayer(playerid, l_targetid, 5.0)) return EMIT_PlayerSystemChat(playerid, -1, "Kamu tidak berada disekitar target");

    if(!IsPlayerCuffed(l_targetid)) return EMIT_PlayerSystemChat(playerid, -1, "Target sedang tidak dalam keadaan terborgol");
    SetPlayerCuffed(l_targetid, false);
    EMIT_PlayerSystemChat(playerid, -1, sprintf("Kamu telah melepas borgol %s", GetName(l_targetid)));
    EMIT_PlayerSystemChat(l_targetid, -1, sprintf("Borgolmu telah dilepas oleh %s", GetName(playerid)));
    return 1;
}

CMD:putinveh(playerid, params[]) {
    if(!IsPlayerLSPD(playerid)) return 0;
    new l_targetid, l_seat_id;
    if(sscanf(params, "ui", l_targetid, l_seat_id)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /putinveh(piv) [target][seat_id]");

    if(l_seat_id < 1 || l_seat_id > 3) EMIT_PlayerSystemChat(playerid, -1, "ERROR: seat_id harus diantara 1-3");

    if(!IsPlayerConnected(l_targetid)) return EMIT_PlayerSystemChat(playerid, -1, "Invalid target, (Disconnected)");
    if(!IsPlayerCuffed(l_targetid)) return EMIT_PlayerSystemChat(playerid, -1, "Target harus diborgol terlebih dahulu.");

    new nearbyVid = GetNearbyVehicle(playerid);
    if(!IsVehicleFactionOwned(nearbyVid, Faction::LSPD)) {
        EMIT_PlayerSystemChat(playerid, -1, "Tidak ada mobil LSPD disekitarmu.");
    }

    PutPlayerInVehicle(l_targetid, nearbyVid, l_seat_id);
    return 1;
}
alias:putinveh("piv")

CMD:backup(playerid, params[]) {
    // TODO: Dispatch Backup
    return 1;
}
alias:backup("bk")

CMD:jail(playerid, params[]) {
    new target_id;
    new jail_time;
    if(!IsPlayerLSPD(playerid)) return 0;
    if(!IsPlayerInRangeOfPoint(playerid, 5.0, LSPD::JailLocation[X], LSPD::JailLocation[Y], LSPD::JailLocation[Z])) {
        EMIT_PlayerSystemChat(playerid, -1, "Kamu tidak berada tempat untuk melakukan jail");
        return 0;
    }
    if(sscanf(params, "ii", target_id, jail_time)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /jail [target_id][jail_time]");
    if(!IsPlayerConnected(target_id)) return EMIT_PlayerSystemChat(playerid, -1, "Jail Error: Invalid [target_id]");
    if(LSPD::FindSuspect(CharacterData[target_id][p_ID])) {
        JailSystem::JailPlayer(target_id, Jail::POLICE, jail_time);
        WriteJailLog(target_id, Jail::POLICE, jail_time,playerid);
    } else {
        EMIT_PlayerSystemChat(playerid, -1, "ERROR: Can't jail non suspect person.");
    }
    return 1;
}
