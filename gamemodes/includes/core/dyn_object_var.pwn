#define DynObjEditResponse:: does_

enum does_Data {
    DynObjEditResponse::response, 
    Float:DynObjEditResponse::x, 
    Float:DynObjEditResponse::y, 
    Float:DynObjEditResponse::z, 
    Float:DynObjEditResponse::rx, 
    Float:DynObjEditResponse::ry, 
    Float:DynObjEditResponse::rz
}



new DynObjEditResponse::Response[MAX_PLAYERS][DynObjEditResponse::Data];

stock DynObjEditResponse::Clear(playerid) {
    DynObjEditResponse::Response[playerid][DynObjEditResponse::response] = -1;
    DynObjEditResponse::Response[playerid][DynObjEditResponse::x] = 0;
    DynObjEditResponse::Response[playerid][DynObjEditResponse::y] = 0;
    DynObjEditResponse::Response[playerid][DynObjEditResponse::z] = 0;
    DynObjEditResponse::Response[playerid][DynObjEditResponse::rx] = 0;
    DynObjEditResponse::Response[playerid][DynObjEditResponse::ry] = 0;
    DynObjEditResponse::Response[playerid][DynObjEditResponse::rz] = 0;
}
