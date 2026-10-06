#define LSPD:: lspd_
#define LSPDLocker:: lspd_lckr_
#define LSPDVeh:: lspd_veh_
#define LSPDLockerItem:: lspd_lckr_i_
#define LSPDUniform:: lspd_uf_
#define LSPDTicket:: lspd_tkt_
#define LSPDSuspect:: lspd_sus_

#define lspd_IsOnDuty(%0) GetPVarInt(%0,"lspd_OnDuty")
#define lspd_SetOnDuty(%0,%1) SetPVarInt(%0,"lspd_OnDuty",%1)

enum eLSPDLevel {
    LSPD::Cadet,
    LSPD::Officer,
    LSPD::Sergeant,
    LSPD::Liutenant,
    LSPD::Captain,
    LSPD::Chief,
    LSPD::MaxLevel
};

new LSPD::Title[LSPD::MaxLevel][Faction::MAX_NAME] = {
    "Cadet",
    "Officer",
    "Sergeant",
    "Liutenant",
    "Captain",
    "Chief"
};

new Float:LSPD::JailLocation[3] = {1528.8900,-1678.2170,5.8906};

enum eLSPDUniformData {
    LSPDUniform::name[56],
    LSPDUniform::skin_id
};
new LSPD::Uniform[][eLSPDUniformData] = {
    {"Outfit 1", 280},
    {"S.W.A.T", 285}
};

new Float:LSPD::locker_position[3] = {254.2935,76.9463,1003.6406};
// enum eLSPDLockerData {
//     LSPDLocker::id,
//     LSPDLocker::pos[3],
//     LSPDLocker::area_id
// };
//
//
// new List:LSPD::LockerItems;
// enum eLSPDLockerItem {
//     LSPDLockerItem::id,
//     LSPDLockerItem::list_idx,
//     LSPDLockerItem::item[Inv::eItem]
// };
//
// new LSPD::LastLockerID = 0;
//
// new LSPDLocker::Schema[][DB::Column] = {
//     {"id", DBColumnType::PK,  _:LSPDLockerItem::id},
//     {"item_id", DBColumnType::INT, _:LSPDLockerItem::item + _:Item::id},
//     {"amount", DBColumnType::INT, _:LSPDLockerItem::item + _:Item::amount},
//     {"durability", DBColumnType::INT, _:LSPDLockerItem::item + _:Item::durability},
//     {"power", DBColumnType::INT, _:LSPDLockerItem::item + _:Item::power},
//     {"addon1", DBColumnType::INT, _:LSPDLockerItem::item + _:Item::addon1},
//     {"addon2", DBColumnType::INT, _:LSPDLockerItem::item + _:Item::addon2},
//     {"addon3", DBColumnType::INT, _:LSPDLockerItem::item + _:Item::addon3}
// };
//
enum eLSPDTicket {
    LSPDTicket::id,
    LSPDTicket::issued_to,
    LSPDTicket::issued_by,
    LSPDTicket::amount,
    LSPDTicket::reason[254]
};

new LSPDTicket::Schema[][DB::Column] = {
    {"id", DBColumnType::PK, LSPDTicket::id},
    {"issued_to", DBColumnType::INT, LSPDTicket::issued_to},
    {"issued_by", DBColumnType::INT, LSPDTicket::issued_by},
    {"amount", DBColumnType::INT, LSPDTicket::amount},
    {"reason", DBColumnType::STRING, LSPDTicket::reason, 254}
};

enum eLSPDSuspect {
    LSPDSuspect::id,
    LSPDSuspect::character_id,
    LSPDSuspect::issued_by,
    LSPDSuspect::crime[254]
};

new LSPDSuspect::Schema[][DB::Column] = {
    {"id", DBColumnType::PK, LSPDSuspect::id},
    {"character_Id", DBColumnType::INT, LSPDSuspect::character_id},
    {"issued_by", DBColumnType::INT, LSPDSuspect::issued_by},
    {"crime", DBColumnType::STRING, LSPDSuspect::crime, 245}
};
