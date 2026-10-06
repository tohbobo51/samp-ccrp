#define WeaponSystem:: sys_wep_
#define Weapon:: wep_
#define AmmoType:: wamt_

#define sys_wep_UsingTazer(%0) GetPVarInt(%0,"syswep_UsingTazer")
#define sys_wep_SetUsingTazer(%0,%1) SetPVarInt(%0,"syswep_UsingTazer",%1)

#define sys_wep_GetTazeTimer(%0) GetPVarInt(%0,"syswep_TazeTimer")
#define sys_wep_SetTazeTimer(%0,%1) SetPVarInt(%0,"syswep_TazeTimer",%1)

enum wep_AmmoType {
    AmmoType::NONE,
    AmmoType::9MM,
    AmmoType::556MM,
    AmmoType::762MM,
    AmmoType::45ACP,
    AmmoType::SGSHELL,
    AmmoType::BATTERY,
};

enum wep_Info {
    Weapon::id,
    bool:Weapon::valid,
    Weapon::name[56],
    Weapon::slot,
    Weapon::itemId,
    Weapon::model,
    Weapon::clip_size,
    Weapon::AmmoType:Weapon::ammo_type,
    Float:Weapon::base_dmg,
};

new Weapon::list[][Weapon::Info] = {
    {0, true, "Fist", 0, -1, 0, 0, AmmoType::NONE}, // 0
    {1, false, "Brass Knuckles", 0, -1, 0, 0, AmmoType::NONE}, // 1 
    {2, false, "Golf Club", 1, -1, 333, 0, AmmoType::NONE}, // 2
    {3, true, "Night Stick", 1, 301, 334, 0, AmmoType::NONE}, // 3
    {4, false, "Knife", 1, 335, 0, AmmoType::NONE}, // 4
    {5, true, "Baseball Bat", 1, 302, 336, 0, AmmoType::NONE}, // 5
    {6, true, "Shovel", 1, 303, 337, 0, AmmoType::NONE}, // 6
    {7, false, "Pool Cue", 1, -1, 338, 0, AmmoType::NONE}, // 7
    {8, false, "Katana", 1, -1, 339, 0, AmmoType::NONE}, // 8
    {9, false, "Chainsaw", 1, -1, 341, 0, AmmoType::NONE}, // 9
    {10, false, "DD1", 1, -1, 321, 0, AmmoType::NONE}, // 10
    {11, false, "DD2", 1, -1, 322, 0, AmmoType::NONE}, // 11
    {12, false, "DD3", 1, -1, 322, 0, AmmoType::NONE}, // 12
    {13, false, "DD4", 1, -1, 324, 0, AmmoType::NONE}, // 13
    {14, false, "Flowers", 1, -1, 325, 0, AmmoType::NONE}, // 14
    {15, false, "Cane", 1, -1, 326, 0, AmmoType::NONE}, // 15
    {16, false, "Grenade", 1, -1, 342, 0, AmmoType::NONE}, // 16
    {17, false, "Tear Gas", 1, -1, 343, 0, AmmoType::NONE}, // 17
    {18, false, "Molotov", 1, -1, 344, 0, AmmoType::NONE}, // 18
    {19, false, "Invalid 19", 1, -1}, // 19
    {20, false, "Invalid 20", 1, -1}, // 20
    {21, false, "Invalid 21", 1, -1}, // 21
    
    {22, true, "Colt 45", 2, 304, 346, 17, AmmoType::9MM, 30.0}, // 22
    {23, true, "Colt 45 Sp.", 2, 304, 347, 17, AmmoType::9MM, 30.0}, // 23
    {24, true, "Desert Eagle", 2, 305, 348, 7, AmmoType::45ACP, 90.0}, // 24
    {25, true, "Shotgun", 3, 306, 349, 1, AmmoType::SGSHELL, 70.0}, // 25
    {26, true, "Sawnoff Shotgun", 3, 307, 350, 2, AmmoType::SGSHELL, 75.0}, // 26
    {27, true, "SPAS", 3, 308, 351, 7, AmmoType::SGSHELL, 80.0}, // 27
    
    {28, true, "UZI", 4, 309, 352, 50, AmmoType::9MM, 12.0}, // 28
    {29, true, "MP5", 4, 310, 353, 30, AmmoType::9MM, 20.0}, // 29
    
    {30, true, "Ak-47", 5, 311, 355, 30, AmmoType::762MM, 50.0}, // 30
    {31, true, "M4", 5, 312, 356, 30, AmmoType::556MM, 40.0}, // 31
    
    {32, true, "Tec-9", 4, 313, 372, 30, AmmoType::9MM, 40.0}, // 32
    
    {33, true, "Rifle", 6, 314, 357, 1, AmmoType::762MM, 90.0}, // 33
    {34, true, "Rifle Scoped", 6, 314, 358, 1, AmmoType::762MM, 90.0}, // 34
    
    
    {35, false, "RPG", 7, 359}, // 35
    {36, false, "HS Missle", 7, 360}, // 36
    {37, false, "Flamethrower", 7, 361}, // 37
    {38, false, "Minigun"}, // 38
    {39, false, "Satchel"}, // 39
    {40, false, "Detonator"}, // 40
    {41, true, "Spraycan", 9, 315}, // 41
    {42, true, "Fire Extinguisher", 9, 316}, // 42
    {43, true, "Camera", 9, 317}, // 43
    {44, false, "Night Vision", 11}, // 44
    {45, false, "Thermal Googles", 11}, // 45
    {46, true, "Parachute", 11, 318} // 46
};

enum wep_UsingInfo {
    bool:Weapon::active,
    Weapon::id,
    Weapon::current_ammo,
    Weapon::ext,
};

new Weapon::player_use[MAX_PLAYERS][Weapon::UsingInfo];
