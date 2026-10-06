public OnGameModeInit() {
  printf("[BUILDING] Gamemode Init");
  // Building::buildings = list_new();
#if defined BLDG_OnGameModeInit
  return BLDG_OnGameModeInit();
#else
  return 1;
#endif
}
#if defined _ALS_OnGameModeInit
#undef OnGameModeInit
#else
#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit BLDG_OnGameModeInit
#if defined BLDG_OnGameModeInit
forward BLDG_OnGameModeInit();
#endif

//TODO: Building:: does this feature continued ?
// Building::LoadAllBuilding() {
//   return 1; 
// }
//
// Building::SaveBuilding(id) {
//   return 1; 
// }
//
// Building::create(ownerid, Building::e_BuildingType:type, dynmap_handle) {
//
//   return 1; 
// }
//
// Building::process_build(playerid) {
//   return 1; 
// }


