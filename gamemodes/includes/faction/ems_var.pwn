#define EMS:: ems_
#define EMSUniform:: ems_uf_

#define EMSHealRequest:: ems_hrq_

#define ems_IsOnDuty(%0) GetPVarInt(%0,"ems_OnDuty")
#define ems_SetOnDuty(%0,%1) SetPVarInt(%0,"ems_OnDuty",%1)
enum eEMSLevel {
    EMS::Trainee,
    EMS::EMT,
    EMS::Paramedic,
    EMS::Liutenant,
    EMS::Chief,
    EMS::MaxLevel
}

new EMS::Title[EMS::MaxLevel][Faction::MAX_NAME] = {
    "Trainee",
    "EMT",
    "Paramedic",
    "Liutenant",
    "Chief"
};

enum eEMSUniformData {
    EMSUniform::name[56],
    EMSUniform::skin_id
};

new EMS::Uniform[][eEMSUniformData] = {
    {"Trainee", 276},
    {"Medic 1", 275},
    {"Medic 2", 274},
    {"Doctor", 70}
};

enum eHealRequest {
    EMSHealRequest::issuer_id,
    EMSHealRequest::price
};

new Map:EMS::heal_request;


new Float:EMS::locker_position[3] = {1154.9333,-1305.6702,17.9123};
