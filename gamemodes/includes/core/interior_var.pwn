#define InteriorData:: intrr_dt_
#define Interior:: intrr_
#define Portal:: prtl_

#define intrr_GetID(%0) GetPVarInt(%0, "inInterior")
#define intrr_SetID(%0,%1) SetPVarInt(%0, "inInterior", %1)

enum Portal::e_Portal {
    Portal::id,
    Portal::name[64],
    Float:Portal::pos[3],
    Portal::vw,
    Portal::int,
    Float:Portal::target_pos[3],
    Float:Portal::target_facing_angle,
    Portal::target_vw,
    Portal::target_int,
    Portal::areaId,
    Portal::pickupId,
    Text3D:Portal::text3d,
    Portal::pickupModel,
}

enum InteriorData::e_Data {
    Map:InteriorData::portals, 
}

enum {
    Interior::FleecaBank,
    Interior::SANews,
    Interior::LSPD,
    Interior::GOV,
    Interior::EMS,
    Interior::OTHER,
    Interior::MAX_INTERIOR
}

new Interior::data[Interior::MAX_INTERIOR][InteriorData::e_Data];

new List:Portal::list_portal;

