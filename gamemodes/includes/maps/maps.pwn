
#include "./includes/maps/block_pns.pwn"
#include "./includes/maps/banks.pwn"
#include "./includes/maps/zip.pwn"
#include "./includes/maps/binco.pwn"
#include "./includes/maps/victim.pwn"

#include "./includes/maps/pom_safe.pwn"

#include "./includes/maps/sanews.pwn"
// #include "./includes/maps/asgh_ext.pwn"
// #include "./includes/maps/asgh_int1.pwn"
// #include "./includes/maps/asgh_int2.pwn"
#include "./includes/maps/asgh_int3.pwn"

stock PlayerRemoveMap(playerid) {
    RemoveBuildingFleccaBank(playerid); 

    RemoveBuilding_ZipMap(playerid);
    RemoveBuilding_BincoMap(playerid);

    RemoveBuilding_PomSafe(playerid);

    
    RemoveBuilding_SANews(playerid);

    // RemoveBuilding_ASGH(playerid);
}

stock LoadGameMap() {
    LoadPNSBlocking();
    // LoadGasStationMap(); 
    LoadFleccaBankMap();
    LoadBankExterior();
    LoadBankInterior();

    LoadVictimMap();
    LoadZipMap();
    LoadBincoMap();

    LoadPomSafe();

    LoadSANewsMap();
    LoadSANewsInt1();
    LoadSANewsInt2();

    // LoadASGHExterior();
    // LoadASGHInt1();
    // LoadASGHInt2();
    LoadASGHInt3();
}
