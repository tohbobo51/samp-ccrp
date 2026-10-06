#include <pp-hooks>
hook OnPlayerEnterDynArea(playerid, areaid) {
    if(Streamer_HasIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_INTERIOR_ID))) {
        Interior::SetID(playerid, Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_INTERIOR_ID))+1);
    }
}

hook OnPlayerLeaveDynArea(playerid, areaid) {
    if(Interior::GetID(playerid) != 0) {
        Interior::SetID(playerid, 0);
    }
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(PRESSED(KEY_SECONDARY_ATTACK)) { 
        if(Interior::GetID(playerid) != 0) {
            if(IsPlayerInAnyVehicle(playerid)) return 1;
            new portalData[Portal::e_Portal];
            list_get_arr(Portal::list_portal, Interior::GetID(playerid)-1, portalData);
            TogglePlayerControllable(playerid, false);
            SetPlayerPos(playerid, 
                        portalData[Portal::target_pos][X],
                        portalData[Portal::target_pos][Y],
                        portalData[Portal::target_pos][Z]);
            SetPlayerFacingAngle(playerid, portalData[Portal::target_facing_angle]);
            SetPlayerInterior(playerid, portalData[Portal::target_int]);
            SetPlayerVirtualWorld(playerid, portalData[Portal::target_vw]);
            SetCameraBehindPlayer(playerid);
            wait_ms(3000);
            TogglePlayerControllable(playerid, true);
            return 1;
        }
    }
    return 0;
}

InitializeInteriorData() {
    Portal::list_portal = list_new();
    new portalData[Portal::e_Portal];
    new portalIndex;
   
    // FleecaBank Besar
    Interior::data[Interior::FleecaBank][InteriorData::portals] = map_new();
    format(portalData[Portal::name], 64, "Masuk FLEECA Bank");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 1456.9420; 
    portalData[Portal::pos][Y] = -1012.2831;
    portalData[Portal::pos][Z] = 26.8438;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 0;
    portalData[Portal::target_pos][X] = 1402.2257;
    portalData[Portal::target_pos][Y] = -1680.2448;
    portalData[Portal::target_pos][Z] = 940.0469;
    portalData[Portal::target_facing_angle] = 352.9665;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 0;
    portalData[Portal::pickupModel] = 1318;

    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::FleecaBank][InteriorData::portals], "enter", portalIndex);

    format(portalData[Portal::name], 64, "Keluar");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 1402.2257;
    portalData[Portal::pos][Y] = -1680.2448;
    portalData[Portal::pos][Z] = 940.0469;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 0;
    portalData[Portal::target_pos][X] = 1467.3029;
    portalData[Portal::target_pos][Y] = -1011.6784;
    portalData[Portal::target_pos][Z] = 26.8438;
    portalData[Portal::target_facing_angle] = 176.6793;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 0;
    portalData[Portal::pickupModel] = 1318;

    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::FleecaBank][InteriorData::portals], "exit", portalIndex);
    //END FLEECABank Besar

   // SANEWS 
    Interior::data[Interior::SANews][InteriorData::portals] = map_new();
    format(portalData[Portal::name], 64, "Masuk SA News");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 648.3444;
    portalData[Portal::pos][Y] = -1357.1669;
    portalData[Portal::pos][Z] = 13.6192;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 0;
    portalData[Portal::target_pos][X] = 1567.5670;
    portalData[Portal::target_pos][Y] = 1459.8499;
    portalData[Portal::target_pos][Z] = 911.3286;
    portalData[Portal::target_facing_angle] = 180.1753;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 0;
    portalData[Portal::pickupModel] = 1318;
    
    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::SANews][InteriorData::portals], "enter", portalIndex);

    format(portalData[Portal::name], 64, "Keluar");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 1567.5670;
    portalData[Portal::pos][Y] = 1459.8499;
    portalData[Portal::pos][Z] = 911.3286;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 0;
    portalData[Portal::target_pos][X] = 648.3444;
    portalData[Portal::target_pos][Y] = -1357.1669;
    portalData[Portal::target_pos][Z] = 13.6192;
    portalData[Portal::target_facing_angle] = 180.1753;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 0;
    portalData[Portal::pickupModel] = 1318;
    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::SANews][InteriorData::portals], "exit", portalIndex);

    format(portalData[Portal::name], 64, "Ke Lt. 2");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 1563.1841;
    portalData[Portal::pos][Y] = 1436.4320;
    portalData[Portal::pos][Z] = 911.3286;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 0;
    portalData[Portal::target_pos][X] = 2129.0813;
    portalData[Portal::target_pos][Y] = 2511.9934;
    portalData[Portal::target_pos][Z] = 1024.9802;
    portalData[Portal::target_facing_angle] = 91.7686;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 0;
    portalData[Portal::pickupModel] = 1318;
    
    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::SANews][InteriorData::portals], "to_2nd", portalIndex);

    format(portalData[Portal::name], 64, "Ke Lt. 1");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 2128.4519;
    portalData[Portal::pos][Y] = 2507.1997;
    portalData[Portal::pos][Z] = 1024.9802;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 0;
    portalData[Portal::target_pos][X] = 1563.2937;
    portalData[Portal::target_pos][Y] = 1432.8230;
    portalData[Portal::target_pos][Z] = 911.3286;
    portalData[Portal::target_facing_angle] = 92.3500;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 0;
    portalData[Portal::pickupModel] = 1318;
    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::SANews][InteriorData::portals], "to_1st", portalIndex);

    //END SANEWS

    // LSPD
    Interior::data[Interior::LSPD][InteriorData::portals] = map_new();
    format(portalData[Portal::name], 64, "Masuk LSPD");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 1554.3728;
    portalData[Portal::pos][Y] = -1675.5770;
    portalData[Portal::pos][Z] = 16.1953;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 0;
    portalData[Portal::target_pos][X] = 246.7839;
    portalData[Portal::target_pos][Y] = 63.9001;
    portalData[Portal::target_pos][Z] = 1003.6406;
    portalData[Portal::target_facing_angle] = 92.3500;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 6;
    portalData[Portal::pickupModel] = 1318;
    
    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::LSPD][InteriorData::portals], "in_lspd_frnt", portalIndex);

    format(portalData[Portal::name], 64, "Keluar");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 246.7839;
    portalData[Portal::pos][Y] = 63.9001;
    portalData[Portal::pos][Z] = 1003.6406;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 6;
    portalData[Portal::target_pos][X] = 1554.3728;
    portalData[Portal::target_pos][Y] = -1675.5770;
    portalData[Portal::target_pos][Z] = 16.1953;
    portalData[Portal::target_facing_angle] = 92.3500;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 0;
    portalData[Portal::pickupModel] = 1318;
    
    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::LSPD][InteriorData::portals], "out_lspd_frnt", portalIndex);

    format(portalData[Portal::name], 64, "Masuk LSPD");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 1568.6758;
    portalData[Portal::pos][Y] = -1691.3551;
    portalData[Portal::pos][Z] = 5.8906;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 0;
    portalData[Portal::target_pos][X] = 246.5631;
    portalData[Portal::target_pos][Y] = 87.5663;
    portalData[Portal::target_pos][Z] = 1003.6406;
    portalData[Portal::target_facing_angle] = 178.7800;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 6;
    portalData[Portal::pickupModel] = 1318;
    
    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::LSPD][InteriorData::portals], "in_lspd_park", portalIndex);

    format(portalData[Portal::name], 64, "Keluar LSPD (Parkiran)");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 246.5631;
    portalData[Portal::pos][Y] = 87.5663;
    portalData[Portal::pos][Z] = 1003.6406;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 6;
    portalData[Portal::target_pos][X] = 1568.6758;
    portalData[Portal::target_pos][Y] = -1691.3551;
    portalData[Portal::target_pos][Z] = 5.8906;
    portalData[Portal::target_facing_angle] = 4.1027;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 0;
    portalData[Portal::pickupModel] = 1318;
    
    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::LSPD][InteriorData::portals], "out_lspd_park", portalIndex);
    
    //END LSPD
   
    // Gov
    Interior::data[Interior::GOV][InteriorData::portals] = map_new();
    format(portalData[Portal::name], 64, "Masuk City Hall");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 1481.0460;
    portalData[Portal::pos][Y] = -1770.3240;
    portalData[Portal::pos][Z] = 18.7958;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 0;
    portalData[Portal::target_pos][X] = 386.4300;
    portalData[Portal::target_pos][Y] = 173.6211;
    portalData[Portal::target_pos][Z] = 1008.3828;
    portalData[Portal::target_facing_angle] = 92.5313;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 3;
    portalData[Portal::pickupModel] = 1318;
    
    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::GOV][InteriorData::portals], "enter_cityhall", portalIndex);

    format(portalData[Portal::name], 64, "Keluar");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 389.5936;
    portalData[Portal::pos][Y] = 173.7427;
    portalData[Portal::pos][Z] = 1008.3828;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 3;
    portalData[Portal::target_pos][X] = 1473.5812;
    portalData[Portal::target_pos][Y] = -1770.1794;
    portalData[Portal::target_pos][Z] = 18.7958;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 0;
    portalData[Portal::target_facing_angle] = 357.5992;
    portalData[Portal::pickupModel] = 1318;

    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::GOV][InteriorData::portals], "exit_cityhall", portalIndex);
    //END GOV
    
    //EMS
    Interior::data[Interior::EMS][InteriorData::portals] = map_new();
    format(portalData[Portal::name], 64, "Masuk ASGH");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 1173.5848;
    portalData[Portal::pos][Y] = -1323.4875;
    portalData[Portal::pos][Z] = 15.1953;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 0;
    portalData[Portal::target_pos][X] = 1160.8408;
    portalData[Portal::target_pos][Y] = -1309.3265;
    portalData[Portal::target_pos][Z] = 14.4256;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 0;
    portalData[Portal::target_facing_angle] = 95.7146;
    portalData[Portal::pickupModel] = 1318;

    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::EMS][InteriorData::portals], "enter_asgh", portalIndex);

    format(portalData[Portal::name], 64, "Keluar");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 1160.8408;
    portalData[Portal::pos][Y] = -1309.3265;
    portalData[Portal::pos][Z] = 14.4256;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 0;
    portalData[Portal::target_pos][X] = 1173.5848;
    portalData[Portal::target_pos][Y] = -1323.4875;
    portalData[Portal::target_pos][Z] = 15.1953;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 0;
    portalData[Portal::target_facing_angle] = 270.4112;
    portalData[Portal::pickupModel] = 1318;

    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::EMS][InteriorData::portals], "enter_asgh", portalIndex);
    //END EMS
    
    // OTHER 
    // AddPlayerClass(23,,,,,0,0,0,0,0,0);
    // 5			
    Interior::data[Interior::OTHER][InteriorData::portals] = map_new();
    format(portalData[Portal::name], 64, "Masuk");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 2167.2166; 
    portalData[Portal::pos][Y] = -1672.4832;
    portalData[Portal::pos][Z] = 15.0757;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 0;
    portalData[Portal::target_pos][X] = 318.3135;
    portalData[Portal::target_pos][Y] = 1114.8385;
    portalData[Portal::target_pos][Z] = 1083.8828;
    portalData[Portal::target_facing_angle] = 4.9778;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 5;
    portalData[Portal::pickupModel] = 1318;

    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::OTHER][InteriorData::portals], "enter_crackden", portalIndex);

    format(portalData[Portal::name], 64, "Keluar");
    portalData[Portal::id] = list_size(Portal::list_portal);
    portalData[Portal::pos][X] = 318.3135;
    portalData[Portal::pos][Y] = 1114.8385;
    portalData[Portal::pos][Z] = 1083.8828;
    portalData[Portal::vw] = 0;
    portalData[Portal::int] = 5;
    portalData[Portal::target_pos][X] = 2167.2166; 
    portalData[Portal::target_pos][Y] = -1672.4832;
    portalData[Portal::target_pos][Z] = 15.0757;
    portalData[Portal::target_facing_angle] = 224.8848;
    portalData[Portal::target_vw] = 0;
    portalData[Portal::target_int] = 0;
    portalData[Portal::pickupModel] = 1318;

    portalIndex = list_add_arr(Portal::list_portal, portalData);
    map_str_add(Interior::data[Interior::OTHER][InteriorData::portals], "enter_crackden", portalIndex);
    //END OTHER
    return 1; 
}

CreatePortalObject() {
    // for(new i=0; i < Interior::MAX_INTERIOR; i++) {
    new i=0;
    for_list(it : Portal::list_portal) {
        new portalData[Portal::e_Portal];
        iter_get_arr(it, portalData);
        portalData[Portal::pickupId] = CreateDynamicPickup(portalData[Portal::pickupModel], 1, 
                                                            portalData[Portal::pos][X],
                                                            portalData[Portal::pos][Y],
                                                            portalData[Portal::pos][Z]);
        new str[128];
        format(str,sizeof(str), "%s\nTekan 'F'", portalData[Portal::name]);
        portalData[Portal::text3d] = CreateDynamic3DTextLabel(str, -1,
                                                                portalData[Portal::pos][X],
                                                                portalData[Portal::pos][Y],
                                                                portalData[Portal::pos][Z],
                                                                30.0, .testlos=1);

        portalData[Portal::areaId] = CreateDynamicCircle(
            portalData[Portal::pos][X],
            portalData[Portal::pos][Y],1.0);
        
        Streamer_SetIntData(STREAMER_TYPE_AREA, portalData[Portal::areaId], E_STREAMER_CUSTOM(E_STREAMER_INTERIOR_ID), i);
        iter_set_arr(it, portalData);
        i++;
        
        Logger_Log("portal created", Logger_S("name", portalData[Portal::name]));
    }
    // }
}

