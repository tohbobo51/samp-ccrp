public OnPlayerRequestClass(playerid, classid)
{
    // SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
    // SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
    // SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
    SpawnPlayer(playerid);
    return 1;
}

public OnPlayerConnect(playerid)
{
    OnlinePlayers++;
    PlayerRemoveMap(playerid);
    if (SvGetVersion(playerid) == 0) // Checking for plugin availability
    {
        SendClientMessage(playerid, -1, "Failed to find plugin.");
    }
    else if (SvHasMicro(playerid) == SV_FALSE) // Checking for microphone availability
    {
        SendClientMessage(playerid, -1, "Failed to find microphone.");
    }
    else
    {
        if (gstream != SV_NONE)
        {
            // SvSetKey(playerid, 0x5A, GLOBAL_CHANNEL); // Z key
            SvAttachStream(playerid, gstream, GLOBAL_CHANNEL);
            SvAttachListener(gstream, playerid);
            SvSetIcon(gstream, "speaker");

            // SendClientMessage(playerid, -1, "Press Z to talk to global chat.");
        }
        if ((lstream[playerid] = SvCreateStream(40.0)) != SV_NONE)
        {
            SvSetKey(playerid, 0x42, LOCAL_CHANNEL); // B key
            SvAttachStream(playerid, lstream[playerid], LOCAL_CHANNEL);
            SvSetTarget(lstream[playerid], SvMakePlayer(playerid));
            SvSetIcon(lstream[playerid], "speaker");
            // SendClientMessage(playerid, -1, "Press B to talk to local chat.");
        }
    }
    // ====
    printf("[MAIN] OnPlayerConnect");
    if(!canAcceptConnection) {
        SendClientMessage(playerid,  -1, "[SERVER]: Sedang mempersiapkan server. Silahkan coba beberapa saat lagi.");
        wait_ticks(1);
        Kick(playerid); 
    }
    PlayerAction::Reset(playerid);
    DynObjEditResponse::Clear(playerid);
    

    RemoveDefaultVendingMachines(playerid);

#if defined Main_OnPlayerConnect
    return Main_OnPlayerConnect(playerid);
#else
    return 1;
#endif
}

#if defined _ALS_OnPlayerConnect
#undef OnPlayerConnect
#else
#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect Main_OnPlayerConnect
#if defined Main_OnPlayerConnect
forward Main_OnPlayerConnect(playerid);
#endif


public OnPlayerDisconnect(playerid, reason)
{
    OnlinePlayers--;
    // Removing the player's local stream after disconnecting
    if (lstream[playerid] != SV_NONE)
    {
        SvDeleteStream(lstream[playerid]);
        lstream[playerid] = SV_NONE;
    }
    
    if(auth_q_processing && auth_q_curr_playerid == playerid) {
        list_remove(auth_queue, auth_q_index);
        auth_q_processing = false;
        auth_q_curr_playerid = INVALID_PLAYER_ID;
        auth_q_index = -1;
        auth_q_err_c = 0;
    }
#if defined Main_OnPlayerDisconnect
    return Main_OnPlayerDisconnect(playerid,reason);
#else
    return 1;
#endif
}

#if defined _ALS_OnPlayerDisconnect
#undef OnPlayerDisconnect
#else
#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect Main_OnPlayerDisconnect
#if defined Main_OnPlayerDisconnect
forward Main_OnPlayerDisconnect(playerid,reason);
#endif


public OnPlayerSpawn(playerid)
{
    if(!isSpawned[playerid]) {
        SetPlayerVirtualWorld(playerid, MAX_PLAYERS+playerid);
        TogglePlayerControllable(playerid, false);
        SetPlayerSkin(playerid, 123);
        SetPlayerCameraPos(playerid, 1093.000, -2036.0000, 90.000);
        SetPlayerCameraLookAt(playerid, -0.825859, 0.557950, -0.081537);
        wait_ms(500);
        for (new i; i < sizeof(AnimationLibraries); i++) ApplyAnimation(playerid, AnimationLibraries[i], "null", 0.0, 0, 0, 0, 0, 0);
        return 1;
    }
    if(CharacterData[playerid][p_injured]) {
        printf("Injured spawn");
        SetPlayerSkin(playerid, CharacterData[playerid][p_skinId]);
        SetPlayerPos(playerid,
            CharacterData[playerid][p_posX],
            CharacterData[playerid][p_posY],
            CharacterData[playerid][p_posZ]
        );
        Character::applyDeath(playerid);
    } 
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    // TODO: Write death log
    CharacterData[playerid][p_injured] = true;
    CharacterData[playerid][p_injured_time] = INJURED_TIME;
    GetPlayerPos(playerid,
                 CharacterData[playerid][p_posX],
                 CharacterData[playerid][p_posY],
                 CharacterData[playerid][p_posZ]);
    SetPlayerHealth(playerid, 9999.0);
    SpawnPlayer(playerid);
    return 1;
}

public OnVehicleSpawn(vehicleid)
{
    return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
    return 1;
}

public OnPlayerText(playerid, text[])
{
    return 0;
    // if(isSpawned[playerid]) {
    //   new message[256];
    //   format(message, sizeof(message), "%s says: %s", GetName(playerid), text);
    //   SendProximityMessage(PLAYER_TEXT_CHAT_RADIUS, playerid, message, -1);
    //   SetPlayerChatBubble(playerid, message, -1,PLAYER_TEXT_CHAT_RADIUS, 5000);
    // }
    // return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    // if (strcmp("/mycommand", cmdtext, true, 10) == 0)
    // {
    // 	// Do something here
    // 	return 1;
    // }
    return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    
#if defined Main_OnPlayerEnterVehicle
    return Main_OnPlayerEnterVehicle(playerid, vehicleid, ispassenger);
#else 
    return 1;
#endif
}
#if defined _ALS_OnPlayerEnterVehicle
#undef OnPlayerEnterVehicle
#else 
#define _ALS_OnPlayerEnterVehicle
#endif
#define OnPlayerEnterVehicle Main_OnPlayerEnterVehicle
#if defined Main_OnPlayerEnterVehicle
forward Main_OnPlayerEnterVehicle(playerid, vehicleid, ispassenger);
#endif


public OnPlayerExitVehicle(playerid, vehicleid)
{
#if defined Main_OnPlayerExitVehicle
    return Main_OnPlayerExitVehicle(playerid,vehicleid);
#else
    return 1;
#endif
}

#if defined _ALS_OnPlayerExitVehicle
#undef OnPlayerExitVehicle
#else
#define _ALS_OnPlayerExitVehicle
#endif
#define OnPlayerExitVehicle Main_OnPlayerExitVehicle
#if defined Main_OnPlayerExitVehicle
forward Main_OnPlayerExitVehicle(playerid,vehicleid);
#endif


public OnPlayerStateChange(playerid, newstate, oldstate)
{
#if defined Main_OnPlayerStateChange 
    return Main_OnPlayerStateChange(playerid, newstate, oldstate);
#else 
    return 1;
#endif
}
#if defined _ALS_OnPlayerStateChange 
#undef OnPlayerStateChange
#else 
#define _ALS_OnPlayerStateChange 
#endif
#define OnPlayerStateChange Main_OnPlayerStateChange
#if defined Main_OnPlayerStateChange
forward Main_OnPlayerStateChange(playerid, newstate, oldstate);
#endif


public OnPlayerEnterCheckpoint(playerid)
{
    return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
    return 1;
}


public OnPlayerEnterRaceCheckpoint(playerid) {
#if defined Main_OPEnterRaceCheckpoint
    return Main_OPEnterRaceCheckpoint(playerid);
#else 
    return 1;
#endif
}
#if defined _ALS_OPEnterRaceCheckpoint
#undef OnPlayerEnterRaceCheckpoint
#else 
#define _ALS_OPEnterRaceCheckpoint
#endif
#define OnPlayerEnterRaceCheckpoint Main_OPEnterRaceCheckpoint
#if defined Main_OPEnterRaceCheckpoint
forward Main_OPEnterRaceCheckpoint(playerid);
#endif

public OnPlayerLeaveRaceCheckpoint(playerid)
{
    return 1;
}

public OnRconCommand(cmd[])
{
    return 1;
}

public OnPlayerRequestSpawn(playerid)
{
    return 1;
}

public OnObjectMoved(objectid)
{
    return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
    return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
    return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
    return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
    return 1;
}

public OnPlayerExitedMenu(playerid)
{
    return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{

#if defined Main_OnPlayerKeyStateChange
    return Main_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#else
    return 1;
#endif
}
#if defined _ALS_OnPlayerKeyStateChange
#undef OnPlayerKeyStateChange
#else
#define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange Main_OnPlayerKeyStateChange 
#if defined Main_OnPlayerKeyStateChange
forward Main_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

public OnRconLoginAttempt(ip[], password[], success)
{
    return 1;
}

public OnPlayerUpdate(playerid)
{
#if defined Main_OnPlayerUpdate
    return Main_OnPlayerUpdate(playerid);
#else
    return 1;
#endif
}

#if defined _ALS_OnPlayerUpdate
#undef OnPlayerUpdate
#else
#define _ALS_OnPlayerUpdate
#endif
#define OnPlayerUpdate Main_OnPlayerUpdate 
#if defined Main_OnPlayerUpdate
forward Main_OnPlayerUpdate(playerid);
#endif

public OnPlayerStreamIn(playerid, forplayerid)
{
    return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
    return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
    return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
    return 1;
}


public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
    return 1;
}

public OnPlayerSelectDynamicObject(playerid, objectid, modelid, Float:x, Float:y, Float:z) {
    printf("SELECT OBJECT ID: %d\n", objectid);
    printf("MODEL IDL %d\n",modelid);
    printf("%f, %f, %f\n", x, y, z);
    return 1; 
}



public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
#if defined Main_OnDialogResponse
    return Main_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#else
    return 1;
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse Main_OnDialogResponse
#if defined Main_OnDialogResponse
forward Main_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

#if defined DEBUG_MODE
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ) {
    new Float:nZ;
    CA_FindZ_For2DCoord(fX, fY, nZ);
    if(AdminSystem::MapTP(playerid)) {
        CA_FindZ_For2DCoord(fX, fY, nZ);
        if(IsPlayerInAnyVehicle(playerid)) {
            new l_vid = GetPlayerVehicleID(playerid);
            SetVehiclePos(l_vid, fX,fY,nZ+1.0);
            return 1;
        } 
        SetPlayerPos(playerid, fX, fY, nZ+1.0);    
    }
    // SetPlayerWaze(playerid, fY, fY, nZ);
    return 1;
}
#endif
