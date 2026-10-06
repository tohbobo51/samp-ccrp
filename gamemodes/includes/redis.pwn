new szRedisEvent[4096];
new redisHost[128], redisPortStr[64], redisPort;

g_redis_Init() {
    if(!Env_Has("REDIS_HOST") ||
        !Env_Has("REDIS_PORT")
    ) {
        printf("NO Redis ENV FOUND");
        SendRconCommand("exit");
    }
    Env_Get("REDIS_HOST", redisHost);
    Env_Get("REDIS_PORT", redisPortStr);
    printf("%s\n", redisHost);
    redisPort = strval(redisPortStr);
    new redRet = Redis_Connect(redisHost, redisPort, "", redisClient);
    if(redRet == 0) {
        Redis_Connect(redisHost, redisPort, "", redisClientPubSub);
        printf("[Redis] Redis connected", redRet);
        new rpcAPIRet = Redis_Subscribe(redisHost, redisPort, "", "to.pwn", "RedCB_apiPubSub", apiPubSub);
        if(rpcAPIRet == 0) {
            new Node:redis_event = JsonObject();
            JsonSetString(redis_event, "event", sprintf("gamemode_start"));
            szRedisEvent[0] = 0;
            JsonStringify(redis_event,szRedisEvent);
            Redis_Publish(redisClientPubSub, "frm.pwn", szRedisEvent);
        }
    } else {
        printf("[Redis] Redis is not connected. Gamemode can't be run properly without redis");
        SendRconCommand("exit");
    }
}

callback RedCB_apiPubSub(PubSub:id, data[]) {
    printf("GOT PUBSUB FROM API");
    new Node:eventjson;
    JsonParse(data, eventjson);
    new ret;
    new eventName[32];
    ret = JsonGetString(eventjson, "event", eventName);

    if(ret) {
        printf("Got Invalid Redis Event");
        printf("%s",data);
        return 1;
    }

    new Node:eventdata;
    ret = JsonGetObject(eventjson, "data", eventdata);
    if(ret) {
        printf("Error parsing event data");
        return 1;
    }
    OnGotRedisEvent(eventName, eventdata);
    return 1;
}

callback OnGotRedisEvent(const eventName[], Node:data) {
    printf("[REDIS HANDLER] Event: %s",eventName);
#if defined RDS_OnGotRedisEvent
    return RDS_OnGotRedisEvent(eventName,data);
#else
    return 1;
#endif
}

#if defined _ALS_OnGotRedisEvent
#undef OnGotRedisEvent
#else
#define _ALS_OnGotRedisEvent
#endif
#define OnGotRedisEvent RDS_OnGotRedisEvent
#if defined RDS_OnGotRedisEvent
forward RDS_OnGotRedisEvent(const eventName[], Node:data);
#endif

