JobMiner::InitializeSmelter() {
    new Float:cPos[3];
    cPos[0] = 682.7009;
    cPos[1] = 849.9801;
    cPos[2] = -42.9609; 
    CraftingStation::Create(CraftingStation::SMELTER, cPos, "PUBLIC SMELTER", .p_static=true);
    cPos[0] = 671.8804;
    cPos[1] = 829.4937;
    cPos[2] = -42.9609; 
    CraftingStation::Create(CraftingStation::SMELTER, cPos, "PUBLIC SMELTER", .p_static=true);
    return 1; 
}

