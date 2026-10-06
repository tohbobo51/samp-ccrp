#define JailSystem:: sys_jail_
#define Jail:: jail_

#define JailVW 200

forward JailSystemTick();

enum sys_jail_e_Type {
    Jail::NONE,
    Jail::POLICE,
    Jail::ADMIN,
    Jail::MAX_TYPE
};

enum sys_jail_s_Coords {
    Float:Jail::pos[3],
    Float:Jail::facing,
    Jail::int
};

new JailSystem::JailPos[Jail::MAX_TYPE][JailSystem::s_Coords] = {
    {{0.0,0.0,0.0},0.0,0}, // NONE
    {{264.0060,77.7701,1001.0391},273.4076,6}, // Police Jail
    {{0.0,0.0,0.0},0.0,0} // Admin Jail
};

new JailSystem::AfterJailPos[Jail::MAX_TYPE][JailSystem::s_Coords] = {
    {{0.0,0.0,0.0},0.0,0}, // NONE
    {{268.3687,78.3123,1001.0391},0.4919,6}, // Police Jail
    {{0.0,0.0,0.0},0.0,0} // Admin Jail
};

new JailSystem::tick_timer;

new List:JailSystem::jailed_players;


