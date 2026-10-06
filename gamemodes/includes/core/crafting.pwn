
public OnGameModeInit() { // can't use pp-hooks because of http request
    printf("[CraftingStation] Gamemode Init");
    Crafting::LoadCraftingDefinition();

    Crafting::LoadAllStation();
    JobLumber::InitializeSawmill();
    JobMiner::InitializeSmelter();

    // Initalize Other
    // AddPlayerClass(23,333.5238,1119.5419,1083.8903,23.5691,0,0,0,0,0,0); // crafting joint
    new Float:cPos[3];
    cPos[X] = 333.5238;
    cPos[Y] = 1119.5419;
    cPos[Z] = 1083.8903;
    new cInt = 5;

    CraftingStation::Create(CraftingStation::CRACKDEN, cPos, "Crack Den", .p_static=true, .p_int=cInt);
    printf("[CRAFTING STATION] Total Crafting Station: %i", list_size(CraftingStation::list));

#if defined FeatCrft_OnGameModeInit
    return FeatCrft_OnGameModeInit();
#else
    return 1;
#endif
}
#if defined _ALS_OnGameModeInit
#undef OnGameModeInit
#else
#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit FeatCrft_OnGameModeInit
#if defined FeatCrft_OnGameModeInit
forward FeatCrft_OnGameModeInit();
#endif


Crafting::LoadCraftingDefinition() {
  RequestJSON(
    httpClient,
    "crafting-stations",
    HTTP_METHOD_GET,
    "OnGotCraftingDefinition",
    .headers = RequestHeaders()
  ); 
}


callback OnCraftItem(playerid, arguments[]) {
    new l_recipeId;
    if(sscanf(arguments, "i", l_recipeId)) {
        printf("[ERROR] OnCraftItem Argument mismatch.");
        return 1;
    }
    if(Crafting::IsUsingStation(playerid)) {
        CraftingStation::OnCraftItem(playerid, l_recipeId);
    }
    // if(Sawmill::IsUsingSawmill(playerid)) {
    //     Sawmill::OnCraftItem(playerid, l_recipeId);
    //     return 1;
    // }
    // if(Smelter::IsUsingSmelter(playerid)) {
    //     Smelter::OnCraftItem(playerid, l_recipeId);
    // }
    return 1;
}

forward OnGotCraftingDefinition(Request:id, E_HTTP_STATUS:status, Node:node);
public OnGotCraftingDefinition(Request:id, E_HTTP_STATUS:status, Node:node) {

  printf("[CRAFTING] Loading Crafting Stations");
  new ret;
  new Node:items;
  new itemLength;
 
  ret = JsonGetArray(node, "items", items);
  if(ret) {
    printf("Failed to get crafting station list list %d", ret);
    return 1;
  }
  ret = JsonArrayLength(items, itemLength);
  if(ret){ 
    printf("Failed to get array length: %d", ret);
    return 1;
  }
  
  if(itemLength > 0) {
    Crafting::stations = map_new();  
  }

  for(new i=0;i<itemLength;i++) {
    printf("[CRAFTING] Loading Station index %i",i);
    new Node:item;
    new l_craftingStation[Crafting::e_Station];

    ret = JsonArrayObject(items,i,item);
    if(ret) {
      printf("Error parsing data line crafing.pwn:62");
      return 1;
    }
    
    ret = JsonGetInt(item, "id", l_craftingStation[CraftingStation::id]);
    if(ret) {
      printf("Error get array length crafting.pwn:68");
      return 1; 
    }

    new nameStr[MAX_ITEMS_NAME];
    ret = JsonGetString(item, "name", nameStr);
    if(ret) {
      printf("Error crafting.pwn:75");
      return 1;
    }
    memcpy(l_craftingStation[CraftingStation::name], nameStr,0,MAX_ITEMS_NAME,MAX_ITEMS_NAME);

    new Node:recipes;
    new recipesLen;
    ret = JsonGetArray(item,"recipes", recipes);
    if(ret) {
      printf("Error crafting.pwn:84");
      return 1;
    }
    ret = JsonArrayLength(recipes, recipesLen);
    if(recipesLen > 0) {
      l_craftingStation[CraftingStation::recipes] = map_new();
      
      for(new ri=0;ri<recipesLen;ri++) {
        printf("Loading Station Recipe station %i recipe %i", i, ri);
        new Node:recipe;
        new l_crafting_recipe[Crafting::e_Recipe];
        ret = JsonArrayObject(recipes, ri, recipe);
        if(ret) {
          printf("Error crafting.pwn:96");
          return 1;
        }

        ret = JsonGetInt(recipe, "id", l_crafting_recipe[CraftingRecipe::id]);
        if(ret) {
          printf("Error crafting.pwn:102");
          return 1;
        }

        l_crafting_recipe[CraftingRecipe::stationId] = l_craftingStation[CraftingStation::id];

        ret = JsonGetString(recipe, "name", nameStr);
        if(ret) {
          printf("Error craftign.pwn:110");
          return 1;
        }
        memcpy(l_crafting_recipe[CraftingRecipe::name], nameStr, 0, MAX_ITEMS_NAME,MAX_ITEMS_NAME);

        new Node:inputArr;
        new inputArrLen;
        ret = JsonGetArray(recipe,"input", inputArr);
        if(ret) {
          printf("Error crafting.pwn:119");
          return 1;
        }
        ret = JsonArrayLength(inputArr,inputArrLen);
        if(ret) {
          printf("Error crafting.pwn:124");
          return 1;
        }
        if(inputArrLen>0) {
          l_crafting_recipe[CraftingRecipe::input] = list_new();
        }
        for(new rii=0;rii<inputArrLen;rii++) {
          printf("[CRAFTING] Load station %i recipe %i input index %i", i, ri, rii);
          new Node:inputItemNode;
          new l_inputItem[Crafting::e_Item];

          ret = JsonArrayObject(inputArr, rii, inputItemNode);
          if(ret) {
            printf("Error crafting.pwn:136");
            return 1;
          }
          
          ret = JsonGetInt(inputItemNode,"id", l_inputItem[CraftingItem::id]);
          if(ret) {
            printf("Error crafting.pwn:142");
            return 1;
          }
          ret = JsonGetInt(inputItemNode,"amt", l_inputItem[CraftingItem::amt]);

          list_add_arr(l_crafting_recipe[CraftingRecipe::input], l_inputItem);
        }

        new Node:outputArr;
        new outputArrLen;
        ret = JsonGetArray(recipe,"output", outputArr);
        if(ret) {
          printf("Error crafting.pwn:154");
          return 1;
        }
        ret = JsonArrayLength(outputArr,outputArrLen);
        if(ret) {
          printf("Error crafting.pwn:159");
          return 1;
        }
        if(outputArrLen>0) {
          l_crafting_recipe[CraftingRecipe::output] = list_new();
        }
        for(new roi=0;roi<outputArrLen;roi++) {
          printf("[CRAFTING] Load station %i recipe %i output %i", i,ri,roi);
          new Node:outputItemNode;
          new l_outputItem[Crafting::e_Item];

          ret = JsonArrayObject(outputArr, roi, outputItemNode);
          if(ret) {
            printf("Error crafting.pwn:171");
            return 1;
          }
          
          ret = JsonGetInt(outputItemNode,"id", l_outputItem[CraftingItem::id]);
          if(ret) {
            printf("Error crafting.pwn:177");
            return 1;
          }
          ret = JsonGetInt(outputItemNode,"amt", l_outputItem[CraftingItem::amt]);

          list_add_arr(l_crafting_recipe[CraftingRecipe::output], l_outputItem);
        }
        

        ret = JsonGetInt(recipe, "duration", l_crafting_recipe[CraftingRecipe::duration]);
        if(ret) {
          printf("Error crafting.pwn:188");
          return 1;
        }

        map_add_arr(l_craftingStation[CraftingStation::recipes], l_crafting_recipe[CraftingRecipe::id], l_crafting_recipe);

      }
      
      map_add_arr(Crafting::stations, l_craftingStation[CraftingStation::id],l_craftingStation);
    }
  } 

  printf("[CraftingStation] %i Crafting Station Loaded", itemLength);

  // for_map(i : Crafting::stations) {
  //   new l_station[Crafting::e_Station];
  //   iter_get_arr(i, l_station);
  //   Crafting::PrintStation(l_station);
  // }

  return 1;
}


