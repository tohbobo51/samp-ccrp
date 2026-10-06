JobLumber::InitializeSawmill() {
    new Float:cPos[3];
    cPos[X] = -2003.1200;
    cPos[Y] = -2409.6548;
    cPos[Z] = 30.6250; 
    CraftingStation::Create(CraftingStation::SAWMILL, cPos, "PUBLIC SAWMILL", .p_static=true);
    // Sawmill::CreatePublic(1, cPos);
    cPos[0] = -2017.0220;
    cPos[1] = -2396.2661;
    cPos[2] = 30.6250; 
    CraftingStation::Create(CraftingStation::SAWMILL, cPos, "PUBLIC SAWMILL", .p_static=true);
    // Sawmill::CreatePublic(2, cPos);
    cPos[0] = -2031.1630;
    cPos[1] = -2382.5835;
    cPos[2] = 30.6250; 
    CraftingStation::Create(CraftingStation::SAWMILL, cPos, "PUBLIC SAWMILL", .p_static=true);
    // Sawmill::CreatePublic(3, cPos);
    return 1; 
}

