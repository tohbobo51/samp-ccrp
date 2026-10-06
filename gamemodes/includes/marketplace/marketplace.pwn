#include <pp-hooks>

hook OnPlayerEnterDynArea(playerid, areaid) {
    if(areaid == Marketplace::area) {
        EMIT_PlayerSystemChat(playerid, -1, "Kamu memasuki Area Marketplace");
    }
    return 0;
}

hook OnPlayerLeaveDynArea(playerid, areaid) {
    if(areaid == Marketplace::area) {
        EMIT_PlayerSystemChat(playerid, -1, "Kamu keluar dari Area Marketplace");
    }
    return 0;
}

public OnGameModeInit() { // can't use pp-hooks because of waiting for db connection handle
    Marketplace::LoadAll();
#if defined Shop_OnGameModeInit
    return Shop_OnGameModeInit();
#else
    return 1;
#endif
}
#if defined _ALS_OnGameModeInit
#undef OnGameModeInit
#else
#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit Shop_OnGameModeInit
#if defined Shop_OnGameModeInit
forward Shop_OnGameModeInit();
#endif

Marketplace::LoadAll() {
    Logger_Log("gamemodeinit", Logger_S("module", "marketplace"));
    Marketplace::area = CreateDynamicPolygon(Marketplace::zone);
    Marketplace::list = list_new();
    format(szQuery, sizeof(szQuery), "SELECT * FROM `shop`");
    mysql_tquery(MainConn, szQuery, "OnShopLoaded");
}

callback OnShopLoaded() {
    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields);
    Logger_Log("on shop loaded", Logger_S("module", "shop"), Logger_I("count", rows));
    if(rows > 0) {
        for(new i=0;i<rows;i++) {
            new l_marketplace[Marketplace::eInfo];
            DB::LoadCacheSchema(i, Marketplace::Schema, sizeof(Marketplace::Schema), l_marketplace);
            if(l_marketplace[Marketplace::with_actor]) {
                l_marketplace[Marketplace::actor_id] = CreateActor(l_marketplace[Marketplace::actor_skin],
                                                                   l_marketplace[Marketplace::pos][X],
                                                                   l_marketplace[Marketplace::pos][Y],
                                                                   l_marketplace[Marketplace::pos][Z],
                                                                   l_marketplace[Marketplace::facing]);
                SetActorInvulnerable(l_marketplace[Marketplace::actor_id], true);
                new str[128];
                format(str,sizeof(str), "%s", l_marketplace[Marketplace::actor_name]);
                CreateDynamic3DTextLabel(
                    str, -1, 
                    l_marketplace[Marketplace::pos][X],
                    l_marketplace[Marketplace::pos][Y],
                    l_marketplace[Marketplace::pos][Z] + 1.0, 10.0, .testlos=1);
            }
            Logger_Dbg("market", "loaded marketplace", Logger_S("name", l_marketplace[Marketplace::name]));
            list_add_arr(Marketplace::list, l_marketplace);
        }
    }
    
    return 1;
}

public OnGotRedisEvent(const eventName[], Node:data) {
  printf("[Market Redis Event] Event: %s",eventName);
#if defined MRKT_OnGotRedisEvent
  return MRKT_OnGotRedisEvent(eventName,data);
#else
  return 1;
#endif
}

#if defined _ALS_OnGotRedisEvent
#undef OnGotRedisEvent
#else
#define _ALS_OnGotRedisEvent
#endif
#define OnGotRedisEvent MRKT_OnGotRedisEvent
#if defined MRKT_OnGotRedisEvent
forward MRKT_OnGotRedisEvent(const eventName[], Node:data);
#endif

callback CEFOnMarketSellItem(playerid, arguments[]) {
    new l_itemId;
    new l_itemAmt;
    new l_sellPrice;
    Logger_Dbg("market", "got market sell item", Logger_S("args", arguments));
    if(sscanf(arguments, "iii", 
              l_itemId,
              l_itemAmt,
              l_sellPrice
              )
    ) {
        Logger_Err("Malformed market:sell_item", Logger_S("args", arguments));
        return 0;
    }
    new l_slot = CharacterInv::GetSlotFromID(playerid, l_itemId);
    if(l_slot == -1) {
        Logger_Err("invalid slot", Logger_S("module", "market"), Logger_I("playerid", playerid), Logger_I("slot", l_slot));
        EMIT_PlayerSystemChat(playerid, -1, "MARKET: Selling failed. (1)");
        return 0;
    }
    if(TakePlayerItem(playerid, l_slot, l_itemAmt) == -1) {
        EMIT_PlayerSystemChat(playerid, -1, "MARKET: Selling failed. (2)");
        return 0;
    }
    Character::GiveCash(playerid, l_sellPrice * l_itemAmt);
    new Node:node = JsonObject();
    JsonSetBool(node,"success", true);
    new l_str[512];
    JsonStringify(node,l_str);
    cef_emit_event(playerid, "market:sell_response", CEFSTR(l_str));
    return 1;
}

callback CEFOnMarketBuyItem(playerid, arguments[]) {
    new l_itemId;
    new l_itemAmt;
    new l_buyPrice;
    Logger_Dbg("market", "got market buy item", Logger_S("args", arguments));
    if(sscanf(arguments, "iii", 
              l_itemId,
              l_itemAmt,
              l_buyPrice
              )
    ) {
        Logger_Err("Malformed market:buy_item", Logger_S("args", arguments));
        return 0;
    }
    new l_totalPrice = l_itemAmt * l_buyPrice;
    if(CharacterData[playerid][p_cash] < l_totalPrice) {
        EMIT_PlayerSystemChat(playerid, -1, "MARKET: Uangmu tidak mencukupi.");
        return 0;
    }

    // new l_itemDef[eItemDef];
    // GetItemDefinition(l_itemId, l_itemDef);
    
    
    new l_item[Inv::eItem];
    l_item[Item::id] = l_itemId;
    l_item[Item::amount] = l_itemAmt;
    l_item[Item::durability] = 0;
    l_item[Item::power] = 0;

    if(l_itemId == ITEM_TOOLS_CHAINSAW || l_itemId == ITEM_TOOLS_SLEDGEHAMMER) {
        l_item[Item::durability] = 1000;
        l_item[Item::power] = 10;
    }
    
    l_item[Item::addon1] = 0;
    l_item[Item::addon2] = 0;
    l_item[Item::addon3] = 0;
    if(GivePlayerItem(playerid, l_item, false) == -1) {
        EMIT_PlayerSystemChat(playerid, -1, "MARKET: Buying failed. (2)");
        return 0;
    }
    Character::TakeCash(playerid, l_totalPrice);
    new Node:node = JsonObject();
    JsonSetBool(node,"success", true);
    new l_str[512];
    JsonStringify(node,l_str);
    cef_emit_event(playerid, "market:buy_response", CEFSTR(l_str));
    return 1;
}

CMD:marketplace(playerid, params[]) {
    new Float:p_Pos[3];
    GetPlayerPos(playerid, VEC3_UNWRAP(p_Pos));
    if(IsPointInDynamicArea(Marketplace::area, VEC3_UNWRAP(p_Pos))) {
        cef_emit_event(playerid, "chat:closeinput");
        EMIT_PlayerSystemChat(playerid, -1, "You're in marketplace");
        GUI_Emit_InventoryItems(playerid);
        Marketplace::Show(playerid, 1);
    } else {
        EMIT_PlayerSystemChat(playerid, -1, "You're not in marketplace");
    }
    return 1;
}

Marketplace::Show(playerid, marketid) {
    new Node:node = JsonObject();
    JsonSetInt(node,"id", marketid);
    new l_str[512];
    JsonStringify(node,l_str);
    cef_emit_event(playerid, "market:show", CEFSTR(l_str));
}
