#define Building:: bldr_
#define BuildingData:: bldr_bldg_
#define BuildingType:: bldg_typ_
#define BuildMaterial:: bldg_bm_

#define bldr_IsPlacingBlueprint(%0) GetPVarInt(%0, "IsPlacingBlueprint")
#define bldr_SetIsPlacingBlueprint(%0,%1) SetPVarInt(%0, "IsPlacingBlueprint", %1)



enum Building::e_BuildingType {
  BuildingType::CRAFTING_STATION,
  BuildingType::HOUSE,
  BuildingType::BUSINESS
}

enum Building::e_BuildMaterial {
  BuildMaterial::id,
  BuildMaterial::amt 
}
  
enum Building::e_Building {
  BuildingData::id,
  BuildingData::ownerid,
  BuildingData::building_type,
  BuildingData::ref_id,
  BuildingData::dynmap_handle,
  bool:BuildingData::is_built,
  BuildingData::progress_count,
  BuildingData::progress_needed,
  List:BuildingData::build_material,

  BuildingData::pickupid,
  BuildingData::areaid,
  Text3D:BuildingData::textid
}

// new List:Building::buildings;


