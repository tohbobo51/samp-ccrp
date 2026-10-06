#define Inv:: Inv_
#define Item:: Item_
#define Slot:: inv_slot_
#define ItemDef:: Itemdef_
#define CharacterInv:: cInv_
#define DropItem:: invDI_
#define MAX_ITEMS_NAME 64

#define DROP_ITEM_MODELID 327
#define DROP_ITEM_EXPIREDTIME 60*3 // 3 Minutes in Seconds
// #define DROP_ITEM_EXPIREDTIME 10*3 // 30 detik

new bool:Feat_ItemInitialized = false;
new Feat_ItemLoaded = 0;

// NOTE: This item ID should match from the API (Yaaruu)
#define ITEM_TOOLS_CHAINSAW 2 
#define ITEM_TOOLS_PICKAXE 3
#define ITEM_TOOLS_FISHINGROD 4
#define ITEM_TOOLS_SLEDGEHAMMER 5
#define ITEM_TOOLS_PHONE 6
#define ITEM_TOOLS_WALKIETALKIE 7

#define ITEM_RES_WOOD_LOG 21

#define ITEM_RES_GOLD_ORE 31
#define ITEM_RES_SILVER_ORE 33
#define ITEM_RES_COPPER_ORE 35
#define ITEM_RES_IRON_ORE 37
#define ITEM_RES_COAL 39
#define ITEM_RES_SULPHUR 40

#define ITEM_BLUEPRINT_SAWMILL 71

#define ITEM_KEY_VEHICLE_MASTER 200
#define ITEM_KEY_VEHICLE_SLAVE 201
#define ITEM_KEY_HOUSE_MASTER 202
#define ITEM_KEY_HOUSE_SLAVE 203

#define ITEM_WEAPON_NIGHTSTICK 301
#define ITEM_WEAPON_BASEBALLBAT 302
#define ITEM_WEAPON_SHOVEL 303
#define ITEM_WEAPON_COLT45 304
#define ITEM_WEAPON_DE 305
#define ITEM_WEAPON_SHOTGUN 306
#define ITEM_WEAPON_SAWNOFF 307
#define ITEM_WEAPON_SPAS 308
#define ITEM_WEAPON_UZI 309
#define ITEM_WEAPON_MP5 310
#define ITEM_WEAPON_AK47 311
#define ITEM_WEAPON_M4 312
#define ITEM_WEAPON_TEC9 313
#define ITEM_WEAPON_RIFLE 314
#define ITEM_WEAPON_SPRAYCAN 315
#define ITEM_WEAPON_FIREEXTINGUISHER 316
#define ITEM_WEAPON_CAMERA 317
#define ITEM_WEAPON_PARACHUTE 318
#define ITEM_WEAPON_TAZER 320

#define ITEM_AMMO_9MM 351
#define ITEM_AMMO_556MM 352
#define ITEM_AMMO_762MM 353
#define ITEM_AMMO_45ACP 354
#define ITEM_AMMO_SGSHELL 355
#define ITEM_AMMO_BATTERY 356

#define MODELS_TOOLS_CHAINSAW 341
#define MODELS_TOOLS_SLEDGEHAMMER 19631
#define MODELS_TOOLS_FISHINGROD 18632

forward Task:LoadPlayerInventory(playerid);

enum eItemDef {
    ItemDef::id,
    ItemDef::name[MAX_ITEMS_NAME],
    ItemDef::cat[MAX_ITEMS_NAME],
    bool:ItemDef::usable,
    ItemDef::weight,
    ItemDef::max_amount,
    ItemDef::plant_time,
};

new Map:map_itemDef;

// INVENTORY
#define MAX_PLAYERS_ITEM_SLOT 10

enum Inv::eItem {
  Item::id,
  Item::amount,
  Item::durability,
  Item::power,
  Item::addon1,
  Item::addon2,
  Item::addon3
};

enum Inv::SlotData {
    Slot::enabled,
    item_tag:Slot::item[Inv::eItem]
};

// new PlayerInventory[MAX_PLAYERS][MAX_PLAYERS_ITEM_SLOT][Inv::eItem];
new PlayerMaximumWeight[MAX_PLAYERS];
new PlayerInventoryWeight[MAX_PLAYERS];

new List:PlayerInventoryList[MAX_PLAYERS];

new DropItem::counter = 0;
enum DropItem::e_DroppedItem {
    DropItem::id,
    DropItem::index,
    bool:DropItem::valid,
    DropItem::item_id,
    DropItem::item_amount,
    DropItem::durability,
    DropItem::power,
    DropItem::addon1,
    DropItem::addon2,
    DropItem::addon3,

    DropItem::time_elapsed,
    Float:DropItem::posX,
    Float:DropItem::posY,
    Float:DropItem::posZ,
    DropItem::pickupId,
    Text3D:DropItem::textId
};

new List:DropItem::list_dropped;
new Task:task_req_item_def;

enum cInv_eInfo {
    CharacterInv::id,
    CharacterInv::list_idx,
    CharacterInv::char_id,
    CharacterInv::item[Inv::eItem],
    CharacterInv::isDirty
};

new CharacterInv::Schema[][DB::Column] = {
    {"id", DBColumnType::PK, _:CharacterInv::id},
    {"characterId", DBColumnType::INT, _:CharacterInv::char_id},
    {"item_id", DBColumnType::INT, _:CharacterInv::item + _:Item::id},
    {"item_amt", DBColumnType::INT, _:CharacterInv::item + _:Item::amount},
    {"durability", DBColumnType::INT, _:CharacterInv::item + _:Item::durability},
    {"power", DBColumnType::INT, _:CharacterInv::item + _:Item::power},
    {"addon1", DBColumnType::INT, _:CharacterInv::item + _:Item::addon1},
    {"addon2", DBColumnType::INT, _:CharacterInv::item + _:Item::addon2},
    {"addon3", DBColumnType::INT, _:CharacterInv::item + _:Item::addon3}
};
