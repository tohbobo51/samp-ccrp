
public OnGotRedisEvent(const eventName[], Node:data) {
    printf("[ADMIN REDIS HANDLER] Event: %s",eventName);
    if(strcmp(eventName, "get_all_players") == 0) { 
        
        new Node:redis_event = JsonObject();
        JsonSetString(redis_event, "event", sprintf("OnGetAllPlayers"));
        new Node:payload = JsonObject();
        new Node:node_items_arr;
        JsonToggleGC(node_items_arr, false);
        for(new i=0;i<MAX_PLAYERS;i++) {
            if(!IsPlayerConnected(i)) continue;
            new Node:l_itemList= JsonObject();
            JsonSetInt(l_itemList, "pid", i );
            JsonSetInt(l_itemList, "cid", CharacterInfo[i][CharacterInfo::id]);
            if(i == 0) {
                node_items_arr = JsonArray(l_itemList);
            } else {
                node_items_arr = JsonAppend(node_items_arr, JsonArray(l_itemList));
            } 
        }
        JsonToggleGC(node_items_arr,true);
        
        JsonSetObject(redis_event, "data", node_items_arr);
        szRedisEvent[0] = 0;
        JsonStringify(redis_event,szRedisEvent);
        Redis_Publish(redisClientPubSub, "frm.pwn", szRedisEvent);
        return 1; 
    }
#if defined ADM_OnGotRedisEvent
    return ADM_OnGotRedisEvent(eventName,data);
#else
    return 1;
#endif
}

#if defined _ALS_OnGotRedisEvent
#undef OnGotRedisEvent
#else
#define _ALS_OnGotRedisEvent
#endif
#define OnGotRedisEvent ADM_OnGotRedisEvent
#if defined ADM_OnGotRedisEvent
forward ADM_OnGotRedisEvent(const eventName[], Node:data);
#endif


callback CEFOnGetPlayerlist(player_id, const arguments[]) {
    // new l_page;
    // if(sscanf(arguments, "i", l_page)) {
    //     printf("[ERROR] Malfored Events admin:get_player_list\n => %s", arguments);
    //     return -1;
    // }
    //
    // new l_getCount = 0;
    // new l_skip = (l_page - 1) *30;
    // new l_skipCount = 0; 
    // foreach(new i : Player)
    // {
    //     if(!IsPlayerConnected(i)) continue;
    //     if(l_skipCount < l_skip) {
    //         l_skipCount++;
    //         continue;
    //     }
    // }
    return 1;
    
}
