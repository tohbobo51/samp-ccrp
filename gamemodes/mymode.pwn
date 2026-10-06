/*
* CAPITOL CITY ROLEPLAY GAMEMODE
* Made from Scratch ;)
* Credits: [ "Yaaruu", ""]
* Put your name above, Don't remove others contributor name.
*/

#define DEBUG_MODE 1
// #define SHOW_PERFORMANCE_LOG 1

#include <a_samp>
#if defined DEBUG_MODE
#include <crashdetect>
#endif

#define STRLIB_RETURN_SIZE 2048
#include <strlib>

#define SERVER_GM_TEXT "CC:RP v0.1.alpha"

#include <a_mysql>
#include <foreach>
#define PP_SYNTAX
// #include <PawnPlus>
#include <pp-hooks>

#include <YSF>
#include <mapandreas>
#include <colandreas>
#include <i_quat>
#define DISABLE_3D_TRYG_INIT
#include <3DTryg>
#include <cef>
// #define SSCANF_NO_NICE_FEATURES
#include <sscanf2>

#include <env>
#include <streamer>

#define DISABLE_MAPFIX_PLACE_125
#include <mapfix>

#include <KeyListener>
#include <Pawn.CMD>
// #include <samp-crypto>
#include <requests>
#include <redis>
#include <RGB>

#include <FCNPC>
// #include <EVF>
#include <GPS>
// #include <samp_player_gangzones>
// #include <WazeGPS>
#include <chandlingsvr>
#include <Pawn.RakNet>
#include <sampvoice>

#define PHY_TIMER_INTERVAL (33)
#include <physics>

#include <vehicleutil>

#include <ESF>

#include <logger>

#include "./includes/defines.pwn"
#include "./includes/forwards.pwn"
#include "./includes/variables.pwn"

#include "./includes/db_schema_var.pwn"

#include "./includes/vendor/cust_math.pwn"
#include "./includes/vendor/cuff.pwn"

#include "./includes/core/dialog_var.pwn"
#include "./includes/core/dyn_object_var.pwn"
#include "./includes/core/account_var.pwn"
// #include "./includes/core/npc_var.pwn"
#include "./includes/core/chat_var.pwn"
#include "./includes/core/player_action_var.pwn"
#include "./includes/core/items_var.pwn"
#include "./includes/core/crafting_var.pwn"
#include "./includes/core/buff_var.pwn"
#include "./includes/core/character_var.pwn"
#include "./includes/core/builder_var.pwn"
#include "./includes/core/vehicles_var.pwn"
#include "./includes/core/interior_var.pwn"
#include "./includes/core/gates_var.pwn"
#include "./includes/core/item_container_var.pwn"
#include "./includes/core/point_interest_var.pwn"
#include "./includes/core/gps_var.pwn"

#include "./includes/bank/bank_teller_var.pwn"

#include "./includes/marketplace/marketplace_var.pwn"

// System Var
#include "./includes/systems/admin_var.pwn"
#include "./includes/systems/admin_ui_var.pwn"
#include "./includes/systems/voice_var.pwn"
#include "./includes/systems/death_var.pwn"
#include "./includes/systems/weapons_var.pwn"
#include "./includes/systems/jail_var.pwn"
#include "./includes/systems/radio_var.pwn"

// Faction Var
#include "./includes/faction/faction_var.pwn"
#include "./includes/faction/ems_var.pwn"
#include "./includes/faction/gov_var.pwn"
#include "./includes/faction/lspd_var.pwn"

// Jobs Var
#include "./includes/jobs/lumber_var.pwn"
#include "./includes/jobs/mining_var.pwn"
#include "./includes/jobs/farmer_var.pwn"
#include "./includes/jobs/sweeper_var.pwn"
#include "./includes/jobs/driver_bus_var.pwn"

#include "./includes/activity/fishing_var.pwn"

#include "./includes/utils.pwn"
#include "./includes/callback.pwn"
#include "./includes/keys.pwn"
#include "./includes/cef.pwn"
#include "./includes/mysql.pwn"
#include "./includes/redis.pwn"

#include "./includes/db_schema.pwn"

// System
#include "./includes/systems/system.pwn"
#include "./includes/systems/admin.pwn"
#include "./includes/systems/admin_ui.pwn"
#include "./includes/systems/voice.pwn"
#include "./includes/systems/death.pwn"
#include "./includes/systems/weapons.pwn"
#include "./includes/systems/jail.pwn"
#include "./includes/systems/radio.pwn"

// Map
#include "./includes/maps/dynamic_map_var.pwn"
#include "./includes/maps/gas_station.pwn"
#include "./includes/jobs/lumber_map.pwn"
#include "./includes/jobs/mining_map.pwn"
#include "./includes/maps/maps.pwn"




// SAMP MODE
//
//
stock testThread() {
    amx_forked(fork_exec)
    {
        new Task:tasks[3];
        tasks[0] = task_new(), tasks[1] = task_new(), tasks[2] = task_new();
        new Task:when_all = task_all(tasks[0], tasks[1], tasks[2]);
        for(new i = 0; i < 3; i++)
        {
            amx_forked(.use_data = false)
            {
                threaded(sync_explicit)
                {
                    thread_sleep(500+i*200);
                }
                printf("Thread %d is done", i);
                task_set_result(tasks[i], true);
            }
        }
        task_await(when_all);
        print("Threads are done");
    }
    print("Threads are started");
}

main(){
    InitVariables();
    // new lastTs = GetTickCount();
    // while(1) {
    //   new nowTs = GetTickCount();
    //   printf("Iteration takes %ims", (lastTs - nowTs));
    //   lastTs = GetTickCount();
    // }
    //
    // testThread();
}




public OnGameModeInit()
{
    new ts = tickcount();
    printf("[INIT] MainGamemodeInit");
    printf("Removing Barriers");
    LoadGameMap();

    Env_Get("INTERFACE_BROWSER_URL", INTERFACE_BROWSER_URL);
    Env_Get("API_ENDPOINT", API_ENDPOINT);

    httpClient = RequestsClient(API_ENDPOINT);
    g_mysql_Init();

    g_redis_Init();

    printf("Init time %i ms", tickcount()-ts);
    printf("gDEBUG_MODE:", gDEBUG_MODE);
    // Uncomment the line to enable debug mode
    // SvEnableDebug();
    gstream = SvCreateStream();
    
    Logger_ToggleDebug("lumber", gDEBUG_MODE);
    Logger_ToggleDebug("farming", gDEBUG_MODE);
    Logger_ToggleDebug("market", gDEBUG_MODE);
    Logger_ToggleDebug("vehicle", gDEBUG_MODE);
    Logger_ToggleDebug("crafting", gDEBUG_MODE);
    Logger_ToggleDebug("crafting-tick", gDEBUG_MODE);

#if defined MyMain_OnGameModeInit
    return MyMain_OnGameModeInit();
#else
    return 1;
#endif
}
#if defined _ALS_OnGameModeInit
#undef OnGameModeInit
#else
#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit MyMain_OnGameModeInit
#if defined MyMain_OnGameModeInit
forward MyMain_OnGameModeInit();
#endif


public OnGameModeExit()
{

    deinitGamemode();
    g_mysql_Exit();
    if (gstream != SV_NONE)
    {
        SvDeleteStream(gstream);
        gstream = SV_NONE;
    }
    return 1;
}

#include "./includes/core/dialog.pwn"
#include "./includes/core/initgamemode.pwn"
#include "./includes/core/picker.pwn"
#include "./includes/core/point_interest.pwn"
#include "./includes/core/gps.pwn"
#include "./includes/core/interval.pwn"
#include "./includes/core/account.pwn"
#include "./includes/core/character.pwn"
#include "./includes/core/player_action.pwn"
#include "./includes/core/auth.pwn"
#include "./includes/core/chat.pwn"
#include "./includes/core/items.pwn"
#include "./includes/core/items_drop.pwn"
#include "./includes/core/crafting.pwn"
#include "./includes/core/crafting_station.pwn"
#include "./includes/core/buff.pwn"
#include "./includes/core/vehicles.pwn"
#include "./includes/core/vehicles_cmd.pwn"
#include "./includes/core/vehicles_storage.pwn"
#include "./includes/core/interior.pwn"
#include "./includes/core/gates.pwn"
#include "./includes/bank/bank_teller.pwn"
#include "./includes/marketplace/marketplace.pwn"
// Systems

 
// CMDS
#include "./includes/cmds.pwn"
#include "./includes/debug_cmds.pwn"
#include "./includes/cmds/admin.pwn"

// Factions
#include "./includes/faction/faction.pwn"
#include "./includes/faction/faction_cmd.pwn"
#include "./includes/faction/faction_locker.pwn"



#include "./includes/faction/gov.pwn"
#include "./includes/faction/gov_cmd.pwn"

#include "./includes/faction/lspd.pwn"
// #include "./includes/faction/lspd_locker.pwn"
#include "./includes/faction/lspd_cmd.pwn"

#include "./includes/faction/ems.pwn"
#include "./includes/faction/ems_cmd.pwn"

// Jobs
#include "./includes/jobs/lumber.pwn"
#include "./includes/jobs/lumber_sawmill.pwn"
#include "./includes/jobs/mining.pwn"
#include "./includes/jobs/mining_smelter.pwn"

#include "./includes/jobs/farmer.pwn"

//Side Jobs enternal
#include "./includes/jobs/swepper.pwn"
#include "./includes/jobs/driver_bus.pwn"

// ETC
#include "./includes/core/builder.pwn"

#include "./includes/maps/dynamic_map.pwn"

#include "./includes/activity/fishing.pwn"

#include "./includes/core/items_usage.pwn"
#include "./includes/core/item_container.pwn"

#include "./includes/core/radialmenu.pwn"
// #include "./includes/core/npc.pwn"
