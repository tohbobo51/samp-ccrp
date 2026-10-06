
#define JobLumber:: job_lj_

#define LJTree:: lj_3_

#define LJ_TREE_MODEL_ID 658
#define LJ_TREE_DEAD_MODEL_ID 846

#define job_lj_IsEditingTree(%0) GetPVarInt(%0,"LJ_IsEditingTree")
#define job_lj_SetEditingTree(%0,%1) SetPVarInt(%0,"LJ_IsEditingTree",%1)
#define job_lj_SetEditTreeID(%0,%1) SetPVarInt(%0,"LJ_EditTreeID",%1)
#define job_lj_GetEditTreeID(%0) GetPVarInt(%0,"LJ_EditTreeID")

#define job_lj_IsUsingCS(%0) GetPVarInt(%0,"LJ_IsUsingCS")
#define job_lj_SetUsingCS(%0,%1) SetPVarInt(%0,"LJ_IsUsingCS",%1)

#define job_lj_IsCuttingTree(%0) GetPVarInt(%0, "LJ_IsCuttingTree")
#define job_lj_SetCuttingTree(%0,%1) SetPVarInt(%0, "LJ_IsCuttingTree", %1)

#define job_lj_SetCuttingTreeID(%0,%1) SetPVarInt(%0, "LJ_CuttingTreeID",%1)
#define job_lj_CuttingTreeID(%0) GetPVarInt(%0, "LJ_CuttingTreeID")

#define job_lj_GetCutPower(%0) GetPVarInt(%0, "LJ_CutPower")
#define job_lj_SetCutPower(%0,%1) SetPVarInt(%0, "LJ_CutPower",%1) 

#define job_lj_IsHarvestingTree(%0) GetPVarInt(%0, "LJ_IsHarvestingTree")
#define job_lj_SetHarvestingTree(%0,%1) SetPVarInt(%0, "LJ_IsHarvestingTree",%1)

#define job_lj_GetHarvestPower(%0) GetPVarInt(%0, "LJ_HarvestPower")
#define job_lj_SetHarvestPower(%0,%1) SetPVarInt(%0, "LJ_HarvestPower",%1)

#define job_lj_GetHarvestingTreeID(%0) GetPVarInt(%0, "LJ_HarvestingTreeID")
#define job_lj_SetHarvestingTreeID(%0,%1) SetPVarInt(%0, "LJ_HarvestingTreeID",%1)

#define job_lj_SetTreeID(%0,%1) SetPVarInt(%0, "LJ_InTreeID", %1)
#define job_lj_GetTreeID(%0) GetPVarInt(%0, "LJ_InTreeID")

#if defined DEBUG_MODE
new JobLumber::DEFAULT_SPAWN_TIME = 60*1; // in seconds
#else 
new JobLumber::DEFAULT_SPAWN_TIME = 60*30; // in seconds
#endif

enum e_PhysObj {
    bool:epo_valid,
    Float:epo_posX,
    Float:epo_posY,
    Float:epo_posZ,
    Float:epo_lastX,
    Float:epo_lastY,
    Float:epo_lastZ,
    epo_treeId,
    bool:epo_checked,
}

new SvrPhysObj[MAX_OBJECTS][e_PhysObj];

DeletePhysObj(index) {
    SvrPhysObj[index][epo_valid] = false;
    SvrPhysObj[index][epo_posX] = 0.0;
    SvrPhysObj[index][epo_posY] = 0.0;
    SvrPhysObj[index][epo_posZ] = 0.0;
    SvrPhysObj[index][epo_lastX] = 0.0;
    SvrPhysObj[index][epo_lastY] = 0.0;
    SvrPhysObj[index][epo_lastZ] = 0.0;
    SvrPhysObj[index][epo_treeId] = -1;
    SvrPhysObj[index][epo_checked] = false;
    DestroyObject(index);
    return 1;
}

stock DebugPhysObject(index) {
  printf("\
    Index: %i\n\
    treeId: %i\n\
    valid: %i\n\
    posX: %f\n\
    posY: %f\n\
    posZ: %f\n\
    lastX: %f\n\
    lastY: %f\n\
    lastZ: %f\n\
    checked: %i\n\
  ",
    index,
    SvrPhysObj[index][epo_treeId],
    SvrPhysObj[index][epo_valid],
    SvrPhysObj[index][epo_posX],
    SvrPhysObj[index][epo_posY],
    SvrPhysObj[index][epo_posZ],
    SvrPhysObj[index][epo_lastX],
    SvrPhysObj[index][epo_lastY],
    SvrPhysObj[index][epo_lastZ],
    SvrPhysObj[index][epo_checked]
  );
  return 1;
}

new JobLumber::AO_CS_DATA[attached_object_data] = {
    0.0, // ox
    0.000999, // oy
    -0.049999, // oz
    0.0, // rx
    -20.500000, // ry
    0.0, // rz
};


// Tree states for state machine
enum TreeState {
    TREE_STATE_ALIVE,      // Tree is standing and can be cut
    TREE_STATE_FALLEN,     // Tree is down but not harvested
    TREE_STATE_HARVESTED,  // Tree is harvested and waiting to respawn
    TREE_STATE_RESPAWNING  // Tree is in process of respawning
}

enum JobLumber::e_Tree {
    LJTree::id,
    Float:LJTree::pos[3],
    bool:LJTree::isDown,
    bool:LJTree::isHarvested,
    LJTree::respawnTimer,

    LJTree::objectId,
    LJTree::phys_objId,
    LJTree::areaId,

    LJTree::cutPerc,
    LJTree::cutPwr,
    List:LJTree::cutPlayers,

    LJTree::harvestPerc,
    LJTree::harvestDropTreshold,
    LJTree::harvestDrop,
    LJTree::harvestPwr,
    LJTree::harvestPlayer,
    
    TreeState:LJTree::state // Current state in the state machine
}

new JobLumber::Schema[][DB::Column] = {
    {"id", DBColumnType::PK, LJTree::id},
    {"pos", DBColumnType::VEC3, LJTree::pos}
};

new List:JobLumber::list_tree;


