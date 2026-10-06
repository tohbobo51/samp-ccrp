#define NPC:: ccnpc_
#define NPCData:: ccnpc_dat_
#define NPCStateMachine:: ccnpc_sm_
#define NPCState:: ccnpc_st_
#define NPCAction:: ccnpc_act_

enum NPCState::enum {
  NPCState::IDLE,
  NPCState::WALKING,
  NPCState::RUNNING,
  NPCState::DRIVING,
  NPCState::IDLE_VEHICLE,
  NPCState::PATROLLING,
  NPCState::WORKING,
  NPCState::MAX_STATE
}

enum (<<= 1)
{
  ccnpc_st_HUNGRY = 1, 
}; 

enum NPCAction::enum {
  NPCAction::GOTO,
}

enum NPC::e_Data {
  NPCData::id,
  NPCData::npcid,
  bool:NPCData::isSpawned,
  NPCData::skinid,
  NPCData::name[MAX_PLAYER_NAME+4],
  NPCData::stamina,
  NPCData::hunger,

  Float:NPCData::posX,
  Float:NPCData::posY,
  Float:NPCData::posZ
}

// new List:NPC::state_group[NPCState::MAX_STATE];
new Map:NPC::spawned;
