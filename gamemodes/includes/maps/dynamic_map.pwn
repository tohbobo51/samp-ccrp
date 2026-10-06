public OnGameModeInit() {
  printf("[Map Prefab] Gamemode Init");
  DynMap::prefabs = map_new(); 
  DynMap::spawned = list_new();
  new mapTumbal[DynMap::e_Spawned];
  list_add_arr(DynMap::spawned, mapTumbal);
  
  LoadMapPrefab();
#if defined DMAP__OnGameModeInit
  return DMAP__OnGameModeInit();
#else
  return 1;
#endif
}
#if defined _ALS_OnGameModeInit
#undef OnGameModeInit
#else
#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit DMAP__OnGameModeInit
#if defined DMAP__OnGameModeInit
forward DMAP__OnGameModeInit();
#endif

new loadedMap=0;
LoadMapPrefab(){
  new mapList[2][64] = {
    {"map_sawmill"},
    {"map_sawmill_uc"}
  };
  for(new i=0;i<sizeof(mapList);i++) {
    RequestJSON(
        httpClient,
        sprintf("map/%s",mapList[i]),
        HTTP_METHOD_GET,
        "OnMapPrefabLoaded",
        .headers = RequestHeaders()
    );
  }
}

public OnPlayerEditDynamicObject(playerid, STREAMER_TAG_OBJECT:objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
  // printf("[DEBUG] DynMap on Edit Dynamic Object");
  
  if(DynMap::IsPlacingMap(playerid) && response == 1) {
    new mapDef[DynMap::e_Spawned];
    new idx = DynMap::PlacingMapID(playerid);
    list_get_arr(DynMap::spawned, idx, mapDef);
    mapDef[DynMap::pivotPosX] = x;
    mapDef[DynMap::pivotPosY] = y;
    mapDef[DynMap::pivotPosZ] = z;
    
    mapDef[DynMap::pivotRotX] = rx;
    mapDef[DynMap::pivotRotY] = ry;
    mapDef[DynMap::pivotRotZ] = rz;
    SetDynamicObjectPos(mapDef[DynMap::pivotObjectID], x,y,z);
    SetDynamicObjectRot(mapDef[DynMap::pivotObjectID], rx,ry,rz);
    for_list(i : mapDef[DynMap::objects]) {
      new l_objId = iter_get(i);
      UpdateAttachedDynamicObject(l_objId);
    }
    list_set_arr(DynMap::spawned, idx, mapDef);
    if(!Building::IsPlacingBlueprint(playerid)){
      DynMap::SetIsPlacingMap(playerid, 0);
      DynMap::SetPlacingMapID(playerid, -1);
    }
    printf("OnEdit Finisih mapID %i", idx);
    task_set_result(Task:DynMap::GetTask(playerid), idx);
  }
#if defined DYN_MAP_OnPlayerEditDynObject
  return DYN_MAP_OnPlayerEditDynObject(playerid,objectid,response,x,y,z,rx,ry,rz);
#else
  return 1;
#endif
}
#if defined _ALS_OnPlayerEditDynamicObject
#undef OnPlayerEditDynamicObject
#else
#define _ALS_OnPlayerEditDynamicObject
#endif
#define OnPlayerEditDynamicObject DYN_MAP_OnPlayerEditDynObject 
#if defined DYN_MAP_OnPlayerEditDynObject
forward DYN_MAP_OnPlayerEditDynObject(playerid, STREAMER_TAG_OBJECT:objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
#endif


callback OnMapPrefabLoaded(Request:id, E_HTTP_STATUS:status, Node:node) {
  printf("[DEBUG] Dynamic Map Response");
  new ret;
  new bool:success;
  new Node:objects;
  new mapName[64];
  
  ret = JsonGetString(node, "mapname", mapName);
  if(ret) {
    printf("[ERR] Failed to get data dynamic_map.pwn:45");
    return 1;
  }
  
  ret = JsonGetBool(node, "status", success);
  if(ret) {
    printf("[ERR] Failed to get data dynamic_map.pwn:46");
    return 1;
  }
  if(!success) {
    printf("[ERR] Failed to load map. Not found for %s", mapName);
    return 1;
  }
  
  ret = JsonGetArray(node, "data", objects);
  if(ret) {
    printf("[ERR] Failed to get data dynamic_map.pwn:50");
    return 1;
  }
  
  new objectLength;
  ret = JsonArrayLength(objects,objectLength);
  if(ret) {
    printf("[ERR] Failed to get data dynamic_map.pwn:64");
    return 1;
  }
  if(objectLength > 0) {
    new List:objectList = list_new();
    for(new i=0;i<objectLength;i++)  {
      new Node:object;
      ret = JsonArrayObject(objects,i,object);
      if(ret) {
        printf("[ERR] Failed to get data");
        return 1;
      }
      new l_Object[DynMap::e_Object];
      l_Object[DynMapObject::materials] = list_new();
      l_Object[DynMapObject::material_texts] = list_new();
      
      JsonGetInt(object, "modelId", l_Object[DynMapObject::modelid]);
      JsonGetFloat(object, "posX", l_Object[DynMapObject::posX]);
      JsonGetFloat(object, "posY", l_Object[DynMapObject::posY]);
      JsonGetFloat(object, "posZ", l_Object[DynMapObject::posZ]);
      JsonGetFloat(object, "rotX", l_Object[DynMapObject::rotX]);
      JsonGetFloat(object, "rotY", l_Object[DynMapObject::rotY]);
      JsonGetFloat(object, "rotZ", l_Object[DynMapObject::rotZ]);

      // printf("ModelID: %i", l_Object[DynMapObject::modelid]);
      // printf("RotX: %f", l_Object[DynMapObject::rotX]);
      // printf("RotY: %f", l_Object[DynMapObject::rotY]);
      // printf("RotZ: %f", l_Object[DynMapObject::rotZ]);
    
      new Node:materials;
      new materialLength;
      JsonGetArray(object,"materials", materials);
      JsonArrayLength(materials,materialLength);
      if(materialLength > 0) {
        for(new m=0;m<materialLength;m++){
          new Node:mat;
          new l_Mat[DynMap::e_Material];
          new szStr[64];
          szStr[0] = 0;
          JsonArrayObject(materials, m, mat);
          JsonGetInt(mat, "index", l_Mat[DynMapMaterial::index]);
          JsonGetInt(mat, "modelid", l_Mat[DynMapMaterial::modelid]);
          JsonGetString(mat, "txdname", szStr);
          memcpy(l_Mat[DynMapMaterial::txdname], szStr,0,4*64,64);
          szStr[0]=0;
          JsonGetString(mat, "texturename", szStr);
          memcpy(l_Mat[DynMapMaterial::texturename],szStr,0,4*64,64);
          
          JsonGetInt(mat, "color", l_Mat[DynMapMaterial::color]);
          list_add_arr(l_Object[DynMapObject::materials], l_Mat);
        }
      }

      new Node:materialtexts;
      new materialTextLength;
      JsonGetArray(object, "materialTexts", materialtexts);
      JsonArrayLength(materialtexts, materialTextLength);
      if(materialTextLength > 0) {
        for(new m=0;m<materialTextLength;m++) {
          new Node:matText;
          new l_matText[DynMap::e_MaterialText];
          JsonArrayObject(materialtexts, m, matText);
          JsonGetInt(matText, "materialindex", l_matText[DynMapMatText::materialindex]);
          new szText[256];
          JsonGetString(matText, "text", szText);
          memcpy(l_matText[DynMapMatText::text],szText,0,4*256,256);
          JsonGetInt(matText, "materialsize", l_matText[DynMapMatText::materialsize]);
          new szFontFace[64];
          JsonGetString(matText, "fontface", szFontFace);
          memcpy(l_matText[DynMapMatText::fontface],szFontFace,0,4*64,64);
          JsonGetInt(matText, "fontsize", l_matText[DynMapMatText::fontsize]);
          JsonGetInt(matText, "bold", l_matText[DynMapMatText::bold]);
          JsonGetInt(matText, "fontcolor", l_matText[DynMapMatText::fontcolor]);
          JsonGetInt(matText, "backcolor", l_matText[DynMapMatText::backcolor]);
          JsonGetInt(matText, "aligment", l_matText[DynMapMatText::alignment]);
          list_add_arr(l_Object[DynMapObject::material_texts], l_matText);
        }
      }

      // DynMap::print_object(l_Object);  
      list_add_arr(objectList, l_Object);
    }
    map_str_add(DynMap::prefabs, mapName, objectList);
  }
  
  printf("Map %s loaded.", mapName);
  loadedMap++;
  printf("Loaded map %i", loadedMap);
  return 1; 
}

stock Task:DynMap::spawn_prefab(playerid, const Float:pos[3], const prefab_name[64]) {
  new Task:t = task_new();

  if(!map_has_str_key(DynMap::prefabs, prefab_name)) {
    printf("Map %s doesn't exists", prefab_name);
    EMIT_PlayerSystemChat(playerid, -1, sprintf("Map %s doesn't exists", prefab_name));
    task_set_result(t, -1);
    return t;
  }
  new mapIdx = list_size(DynMap::spawned);
  
  new mapDef[DynMap::e_Spawned];
  mapDef[DynMap::id] = mapIdx;
  mapDef[DynMap::pivotObjectID] = CreateDynamicObject(19574,pos[0],pos[1],pos[2],0.0,0.0,0.0, -1, -1, -1, 9999.0, 300.0, -1, 1);
  mapDef[DynMap::pivotPosX] = pos[0];
  mapDef[DynMap::pivotPosY] = pos[1];
  mapDef[DynMap::pivotPosZ] = pos[2];
  mapDef[DynMap::pivotRotX] = 0.0;
  mapDef[DynMap::pivotRotY] = 0.0;
  mapDef[DynMap::pivotRotZ] = 0.0;
  SetDynamicObjectMaterial(mapDef[DynMap::pivotObjectID], 0, 1419, "break_fence3", "CJ_FRAME_Glass", 0x00000000);
  
  mapDef[DynMap::objects] = list_new();
  new List:prefab_objects_handle = List:map_str_get(DynMap::prefabs, prefab_name);
  // should after map_str_get idk it won't work if set memcpy before 
  memcpy(mapDef[DynMap::mapName],prefab_name,0,4*64,64);
  new tmpId;
  for_list(obj : prefab_objects_handle) {
    new l_Object[DynMap::e_Object];
    
    
    iter_get_arr(obj, l_Object);
    
    // DynMap::print_object(l_Object);
    tmpId = CreateDynamicObject(
      l_Object[DynMapObject::modelid],
      pos[0] + l_Object[DynMapObject::posX],
      pos[1] + l_Object[DynMapObject::posY],
      pos[2] + l_Object[DynMapObject::posZ],
      l_Object[DynMapObject::rotX],
      l_Object[DynMapObject::rotY],
      l_Object[DynMapObject::rotZ],
      -1,-1,-1,
      300.0,300.0
    );
    new Float:checkRot[3];
    GetDynamicObjectRot(tmpId, checkRot[0],checkRot[1],checkRot[2]);
    // printf("CheckRot");
    // printf("DataX: %f actualX: %f", l_Object[DynMapObject::rotX], checkRot[0]);
    // printf("DataY: %f actualY: %f", l_Object[DynMapObject::rotY], checkRot[1]);
    // printf("DataZ: %f actualZ: %f", l_Object[DynMapObject::rotZ], checkRot[2]);
    for_list(mat : l_Object[DynMapObject::materials]) {
      new l_mat[DynMap::e_Material];
      iter_get_arr(mat, l_mat);
      SetDynamicObjectMaterial(
        tmpId,
        l_mat[DynMapMaterial::index],
        l_mat[DynMapMaterial::modelid],
        l_mat[DynMapMaterial::txdname],
        l_mat[DynMapMaterial::texturename],
        l_mat[DynMapMaterial::color]
      ); 
    }
    for_list(mattext: l_Object[DynMapObject::material_texts]) {
      new l_matText[DynMap::e_MaterialText];
      iter_get_arr(mattext, l_matText);
      SetDynamicObjectMaterialText(
        tmpId,
        l_matText[DynMapMatText::materialindex],
        l_matText[DynMapMatText::text],
        l_matText[DynMapMatText::materialsize],
        l_matText[DynMapMatText::fontface],
        l_matText[DynMapMatText::fontsize],
        l_matText[DynMapMatText::bold],
        l_matText[DynMapMatText::fontcolor],
        l_matText[DynMapMatText::backcolor],
        l_matText[DynMapMatText::alignment]
      );
    }
    AttachDynamicObjectToObject(
      tmpId,
      mapDef[DynMap::pivotObjectID],
      l_Object[DynMapObject::posX],
      l_Object[DynMapObject::posY],
      l_Object[DynMapObject::posZ],
      l_Object[DynMapObject::rotX],
      l_Object[DynMapObject::rotY],
      l_Object[DynMapObject::rotZ]
    );
    list_add(mapDef[DynMap::objects], tmpId);
  }
  list_add_arr(DynMap::spawned, mapDef);
  
  DynMap::SetIsPlacingMap(playerid, 1);
  DynMap::SetPlacingMapID(playerid,mapIdx);
  DynMap::SetTask(playerid, _:t);
  printf("Spawning prefab mapID: %i",mapIdx);
  EditDynamicObject(playerid, mapDef[DynMap::pivotObjectID]);
  return t;
}

CMD:spawnmapprefab(playerid, params[]) {
  new mapName[64];
  if(sscanf(params, "s[64]", mapName)) return 1;
  
  new Float:l_pX, Float:l_pY, Float:l_pZ,
    Float: l_pAngle,
    Float: l_dist;

  GetPlayerPos(playerid, l_pX,l_pY,l_pZ);
  printf("[DEBUG] Player posX: %f posY: %f posZ: %f", l_pX,l_pY,l_pZ);

  GetPlayerFacingAngle(playerid, l_pAngle);

  l_dist = 5.0;
  GetXYInFrontOfPoint(l_pX,l_pY,l_pAngle, l_dist);

  printf("[DEBUG] Object posX: %f posY: %f posZ: %f", l_pX,l_pY,l_pZ);

  CA_FindZ_For2DCoord(l_pX,l_pY,l_pZ);

  EMIT_PlayerSystemChat(playerid, -1, "Spawning map");
  
  new Float:l_spawnPos[3];
  l_spawnPos[0] = l_pX;
  l_spawnPos[1] = l_pY;
  l_spawnPos[2] = l_pZ;
  new ret = await DynMap::spawn_prefab(playerid, l_spawnPos, mapName);
  if(ret == -1) {
    EMIT_PlayerSystemChat(playerid, -1, "Error spawning map");
    return 1;
  } 
  if(ret == 1) {
    EMIT_PlayerSystemChat(playerid, -1, "Map Spawned");
  }
  return 1;
}

CMD:listdynmap(playerid, params[]) {
  for_list(i : DynMap::spawned) {
    new mapDef[DynMap::e_Spawned];
    iter_get_arr(i, mapDef);
    if(mapDef[DynMap::id] == 0) continue;
    EMIT_PlayerSystemChat(playerid, -1, sprintf("#%i [%s]", mapDef[DynMap::id], mapDef[DynMap::mapName]));
  } 
  return 1;
}

stock DynMap::destroy(id) {
  if(id < 1) return 1;
  if(list_size(DynMap::spawned) < id) {
    return -1;
  }

  new mapDef[DynMap::e_Spawned];
  list_get_arr(DynMap::spawned, id, mapDef);
  for_list(i : mapDef[DynMap::objects]) {
    new objId = iter_get(i);
    if(IsValidDynamicObject(objId)) {
      DestroyDynamicObject(objId);
    }
  }
  list_clear(mapDef[DynMap::objects]);
  list_remove(DynMap::spawned, id);
  return 1;

}

CMD:destroydynmap(playerid, params[]){
  new dynmapid;
  if(sscanf(params,"i",dynmapid)) return 1;
  
  if(dynmapid < 1) return 1;
  DynMap::destroy(dynmapid);
  return 1;
}


