#define AdminSystem:: sys_adm_
#define AdminPerms:: adm_prm_

#define ADMIN_PERMS_GET "get"
#define ADMIN_PERMS_GOTO "goto"
#define ADMIN_PERMS_WARN "warn"
#define ADMIN_PERMS_KICK "kick"
#define ADMIN_PERMS_BAN "ban"
#define ADMIN_PERMS_SPECTATE "spectate"

#define ADMIN_PERMS_MANAGE_FACTION "managefaction"
#define ADMIN_PERMS_MANAGE_GATES "managegates"


#define sys_adm_MapTP(%0) GetPVarInt(%0, "sys_adm_MapTP")
#define sys_adm_SetMapTP(%0,%1) SetPVarInt(%0, "sys_adm_MapTP",%1)

#define sys_adm_IsSpectating(%0) GetPVarInt(%0, "sys_adm_Spectating")
#define sys_adm_SetSpectating(%0,%1) SetPVarInt(%0, "sys_adm_Spectating",%1)
#define sys_adm_GetSpectateTarget(%0) GetPVarInt(%0, "sys_adm_SpectateTarget")
#define sys_adm_SetSpectateTarget(%0,%1) SetPVarInt(%0, "sys_adm_SpectateTarget",%1)
#define sys_adm_GetSpectatorLastPos(%0,%1) GetPVarFloat(%0,%1)
#define sys_adm_SetSpectatorLastPos(%0,%1,%2) SetPVarFloat(%0,%1,%2)

enum AdminSystem::e_Data {
    Map:AdminPerms::permissions
};

new Map:AdminSystem::admin_list;
