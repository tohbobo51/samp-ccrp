#include <pp-hooks>
hook OnGameModeInit() {
    printf("[JOB Sweeped] Gamemode Init");
    
    JobSweeper::CreateVehicle();
    JobSweeper::CreateRoute();

}


hook OnPlayerDisconnect(playerid, reason)
{
    JobSweeper::Quit(playerid); 
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER && oldstate == PLAYER_STATE_ONFOOT)
    {
        // Cek kembali jika kendaraan adalah Sweeper
        if(
            !JobSweeper::IsWorking(playerid) &&
            JobSweeper::IsVehValid(GetPlayerVehicleID(playerid))
        )
        {
            new String[256], enternal_string[2048];
            enternal_string[0] = '\0'; // Inisialisasi string kosong
            // Cek apakah timer side job pemain adalah 0
            if(CharacterData[playerid][p_sweeper_timer] > 0)
            {
                // Jika pemain masih dalam cooldown, kirim pesan error
                format(String, sizeof(String), "ERROR: Kamu harus menunggu %d Menit untuk menjadi Street Cleaner", CharacterData[playerid][p_sweeper_timer] / 60);
				EMIT_PlayerSystemChat(playerid,-1, String);
                RemovePlayerFromVehicle(playerid); // Keluarkan pemain dari kendaraan
                SetVehicleToRespawn(GetPlayerVehicleID(playerid)); // Respawn kendaraan
                return 1;
            }
            // Persiapkan dialog job sweeper
            strcat(enternal_string, "Route\tPrice\n");
            for(new i;i< MAX_SWEEPER_ROUTE;i++) {
                format(String, sizeof(String), "Sweeper Route %s\t%s%s\n", 
                       JobSweeper::Route[i][SweeperRoute::name],
                       (JobSweeper::Route[i][SweeperRoute::taken] == true) ? ("{FF0000}Taken") : ("{33AA33}"),
                       (JobSweeper::Route[i][SweeperRoute::taken] == true) ? ("") : sprintf("$%i",JobSweeper::Route[i][SweeperRoute::reward])
                );
                strcat(enternal_string, String);
            }
            // Tampilkan dialog ke pemain
            ShowPlayerDialog(playerid, SWEEPERJOB, DIALOG_STYLE_TABLIST_HEADERS, "Sweeper Sidejob", enternal_string, "Select", "Cancel");
        }
    }
    if(newstate == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_DRIVER) {
        if(JobSweeper::IsWorking(playerid)) {
            JobSweeper::Quit(playerid);
        }
    }
    return 0;
}


hook OnPlayerEnterRaceCP(playerid)
{
    if(!JobSweeper::IsWorking(playerid)) {
        return 0;
    }
    DisablePlayerRaceCheckpoint(playerid);
    new pRoute = JobSweeper::GetRoute(playerid)-1;
    if(pRoute < 0) {
        return 1;
    }
    if(!IsPlayerInAnyVehicle(playerid))
    {
        return 1;
    }
    if(GetVehicleModel(GetPlayerVehicleID(playerid)) != 574)
    {
        EMIT_PlayerSystemChat(playerid, -1, "SIDEJOB: Kamu harus menggunakan kendaraan yang telah ditentukan");
        JobSweeper::Quit(playerid);
        return 1;
    }
    new l_step = JobSweeper::GetStep(playerid);
    new max_step = list_size(JobSweeper::RoutePos[pRoute])-1;
    if(l_step == max_step) {
        JobSweeper::Complete(playerid);
    } else {
        JobSweeper::SetStep(playerid, l_step+1);
        JobSweeper::AdvanceStep(playerid);
    }
    return 0;
}


// public OnPlayerExitVehicle(playerid, vehicleid)
// {
//     JobSweeper::Quit(playerid); 
// #if defined J_SWP_OnPlayerExitVehicle
//     return J_SWP_OnPlayerExitVehicle(playerid,vehicleid);
// #else
//     return 1;
// #endif
// }
// #if defined _ALS_OnPlayerExitVehicle
// #undef OnPlayerExitVehicle
// #else
// #define _ALS_OnPlayerExitVehicle
// #endif
// #define OnPlayerExitVehicle J_SWP_OnPlayerExitVehicle
// #if defined J_SWP_OnPlayerExitVehicle
// forward J_SWP_OnPlayerExitVehicle(playerid,vehicleid);
// #endif

// TODO: Refactor using Async Dialog
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == SWEEPERJOB) {
        if(CharacterData[playerid][p_sweeper_timer] > 0) {
            return 1;
        }
		if(response) {
            if(JobSweeper::Route[listitem][SweeperRoute::taken] == true) {
                EMIT_PlayerSystemChat(playerid,-1, "SIDEJOB: Rute telah diambil pekerja lain.");
                return 1;
            }
            JobSweeper::SetIsWorking(playerid, 1);
            JobSweeper::SetRoute(playerid, listitem + 1);
            new l_step = 0;
            JobSweeper::SetStep(playerid, l_step);
            JobSweeper::Route[listitem][SweeperRoute::taken] = true;
            EMIT_PlayerSystemChat(playerid,-1, "SIDEJOB: Ikutilah checkpoint yang tersedia pada Radar");
            
            JobSweeper::AdvanceStep(playerid);
		}
		else RemovePlayerFromVehicle(playerid);
	}
    return 0;
}


// TODO: Optimize this ? Bug ?
JobSweeper::Tick()
{
    // for(new x;x<MAX_SWEEPER_VEHICLES; x++)
    // {
    //     if(IsVehicleEmpty(SweepVeh[x]))
    //     {
    //         SetVehicleToRespawn(SweepVeh[x]);
    //         // TODO: Change to anticheat version
    //         SetVehicleHealth(SweepVeh[x], 2000);
    //         // SetVehicleFuel(SweepVeh[x], 1000); // currently no fuel system for job vehicle
    //         SetVehicleDoorsLockedState(SweepVeh[x], false);
    //     }
    // }
	return 1;
}

JobSweeper::DelayTimer(playerid)
{
    if(CharacterData[playerid][p_sweeper_timer] > 0)
	{
		CharacterData[playerid][p_sweeper_timer]--;
        if(CharacterData[playerid][p_sweeper_timer] <= 1)
        {
			EMIT_PlayerSystemChat(playerid,-1, "SIDEJOB: Sekarang, anda sudah bisa bekerja SideJob Sweeper");
            CharacterData[playerid][p_sweeper_timer] = 0;
        }
    }
}

JobSweeper::IsVehValid(carid)
{
	for(new v = 0; v < MAX_SWEEPER_VEHICLES; v++) {
	    if(carid == SweepVeh[v]) return 1;
	}
	return 0;
}

JobSweeper::CreateVehicle()
{
    //SIDE JOB SWEEPER VEHICLE
	SweepVeh[0] = AddStaticVehicle(574, 1615.5201, -1896.2864, 13.2474, 0.0000, 1, 1);
	SweepVeh[1] = AddStaticVehicle(574, 1622.4797, -1896.2864, 13.2474, 0.0000, 1, 1);
	SweepVeh[2] = AddStaticVehicle(574, 1619.0095, -1896.2864, 13.2474, 0.0000, 1, 1);
	SweepVeh[3] = AddStaticVehicle(574, 774.5986,-1127.7871,23.8281,84.0562, 1, 1);

    for(new x;x<MAX_SWEEPER_VEHICLES; x++)
	{
		new string_enternal[128];
	    format(string_enternal, sizeof(string_enternal), "-SWPR- %d", SweepVeh[x]);
	    SetVehicleNumberPlate(SweepVeh[x], string_enternal);
	    SetVehicleToRespawn(SweepVeh[x]);
	}
}

JobSweeper::CreateRoute() {
    // Route A
    JobSweeper::RoutePos[0] = list_new();
    list_add_arr(JobSweeper::RoutePos[0], Float:{1631.1259,-1875.8676,13.1079});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1679.4075,-1867.3059,13.1157});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1691.9288,-1832.2202,13.1079});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1692.4034,-1749.3794,13.1151});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1660.8494,-1729.7914,13.1080});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1540.9940,-1729.6190,13.1079});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1531.4606,-1704.6635,13.1080});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1531.5427,-1606.7444,13.1079});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1466.9369,-1589.1991,13.1079});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1432.4270,-1570.9565,13.0785});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1456.8425,-1454.2955,13.0915});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1494.9351,-1443.1246,13.1079});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1641.8486,-1443.4198,13.1079});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1732.5580,-1443.5229,13.0907});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1833.8168,-1463.2640,13.1003});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1842.4902,-1501.7483,13.0885});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1819.2338,-1595.7828,13.0841});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1818.7572,-1715.2195,13.1079});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1784.2252,-1730.2830,13.1079});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1702.9146,-1730.3160,13.1079});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1687.1395,-1765.6285,13.1079});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1647.3860,-1868.7577,13.1079});
    list_add_arr(JobSweeper::RoutePos[0], Float:{1623.1375,-1894.7131,13.2753});

    JobSweeper::RoutePos[1] = list_new();
    list_add_arr(JobSweeper::RoutePos[1], Float:{1613.3342,-1876.3984,13.1080});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1543.2211,-1870.5433,13.1079});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1406.1967,-1869.4572,13.1079});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1322.0150,-1848.8750,13.1079});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1314.3750,-1767.4312,13.1079});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1339.7153,-1734.7532,13.1157});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1409.3979,-1734.8229,13.1157});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1431.8108,-1670.3778,13.1079});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1431.4230,-1607.5250,13.1079});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1504.0176,-1594.9081,13.1080});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1643.0905,-1594.6688,13.1499});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1659.6577,-1563.4302,13.1157});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1697.9161,-1549.8684,13.1079});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1703.6350,-1488.4021,13.1135});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1670.9244,-1478.6689,13.1079});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1654.8127,-1575.8204,13.1079});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1678.8986,-1594.3568,13.1110});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1686.6621,-1712.4702,13.1079});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1716.0092,-1735.4749,13.1079});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1810.7306,-1734.4653,13.1157});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1819.9282,-1812.2948,13.1282});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1702.8337,-1810.1008,13.0919});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1657.6678,-1868.3313,13.1079});
    list_add_arr(JobSweeper::RoutePos[1], Float:{1619.0530,-1894.1783,13.2742});

    JobSweeper::RoutePos[2] = list_new();
    list_add_arr(JobSweeper::RoutePos[2], Float:{1631.8092,-1875.8730,13.4909});
    list_add_arr(JobSweeper::RoutePos[2], Float:{1691.4486,-1833.3379,13.4829});
    list_add_arr(JobSweeper::RoutePos[2], Float:{1805.1152,-1834.9608,13.4886});
    list_add_arr(JobSweeper::RoutePos[2], Float:{1819.1494,-1914.2688,13.4891});
    list_add_arr(JobSweeper::RoutePos[2], Float:{1933.4349,-1934.3416,13.4831});
    list_add_arr(JobSweeper::RoutePos[2], Float:{2052.3677,-1935.8784,13.4118});
    list_add_arr(JobSweeper::RoutePos[2], Float:{2083.9021,-1837.6925,13.4855});
    list_add_arr(JobSweeper::RoutePos[2], Float:{2019.7606,-1810.0647,13.4873});
    list_add_arr(JobSweeper::RoutePos[2], Float:{1965.0964,-1768.8557,13.4828});
    list_add_arr(JobSweeper::RoutePos[2], Float:{1943.7153,-1733.3943,13.4897});
    list_add_arr(JobSweeper::RoutePos[2], Float:{1944.3800,-1629.5052,13.4863});
    list_add_arr(JobSweeper::RoutePos[2], Float:{1854.7311,-1609.5864,13.4915});
    list_add_arr(JobSweeper::RoutePos[2], Float:{1763.6650,-1601.8796,13.4821});
    list_add_arr(JobSweeper::RoutePos[2], Float:{1747.2145,-1707.9730,13.4852});
    list_add_arr(JobSweeper::RoutePos[2], Float:{1704.5280,-1730.1855,13.4832});
    list_add_arr(JobSweeper::RoutePos[2], Float:{1671.0392,-1867.4829,13.4894});
    list_add_arr(JobSweeper::RoutePos[2], Float:{1627.4254,-1874.8622,13.4865});
    list_add_arr(JobSweeper::RoutePos[2], Float:{1614.0293,-1895.2081,13.6549});


    JobSweeper::RoutePos[3] = list_new();
    list_add_arr(JobSweeper::RoutePos[3], Float:{1794.9688,-1140.3323,23.7348});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1962.6061,-1129.8535,23.5519});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1962.3199,-980.1069,38.7472});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1791.6376,-1049.4366,24.5885});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1627.6912,-1226.3948,17.9656});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1634.1520,-1605.4928,15.5073});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1755.3953,-1756.8350,12.6886});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1770.8976,-1576.8060,13.2635});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1797.1500,-1382.3519,13.2899});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1783.2335,-1151.8718,23.3615});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1661.5624,-1228.8263,15.5296});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1158.3124,-1556.6473,11.0299});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1194.3909,-1518.4525,5.8360});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1548.6324,-1192.7557,44.4105});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1835.6268,-878.5748,68.1284});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1984.2629,-952.3107,40.8154});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1962.5627,-1131.7030,23.6189});
    list_add_arr(JobSweeper::RoutePos[3], Float:{1760.8343,-1130.0598,24.1861});

    return;
}

JobSweeper::AdvanceStep(playerid) {
    if(!JobSweeper::IsWorking(playerid)) return 0;
    new l_route = JobSweeper::GetRoute(playerid)-1;
    new l_step = JobSweeper::GetStep(playerid);
    new l_maxstep = list_size(JobSweeper::RoutePos[l_route])-1;
    EMIT_PlayerSystemChat(playerid, -1, sprintf("SIDEJOB: %i / %i selesai ", l_step,l_maxstep));
    new Float:c_Pos[3];
    new Float:n_Pos[3];
    if(l_step < l_maxstep) {
        list_get_arr_safe(JobSweeper::RoutePos[l_route], l_step, c_Pos);
        list_get_arr_safe(JobSweeper::RoutePos[l_route], l_step+1, n_Pos);
		SetPlayerRaceCheckpoint(playerid, 0, c_Pos[X], c_Pos[Y],c_Pos[Z],n_Pos[X],n_Pos[Y],n_Pos[Z], 5);
        return 1;
    }
    if(l_step == l_maxstep) {
        list_get_arr_safe(JobSweeper::RoutePos[l_route], l_step, c_Pos);
		SetPlayerRaceCheckpoint(playerid, 1, c_Pos[X], c_Pos[Y],c_Pos[Z],c_Pos[X],c_Pos[Y],c_Pos[Z], 5);
        return 1;
    }
    return 1;
}

JobSweeper::Quit(playerid) {
    if(JobSweeper::IsWorking(playerid)) {
        //TODO: Do not force cancel, set timer and ask player to get back if they want to continue the job
        DisablePlayerRaceCheckpoint(playerid);
        JobSweeper::SetIsWorking(playerid, 0);
        new pRoute = JobSweeper::GetRoute(playerid)-1;
        JobSweeper::Route[pRoute][SweeperRoute::taken] = false;
        JobSweeper::SetRoute(playerid, 0);
        if(IsPlayerInAnyVehicle(playerid)) {
            new vehid = GetPlayerVehicleID(playerid);
            SetVehicleToRespawn(vehid);
        }
        EMIT_PlayerSystemChat(playerid, -1, "SIDEJOB: Kamu meninggalkan sidejob.");
    }
    return 1;
}

JobSweeper::Complete(playerid) {
    if(JobSweeper::IsWorking(playerid)) {
        new pRoute = JobSweeper::GetRoute(playerid)-1;
        new reward = JobSweeper::Route[pRoute][SweeperRoute::reward];
        Character::GiveCash(playerid, reward);
        EMIT_PlayerSystemChat(playerid, -1, sprintf("SIDEJOB: Kamu mendapatkan $%i dari Job Sweeper", reward));
        JobSweeper::Quit(playerid);
    }
}
