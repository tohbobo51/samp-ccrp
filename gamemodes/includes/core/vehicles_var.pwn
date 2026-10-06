#include <VehiclePartPosition>
#if !defined IsValidVehicle
    native IsValidVehicle(vehicleid);
#endif

#define Vehicle:: vhcl_
#define VehicleData:: vhcl_dat_
#define VehicleDmgStat:: vhcl_ds_
#define VehicleFactory:: vhcl_fc_
#define VehicleHandling:: vhcl_hdl_
#define VehicleEngine:: vhcl_ngn_
#define VehicleStorage:: vhcl_stor_
#define VehStorageItem:: vh_str_itm_

#define VEHICLE_MAX_COMPONENT_SLOT 13

#if !defined MIN_VEHICLE_MODEL
	#define MIN_VEHICLE_MODEL			(400)
#endif
#if !defined MAX_VEHICLE_MODEL
	#define MAX_VEHICLE_MODEL			(611)
#endif
#if !defined MAX_VEHICLE_MODELS
	#define MAX_VEHICLE_MODELS			(MAX_VEHICLE_MODEL - MIN_VEHICLE_MODEL)
#endif

#define vhcl_fc_IsUsingFactory(%0) GetPVarInt(%0, "IsUsingVehFac")
#define vhcl_fc_SetUsingFactory(%0,%1) SetPVarInt(%0, "IsUsingVehFac", %1)
#define vhcl_fc_SetFactoryID(%0,%1) SetPVarInt(%0, "VehFacID", %1)
#define vhcl_fc_FactoryID(%0) GetPVarInt(%0, "VehFacID")

#define vhcl_stor_IsAccessing(%0) GetPVarInt(%0, "IsUsingVStor")
#define vhcl_stor_SetAccessing(%0,%1) SetPVarInt(%0, "IsUsingVStor", %1)
#define vhcl_stor_AccessID(%0) GetPVarInt(%0, "VStorID")
#define vhcl_stor_SetAccessID(%0,%1) SetPVarInt(%0, "VStorID", %1)

#define vhcl_stor_IsUsed(%0) GetSVarInt(sprintf("VehStorOn_%i", %0))
#define vhcl_stor_SetUsed(%0,%1) SetSVarInt(sprintf("VehStorOn_%i", %0), %1)


forward Task:VehicleStorage::LoadStorage(vehicle_id);

enum (<<= 1)
{
  VEH_PARAM_ENGINE = 1, 
  VEH_PARAM_LIGHTS,     
  VEH_PARAM_ALARM, 
  VEH_PARAM_DOORS,
  VEH_PARAM_BONNET,
  VEH_PARAM_BOOT,
  VEH_PARAM_OBJECTIVE
};

enum Vehicle::e_Engine {
  Float:VehicleHandling::acceleration,
  Float:VehicleHandling::top_speed,
  Float:VehicleHandling::inertia
}

enum Vehicle::e_EngineType {
  VehicleEngine::NONE,
  VehicleEngine::TIER1,
  VehicleEngine::TIER2,
  VehicleEngine::TIER3,
  VehicleEngine::TIER4
}

new Vehicle::engines[5][Vehicle::e_Engine] = {
  {0.01, 0.01, 1.0},
  {0.5, 0.50, 2.0},
  {0.5,  0.75,  1.50},
  {0.75, 1.0, 1.0},
  {1.50,  1.0,  0.75}
};


enum Vehicle::e_DmgStat {
    VehicleDmgStat::panels,
    VehicleDmgStat::doors,
    VehicleDmgStat::lights,
    VehicleDmgStat::tires
}

enum Vehicle::e_Data {
    VehicleData::id,
    VehicleData::vehicleid,
    VehicleData::modelid,
    Float:VehicleData::fuel,
    Float:VehicleData::max_fuel,
    Float:VehicleData::health,
    Float:VehicleData::spawnPos[3],
    Float:VehicleData::zAngle,
    VehicleData::dmgStat[Vehicle::e_DmgStat],
    VehicleData::color[2],
    VehicleData::components[VEHICLE_MAX_COMPONENT_SLOT],
    VehicleData::plateNumber[10],
    VehicleData::engineType,
    
    VehicleData::params,
    VehicleData::odo_km,
    VehicleData::odo_m,
    VehicleData::serial,

    VehicleData::key_attached,
    VehicleData::faction_id,
        
    bool:VehicleData::spawned,
    VehicleData::lastUpdate,
};

new Vehicle::Schema[][DB::Column] = {
    {"id", DBColumnType::PK, VehicleData::id},
    {"modelid", DBColumnType::INT, VehicleData::modelid},
    {"fuel", DBColumnType::FLOAT, VehicleData::fuel},
    {"max_fuel", DBColumnType::FLOAT, VehicleData::max_fuel},
    {"health", DBColumnType::FLOAT, VehicleData::health},
    {"pos", DBColumnType::VEC3, VehicleData::spawnPos},
    {"angle", DBColumnType::FLOAT, VehicleData::zAngle},
    {"dmg_panels", DBColumnType::INT, _:VehicleData::dmgStat+0},
    {"dmg_doors", DBColumnType::INT, _:VehicleData::dmgStat+1},
    {"dmg_lights", DBColumnType::INT, _:VehicleData::dmgStat+2},
    {"dmg_tires", DBColumnType::INT, _:VehicleData::dmgStat+3},
    {"color1", DBColumnType::INT, _:VehicleData::color+0},
    {"color2", DBColumnType::INT, _:VehicleData::color+1},
    {"engine_type", DBColumnType::INT, VehicleData::engineType},
    {"plate_number", DBColumnType::STRING, VehicleData::plateNumber, 10},
    {"params", DBColumnType::INT, VehicleData::params},
    {"odo_km", DBColumnType::INT, VehicleData::odo_km},
    {"odo_m", DBColumnType::INT, VehicleData::odo_m},
    {"serial", DBColumnType::INT, VehicleData::serial},
    {"key_attached", DBColumnType::INT, VehicleData::key_attached},
    {"faction_id", DBColumnType::INT, VehicleData::faction_id}
};

new Map:Vehicle::list;

// Vehicle Factory

enum VehicleFactory::e_Factory {
    Float:VehicleFactory::position[3],
    Float:VehicleFactory::vehSpawnPos[3],
    Float:VehicleFactory::vehSpawnAngle,
    VehicleFactory::pickupid,
    Text3D:VehicleFactory::textid,
    VehicleFactory::areaid,
    bool:VehicleFactory::used
}

new VehicleFactory::factories[4][VehicleFactory::e_Factory];

new Float:Vehicle::MODEL_FUEL[MAX_VEHICLE_MODELS + 1] = 
{
	 70.0,  45.0, 40.0, 298.0,  40.0,  40.0, 200.0, 80.0, 60.0,  40.0,  40.0,
	 40.0,  40.0, 45.0,  45.0,  40.0,  70.0, 100.0, 45.0, 40.0,  40.0,  40.0,
	 45.0,  45.0, 20.0, 200.0,  40.0,  70.0,  70.0, 40.0, 45.0,  60.0,  90.0,
	100.0,  35.0,  0.0,  40.0,  50.0,  40.0,  40.0, 45.0,  5.0,  40.0,  50.0,
	 65.0,  40.0, 35.0,  90.0,  20.0,  60.0,   0.0, 40.0, 20.0,  20.0,  20.0,
	 60.0,  50.0, 20.0,  40.0,  45.0,  90.0,  30.0, 20.0, 35.0,   5.0,   5.0,
	 40.0,  40.0, 20.0,  90.0,  90.0,  20.0,  20.0, 20.0, 40.0,  40.0,  40.0,
	 40.0,  40.0, 45.0,  40.0,   0.0,  45.0,  45.0, 20.0, 20.0,  30.0,  90.0,
	 90.0,  70.0, 70.0,  40.0,  40.0,  20.0,  40.0, 45.0, 40.0,  90.0,  50.0,
	 50.0,  40.0,  5.0,  40.0,  40.0,  40.0,  50.0, 40.0, 40.0,  50.0,   0.0,
	  0.0,  90.0, 90.0,  90.0, 298.0, 298.0,  40.0, 40.0, 40.0, 400.0, 400.0,
	 30.0,  30.0, 30.0,  50.0,  50.0,  40.0,  40.0, 50.0, 40.0,  20.0,  20.0,
	 60.0,  40.0, 40.0,  40.0,  40.0,  50.0,  50.0, 20.0, 40.0,  40.0,  40.0,
	 50.0,  70.0, 40.0,  40.0,  40.0,  90.0,  40.0, 40.0, 40.0,  40.0, 300.0,
	 50.0,  40.0, 80.0,  80.0,  40.0,  40.0,  40.0, 40.0, 40.0,  90.0,  90.0,
	 40.0,  45.0, 45.0,  20.0,   0.0,  50.0,  10.0, 20.0, 50.0,  20.0,  40.0,
	 40.0, 300.0, 50.0,  50.0,  40.0,  30.0,  50.0, 20.0,  0.0,  40.0,  30.0,
	 40.0,  50.0, 40.0,   0.0,   0.0, 300.0, 200.0,  0.0, 20.0,  40.0,  40.0,
	 40.0,  50.0, 40.0,  60.0,  40.0,  40.0,  40.0, 45.0,  0.0,   0.0,   0.0,
	 50.0,   0.0,  0.0
};

new Vehicle::MODEL_STORAGE[MAX_VEHICLE_MODELS + 1] = 
{
    200, 150, 150, 0, 150, 150, 0, 0, 0, 200, 150, // 400-410
    150, 150, 350, 350, 150, 0, 0, 200, 150, 150, // 411 - 420
    150, 300, 0, 0, 0, 150, 0, 0, 150, 0, // 421- 430
    0, 0, 0, 0, 3000, 150, 0, 150, 150, 350, // 431 - 440
    0, 150, 0, 0, 150, 0, 0, 30, 0, 3000, // 441 - 450 
    150, 0, 0, 0, 1500, 2000, 0, 200, 500, 0, // 451 - 460
    0, 0, 0, 0, 0, 150, 150, 0, 0, 150, // 461 - 470 
    0, 0, 0, 150, 150, 0, 150, 300, 200, 150, // 471 - 480
    0, 500, 300, 0, 0, 0, 0, 0, 0, 0, // 481 - 490 
    150, 150, 0, 0, 0, 150, 0, 1000, 1000, 0, // 491 - 500 
    0, 0, 0, 0, 0, 150, 150, 350, 0, 0, // 501 - 510
    0, 0, 0, 0, 0, 150, 150, 150, 0, 0, // 511 - 520
    0, 0, 0, 0, 0, 150, 150, 0, 150, 0, // 521 - 530
    0, 0, 150, 150, 200, 150, 0, 0, 0, 150, // 531 - 540
    150, 150, 350, 0, 0, 150, 150, 0, 150, 150, // 541 - 550 
    150, 0, 0, 350, 150, 0, 0, 150, 150, 150, // 551 - 560
    150, 150, 0, 0, 150, 150, 150, 0, 0, 0, // 561 - 570
    0, 0, 0, 0, 150, 150, 0, 0, 150, 150, // 571 - 580
    0, 250, 0, 0, 150, 0, 150, 0, 150, 0, // 581 - 590
    3000, 0, 0, 0, 0, 150, 150, 150, 0, 175, // 591 - 600 
    0, 150, 150, 0, 0, 0, 0, 0, 1000, 0, 0
};

new Map:VehicleStorage::map;

enum eVehicleStorageMap {
    List:VehicleStorage::items,
    VehicleStorage::timestamp,
    VehicleStorage::current_capacity,
    VehicleStorage::max_capacity,
    VehicleStorage::is_dirty
};

enum eVehicleStorageItem {
    VehStorageItem::id,
    VehStorageItem::vehicle_id,
    VehStorageItem::list_idx,
    VehStorageItem::item[Inv::eItem]
};

new VehicleStorage::Schema[][DB::Column] = {
    {"id", DBColumnType::PK,  _:VehStorageItem::id},
    {"vehicle_id", DBColumnType::INT, _:VehStorageItem::vehicle_id},
    {"item_id", DBColumnType::INT, _:VehStorageItem::item + _:Item::id},
    {"amount", DBColumnType::INT, _:VehStorageItem::item + _:Item::amount},
    {"durability", DBColumnType::INT, _:VehStorageItem::item + _:Item::durability},
    {"power", DBColumnType::INT, _:VehStorageItem::item + _:Item::power},
    {"addon1", DBColumnType::INT, _:VehStorageItem::item + _:Item::addon1},
    {"addon2", DBColumnType::INT, _:VehStorageItem::item + _:Item::addon2},
    {"addon3", DBColumnType::INT, _:VehStorageItem::item + _:Item::addon3}
};

new VehicleStorage::LastItemID;
