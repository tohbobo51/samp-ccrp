
#define DynMap:: dynmap_
#define DynMapObject:: dymp_obj_
#define DynMapPrefab:: dymp_pfb_
#define DynMapMaterial:: dymp_mat_
#define DynMapMatText:: dymp_mattx_

#define dynmap_IsPlacingMap(%0) GetPVarInt(%0, "DynMapIsPlacing")
#define dynmap_SetIsPlacingMap(%0,%1) SetPVarInt(%0, "DynMapIsPlacing", %1)
#define dynmap_PlacingMapID(%0) GetPVarInt(%0, "DynMapPlacingMapID")
#define dynmap_SetPlacingMapID(%0,%1) SetPVarInt(%0, "DynMapPlacingMapID", %1)

#define dynmap_GetTask(%0) GetPVarInt(%0, "DynMapTask")
#define dynmap_SetTask(%0,%1) SetPVarInt(%0, "DynMapTask", %1)

enum DynMap::e_Material {
  DynMapMaterial::index,
  DynMapMaterial::modelid,
  DynMapMaterial::txdname[64],
  DynMapMaterial::texturename[64],
  DynMapMaterial::color
}

enum DynMap::e_MaterialText {
  DynMapMatText::materialindex,
  DynMapMatText::text[256],
  DynMapMatText::materialsize,
  DynMapMatText::fontface[64],
  DynMapMatText::fontsize,
  DynMapMatText::bold,
  DynMapMatText::fontcolor,
  DynMapMatText::backcolor,
  DynMapMatText::alignment
}

enum DynMap::e_Object {
  DynMapObject::modelid,
  Float:DynMapObject::posX,
  Float:DynMapObject::posY,
  Float:DynMapObject::posZ,
  Float:DynMapObject::rotX,
  Float:DynMapObject::rotY,
  Float:DynMapObject::rotZ,
  List:DynMapObject::materials,
  List:DynMapObject::material_texts
}

stock DynMap::print_material(const mat[DynMap::e_Material]) {
  printf("=>");
  printf("index: %i", mat[DynMapMaterial::index]);
  printf("modelid: %i", mat[DynMapMaterial::modelid]);
  printf("txdname: %s", mat[DynMapMaterial::txdname]);
  printf("texturename: %s", mat[DynMapMaterial::texturename]);
  printf("color: %i", mat[DynMapMaterial::color]);
  return 1;
}

stock DynMap::print_materialtext(const mattext[DynMap::e_MaterialText]) {
  printf("###=>");
  printf("materialindex: %i",mattext[DynMapMatText::materialindex]);
  printf("text: %s",mattext[DynMapMatText::text]);
  printf("materialsize: %i", mattext[DynMapMatText::materialsize]);
  printf("fontface: %s",mattext[DynMapMatText::fontface]);
  printf("fontsize: %i",mattext[DynMapMatText::fontsize]);
  printf("bold: %i",mattext[DynMapMatText::bold]);
  printf("fontcolor: %i",mattext[DynMapMatText::fontcolor]);
  printf("backcolor: %i",mattext[DynMapMatText::backcolor]);
  printf("alignment: %i", mattext[DynMapMatText::alignment]);
  return 1; 
}

stock DynMap::print_object(const object[DynMap::e_Object]) {
  printf("Dynamic Map Object");
  printf("modelid: %i", object[DynMapObject::modelid]);
  printf("posX: %f", object[DynMapObject::posX]);
  printf("posY: %f", object[DynMapObject::posY]);
  printf("posZ: %f", object[DynMapObject::posZ]);
  printf("rotX: %f", object[DynMapObject::rotX]);
  printf("rotY: %f", object[DynMapObject::rotY]);
  printf("rotZ: %f", object[DynMapObject::rotZ]);
  for_list(mat : object[DynMapObject::materials]) {
    new l_Mat[DynMap::e_Material];
    iter_get_arr(mat, l_Mat);
    DynMap::print_material(l_Mat);
  }
  for_list(mattext : object[DynMapObject::material_texts]) {
    new l_matText[DynMap::e_MaterialText];
    iter_get_arr(mattext, l_matText);
    DynMap::print_materialtext(l_matText);
  }
  return 1; 
}

new Map:DynMap::prefabs;

enum DynMap::e_Spawned {
  DynMap::id,
  DynMap::mapName[64],
  DynMap::pivotObjectID,
  Float:DynMap::pivotPosX,
  Float:DynMap::pivotPosY,
  Float:DynMap::pivotPosZ,
  Float:DynMap::pivotRotX,
  Float:DynMap::pivotRotY,
  Float:DynMap::pivotRotZ,
  
  List:DynMap::objects
}

new List:DynMap::spawned;
