// #define INTERFACE_BROWSER_ID 0xABCDE
#define MAX_CELL_SIZE 0xFFFFFFFF
#define MAX_FLOAT 0x7F800000

new INTERFACE_BROWSER_URL[256];
new API_ENDPOINT[256];

new bool:gDEBUG_MODE;

#define callback%0(%1) forward %0(%1); public %0(%1)
#define system%0(%1) forward %0(%1); public %0(%1)

#define COPY_ARRAY(%0,%1,%2) for(new i=0;i<_:%2;i++) { %1[%2:i] = %0[%2:i]; }

#define VEC2_UNWRAP(%0) %0[0], %0[1]
#define VEC3_UNWRAP(%0) %0[0], %0[1], %0[2]

#define VEC3_COPY(%0,%1) %1[0] = %0[0]; %1[1] = %0[1]; %1[2] = %0[2]

#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_ORCHID 0xDA70D6FF
#define COLOR_GRAY1000 0xE5E4E2FF
#define COLOR_GRAY750 0xD3D3D3FF
#define COLOR_GRAY500 0xA9A9A9FF
#define COLOR_GRAY250 0x808080FF
#define COLOR_GRAY100 0x36454FFF
#define COLOR_DARKGOLDENROD 0xB8860BFF
#define COLOR_LSPD_BLUE 0x0066FFFF

#define PLAYER_TEXT_CHAT_RADIUS 30.0
#define PLAYER_TEXT_SHOUT_RADIUS 60.0
#define PLAYER_TEXT_WHISP_RADIUS 15.0

#define X 0 
#define Y 1 
#define Z 2

#define EMODE_NONE      0
#define EMODE_CREATE    1
#define EMODE_EDIT      2



#define HOLDING(%0) \
    ((newkeys & (%0)) == (%0))

#define PRESSED(%0) \
    (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define PRESSING(%0,%1) \
    (%0 & (%1))

#define RELEASED(%0) \
    (((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

#if defined SHOW_PERFORMANCE_LOG
new 
  pflog_H,
  pflog_M,
  pflog_S,
  pflog_TS;
#define PERFLOG(%0) \
    pflog_TS = gettime(pflog_H, pflog_M, pflog_S); \
    printf("%02d:%02d:%02d(%i) %s", pflog_H, pflog_M, pflog_S, pflog_TS, %0);
#else 
#define PERFLOG(%0) 
#endif


#define E_STREAMER_INTERIOR_ID 101
#define E_STREAMER_LUMBER_ID 102
#define E_STREAMER_GATE_ID 103
#define E_STREAMER_ROCK_ID 104
#define E_STREAMER_CRFTSTATION_ID 105
#define E_STREAMER_LAND_ID 106
#define E_STREAMER_PLANT_ID 107
