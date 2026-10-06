#define DBG_MARK_X 3101
#define DBG_MARK_Y 3104
#define DBG_MARK_Z 3100
#define DBG_MARK_X2 2997
#define DBG_MARK_Y2 3000
#define DBG_MARK_Z2 2996 
#define DBG_MARK_PIVOT 3106

// new ObjPivot;
// new ObjXYZ[3];
// new TargetXYZ[3];

public OnGetUserCursorClick(playerid, const arguments[]) {
    if(!isSpawned[playerid]) return 0;
    if(!GetPVarInt(playerid, "PICKER_ENABLED")) return 0;
    new Float:cursorNDC[2],Float:scrWidth,Float:scrHeight;
    new Float:cursor[2];
    sscanf(arguments, "ffffff", cursor[X], cursor[Y], cursorNDC[X],cursorNDC[Y],scrWidth,scrHeight);
    printf("DEBUG PICKER");
    printf("cursor X: %.2f", cursor[X]);
    printf("cursor Y: %.2f", cursor[Y]);
    printf("cNDC: X: %.2f", cursorNDC[X]);
    printf("cNDC: Y: %.2f", cursorNDC[Y]);
    printf("scrWidth: %.2f", scrWidth);
    printf("scrHeight: %.2f", scrHeight);
    new Float:w_Pos[3];
    cursor[X] = ((cursorNDC[X] + 1.0) / 2.0) * 640.0; // from cOnScreenX 3DTryg
    cursor[Y] = ((cursorNDC[Y] + 1.0) / 2.0) * 448.0;
    printf("cursor X: %.2f", cursor[X]);
    printf("cursor Y: %.2f", cursor[Y]);
    if(!ScreenToWorldCol(playerid, 25.0, cursor[X],cursor[Y],w_Pos[X],w_Pos[Y],w_Pos[Z])) {
        EMIT_PlayerSystemChat(playerid, -1, "PICKER: Failed");
        return 0;
    }
    printf("World Pos");
    printf("X: %f Y: %f Z: %f", w_Pos[X], w_Pos[Y], w_Pos[Z]);
    new Float:p_Pos[3];
    GetPlayerPos(playerid, p_Pos[X], p_Pos[Y], p_Pos[Z]);
    new int = GetPlayerInterior(playerid);
    new vw = GetPlayerVirtualWorld(playerid);
    new tmp_pickup = CreateDynamicPickup(
        1239, 1,
        w_Pos[X],
        w_Pos[Y],
        w_Pos[Z]+0.5,
        .worldid=vw,
        .interiorid = int
    );
    SetTimerEx("DestroyTempPickup", 3000, false, "i", tmp_pickup);
    return 1;
}

callback DestroyTempPickup(pickupid) {
    DestroyDynamicPickup(pickupid);
}

#if defined DEBUG_MODE
CMD:picker(playerid, params[]) {
    new enabled = GetPVarInt(playerid, "PICKER_ENABLED");
    SetPVarInt(playerid, "PICKER_ENABLED", !enabled);
    return 1;
}
#endif
