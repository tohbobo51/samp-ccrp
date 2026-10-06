

// Function to generate a random string
stock GenerateRandomString(length, output[], maxLength = sizeof(output)) {
    new charset[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    new charsetLength = strlen(charset);

    new randomString[256]; // Constant size for the randomString array
    for (new i = 0; i < length && i < sizeof(randomString) - 1; i++) {
        new randomIndex = random(charsetLength);
        randomString[i] = charset[randomIndex];
    }
    randomString[length] = '\0'; // Null-terminate the string

    strcat(output, randomString, maxLength);
}


stock charreplace(string[], find, replace)
{
    for(new i=0; string[i]; i++)
    {
        if(string[i] == find)
        {
            string[i] = replace;
        }
    }
}

stock GetName(playerid) {
    new name[24];
    GetPlayerName(playerid, name, 24);
    charreplace(name, '_', ' ');
    return name;
}

stock SendProximityMessage(Float:radi, playerid,const type[], const string[],color)
{
    new Float:l_posX,Float:l_posY,Float:l_posZ;
    GetPlayerPos(playerid,l_posX,l_posY,l_posZ);
    
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i,radi,l_posX,l_posY,l_posZ)) 
        {
            new Float:l_dist = GetPlayerDistanceFromPoint(i,l_posX,l_posY,l_posZ);
            new Float:adjust = floatabs((l_dist/radi) - 1);
            new adjustedColor = RGB::AdjustColorLuminance(color,adjust);
            if(i != playerid){
                // SendClientMessage(i,adjustedColor,string);
                EMIT_PlayerChat(i, playerid, adjustedColor,type, string);
            } else {
                // SendClientMessage(i,color,string);
                EMIT_PlayerChat(i, playerid, color,type, string);
            }
        }
    }
}

stock SendProximityAction(Float:radi, playerid,const type[], const cat[], const string[],color)
{
    new Float:l_posX,Float:l_posY,Float:l_posZ;
    GetPlayerPos(playerid,l_posX,l_posY,l_posZ);
    
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i,radi,l_posX,l_posY,l_posZ)) 
        {
            new Float:l_dist = GetPlayerDistanceFromPoint(i,l_posX,l_posY,l_posZ);
            new Float:adjust = floatabs((l_dist/radi) - 1);
            new adjustedColor = RGB::AdjustColorLuminance(color,adjust);
            if(i != playerid){
                // SendClientMessage(i,adjustedColor,string);
                EMIT_PlayerChatCat(i, playerid, adjustedColor,type,cat, string);
            } else {
                // SendClientMessage(i,color,string);
                EMIT_PlayerChatCat(i, playerid, color,type,cat, string);
            }
        }
    }
}


stock Float:DegreesToRad(Float:p_degrees) {
    return p_degrees * (PI / 180.0);
}

stock GetXYInFrontOfPoint(&Float:x,&Float:y,Float:angle, Float:distance) {
    x += (distance*floatsin(-angle, degrees));
    y += (distance*floatcos(-angle,degrees));
}

stock GetXYRightOfPoint(&Float:x, &Float:y, Float:angle, Float:distance) {
    // Add 90 degrees to get the right direction
    x += (distance*floatsin(-(angle + 90.0), degrees));
    y += (distance*floatcos(-(angle + 90.0), degrees));
}

stock Float:SetPlayerFacingAngleToPoint(playerid, Float:tX, Float:tY) {
  new Float:Px, Float:Py, Float: Pa;
  GetPlayerPos(playerid, Px, Py, Pa);
  
  Pa = floatabs(atan((tY-Py)/(tX-Px)));
  if (tX <= Px && tY >= Py) Pa = floatsub(180, Pa);
  else if (tX < Px && tY < Py) Pa = floatadd(Pa, 180);
  else if (tX >= Px && tY <= Py) Pa = floatsub(360.0, Pa);
  Pa = floatsub(Pa, 90.0);
  if (Pa >= 360.0) Pa = floatsub(Pa, 360.0);
  return Pa;
}

stock bool:IsPointInRangeOfPoint2D(Float:range, Float:x1, Float:y1, Float:x2, Float:y2)
{
	return VectorSize(x1 - x2, y1 - y2, 0.0) <= range;
}

stock Float:GetPlayerFOV(playerid) {
    return GetPlayerCameraZoom(playerid) * 0.667;
}


// stock map_serialize(Map:map, str[],len=sizeof(str)) {
//   if(!map_valid(map)) return -1;
//   new l_mapsize = map_size(map);
//   for_map(i : map) {
//     new l_key[32],l_value_str[32];
//     new Float:l_value_f,l_value;
//     iter_key_key_str(i, l_key);
//      
//   }
//   return 1;
// }
//
// stock map_deserialize(Map:map, const str[]) {
//   return 1;
// }

/*
stock SendClientMessageEx(playerid, color, const message[], { _ , AmxString , Bit , bool , File , Float , Group , String , Text , Text3D }:...)
{
    static args, str[256],

    if ((args = numargs()) == 2)
    {
        SendClientMessage(playerid, color, message);

        // Make cimpiler happy
        return 0x0;
    }

    while (--args >= 2)
    {
        #emit LCTRL 5
        #emit LOAD.alt args
        #emit SHL.C.alt 2
        #emit ADD.c 12
        #emit ADD
        #emit LOAD.I
        #emit PUSH.pri
    }

    #emit PUSH.S message
    #emit PUSH.C 144
    #emit PUSH.C str
    #emit LOAD.s.pri 8
    #emit ADD.C 4
    #emit PUSH.pri
    #emit SYSREQ.C format
    #emit LCTRL 5
    #emit SCTRL 4

    SendClientMessage(playerid, color, str);

    #emit RETN

    // Make cimpiler happy
    return 0x1;
}
*/

stock IntToHex(int)
{
    new
        str[15];
    format(str, sizeof(str), "%x", int);
    return str;
}

stock HexToInt(const hex[])
{
    new
        str[15];
    format(str, sizeof(str), "%i", hex);
    return strval(str);
}

stock ClearChat(playerid) {
  for(new i=0;i<60;i++) {
    SendClientMessage(playerid, -1, " ");
  }
  return 1;
}

stock IsVehicleEmpty(vehicleid)
{
    for(new i=0; i<MAX_PLAYERS; i++)
    {
            if(IsPlayerInVehicle(i, vehicleid)) return 0;
    }
    return 1;
}

stock bool:IsPlayerInRangeOfPlayer(playerid, targetid, Float:range, bool:ignoreVW = false, bool:ignoreInterior = false)
{
	new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2;

	return GetPlayerPos(playerid, x1, y1, z1)
		&& GetPlayerPos(targetid, x2, y2, z2)
		&& VectorSize(x1 - x2, y1 - y2, z1 - z2) <= range
		&& (ignoreVW || GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(targetid))
		&& (ignoreInterior || GetPlayerInterior(playerid) == GetPlayerInterior(targetid))
	;
}

stock bool:IsPlayerInRangeOfVehicle(playerid, vehicleid, Float:range) {
    if(!IsValidVehicle(vehicleid)) return 0;
    new l_vPos[3];
    GetVehiclePos(vehicleid, l_vPos[X], l_vPos[Y], l_vPos[Z]);
    if(IsPlayerInRangeOfPoint(playerid, range, l_vPos[X], l_vPos[Y], l_vPos[Z])) {
        return 1;
    }
    return 0;
}

stock IsPlayerInRangeOfPointVec(playerid, Float:range, const Float:p_point[3]) {
    return IsPlayerInRangeOfPoint(playerid, range,p_point[X], p_point[Y], p_point[Z]);
}

stock GetNearbyVehicle(playerid, Float:max_radius=5.0) {
    new Float:l_pPos[3], Float:l_vPos[3];
    new nearVid = INVALID_VEHICLE_ID;
    new Float:dist = max_radius;
    GetPlayerPos(playerid, l_pPos[X], l_pPos[Y], l_pPos[Z]);
    foreach(new vid : Vehicle) {
        GetVehiclePos(vid, l_vPos[X], l_vPos[Y], l_vPos[Z]);
        new Float:norm = GetDistance(l_pPos, l_vPos);
        if(norm < dist) {
            dist = norm;
            nearVid = vid;
        }
    }
    return nearVid;
}
stock Float:GetDistance(const Float:p_pos1[3], const Float:p_pos2[3]) {
    return VectorSize(
        p_pos1[X] - p_pos2[X],
        p_pos1[Y] - p_pos2[Y],
        p_pos1[Z] - p_pos2[Z]
    );
}

stock SelectWeightedRandom(const probabilities[][], size) {
    new total = 0;
    
    // Calculate total probability
    for (new i = 0; i < size; i++) {
        total += probabilities[i][1];
    }
    
    // Generate random number
    new rand_num = random(total);
    new cumulative_prob = 0;
    
    // Select item based on weighted probability
    for (new i = 0; i < size; i++) {
        cumulative_prob += probabilities[i][1];
        if (rand_num < cumulative_prob) {
            return probabilities[i][0];
        }
    }
    
    // Fallback (should rarely happen)
    return probabilities[size-1][0];
}

RemoveDefaultVendingMachines(playerid) {
    RemoveBuildingForPlayer(playerid, 955, 0.0, 0.0, 0.0, 20000.0); // CJ_EXT_SPRUNK
    RemoveBuildingForPlayer(playerid, 956, 0.0, 0.0, 0.0, 20000.0); // CJ_EXT_CANDY
    RemoveBuildingForPlayer(playerid, 1209, 0.0, 0.0, 0.0, 20000.0); // vendmach
    RemoveBuildingForPlayer(playerid, 1302, 0.0, 0.0, 0.0, 20000.0); // vendmachfd
    RemoveBuildingForPlayer(playerid, 1775, 0.0, 0.0, 0.0, 20000.0); // CJ_SPRUNK1
    RemoveBuildingForPlayer(playerid, 1776, 0.0, 0.0, 0.0, 20000.0); // CJ_CANDYVENDOR
    RemoveBuildingForPlayer(playerid, 1977, 0.0, 0.0, 0.0, 20000.0); // vendin3

    // Make sure they're all gone..
    for (new i = 0; i < sizeof(VendingMachines); i++) {
        RemoveBuildingForPlayer(
            playerid,
            VendingMachines[i][e_Model],
            VendingMachines[i][e_PosX],
            VendingMachines[i][e_PosY],
            VendingMachines[i][e_PosZ],
            1.0
        );
    }
}

ToCents(Float:amount) {
    return floatround(amount * 100, floatround_floor);
}

Float:FromCents(amount) {
    return float(amount) / 100.0;
}

GetTS() {
    new
	hours,
	minutes,
	seconds;
    return gettime(hours, minutes, seconds);
}
