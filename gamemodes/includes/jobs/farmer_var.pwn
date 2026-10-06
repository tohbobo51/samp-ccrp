#define Farming:: frm_
#define Plant:: frm_plt_
#define Land:: frm_lnd_
#define LandInfo:: lnd_inf_
#define LandPermission:: lnd_prms_

#define ITEM_RES_FERTILIZER 400
#define ITEM_SEED_WEED 401
#define ITEM_SEED_WHEAT 404

#define ITEM_RES_HEMP 402
#define ITEM_RES_WHEAT 405

#define ITEM_RES_JOINT 403

#define PLANT_OBJ_MODEL 2244

#define frm_LandID(%0) GetPVarInt(%0, "FarmLandID")
#define frm_SetLandID(%0,%1) SetPVarInt(%0, "FarmLandID",%1)

#define frm_PlantID(%0) GetPVarInt(%0, "FarmPlantID")
#define frm_SetPlantID(%0,%1) SetPVarInt(%0, "FarmPlantID",%1)


enum ePlant {
    Plant::id,
    Plant::list_idx,
    Plant::character_id,
    Float:Plant::pos[3],
    Plant::seed_id,
    Plant::harvest_time,
    Plant::current_time,
    Plant::fertilized,

    Plant::can_harvest,
    Plant::object_id,
    Plant::area_id
};

enum ePlantHarvest {
    Plant::plant_seed_id,
    Plant::harvest_item_id,
    Plant::harvest_amount
};

new Farming::HarvestInfo[][ePlantHarvest] = {
    {ITEM_SEED_WEED, ITEM_RES_HEMP, 50},
    {ITEM_SEED_WHEAT, ITEM_RES_WHEAT, 15}
};

new List:Farming::plant_list;
new Plant::Schema[][DB::Column] = {
    {"id", DBColumnType::PK, _:Plant::id},
    {"character_id", DBColumnType::INT, _:Plant::character_id},
    {"pos", DBColumnType::VEC3, _:Plant::pos},
    {"seed_id", DBColumnType::INT, _:Plant::seed_id},
    {"harvest_time", DBColumnType::INT, _:Plant::harvest_time},
    {"current_time", DBColumnType::INT, _:Plant::current_time},
    {"fertilized", DBColumnType::INT, _:Plant::fertilized}
};


enum eLandPlotInfo {
    LandInfo::id,
    LandInfo::name[64],
    LandInfo::owner_id,
    LandInfo::coord_str[512],
    LandInfo::access_permission[512],
    LandInfo::base_price,
    LandInfo::rent_price,

    LandInfo::rental_balance,
};

enum eLandPerms {
    LandPermission::character_id,
    LandPermission::exp_timestamp
};

enum eLandPlot {
    Land::id,
    Land::name[64],
    Land::owner_id,
    Map:Land::permission,
    Land::base_price,
    Land::rent_price,
    Land::rental_balance,
    
    Land::area_id,
};

new LandInfo::Schema[][DB::Column] = {
    {"id", DBColumnType::PK, _:LandInfo::id},
    {"name", DBColumnType::STRING, _:LandInfo::name, 64},
    {"owner_id", DBColumnType::INT, _:LandInfo::owner_id},
    {"access_permission", DBColumnType::STRING, _:LandInfo::access_permission, 512},
    {"coord_str", DBColumnType::STRING, _:LandInfo::coord_str, 512},
    {"base_price", DBColumnType::INT, _:LandInfo::base_price},
    {"rent_price", DBColumnType::INT, _:LandInfo::rent_price},
    {"rental_balance", DBColumnType::INT, _:LandInfo::rental_balance}
};


new List:Farming::land_list;

forward Task:Plant::DBSaveAndSpawn(plant[ePlant]);
