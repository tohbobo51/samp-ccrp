
#define JobMiner:: job_minr_
#define MNRRock:: mnr_rck_

#define job_minr_ROCK_MODEL 905

#define job_minr_IsEditingRock(%0) GetPVarInt(%0,"MNR_IsEditingRock")
#define job_minr_SetEditingRock(%0,%1) SetPVarInt(%0,"MNR_IsEditingRock",%1)
#define job_minr_SetEditRockID(%0,%1) SetPVarInt(%0,"MNR_EditRockID",%1)
#define job_minr_GetEditRockID(%0) GetPVarInt(%0,"MNR_EditRockID")

#define job_minr_IsUsingSH(%0) GetPVarInt(%0, "MNR_IsUsingSH")
#define job_minr_SetUsingSH(%0,%1) SetPVarInt(%0, "MNR_IsUsingSH", %1)

#define job_minr_SetRockID(%0,%1) SetPVarInt(%0, "MNR_RockID", %1)
#define job_minr_GetRockID(%0) GetPVarInt(%0, "MNR_RockID")


#if defined DEBUG_MODE
new JobMiner::DEFAULT_SPAWN_TIME = 60*1; // in seconds
#else 
new JobMiner::DEFAULT_SPAWN_TIME = 60*30; // in seconds
#endif

enum JobMiner::e_Rock {
  MNRRock::id,
  Float:MNRRock::pos[3],
  Float:MNRRock::rot[3],

  MNRRock::objectId,
  MNRRock::areaId,
  
  MNRRock::hp,
  MNRRock::respawnTimer,
};

new List:JobMiner::list_rock;
new JobMiner::list_locked = false;
new JobMiner::AO_CS_DATA[attached_object_data] = {
    0.071999, // ox
    0.039998, // oy
    0.319001, // oz
    -89.399963, // rx
    99.000007, // ry
    0.0, // rz
};

new JobMiner::Schema[][DB::Column] = {
    {"id", DBColumnType::PK, MNRRock::id},
    {"pos", DBColumnType::VEC3, MNRRock::pos},
    {"rot", DBColumnType::VEC3, MNRRock::rot}
};

new JobMiner::rewards[][] = {
    {ITEM_RES_GOLD_ORE, 10},
    {ITEM_RES_SILVER_ORE, 20},
    {ITEM_RES_COPPER_ORE, 40},
    {ITEM_RES_IRON_ORE, 60},
    {ITEM_RES_SULPHUR, 75},
    {ITEM_RES_COAL, 90}
};


// ox: 0.071999
// oy:0.039998
// oz:0.319001
// rx:-89.399963
// ry:99.000007
// rz:0.000000
