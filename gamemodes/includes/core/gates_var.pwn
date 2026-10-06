#define Gates:: gts_
#define Gate:: gate_
#define GateType:: t_gate_
#define GateAccess:: at_gate_


#define gts_IsCreatingGate(%0) GetPVarInt(%0,"gts_IsCreatingGate")
#define gts_SetCreatingGate(%0,%1) SetPVarInt(%0, "gts_IsCreatingGate", %1)
#define gts_EditMode(%0) GetPVarInt(%0, "gts_EditMode")
#define gts_SetEditMode(%0,%1)  SetPVarInt(%0, "gts_EditMode", %1)
#define gts_IsPlacingObject(%0) GetPVarInt(%0, "gts_IsPlacingObject")
#define gts_SetPlacingObject(%0,%1) SetPVarInt(%0, "gts_IsPlacingObject", %1)
#define gts_PlacingObjectID(%0) GetPVarInt(%0, "gts_PlacingObjectID")
#define gts_SetPlacingObjectID(%0,%1) SetPVarInt(%0, "gts_PlacingObjectID", %1)
#define gts_SetTask(%0,%1) SetPVarInt(%0, "gts_Task", %1)
#define gts_GetTask(%0) GetPVarInt(%0, "gts_Task")
#define gts_ListID(%0) GetPVarInt(%0, "gts_ListID")
#define gts_SetListID(%0,%1) SetPVarInt(%0, "gts_ListID", %1)

#define gts_SetID(%0,%1) SetPVarInt(%0, "gts_inGate", %1)
#define gts_GetID(%0) GetPVarInt(%0, "gts_inGate")


enum gate_Type {
    GateType::NONE,
    GateType::FACTION,
};

enum gate_AccessType {
    GateAccess::RADIUS,
    GateAccess::KEY,
    GateAccess::PANEL,
};

new Gates::TypeStr[Gate::Type][] ={
    "NONE",
    "FACTION"
};

new Gates::AccessTypeStr[Gate::AccessType][] ={
    "RADIUS",
    "KEY",
    "PANEL"
};


enum (<<= 1)
{
    Gate::Open = 1,
    Gate::Locked,
};


enum gts_GateInfo {
    Gate::id,
    Gate::status_flag,
    Gate::Type:Gate::type,
    Gate::ref_id,
    Gate::AccessType:Gate::access_type,
    Gate::model_id,
    Gate::obj_id,
    Gate::area_id,
    Float:Gate::radius,
    Gate::world,
    Gate::int,
    Float:Gate::speed,
    Float:Gate::base_pos[3],
    Float:Gate::base_rot[3],
    Float:Gate::move_pos[3],
    Float:Gate::move_rot[3],
};

new Gates::Schema[][DB::Column] = {
    {"id", DBColumnType::PK, Gate::id},
    {"status_flag", DBColumnType::INT, Gate::status_flag},
    {"type", DBColumnType::INT, Gate::type},
    {"ref_id", DBColumnType::INT, Gate::ref_id},
    {"access_type", DBColumnType::INT, Gate::access_type},
    {"model_id", DBColumnType::INT, Gate::model_id},
    {"radius", DBColumnType::FLOAT, Gate::radius},
    {"world", DBColumnType::INT, Gate::world},
    {"interior", DBColumnType::INT, Gate::int},
    {"speed", DBColumnType::FLOAT, Gate::speed},
    {"base_pos", DBColumnType::VEC3, Gate::base_pos},
    {"base_rot", DBColumnType::VEC3, Gate::base_rot},
    {"move_pos", DBColumnType::VEC3, Gate::move_pos},
    {"move_rot", DBColumnType::VEC3, Gate::move_rot}
};

new Gates::last_id = 0;
new Map:Gates::list;

