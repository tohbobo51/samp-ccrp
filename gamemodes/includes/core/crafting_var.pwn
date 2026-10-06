#define Crafting:: crftng_
#define CraftingStation:: crftsttn_
#define CraftingRecipe:: crftrcp_
#define CraftingItem:: crftitm_
#define CraftingStorage:: crftstg_

#define crftng_SetStationID(%0,%1) SetPVarInt(%0, "CraftStationID", %1)
#define crftng_GetStationID(%0) GetPVarInt(%0, "CraftStationID")

#define crftng_SetUsingStation(%0,%1) SetPVarInt(%0, "CraftUsingStation", %1)
#define crftng_IsUsingStation(%0) GetPVarInt(%0, "CraftUsingStation")


enum Crafting::e_Station {
  CraftingStation::id,
  CraftingStation::name[MAX_ITEMS_NAME],
  Map:CraftingStation::recipes
}

enum Crafting::e_Recipe {
  CraftingRecipe::id,
  CraftingRecipe::stationId,
  CraftingRecipe::name[MAX_ITEMS_NAME],
  List:CraftingRecipe::input,
  List:CraftingRecipe::output,
  CraftingRecipe::duration
}

enum Crafting::e_Item {
  CraftingItem::id,
  CraftingItem::amt
}

new Map:Crafting::stations;

enum CraftingStation::TYPE {
    CraftingStation::SAWMILL = 1,
    CraftingStation::SMELTER = 2,
    CraftingStation::CRACKDEN = 3
};

enum CraftingStation::eInfo {
    CraftingStation::id,
    CraftingStation::name[56],
    CraftingStation::TYPE:CraftingStation::type,
    Float:CraftingStation::pos[3],
    bool:CraftingStation::used,
    CraftingStation::usedByPlayerId,
    CraftingStation::pickupId,
    Text3D:CraftingStation::textId,
    CraftingStation::areaId,

    CraftingStation::isCrafting,
    CraftingStation::craftingRecipe,
    CraftingStation::craftingTime,
    CraftingStation::craftingFinishTime,
    CraftingStation::isStatic,
    List:CraftingStation::storage,
};

new List:CraftingStation::list;

Crafting::PrintItem(const item[Crafting::e_Item]) {
  new l_itemDef[eItemDef];
  GetItemDefinition(item[CraftingItem::id], l_itemDef);
  printf("ItemName: %s\nItem Amount: %i\n", l_itemDef[ItemDef::name], item[CraftingItem::amt]);
  return 1;
}

Crafting::PrintRecipe(const recipe[Crafting::e_Recipe]) {
  printf("Recipes");
  printf("id: %i", recipe[CraftingRecipe::id]);
  printf("stationId: %i", recipe[CraftingRecipe::stationId]);
  printf("name: %s", recipe[CraftingRecipe::name]);
  printf("INPUT =>");
  for_list(i : recipe[CraftingRecipe::input]) {
    new l_item[Crafting::e_Item];
    iter_get_arr(i, l_item);
    Crafting::PrintItem(l_item);
  }
  print("OUTPUT =>");
  for_list(i : recipe[CraftingRecipe::output]) {
    new l_item[Crafting::e_Item];
    iter_get_arr(i, l_item);
    Crafting::PrintItem(l_item);
  }
  printf("duration: %i", recipe[CraftingRecipe::duration]);
  return 1;
}

stock Crafting::PrintStation(const station[Crafting::e_Station]) {
  printf("PRINT STATION");
  printf("id: %i", station[CraftingStation::id]);
  printf("name: %s", station[CraftingStation::name]);
  
  printf("RECIPES =>");
  for_map(i : station[CraftingStation::recipes]) {
    new l_recipe[Crafting::e_Recipe];
    iter_get_arr(i, l_recipe);
    Crafting::PrintRecipe(l_recipe);
  }

  return 1;
}
