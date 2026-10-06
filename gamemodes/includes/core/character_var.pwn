// Character Related
#define CHARACTER_LEVEL_MULT 50

#define Character:: SV_Char_
#define CharacterInfo:: cinfo_

#define SV_Char_IsHealthCheck(%0) GetPVarInt(%0, "CHAR_HealthCheck")
#define SV_Char_SetHealthCheck(%0,%1) SetPVarInt(%0, "CHAR_HealthCheck",%1)

#define SV_Char_IsUsingTools(%0) GetPVarInt(%0, "CHAR_UsingTools")
#define SV_Char_SetUsingTools(%0,%1) SetPVarInt(%0, "CHAR_UsingTools",%1)

#define SV_Char_GetToolsSlot(%0) GetPVarInt(%0, "Char_ToolSlot")
#define SV_Char_SetToolsSlot(%0,%1) SetPVarInt(%0, "Char_ToolSlot",%1)

// #define SV_Char_Cuffed(%0) GetPVarInt(%0, "Char_Cuffed")
// #define SV_Char_SetCuffed(%0,%1) SetPVarInt(%0, "Char_Cuffed",%1)
//
#define SV_Char_Tazed(%0) GetPVarInt(%0, "Char_Tazed")
#define SV_Char_SetTazed(%0,%1) SetPVarInt(%0, "Char_Tazed",%1)

#define SV_Char_Dragging(%0) GetPVarInt(%0, "Char_Dragging")
#define SV_Char_SetDragging(%0,%1) SetPVarInt(%0, "Char_Dragging",%1)

#define SV_Char_JointLeft(%0) GetPVarInt(%0, "Char_JointLeft")
#define SV_Char_SetJointLeft(%0,%1) SetPVarInt(%0, "Char_JointLeft",%1)

enum e_CharacterInfo { 
    ORM:CharacterInfo::ORM_ID,
    CharacterInfo::id,
    CharacterInfo::firstName[10],
    CharacterInfo::lastName[10],
    bool:CharacterInfo::isEverSpawn,
    CharacterInfo::gender,
    CharacterInfo::accountId,
    CharacterInfo::dataId,
}
new CharacterInfo[MAX_PLAYERS][e_CharacterInfo];

enum e_CharacterData {
    ORM:ORM_ID,
    p_ID,
    p_level,
    p_cash,
    p_exp,
    p_playtime,

    Float:p_health,
    Float:p_armor,
    p_skinId, 

    // p_statStr,
    // p_statInt,
    p_hunger,
    p_stamina,

    bool:p_injured,
    p_injured_time,

    p_has_id,
    
    p_inv_weight,

    Float:p_posX,
    Float:p_posY,
    Float:p_posZ,
    Float:p_angle,
    p_interior,
    p_vw,
    p_sweeper_timer,
    p_driversbus_timer,

    eFaction:p_faction,
    p_faction_level,

    bool:p_jailed,
    p_jail_time,
    p_jail_type,
}
new CharacterData[MAX_PLAYERS][e_CharacterData];


enum attached_object_data
{
    Float:ao_x,
    Float:ao_y,
    Float:ao_z,
    Float:ao_rx,
    Float:ao_ry,
    Float:ao_rz,
    Float:ao_sx,
    Float:ao_sy,
    Float:ao_sz
}

new ao[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS][attached_object_data];

enum eCharDragging {
    bool:dragged,
    drag_timer,
    drag_time,
    drag_targetid
};

new DragInfo[MAX_PLAYERS][eCharDragging];

new AnimationLibraries[][] = 
{
    "AIRPORT", "Attractors", "BAR", "BASEBALL", "BD_FIRE", "BEACH", "benchpress", "BF_injection", "BIKED", "BIKEH", "BIKELEAP",
    "BIKES", "BIKEV", "BIKE_DBZ", "BLOWJOBZ", "BMX", "BOMBER", "BOX", "BSKTBALL", "BUDDY", "BUS", "CAMERA", "CAR", "CARRY", "CAR_CHAT",
    "CASINO", "CHAINSAW", "CHOPPA", "CLOTHES", "COACH", "COLT45", "COP_AMBIENT", "COP_DVBYZ", "CRACK", "CRIB", "DAM_JUMP", "DANCING",
    "DEALER", "DILDO", "DODGE", "DOZER", "DRIVEBYS", "FAT", "FIGHT_B", "FIGHT_C", "FIGHT_D", "FIGHT_E", "FINALE", "FINALE2", "FLAME",
    "Flowers", "FOOD", "Freeweights", "GANGS", "GHANDS", "GHETTO_DB", "goggles", "GRAFFITI", "GRAVEYARD", "GRENADE", "GYMNASIUM", "HAIRCUTS",
    "HEIST9", "INT_HOUSE", "INT_OFFICE", "INT_SHOP", "JST_BUISNESS", "KART", "KISSING", "KNIFE", "LAPDAN1", "LAPDAN2", "LAPDAN3", "LOWRIDER",
    "MD_CHASE", "MD_END", "MEDIC", "MISC", "MTB", "MUSCULAR", "NEVADA", "ON_LOOKERS", "OTB", "PARACHUTE", "PARK", "PAULNMAC", "ped", "PLAYER_DVBYS",
    "PLAYIDLES", "POLICE", "POOL", "POOR", "PYTHON", "QUAD", "QUAD_DBZ", "RAPPING", "RIFLE", "RIOT", "ROB_BANK", "ROCKET", "RUSTLER", "RYDER",
    "SCRATCHING", "SHAMAL", "SHOP", "SHOTGUN", "SILENCED", "SKATE", "SMOKING", "SNIPER", "SPRAYCAN", "STRIP", "SUNBATHE", "SWAT", "SWEET", "SWIM",
    "SWORD", "TANK", "TATTOOS", "TEC", "TRAIN", "TRUCK", "UZI", "VAN", "VENDING", "VORTEX", "WAYFARER", "WEAPONS", "WUZI", "SAMP"
};
