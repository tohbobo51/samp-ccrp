#define VoiceSystem:: sys_sv_ 

#define GLOBAL_CHANNEL 0
#define  LOCAL_CHANNEL 1

new SV_UINT:gstream = SV_NONE;
new SV_UINT:lstream[MAX_PLAYERS] = { SV_NONE, ... };

#define sys_sv_GetPluginState(%0) GetPVarInt(%0,"SV_PluginState")
#define sys_sv_SetPluginState(%0,%1) SetPVarInt(%0,"SV_PluginState",%1)

