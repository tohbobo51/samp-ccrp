
public OnGotRedisEvent(const eventName[], Node:data) {
  printf("[Redis NPC HANDLER] Event: %s",eventName);
#if defined NPC_OnGotRedisEvent
  return NPC_OnGotRedisEvent(eventName,data);
#else
  return 1;
#endif
}

#if defined _ALS_OnGotRedisEvent
#undef OnGotRedisEvent
#else
#define _ALS_OnGotRedisEvent
#endif
#define OnGotRedisEvent NPC_OnGotRedisEvent
#if defined NPC_OnGotRedisEvent
forward NPC_OnGotRedisEvent(const eventName[], Node:data);
#endif

public OnGameModeInit() {
  printf("[NPC] Gamemode Init");

  for(new i=0;i<FCNPC_MAX_NODES; i++) {
    if(!FCNPC_IsNodeOpen(i) && !FCNPC_OpenNode(i)) {
      printf("[NPC] Error: Failed to open node %d", i);
    }
  }
  
  NPC::spawned = map_new();
  NPC::LoadAll();
#if defined NPC_OnGameModeInit
  return NPC_OnGameModeInit();
#else
  return 1;
#endif
}
#if defined _ALS_OnGameModeInit
#undef OnGameModeInit
#else
#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit NPC_OnGameModeInit
#if defined NPC_OnGameModeInit
forward NPC_OnGameModeInit();
#endif

NPC::LoadAll() {
  mysql_tquery(MainConn, "SELECT * FROM `npc`", "OnLoadAllNPC");
  return 1;
}

callback OnLoadAllNPC() {
  new rows, fields;
  cache_get_row_count(rows);
  cache_get_field_count(fields);

  if(rows < 1) return 1;
  printf("[NPC] Spawning %i npcs", rows);

  new npcData[NPC::e_Data];
  for(new i=0;i<rows;i++) {
    cache_get_value_name_int(i, "id", npcData[NPCData::id]);
    cache_get_value_name(i, "name", npcData[NPCData::name], MAX_PLAYER_NAME+4);
    cache_get_value_name_int(i, "skinid", npcData[NPCData::skinid]);
    cache_get_value_name_int(i, "stamina", npcData[NPCData::stamina]);
    cache_get_value_name_int(i, "hunger", npcData[NPCData::hunger]);

    cache_get_value_name_float(i, "posX", npcData[NPCData::posX]);
    cache_get_value_name_float(i, "posY", npcData[NPCData::posY]);
    cache_get_value_name_float(i, "posZ", npcData[NPCData::posZ]);

    new npcID = FCNPC_Create(npcData[NPCData::name]);
    FCNPC_Spawn(npcID, npcData[NPCData::skinid], 
                npcData[NPCData::posX],
                npcData[NPCData::posY],
                npcData[NPCData::posZ]);

    npcData[NPCData::isSpawned] = true;
    npcData[NPCData::npcid] = npcID;

    map_set_arr(NPC::spawned, npcID, npcData);
  }

  return 1;
}


public FCNPC_OnStreamIn(npcid, forplayerid) {
  printf("NPC %i streamed in for player: %i",npcid, forplayerid);
}

public FCNPC_OnStreamOut(npcid, forplayerid) {
  printf("NPC %i streamed out for player: %i",npcid, forplayerid);
}

public FCNPC_OnFinishMovePath(npcid, pathid) {
  printf("NPC %i finished movepath %i", npcid, pathid);
  FCNPC_DestroyMovePath(pathid);
}

public FCNPC_OnFinishMovePathPoint(npcid, pathid, pointid) {
  printf("NPC %i finished point %i for movepath %i", npcid, pointid, pathid);
}

//TODO: NPC Behavior
// NPC::Hear(npcid, from, const msg[]) {
//   if(!map_has_key(NPC::spawned, npcid)) return 0;
//   return 1;
// }
//
// NPC::load() {
//
// }
//
// NPC::save() {
//
// }
//
// NPC::process() {
//
// }

#if defined DEBUG_MODE

CMD:gotonpc(playerid, params[]) {
  new npcid;
  if(sscanf(params, "i", npcid)) return 1;
  if(!map_valid(NPC::spawned)) return 1;
  if(!map_has_key(NPC::spawned, npcid)) return 1;

  new l_NPC[NPC::e_Data];
  map_get_arr(NPC::spawned, npcid, l_NPC);

  new Float:nx,Float:ny,Float:nz;
  FCNPC_GetPosition(l_NPC[NPCData::npcid], nx, ny,nz);

  SetPlayerPos(playerid, nx, ny, nz + 5.0);
  return 1;
}


CMD:npcgethere(playerid, params[]) {
  new npcid; 
  if(sscanf(params, "i", npcid)) return 1;

  if(!map_valid(NPC::spawned)) return 1;
  if(!map_has_key(NPC::spawned, npcid)) return 1;

  new l_NPC[NPC::e_Data];
  map_get_arr(NPC::spawned, npcid, l_NPC);

  new Float:px, Float:py, Float:pz,
    Float:npx, Float:npy, Float:npz;

  GetPlayerPos(playerid, px, py,pz);
  FCNPC_GetPosition(l_NPC[NPCData::npcid], npx, npy, npz);
  new MapNode:start;
  if(GetClosestMapNodeToPoint(npx, npy, npz, start) != GPS_ERROR_NONE) {
    return EMIT_PlayerSystemChat(playerid, -1, "Failed to find node near npc");
  }

  new MapNode:target;

  if(GetClosestMapNodeToPoint(px, py, pz, target)) {
    return EMIT_PlayerSystemChat(playerid, -1, "Failed to find node near you");
  }

  if(FindPathThreaded(start,target, "OnCallNPCPathFound" , "iii", playerid,  GetTickCount())) {
    return EMIT_PlayerSystemChat(playerid, -1, "Pathfinding failed for some reason");
  }
  EMIT_PlayerSystemChat(playerid, -1, "Calling NPC to you.");
  return 1;
}

callback OnCallNPCPathFound(Path:pathid, playerid, npcid, start_time) {
  if(!IsValidPath(pathid)) {
    return EMIT_PlayerSystemChat(playerid, -1, "Pathfinding failed");
  } 

  new string[128],size,Float:length;
  GetPathSize(pathid, size);
  GetPathLength(pathid, length);

  format(string,sizeof(string), "Path found in %ims.\nAmount of nodes:%i\nlength:%i", GetTickCount()-start_time,size,length);
  EMIT_PlayerSystemChat(playerid, -1, string);

  new MapNode:nodeid, Float:lx, Float:ly, Float:lz;

  new movepath = FCNPC_CreateMovePath();

  printf("Created movepath %i", movepath);

  for(new i;i<size;i++) {    
    GetPathNode(pathid, i, nodeid);
    GetMapNodePos(nodeid, lx,ly,lz);
    format(string,sizeof(string), "Node %i x: %f y: %f z: %f", 
           i, lx,ly,lz);
    EMIT_PlayerSystemChat(playerid, -1, string);
    printf("Adding node %d to movepath", _:nodeid, movepath);
    FCNPC_AddPointToMovePath(movepath, lx,ly,lz);
    CreateDynamicPickup(1318, 1, lx,ly,lz);
  }

  printf("Number of points in movepath = %i", FCNPC_GetNumberMovePathPoint(movepath));

  if(FCNPC_IsValidMovePath(movepath)) {
    if(FCNPC_GoByMovePath(npcid, movepath)) {
      EMIT_PlayerSystemChat(playerid, -1, "NPC Moving.");
    } else {
      EMIT_PlayerSystemChat(playerid, -1, "NPC Not Moving.");
    }
  } else {
    EMIT_PlayerSystemChat(playerid, -1, "Invalid Path.");
  }

  printf("Cleanup");
  
  DestroyPath(pathid);
  return 1;
}

#endif
