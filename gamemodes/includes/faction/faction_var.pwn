#define Faction:: fac_
#define FactionVehicle:: fac_v_
#define FactionLocker:: fac_lck_
#define FactionLockerItem:: fac_lcki_

#define fac_MAX_NAME 56

#define fac_FactionInvite(%0) GetPVarInt(%0,"fac_FactionInvite")
#define fac_SetFactionInvite(%0,%1) SetPVarInt(%0,"fac_FactionInvite",%1)

#define fac_FactionInviteID(%0) GetPVarInt(%0, "fac_FactionInviteID")
#define fac_SetFactionInviteID(%0,%1) SetPVarInt(%0, "fac_SetFactionInviteID",%1)

enum eFaction {
    Faction::NONE,
    Faction::GOV,
    Faction::LSPD,
    Faction::EMS,
    Faction::SANEWS,
    Faction::MAX_FACTION
}

new Faction::NAME[Faction::MAX_FACTION][Faction::MAX_NAME] = {
    "NONE",
    "Government",
    "LSPD",
    "EMS",
    "SA News"
};

forward SetupFaction();

new List:FactionLocker::LockerItems[Faction::MAX_FACTION];
enum eLockerItem {
    FactionLockerItem::id,
    FactionLockerItem::faction_id,
    FactionLockerItem::list_idx,
    FactionLockerItem::item[Inv::eItem]
};

new FactionLocker::Schema[][DB::Column] = {
    {"id", DBColumnType::PK,  _:FactionLockerItem::id},
    {"faction_id", DBColumnType::INT, _:FactionLockerItem::faction_id},
    {"item_id", DBColumnType::INT, _:FactionLockerItem::item + _:Item::id},
    {"amount", DBColumnType::INT, _:FactionLockerItem::item + _:Item::amount},
    {"durability", DBColumnType::INT, _:FactionLockerItem::item + _:Item::durability},
    {"power", DBColumnType::INT, _:FactionLockerItem::item + _:Item::power},
    {"addon1", DBColumnType::INT, _:FactionLockerItem::item + _:Item::addon1},
    {"addon2", DBColumnType::INT, _:FactionLockerItem::item + _:Item::addon2},
    {"addon3", DBColumnType::INT, _:FactionLockerItem::item + _:Item::addon3}
};
