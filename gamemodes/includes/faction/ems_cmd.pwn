#include <pp-hooks>

hook OnPlayerDisconnect(playerid) {
    if(map_has_key(EMS::heal_request, playerid)) {
        map_remove(EMS::heal_request, playerid);
    }
    return 0;
}

CMD:revive(playerid, params[]) {
    if(!IsPlayerEMS(playerid)) return 0;
    new targetid;
    if(sscanf(params, "u", targetid)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /revive [target]");
    if(!IsPlayerConnected(targetid) && IsPlayerNPC(targetid)) return EMIT_PlayerSystemChat(playerid, -1, "CMD(revive): Invalid target.");
    if(!CharacterData[targetid][p_injured]) return EMIT_PlayerSystemChat(playerid, -1, "ERROR: Target is not injured.");
    
    Character::Revive(targetid);
    return 1;
}

CMD:heal(playerid, params[]) {
    if(!IsPlayerEMS(playerid)) return 0;
    new targetid;
    new Float:price;
    
    if(sscanf(params, "uf", targetid, price)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /heal [target][price]");
    if(!IsPlayerConnected(targetid) && IsPlayerNPC(targetid)) return EMIT_PlayerSystemChat(playerid, -1, "Invalid Target");
    if(price < 0.0) return EMIT_PlayerSystemChat(playerid, -1, "Invalid price, harus lebih besar dari 0.0");
    new Float:tPos[3];
    GetPlayerPos(targetid, VEC3_UNWRAP(tPos));
    
    if(!IsPlayerInRangeOfPoint(playerid, 4.0, VEC3_UNWRAP(tPos))) return EMIT_PlayerSystemChat(playerid, -1, "ERROR: Kamu tidak berada disekitar target");
    new l_heal_request[eHealRequest];
    l_heal_request[EMSHealRequest::issuer_id] = playerid;
    l_heal_request[EMSHealRequest::price] = ToCents(price);
    map_set_arr(EMS::heal_request, targetid, l_heal_request);
    EMIT_PlayerSystemChat(targetid, -1, sprintf("HEAL: %s menawarkan jasa heal dengan tarif $%.2f", price));
    EMIT_PlayerSystemChat(targetid, -1, "ketik '/accept heal' untuk menerima tawaran ini");
    EMIT_PlayerSystemChat(playerid, -1, "HEAL: Penawaran jasa heal dikirim");
    return 1;
}
