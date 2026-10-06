public OnPlayerEditDynamicObject(playerid, STREAMER_TAG_OBJECT:objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
    if(Gates::IsPlacingObject(playerid) && Gates::PlacingObjectID(playerid) == objectid && response == 1) {
        new l_task = Gates::GetTask(playerid);
        Gates::SetTask(playerid, -1);
        Gates::SetPlacingObject(playerid, false);
        Gates::SetPlacingObjectID(playerid, -1);
        DynObjEditResponse::Response[playerid][DynObjEditResponse::response] = response;
        DynObjEditResponse::Response[playerid][DynObjEditResponse::x] = x;
        DynObjEditResponse::Response[playerid][DynObjEditResponse::y] = y;
        DynObjEditResponse::Response[playerid][DynObjEditResponse::z] = z;
        DynObjEditResponse::Response[playerid][DynObjEditResponse::rx] = rx;
        DynObjEditResponse::Response[playerid][DynObjEditResponse::ry] = ry;
        DynObjEditResponse::Response[playerid][DynObjEditResponse::rz] = rz;
        task_set_result(Task:l_task, true);
    }
    if(Gates::IsPlacingObject(playerid) && Gates::PlacingObjectID(playerid) == objectid && response == 0) {
        new l_task = Gates::GetTask(playerid);
        Gates::SetTask(playerid, -1);
        Gates::SetPlacingObject(playerid, false);
        Gates::SetPlacingObjectID(playerid, -1);
        DynObjEditResponse::Response[playerid][DynObjEditResponse::response] = response;
        task_set_result(Task:l_task, true);
    }
#if defined gts_OnPlayerEditDynObject
    return gts_OnPlayerEditDynObject(playerid,objectid,response,x,y,z,rx,ry,rz);
#else
    return 1;
#endif
}
#if defined _ALS_OnPlayerEditDynamicObject
#undef OnPlayerEditDynamicObject
#else
#define _ALS_OnPlayerEditDynamicObject
#endif
#define OnPlayerEditDynamicObject gts_OnPlayerEditDynObject 
#if defined gts_OnPlayerEditDynObject
forward gts_OnPlayerEditDynObject(playerid, STREAMER_TAG_OBJECT:objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
#endif

public OnPlayerEnterDynamicArea(playerid, areaid) {
    if(Streamer_HasIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_GATE_ID))) {
        Gates::SetID(playerid, Streamer_GetIntData(STREAMER_TYPE_AREA, areaid, E_STREAMER_CUSTOM(E_STREAMER_GATE_ID))+1);
    }
#if defined GTS_OnPlayerEnterDynArea
        return GTS_OnPlayerEnterDynArea(playerid, areaid);
#else
        return 1;
#endif
}
#if defined _ALS_OnPlayerEnterDynArea
#undef OnPlayerEnterDynamicArea
#else
#define _ALS_OnPlayerEnterDynArea
#endif
#define OnPlayerEnterDynamicArea GTS_OnPlayerEnterDynArea
#if defined GTS_OnPlayerEnterDynArea
forward GTS_OnPlayerEnterDynArea(playerid, areaid);
#endif

public OnPlayerLeaveDynamicArea(playerid, areaid) {
    if(Gates::GetID(playerid) != 0) {
        Gates::SetID(playerid, 0);
    }
#if defined GTS_OnPlayerLeaveDynArea
        return GTS_OnPlayerLeaveDynArea(playerid, areaid);
#else
        return 1;
#endif
}
#if defined _ALS_OnPlayerLeaveDynArea
#undef OnPlayerLeaveDynamicArea
#else
#define _ALS_OnPlayerLeaveDynArea
#endif
#define OnPlayerLeaveDynamicArea GTS_OnPlayerLeaveDynArea
#if defined GTS_OnPlayerLeaveDynArea
forward GTS_OnPlayerLeaveDynArea(playerid, areaid);
#endif

Gates::Init() {
    Gates::list = map_new();
    Gates::LoadAll();
    return 1;
}

Gates::deInit() {
    Gates::SaveAll();
    map_delete_deep(Gates::list);
    return 1;
}

stock bool:Gates::isOpen(const gate[Gates::GateInfo]) {
    return (gate[Gate::status_flag] & Gate::Open) == Gate::Open;
}

stock bool:Gates::isLocked(const gate[Gates::GateInfo]) {
    return (gate[Gate::status_flag] & Gate::Locked) == Gate::Locked;
}

stock Gates::set_flag(gate[Gates::GateInfo], flag, bool:toggle) {
    if(toggle) {
        new mask = 1 << (flag-1);
        gate[Gate::status_flag] = gate[Gate::status_flag] | mask;
    } else {
        new mask = ~(1<<(flag-1));
        gate[Gate::status_flag] = gate[Gate::status_flag] & mask;
    }
    return 1;
}

Gates::spawn(data[Gates::GateInfo]) {
    data[Gate::obj_id] = CreateDynamicObject(
        data[Gate::model_id],
        data[Gate::base_pos][X],
        data[Gate::base_pos][Y],
        data[Gate::base_pos][Z],
        data[Gate::base_rot][X],
        data[Gate::base_rot][Y],
        data[Gate::base_rot][Z],
        data[Gate::world],
        data[Gate::int],
        .streamdistance = 100
    );
    if(data[Gate::access_type] == GateAccess::RADIUS) {
        data[Gate::area_id] = CreateDynamicSphere(
            data[Gate::base_pos][X],
            data[Gate::base_pos][Y],
            data[Gate::base_pos][Z],
            data[Gate::radius],
            data[Gate::world],
            data[Gate::int]
        );
        Streamer_SetIntData(STREAMER_TYPE_AREA, data[Gate::area_id], E_STREAMER_CUSTOM(E_STREAMER_GATE_ID), data[Gate::id]);
    }
    Gates::move_gate(data); 
    return 1;
}

Gates::despawn(const data[Gates::GateInfo]) {
    if(IsValidDynamicObject(data[Gate::obj_id])) {
        DestroyDynamicObject(data[Gate::obj_id]);
    }
    if(IsValidDynamicArea(data[Gate::area_id])) {
        DestroyDynamicArea(data[Gate::area_id]);
    }
    return 1;
}

stock Gates::move_gate(const gate[Gates::GateInfo]) {
    if(!IsValidDynamicObject(gate[Gate::obj_id])) return 0;
    if(IsDynamicObjectMoving(gate[Gate::obj_id])) {
        StopDynamicObject(gate[Gate::obj_id]);
    }
    if(Gates::isOpen(gate)) {
        MoveDynamicObject(gate[Gate::obj_id], gate[Gate::move_pos][X], gate[Gate::move_pos][Y], gate[Gate::move_pos][Z], gate[Gate::speed], gate[Gate::move_rot][X], gate[Gate::move_rot][Y], gate[Gate::move_rot][Z]);
    } else {
        MoveDynamicObject(gate[Gate::obj_id], gate[Gate::base_pos][X], gate[Gate::base_pos][Y], gate[Gate::base_pos][Z], gate[Gate::speed], gate[Gate::base_rot][X], gate[Gate::base_rot][Y], gate[Gate::base_rot][Z]);
    }
    return 1;
}

stock Gates::toggle(gate[Gates::GateInfo]) {
    Gates::set_flag(gate, Gate::Open, !Gates::isOpen(gate));
    Gates::move_gate(gate);
    return 1;
}

stock Gates::open(gate[Gates::GateInfo]) {
    if(Gates::isLocked(gate)) return 0;
    Gates::set_flag(gate, Gate::Open, true);
    Gates::move_gate(gate);
    return 1;
}

stock Gates::close(gate[Gates::GateInfo]) {
    Gates::set_flag(gate, Gate::Open, false);
    Gates::move_gate(gate);
    return 1;
}

stock Gates::lock(gate[Gates::GateInfo]) {
    Gates::set_flag(gate, Gate::Locked, !Gates::isLocked(gate));
    return 1;
}

stock Gates::PrintDebug(const gate[Gates::GateInfo], playerid = INVALID_PLAYER_ID) {
    new szMsgStr[1024];
    format(szMsgStr,sizeof(szMsgStr), "DEBUG GATE\n\
        ID: %i\n\
        FLAG: %i \n\
        Type: %i | AccessType: %i \n\
        Base: %f,%f,%f | %f, %f, %f \n\
        Move: %f,%f,%f | %f, %f, %f \n\
        Speed: %f",
            gate[Gate::id],
            gate[Gate::status_flag],
            gate[Gate::type], gate[Gate::access_type],
            gate[Gate::base_pos][X],gate[Gate::base_pos][Y],gate[Gate::base_pos][Z],
            gate[Gate::base_rot][X],gate[Gate::base_rot][Y],gate[Gate::base_rot][Z],
            gate[Gate::move_pos][X],gate[Gate::move_pos][Y],gate[Gate::move_pos][Z],
            gate[Gate::move_rot][X],gate[Gate::move_rot][Y],gate[Gate::move_rot][Z],
            gate[Gate::speed]
    );
    if(playerid == INVALID_PLAYER_ID) {
        print(szMsgStr);
    } else {
        EMIT_PlayerSystemChat(playerid, -1, szMsgStr);
    }
}

Gates::LoadAll() {
    mysql_tquery(MainConn,"SELECT * from `gates`", "OnGatesLoaded");
    return 1;
}

callback OnGatesLoaded() {
    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields);
    new l_gate[Gates::GateInfo];
    if(rows > 0) {
        for(new i=0;i<rows;i++) {
            DB::LoadCacheSchema(i, Gates::Schema, sizeof(Gates::Schema), l_gate);
            if(l_gate[Gate::id] > Gates::last_id) { 
                Gates::last_id = l_gate[Gate::id];
            }
            Gates::spawn(l_gate);
            map_add_arr(Gates::list, l_gate[Gate::id], l_gate);
        }
    }
    printf("[GATES] %i gate(s) loaded.", rows);
}

stock Gates::Save(const gate[Gates::GateInfo]) {
    DB::MakeUpdateQuery("gates", Gates::Schema, sizeof(Gates::Schema));
    DB::PopulateUpdateQuery(Gates::Schema, sizeof(Gates::Schema), gate);
    mysql_tquery(MainConn, szQuery);
    return 1;
}

stock Gates::Insert(const gate[Gates::GateInfo]) {
    DB::MakeInsertQuery("gates", Gates::Schema, sizeof(Gates::Schema), true);
    DB::PopulateInsertQuery(Gates::Schema, sizeof(Gates::Schema), gate, true);
    mysql_tquery(MainConn, szQuery);
}

stock Gates::Delete(id) {
    if(!map_has_key(Gates::list, id)) return 0;
    new l_gate[Gates::GateInfo];
    map_get_arr(Gates::list, id, l_gate);
    if(IsValidDynamicObject(l_gate[Gate::obj_id])) {
        DestroyDynamicObject(l_gate[Gate::obj_id]);
    }
    if(IsValidDynamicArea(l_gate[Gate::area_id])) {
        DestroyDynamicArea(l_gate[Gate::area_id]);
    }
    map_remove(Gates::list, id);
    mysql_format(MainConn, szQuery, sizeof(szQuery), "DELETE from `gates` where 'id' = %i", id);
    mysql_tquery(MainConn, szQuery);
    return 1;
}

stock Gates::SaveAll() {
    for_map(it : Gates::list) {
        new l_gate[Gates::GateInfo];
        iter_get_arr(it, l_gate);
        Gates::Save(l_gate);
    }
    return 1;
}

// Commands
CMD:nearbygates(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_MANAGE_GATES)) return 0;
    new l_gate[Gates::GateInfo];
    EMIT_PlayerSystemChat(playerid, -1, "===================NEARBY GATE=================");
    new szMsgStr[1024];
    szMsgStr[0] = 0;
    for_map(i : Gates::list) {
        iter_get_arr(i, l_gate);
        if(IsPlayerInRangeOfPoint(playerid, 10.0, l_gate[Gate::base_pos][X], l_gate[Gate::base_pos][Y], l_gate[Gate::base_pos][Z])) {
            format(szMsgStr, sizeof(szMsgStr), "%sID: %i\n",szMsgStr, l_gate[Gate::id]);
        }
    }
    EMIT_PlayerSystemChat(playerid, -1, szMsgStr);
    EMIT_PlayerSystemChat(playerid, -1, "===================-----------=================");
    return 1;
}

static gateedit_menuitem[] = "Change Object\nSet Base Pos\nSet Move Pos\nSet Type\nSet Access Type\nSet Speed\nSet Radius\nTest\nAdd Ref\nFinish";

Gates::EditMenu(playerid, l_gate[Gates::GateInfo]) {
    new szList[2048];
    Gates::SetCreatingGate(playerid, true);
    while(Gates::IsCreatingGate(playerid)) {
        await task_ms(250);
        new Task:ret = Dialog::ShowAsyncDialog(playerid, Dialog::LIST, "Gate Menu", gateedit_menuitem, "Pilih", "Batal");
        await ret;
        new a_res = Dialog::Response[playerid][DialogResponse::response];
        new a_listitem = Dialog::Response[playerid][DialogResponse::listitem];
        if(!a_res) {
            Gates::SetCreatingGate(playerid, false);
            continue;
        }
        switch(a_listitem) {
            case 0: {
                await task_ms(250);
                new Task:t = Dialog::ShowAsyncDialog(playerid, Dialog::INPUT, "Create Gate", "ObjectID", "Ok", "Cancel");
                await t;
                if(Dialog::Response[playerid][DialogResponse::response]) {
                    new l_modelId;
                    if(sscanf(Dialog::Response[playerid][DialogResponse::inputtext], "i", l_modelId)) return EMIT_PlayerSystemChat(playerid, -1, "Invalid objectid");
                    l_gate[Gate::model_id] = l_modelId;
                    new Task:tt = task_new();
                    new Float:l_pos[3],
                        Float:l_rot[3],
                        Float: l_pAngle,
                        Float: l_dist;
                    l_gate[Gate::world] = GetPlayerVirtualWorld(playerid);
                    l_gate[Gate::int] = GetPlayerInterior(playerid);
                    if(IsValidDynamicObject(l_gate[Gate::obj_id])) {
                        EMIT_PlayerSystemChat(playerid, -1, "Change object");
                        GetDynamicObjectPos(l_gate[Gate::obj_id], l_pos[X], l_pos[Y], l_pos[Z]);
                        GetDynamicObjectRot(l_gate[Gate::obj_id], l_rot[X], l_rot[Y], l_rot[Z]);
                        DestroyDynamicObject(l_gate[Gate::obj_id]);
                    } else {
                        EMIT_PlayerSystemChat(playerid, -1, "New Object");
                        GetPlayerPos(playerid, VEC3_UNWRAP(l_pos));
                        GetPlayerFacingAngle(playerid, l_pAngle);
                        l_dist = 3.0;
                        GetXYInFrontOfPoint(l_pos[X],l_pos[Y],l_pAngle, l_dist);
                        if(l_gate[Gate::int] < 1) {
                            CA_FindZ_For2DCoord(l_pos[X],l_pos[Y],l_pos[Z]);
                        }
                    }
                    
                    EMIT_PlayerSystemChat(playerid, -1, sprintf("vw: %i, int: %i", l_gate[Gate::world], l_gate[Gate::int]));
                    l_gate[Gate::obj_id] = CreateDynamicObject(l_modelId, l_pos[X],l_pos[Y],l_pos[Z],l_rot[X],l_rot[Y],l_rot[Z],l_gate[Gate::world], l_gate[Gate::int]);
                    Gates::SetPlacingObject(playerid, true);
                    Gates::SetPlacingObjectID(playerid, l_gate[Gate::obj_id]);
                    Gates::SetTask(playerid, _:tt);
                    EditDynamicObject(playerid, l_gate[Gate::obj_id]);
                    await tt;
                    if(DynObjEditResponse::Response[playerid][DynObjEditResponse::response] == 1) {
                        l_gate[Gate::base_pos][X] = DynObjEditResponse::Response[playerid][DynObjEditResponse::x];
                        l_gate[Gate::base_pos][Y] = DynObjEditResponse::Response[playerid][DynObjEditResponse::y];
                        l_gate[Gate::base_pos][Z] = DynObjEditResponse::Response[playerid][DynObjEditResponse::z];
                        l_gate[Gate::base_rot][X] = DynObjEditResponse::Response[playerid][DynObjEditResponse::rx];
                        l_gate[Gate::base_rot][Y] = DynObjEditResponse::Response[playerid][DynObjEditResponse::ry];
                        l_gate[Gate::base_rot][Z] = DynObjEditResponse::Response[playerid][DynObjEditResponse::rz];    
                        EMIT_PlayerSystemChat(playerid, -1, "Edit Finished");
                    } else {
                        EMIT_PlayerSystemChat(playerid, -1, "Edit Canceled");
                    }
                    DynObjEditResponse::Clear(playerid);
                }
            }
            case 1: { // Base Pos
                if(!IsValidDynamicObject(l_gate[Gate::obj_id])) {
                    EMIT_PlayerSystemChat(playerid, -1, "Please choose object id first");
                    continue;
                }
                if(IsDynamicObjectMoving(l_gate[Gate::obj_id])) {
                    StopDynamicObject(l_gate[Gate::obj_id]);
                    SetDynamicObjectPos(l_gate[Gate::obj_id], l_gate[Gate::base_pos][X], l_gate[Gate::base_pos][Y], l_gate[Gate::base_pos][Z]);
                    SetDynamicObjectRot(l_gate[Gate::obj_id], l_gate[Gate::base_rot][X], l_gate[Gate::base_rot][Y], l_gate[Gate::base_rot][Z]);
                }
                new Task:tt = task_new();
                Gates::SetPlacingObject(playerid, true);
                Gates::SetPlacingObjectID(playerid, l_gate[Gate::obj_id]);
                Gates::SetTask(playerid, _:tt);
                EditDynamicObject(playerid, l_gate[Gate::obj_id]);
                await tt;
                if(DynObjEditResponse::Response[playerid][DynObjEditResponse::response] == 1) {
                    l_gate[Gate::base_pos][X] = DynObjEditResponse::Response[playerid][DynObjEditResponse::x];
                    l_gate[Gate::base_pos][Y] = DynObjEditResponse::Response[playerid][DynObjEditResponse::y];
                    l_gate[Gate::base_pos][Z] = DynObjEditResponse::Response[playerid][DynObjEditResponse::z];
                    l_gate[Gate::base_rot][X] = DynObjEditResponse::Response[playerid][DynObjEditResponse::rx];
                    l_gate[Gate::base_rot][Y] = DynObjEditResponse::Response[playerid][DynObjEditResponse::ry];
                    l_gate[Gate::base_rot][Z] = DynObjEditResponse::Response[playerid][DynObjEditResponse::rz];    
                    EMIT_PlayerSystemChat(playerid, -1, "Edit Finished");
                } else {
                    EMIT_PlayerSystemChat(playerid, -1, "Edit Canceled");
                }
                DynObjEditResponse::Clear(playerid);
            }
            case 2: { // Move Pos
                if(!IsValidDynamicObject(l_gate[Gate::obj_id])) {
                    EMIT_PlayerSystemChat(playerid, -1, "Please choose object id first");
                    continue;
                }
                if(IsDynamicObjectMoving(l_gate[Gate::obj_id])) {
                    StopDynamicObject(l_gate[Gate::obj_id]);
                    SetDynamicObjectPos(l_gate[Gate::obj_id], l_gate[Gate::base_pos][X], l_gate[Gate::base_pos][Y], l_gate[Gate::base_pos][Z]);
                    SetDynamicObjectRot(l_gate[Gate::obj_id], l_gate[Gate::base_rot][X], l_gate[Gate::base_rot][Y], l_gate[Gate::base_rot][Z]);
                }
                new Task:tt = task_new();
                Gates::SetPlacingObject(playerid, true);
                Gates::SetPlacingObjectID(playerid, l_gate[Gate::obj_id]);
                Gates::SetTask(playerid, _:tt);
                EditDynamicObject(playerid, l_gate[Gate::obj_id]);
                await tt;
                
                l_gate[Gate::move_pos][X] = DynObjEditResponse::Response[playerid][DynObjEditResponse::x];
                l_gate[Gate::move_pos][Y] = DynObjEditResponse::Response[playerid][DynObjEditResponse::y];
                l_gate[Gate::move_pos][Z] = DynObjEditResponse::Response[playerid][DynObjEditResponse::z];
                l_gate[Gate::move_rot][X] = DynObjEditResponse::Response[playerid][DynObjEditResponse::rx];
                l_gate[Gate::move_rot][Y] = DynObjEditResponse::Response[playerid][DynObjEditResponse::ry];
                l_gate[Gate::move_rot][Z] = DynObjEditResponse::Response[playerid][DynObjEditResponse::rz];
                DynObjEditResponse::Clear(playerid);
                EMIT_PlayerSystemChat(playerid, -1, "Edit Finished");
                
                // reset to base pos
                SetDynamicObjectPos(l_gate[Gate::obj_id], l_gate[Gate::base_pos][X], l_gate[Gate::base_pos][Y], l_gate[Gate::base_pos][Z]);
                SetDynamicObjectRot(l_gate[Gate::obj_id], l_gate[Gate::base_rot][X], l_gate[Gate::base_rot][Y], l_gate[Gate::base_rot][Z]);
            }
            case 3: { // set type
                szList[0] = 0;
                for(new i=0;i<sizeof(Gates::TypeStr);i++) {
                    format(szList, sizeof(szList), "%s%i. %s\n", szList, i, Gates::TypeStr[Gate::Type:i]);
                }
                new Task:tt = Dialog::ShowAsyncDialog(playerid, Dialog::LIST, "Tipe", szList, "Pilih", "Batal");
                await tt;
                await task_ms(100);
                
                Dialog::DEBUG_Response(playerid);  
                if(!Dialog::Response[playerid][DialogResponse::response]) continue;
                new selitem = Dialog::Response[playerid][DialogResponse::listitem];
                EMIT_PlayerSystemChat(playerid, -1, sprintf("you selected %i", selitem));
                l_gate[Gate::type] = Gate::Type:selitem;
            }
            case 4: { // set access type
                szList[0] = 0;
                for(new i=0;i<sizeof(Gates::AccessTypeStr);i++) {
                    format(szList, sizeof(szList), "%s%i. %s\n", szList, i, Gates::AccessTypeStr[Gate::AccessType:i]);
                }
                new Task:tt = Dialog::ShowAsyncDialog(playerid, Dialog::LIST, "Tipe akses", szList, "Pilih", "Batal");
                await tt;
                await task_ms(100);
                Dialog::DEBUG_Response(playerid);
                if(!Dialog::Response[playerid][DialogResponse::response]) continue;
                new selitem = Dialog::Response[playerid][DialogResponse::listitem];
                l_gate[Gate::access_type] = Gate::AccessType:selitem;
            }
            case 5: { // set speed
                new Task:tt = Dialog::ShowAsyncDialog(playerid, Dialog::INPUT, "Speed", "Masukan move speed", "Ok", "Batal");
                await tt;
                if(!Dialog::Response[playerid][DialogResponse::response]) continue;
                new Float:l_speed;
                if(sscanf(Dialog::Response[playerid][DialogResponse::inputtext], "f", l_speed)) {
                    EMIT_PlayerSystemChat(playerid, -1, "Format speed harus float. (eg. 1.0)");
                    continue;
                }
                l_gate[Gate::speed] = l_speed;
            }
            case 6: { // radius
                new Task:tt = Dialog::ShowAsyncDialog(playerid, Dialog::INPUT, "Radius", "Masukan Jarak Akses", "Ok", "Batal");
                await tt;
                if(!Dialog::Response[playerid][DialogResponse::response]) continue;
                new Float:l_radius;
                if(sscanf(Dialog::Response[playerid][DialogResponse::inputtext], "f", l_radius)) {
                    EMIT_PlayerSystemChat(playerid, -1, "Format radius harus float. (eg. 1.0)");
                    continue;
                }
                l_gate[Gate::radius] = l_radius;
                Gates::despawn(l_gate);
                Gates::spawn(l_gate);
            }
            case 7: { //test 
                if(Gates::isOpen(l_gate)) {
                    EMIT_PlayerSystemChat(playerid, -1, "Closing Gate");
                    Gates::close(l_gate);
                } else {
                    EMIT_PlayerSystemChat(playerid, -1, "Opening Gate");
                    Gates::open(l_gate);
                }
            }
            case 8: {
                if(l_gate[Gate::type] == GateType::FACTION) {
                    szList[0] = 0;
                    for(new i=0;i<_:Faction::MAX_FACTION;i++) {
                        format(szList, sizeof(szList), "%s%i. %s\n", szList, i, Faction::NAME[eFaction:i]);
                    }
                    new Task:tt = Dialog::ShowAsyncDialog(playerid, Dialog::LIST, "Tipe", szList, "Pilih", "Batal");
                    await tt;
                    await task_ms(100);
                    
                    Dialog::DEBUG_Response(playerid);
                    if(!Dialog::Response[playerid][DialogResponse::response]) continue;
                    new selitem = Dialog::Response[playerid][DialogResponse::listitem];
                    l_gate[Gate::ref_id] = selitem;
                }
            }
            case 9: { // finish
                Gates::SetCreatingGate(playerid, false);
                Gates::PrintDebug(l_gate, playerid);
                Gates::SetCreatingGate(playerid, false);
                if(Gates::EditMode(playerid) == EMODE_CREATE) {
                    if(l_gate[Gate::access_type] == GateAccess::RADIUS) {
                        l_gate[Gate::area_id] = CreateDynamicSphere(
                            l_gate[Gate::base_pos][X],
                            l_gate[Gate::base_pos][Y],
                            l_gate[Gate::base_pos][Z],
                            l_gate[Gate::radius],
                            l_gate[Gate::world],
                            l_gate[Gate::int]
                        );
                        Streamer_SetIntData(STREAMER_TYPE_AREA, l_gate[Gate::area_id], E_STREAMER_CUSTOM(E_STREAMER_GATE_ID), l_gate[Gate::id]);
                    }
                    Gates::last_id++;
                    l_gate[Gate::id] = Gates::last_id;
                    map_add_arr(Gates::list, Gates::last_id, l_gate);
                    Gates::Insert(l_gate);
                }
                if(Gates::EditMode(playerid) == EMODE_EDIT) {
                    map_set_arr(Gates::list, l_gate[Gate::id], l_gate);
                    Gates::Save(l_gate);
                }
                Gates::SetEditMode(playerid, EMODE_NONE);
            }
        }
    }
    return 1;
}

CMD:creategate(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_MANAGE_GATES)) return 0;
    if(Gates::IsCreatingGate(playerid)) return 1;
    if(isPlayerUIInteractable[playerid]) {
        HideCEFUI(playerid); 
    }
    new l_gate[Gates::GateInfo];
    l_gate[Gate::speed] = 2.0;
    Gates::SetEditMode(playerid, EMODE_CREATE);
    Gates::EditMenu(playerid, l_gate);
    return 1;
}

CMD:editgate(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_MANAGE_GATES)) return 0;
    if(Gates::IsCreatingGate(playerid)) return 1;
    new l_gateId;
    if(sscanf(params, "i", l_gateId)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /editgate [gate_id]");
    if(isPlayerUIInteractable[playerid]) {
        HideCEFUI(playerid); 
    }
    if(!map_has_key(Gates::list, l_gateId)) return EMIT_PlayerSystemChat(playerid, -1, "EDIT GATE: No Gate with found with provided 'id'");
    new l_gate[Gates::GateInfo];
    map_get_arr(Gates::list, l_gateId, l_gate);
    if(!IsPlayerInRangeOfPoint(playerid, 10.0, l_gate[Gate::base_pos][X], l_gate[Gate::base_pos][Y], l_gate[Gate::base_pos][Z]))
        return EMIT_PlayerSystemChat(playerid, -1, "EDIT GATE: You're not near that gate");
    Gates::SetEditMode(playerid, EMODE_EDIT);
    Gates::EditMenu(playerid, l_gate);
    return 1;
}

CMD:deletegate(playerid, params[]) {
    if(!AdminSystem::HasPerms(playerid, ADMIN_PERMS_MANAGE_GATES)) return 0;
    if(Gates::IsCreatingGate(playerid)) return 1;
    new l_gate_id;
    if(sscanf(params, "i", l_gate_id)) return EMIT_PlayerSystemChat(playerid, -1, "USAGE: /deletegate [gate_id]");
    if(Gates::Delete(gate_id)) {
        EMIT_PlayerSystemChat(playerid, -1, "Gate has been deleted");
    } else {
        EMIT_PlayerSystemChat(playerid, -1, "Failed to delete gate");
    }
    return 1;
}

CMD:gateopen(playerid, params[]) {
    if(Gates::GetID(playerid) != 0) {
        if(!map_has_key(Gates::list, Gates::GetID(playerid))) return 0;
        new l_gate[Gates::GateInfo];
        map_get_arr(Gates::list, Gates::GetID(playerid)-1, l_gate);
        if(l_gate[Gate::type] == GateType::FACTION) {
            if(!IsPlayerInFaction(playerid, eFaction:l_gate[Gate::ref_id])) return 0;
        }
        if(Gates::open(l_gate)) {
            EMIT_PlayerSystemChat(playerid, -1, "GATE: Gate opened");
            return 1;
        } else {
            EMIT_PlayerSystemChat(playerid, -1, "GATE: Gate is locked");
        }
    }
    return 1;
}
alias:gateopen("go")

CMD:gateclose(playerid, params[]) {
    if(Gates::GetID(playerid) != 0) {
        new l_gate[Gates::GateInfo];
        map_get_arr(Gates::list, Gates::GetID(playerid)-1, l_gate);
        if(l_gate[Gate::type] == GateType::FACTION) {
            if(!IsPlayerInFaction(playerid, eFaction:l_gate[Gate::ref_id])) return 0;
        }
        Gates::close(l_gate);
        EMIT_PlayerSystemChat(playerid, -1, "GATE: Gate closed");
    }
    return 1;
}
alias:gateclose("gc")

CMD:gatelock(playerid, params[]) {
    // new gate[Gates::GateInfo];
    // Gates::lock(gate);
    return 1;
}

CMD:gateunlock(playerid, params[]) {
    return 1;
}
