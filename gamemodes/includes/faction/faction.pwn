// Faction Setup

FactionSetup() {
    SetupFactionGOV();
    SetupFactionLSPD();
    SetupFactionEMS();

    FactionLocker::LoadLockers();
}

FactionCleanup() {
    FactionLocker::Cleanup();
}

// Faction Functions
SetPlayerFaction(playerid, eFaction:faction) {
    CharacterData[playerid][p_faction] = faction;
    new szNotif[512];
    format(szNotif, sizeof(szNotif), "%s has joined %s", GetName(playerid), Faction::NAME[faction]);
    Faction::SendChat(faction, szNotif);
    return 1;
}

bool:IsPlayerInAnyFaction(playerid) {
    if(CharacterData[playerid][p_faction] == Faction::NONE) {
        return false;
    }
    return true;
}

IsPlayerInFaction(playerid, eFaction:faction) {
    return CharacterData[playerid][p_faction] == faction;
}

bool:IsVehicleFactionOwned(vehicleid, eFaction:faction) {
    if(map_has_key(Vehicle::list, vehicleid)) {
        return false;
    }
    new vehData[Vehicle::e_Data];
    map_get_arr(Vehicle::list, vehicleid, vehData);
    if(vehData[VehicleData::faction_id] != _:faction) {
        return false;
    }
    return true;
}

GetFactionMaxLevel(eFaction:faction) {
    if(faction == Faction::GOV) return GOV::MaxLevel;
    if(faction == Faction::LSPD) return LSPD::MaxLevel;
    if(faction == Faction::EMS) return EMS::MaxLevel;
    return -1;
}

GetPlayerFactionRankName(playerid, s_name[Faction::MAX_NAME]) {
    if(CharacterData[playerid][p_faction] == Faction::NONE) {
        format(s_name,sizeof(s_name), "NONE");
        return 1;
    }
    switch (CharacterData[playerid][p_faction]) {
        case Faction::GOV: {
            format(s_name, sizeof(s_name), "%s", GOV::Title[eGovLevel:CharacterData[playerid][p_faction_level]]);
            return 1;
        }
        case Faction::LSPD: {
            format(s_name,sizeof(s_name), "%s", LSPD::Title[eLSPDLevel:CharacterData[playerid][p_faction_level]]);
            return 1;
        }
        case Faction::EMS: {
            format(s_name,sizeof(s_name), "%s", EMS::Title[eEMSLevel:CharacterData[playerid][p_faction_level]]);
        }
    }
    return 1;
}

SetPlayerFactionLevel(playerid, level) {
    new eFaction:factionId = CharacterData[playerid][p_faction];
    if(factionId == Faction::NONE) return 0;
    new cLevel = CharacterData[playerid][p_faction_level];
    new promotType = level - cLevel;
    new promotText[56];
    if(promotType > 0) {
        format(promotText, sizeof(promotText), "Promoted");
    } else {
        format(promotText, sizeof(promotText), "Demoted");
    }

    new szNotif[512];
    switch(factionId) {
        case Faction::GOV: {
            if(level >= _:GOV::MaxLevel) {
                EMIT_PlayerSystemChat(playerid, -1, "Can't set level higher than available.");
                return 0;
            }
            format(szNotif, sizeof(szNotif), "%s has been %s to %s", GetName(playerid), promotText, GOV::Title[eGovLevel:level]);
            CharacterData[playerid][p_faction_level] = level;
            EMIT_PlayerSystemChat(playerid, -1, sprintf("Your faction level has been set to %s", GOV::Title[eGovLevel:level]));
        }
        case Faction::LSPD: {
            if(level >= _:LSPD::MaxLevel) {
                EMIT_PlayerSystemChat(playerid, -1, "Can't set level higher than available.");
                return 0;
            }
            format(szNotif, sizeof(szNotif), "%s has been %s to %s", GetName(playerid), promotText, LSPD::Title[eLSPDLevel:level]);
            CharacterData[playerid][p_faction_level] = level;
            EMIT_PlayerSystemChat(playerid, -1, sprintf("Your faction level has been set to %s", LSPD::Title[eLSPDLevel:level]));
        }

        case Faction::EMS: {
            if(level >= _:EMS::MaxLevel) {
                EMIT_PlayerSystemChat(playerid, -1, "Can't set level higher than available.");
                return 0;
            }
            format(szNotif, sizeof(szNotif), "%s has been %s to %s", GetName(playerid), promotText, EMS::Title[eEMSLevel:level]);
            CharacterData[playerid][p_faction_level] = level;
            EMIT_PlayerSystemChat(playerid, -1, sprintf("Your faction level has been set to %s", EMS::Title[eEMSLevel:level]));
        }
    }
    Faction::SendChat(factionId, szNotif);
    return 0;
}

// Utility
Faction::SendChat(eFaction:faction, const msg[]) {
    foreach(new i : Player) {
        if(CharacterData[i][p_faction] == faction) {
            EMIT_FactionChat(i, msg);
        }
    }
    return 1;
}

