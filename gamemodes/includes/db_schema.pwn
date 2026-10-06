#define SEPARATOR_CHECK(%0) (i==%0-1 ? " " : ",") 
// should called in for loop with 'i' iterator variable

stock DB::Select(const table_name[64], const schema[][], col_size, id, data[], data_size) {
    new Task:task_select = task_new();
    szQuery[0] = 0;
    mysql_format(MainConn, szQuery, sizeof(szQuery), "SELECT * FROM `%s` WHERE `id`='%i'", table_name, id);
    new Variant:schema_var = var_new_arr_2d(schema, col_size, DB::Column);
    new Variant:data_var = var_new_arr(data, data_size);
    var_acquire(schema_var);
    var_acquire(data_var);
    printf("col_size: %i, stride: %i", col_size, _:DB::Column);
    printf("variant handle: %i", _:schema_var);
    mysql_tquery(MainConn, szQuery, "OnDBSchemaSelect", "iiiiii", _:schema_var, col_size, _:data_var, data, data_size, _:task_select);
    await task_select;
    var_get_arr(data_var, data, data_size);
    var_release(schema_var);
    var_release(data_var);
    return 1;
}

callback OnDBSchemaSelect(schema_var, col_size, data_var, data[], data_size, task) {
    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields);
    if(rows > 0) {
        DB::LoadCacheSchemaVar(0, schema_var, col_size, data);
        DB::DataDebugVar("farm_plant cb", schema_var, col_size, data);
    }
    var_set_cells(Variant:data_var, 0, data, data_size);
    task_set_result(Task:task, true);
}

stock DB::LoadCacheSchemaVar(row, schema_var, col_size, data[]) {
    new l_col_name[64]; 
    new l_offset;
    new schema[DB::Column];
    printf("LoadCacheSchemaVar"); 
    printf("variant handle: %i", schema_var);
    for(new i=0;i<col_size;i++) {
        new target[1];
        target[0] = i;
        var_get_md_arr(Variant:schema_var, target, schema);
        switch(schema[DBColumn::type]) {
            case DBColumnType::PK, DBColumnType::INT: {
                format(l_col_name, sizeof(l_col_name), "%s", schema[DBColumn::name]);
                l_offset = schema[DBColumn::data_offset];
                cache_get_value_name_int(row, l_col_name, data[l_offset]);
            }
            case DBColumnType::FLOAT: {
                format(l_col_name, sizeof(l_col_name), "%s", schema[DBColumn::name]);
                l_offset = schema[DBColumn::data_offset];
                cache_get_value_name_float(row, l_col_name, Float:data[l_offset]);
            }
            case DBColumnType::STRING: {
                format(l_col_name, sizeof(l_col_name), "%s", schema[DBColumn::name]);
                l_offset = schema[DBColumn::data_offset];
                new l_len = schema[DBColumn::data_length];
                cache_get_value_name(row, l_col_name, data[l_offset], l_len);
            }
            case DBColumnType::VEC2: {
                format(l_col_name, sizeof(l_col_name), "%sX", schema[DBColumn::name]);
                l_offset = schema[DBColumn::data_offset];
                cache_get_value_name_float(row, l_col_name, Float:data[l_offset]);

                format(l_col_name, sizeof(l_col_name), "%sY", schema[DBColumn::name]);
                l_offset++; 
                cache_get_value_name_float(row, l_col_name, Float:data[l_offset]);
            }
            case DBColumnType::VEC3: {
                format(l_col_name, sizeof(l_col_name), "%sX", schema[DBColumn::name]);
                l_offset = schema[DBColumn::data_offset];
                cache_get_value_name_float(row, l_col_name, Float:data[l_offset]);

                format(l_col_name, sizeof(l_col_name), "%sY", schema[DBColumn::name]);
                l_offset++; 
                cache_get_value_name_float(row, l_col_name, Float:data[l_offset]);

                format(l_col_name, sizeof(l_col_name), "%sZ", schema[DBColumn::name]);
                l_offset++; 
                cache_get_value_name_float(row, l_col_name, Float:data[l_offset]);
            }
        }
    }
    return 1;
}

stock DB::DataDebugVar(const table_name[64], schema_var, col_size, data[]) {
#if defined DEBUG_MODE
    printf("TABLE %s ROW DEBUG", table_name);
    new schema[DB::Column];
    for(new i=0;i<col_size;i++) {
        new target[1];
        target[0] = i;
        var_get_md_arr(Variant:schema_var, target, schema);
        switch(schema[DBColumn::type]) {
            case DBColumnType::INT, DBColumnType::PK: {
                new offset = schema[DBColumn::data_offset];
                printf("%s: %i", schema[DBColumn::name], data[offset]);
            }
            case DBColumnType::FLOAT: {
                new offset = schema[DBColumn::data_offset];
                printf("%s: %.2f", schema[DBColumn::name], data[offset]);
            }
            case DBColumnType::STRING: {
                new offset = schema[DBColumn::data_offset];
                printf("%s: %s", schema[DBColumn::name], data[offset]);
            }
            case DBColumnType::VEC2: {
                new offset = schema[DBColumn::data_offset];
                printf("%sX: %f", schema[DBColumn::name], data[offset]);
                offset++;
                printf("%sY: %f", schema[DBColumn::name], data[offset]);
            }
            case DBColumnType::VEC3: {
                new offset = schema[DBColumn::data_offset];
                printf("%sX: %f", schema[DBColumn::name], data[offset]);
                offset++;
                printf("%sY: %f", schema[DBColumn::name], data[offset]);
                offset++;
                printf("%sZ: %f", schema[DBColumn::name], data[offset]);
            }
        }
    }
    printf("END TABLE %s ROW DEBUG", table_name);
#endif
    return 1;
}



stock DB::DataDebug(const table_name[64], const schema[][], col_size, data[]) {
#if defined DEBUG_MODE
    printf("TABLE %s ROW DEBUG", table_name);
    for(new i=0;i<col_size;i++) {
        switch(schema[i][DBColumn::type]) {
            case DBColumnType::INT, DBColumnType::PK: {
                new offset = schema[i][DBColumn::data_offset];
                printf("%s: %i", schema[i][DBColumn::name], data[offset]);
            }
            case DBColumnType::FLOAT: {
                new offset = schema[i][DBColumn::data_offset];
                printf("%s: %.2f", schema[i][DBColumn::name], data[offset]);
            }
            case DBColumnType::STRING: {
                new offset = schema[i][DBColumn::data_offset];
                printf("%s: %s", schema[i][DBColumn::name], data[offset]);
            }
            case DBColumnType::VEC2: {
                new offset = schema[i][DBColumn::data_offset];
                printf("%sX: %f", schema[i][DBColumn::name], data[offset]);
                offset++;
                printf("%sY: %f", schema[i][DBColumn::name], data[offset]);
            }
            case DBColumnType::VEC3: {
                new offset = schema[i][DBColumn::data_offset];
                printf("%sX: %f", schema[i][DBColumn::name], data[offset]);
                offset++;
                printf("%sY: %f", schema[i][DBColumn::name], data[offset]);
                offset++;
                printf("%sZ: %f", schema[i][DBColumn::name], data[offset]);
            }
        }
    }
    printf("END TABLE %s ROW DEBUG", table_name);
#endif
    return 1;
}

stock DB::LoadCacheSchema(row, const schema[][], col_size, data[]) {
    new l_col_name[64]; 
    new l_offset;
    for(new i=0;i<col_size;i++) {
        switch(schema[i][DBColumn::type]) {
            case DBColumnType::PK, DBColumnType::INT: {
                format(l_col_name, sizeof(l_col_name), "%s", schema[i][DBColumn::name]);
                l_offset = schema[i][DBColumn::data_offset];
                cache_get_value_name_int(row, l_col_name, data[l_offset]);
            }
            case DBColumnType::FLOAT: {
                format(l_col_name, sizeof(l_col_name), "%s", schema[i][DBColumn::name]);
                l_offset = schema[i][DBColumn::data_offset];
                cache_get_value_name_float(row, l_col_name, Float:data[l_offset]);
            }
            case DBColumnType::STRING: {
                format(l_col_name, sizeof(l_col_name), "%s", schema[i][DBColumn::name]);
                l_offset = schema[i][DBColumn::data_offset];
                new l_len = schema[i][DBColumn::data_length];
                cache_get_value_name(row, l_col_name, data[l_offset], l_len);
            }
            case DBColumnType::VEC2: {
                format(l_col_name, sizeof(l_col_name), "%sX", schema[i][DBColumn::name]);
                l_offset = schema[i][DBColumn::data_offset];
                cache_get_value_name_float(row, l_col_name, Float:data[l_offset]);

                format(l_col_name, sizeof(l_col_name), "%sY", schema[i][DBColumn::name]);
                l_offset++; 
                cache_get_value_name_float(row, l_col_name, Float:data[l_offset]);
            }
            case DBColumnType::VEC3: {
                format(l_col_name, sizeof(l_col_name), "%sX", schema[i][DBColumn::name]);
                l_offset = schema[i][DBColumn::data_offset];
                cache_get_value_name_float(row, l_col_name, Float:data[l_offset]);

                format(l_col_name, sizeof(l_col_name), "%sY", schema[i][DBColumn::name]);
                l_offset++; 
                cache_get_value_name_float(row, l_col_name, Float:data[l_offset]);

                format(l_col_name, sizeof(l_col_name), "%sZ", schema[i][DBColumn::name]);
                l_offset++; 
                cache_get_value_name_float(row, l_col_name, Float:data[l_offset]);
            }
        }
    }
    return 1;
}

stock DB::MakeInsertQuery(const table_name[64], schema[][], col_size, with_pk=false) {
    new l_key[128];
    szMiscArray[0] = 0;
    format(l_key,sizeof(l_key), "insert_%s", table_name);
    if(map_has_str_key(DB::query_fmt_cache, l_key)) {
        map_str_get_str(DB::query_fmt_cache, l_key, szMiscArray);
    } else {
        format(szMiscArray,sizeof(szMiscArray),
        "INSERT INTO `%s` (", table_name);

        for(new i=0;i<col_size;i++) { // colname
            if(!with_pk && schema[i][DBColumn::type] == DBColumnType::PK) continue;
            if(schema[i][DBColumn::type] == DBColumnType::VEC3) {
                format(szMiscArray,sizeof(szMiscArray), "%s `%sX`,", szMiscArray, schema[i][DBColumn::name]);
                format(szMiscArray,sizeof(szMiscArray), "%s `%sY`,", szMiscArray, schema[i][DBColumn::name]);
                format(szMiscArray,sizeof(szMiscArray), "%s `%sZ`%s", szMiscArray, schema[i][DBColumn::name], SEPARATOR_CHECK(col_size));
            } else if(schema[i][DBColumn::type] == DBColumnType::VEC2) {
                format(szMiscArray,sizeof(szMiscArray), "%s `%sX`,", szMiscArray, schema[i][DBColumn::name]);
                format(szMiscArray,sizeof(szMiscArray), "%s `%sY`%s", szMiscArray, schema[i][DBColumn::name], SEPARATOR_CHECK(col_size));
            } else {
                format(szMiscArray,sizeof(szMiscArray), "%s `%s`%s", szMiscArray, schema[i][DBColumn::name], SEPARATOR_CHECK(col_size));
            }
        }
        format(szMiscArray,sizeof(szMiscArray),
        "%s ) VALUES (", szMiscArray);
        for(new i=0;i<col_size;i++) { // values
            switch(schema[i][DBColumn::type]) {
                case DBColumnType::PK: {
                    if(!with_pk) continue;
                    format(szMiscArray,sizeof(szMiscArray), 
                        "%s '%%i'%s", szMiscArray,SEPARATOR_CHECK(col_size));
                }
                case DBColumnType::INT: {
                    format(szMiscArray,sizeof(szMiscArray), 
                        "%s '%%i'%s", szMiscArray,SEPARATOR_CHECK(col_size));
                }
                case DBColumnType::FLOAT: {
                    format(szMiscArray,sizeof(szMiscArray), 
                        "%s '%%f'%s", szMiscArray,SEPARATOR_CHECK(col_size));
                }
                case DBColumnType::STRING: {
                    format(szMiscArray,sizeof(szMiscArray), 
                        "%s '%%e'%s", szMiscArray,SEPARATOR_CHECK(col_size));
                }
                case DBColumnType::VEC2: {
                    format(szMiscArray,sizeof(szMiscArray), 
                        "%s '%%f', '%%f'%s", szMiscArray,SEPARATOR_CHECK(col_size));
                }
                case DBColumnType::VEC3: {
                    format(szMiscArray,sizeof(szMiscArray), 
                        "%s '%%f', '%%f', '%%f'%s", szMiscArray,SEPARATOR_CHECK(col_size));
                }
            }
        }
        format(szMiscArray,sizeof(szMiscArray),
        "%s )", szMiscArray);

        map_str_add_str(DB::query_fmt_cache, l_key, szMiscArray);
    }
    return 1;
}

stock DB::PopulateInsertQuery(const schema[][], col_size, const data[], with_pk=false) {
    mysql_format(MainConn,szQuery,sizeof(szQuery), "%i", 1);
    new l_offset = 0;
    new startStackFrame;
    new i;
    
    szQuery[0] = 0;
    new totalArgs = 0;
    // Allocate stack variable before this line
    #emit LCTRL 4
    #emit STOR.S.pri startStackFrame
    for(i = col_size-1; i > -1; i--) {
        switch(schema[i][DBColumn::type]) {
            case DBColumnType::PK: {
                if(!with_pk) continue;
                l_offset = schema[i][DBColumn::data_offset];
                totalArgs += 1;
                #emit LOAD.S.alt data
                #emit LOAD.S.pri l_offset
                #emit IDXADDR
                #emit PUSH.pri
            }
            case DBColumnType::INT, DBColumnType::FLOAT: {
                l_offset = schema[i][DBColumn::data_offset];
                totalArgs += 1;
                #emit LOAD.S.alt data
                #emit LOAD.S.pri l_offset
                #emit IDXADDR
                #emit PUSH.pri
            }
            case DBColumnType::STRING: {
                l_offset = schema[i][DBColumn::data_offset];
                #emit LOAD.S.alt data
                #emit LOAD.S.pri l_offset
                #emit IDXADDR
                #emit PUSH.pri
                totalArgs += 1;
            }
            case DBColumnType::VEC3: {
                l_offset = schema[i][DBColumn::data_offset]+2;
                totalArgs += 3;
                // push Z first
                #emit LOAD.S.alt data
                #emit LOAD.S.pri l_offset
                #emit IDXADDR
                #emit PUSH.pri
                l_offset--;

                // push Y
                #emit LOAD.S.alt data
                #emit LOAD.S.pri l_offset
                #emit IDXADDR
                #emit PUSH.pri
                l_offset--;

                // push X
                #emit LOAD.S.alt data
                #emit LOAD.S.pri l_offset
                #emit IDXADDR
                #emit PUSH.pri
            }
        }
    }

    totalArgs += 4; // add argv + argc (4)
    totalArgs = totalArgs * 4;
    // Push initial arguments
    #emit CONST.pri szMiscArray // global variable must be formatted before calling this function
    #emit PUSH.pri
    #emit PUSH.C 4096 // this szMiscArray size
    #emit CONST.pri szQuery // global variable
    #emit PUSH.pri
    #emit LOAD.pri MainConn // Push ConnHandle global variable
    #emit PUSH.pri
    #emit LOAD.S.pri totalArgs // Push total arguments
    #emit PUSH.pri
    #emit SYSREQ.C mysql_format

    // Clear stack frame
    #emit LOAD.S.pri startStackFrame
    #emit SCTRL 4
#if defined DEBUG_MODE
    printf("%s", szQuery);
#endif
    return 1;
}

stock DB::MakeUpdateQuery(const table_name[64], schema[][], col_size) {
    new l_key[128];
    szMiscArray[0] = 0;
    format(l_key,sizeof(l_key), "update_%s", table_name);
    if(map_has_str_key(DB::query_fmt_cache, l_key)) {
        map_str_get_str(DB::query_fmt_cache, l_key, szMiscArray);
    } else {
        format(szMiscArray,sizeof(szMiscArray),
        "UPDATE `%s` SET ", table_name);
        for(new i=0;i<col_size;i++) { // values
            switch(schema[i][DBColumn::type]) {
                case DBColumnType::INT: {
                    format(szMiscArray,sizeof(szMiscArray), 
                        "%s `%s`='%%i'%s", szMiscArray,schema[i][DBColumn::name], SEPARATOR_CHECK(col_size));
                }
                case DBColumnType::FLOAT: {
                    format(szMiscArray,sizeof(szMiscArray), 
                        "%s `%s`='%%f'%s", szMiscArray,schema[i][DBColumn::name], SEPARATOR_CHECK(col_size));
                }
                case DBColumnType::STRING: {
                    format(szMiscArray,sizeof(szMiscArray), 
                        "%s `%s`='%%e'%s", szMiscArray, schema[i][DBColumn::name], SEPARATOR_CHECK(col_size));
                }
                case DBColumnType::VEC2: {
                    format(szMiscArray,sizeof(szMiscArray), 
                        "%s `%sX`='%%f', `%sY`='%%f'%s", szMiscArray,
                        schema[i][DBColumn::name],
                        schema[i][DBColumn::name],
                        SEPARATOR_CHECK(col_size));
                }
                case DBColumnType::VEC3: {
                    format(szMiscArray,sizeof(szMiscArray), 
                        "%s `%sX`='%%f', `%sY`='%%f', `%sZ`='%%f'%s", szMiscArray,
                        schema[i][DBColumn::name],
                        schema[i][DBColumn::name],
                        schema[i][DBColumn::name],
                        SEPARATOR_CHECK(col_size));
                }
            }
        }
        format(szMiscArray,sizeof(szMiscArray),
        "%s WHERE id='%%i'", szMiscArray);
    }
    return 1;
}

stock DB::PopulateUpdateQuery(const schema[][], col_size, const data[]) {
    mysql_format(MainConn,szQuery,sizeof(szQuery), "%i", 1);
    new l_offset = 0;
    new startStackFrame;
    new i;
    
    szQuery[0] = 0;
    new totalArgs = 1;
    // Allocate stack variable before this line
    #emit LCTRL 4
    #emit STOR.S.pri startStackFrame
   
    #emit LOAD.S.alt data
    #emit LOAD.S.pri l_offset
    #emit IDXADDR
    #emit PUSH.pri
    for(i = col_size-1; i > -1; i--) {
        switch(schema[i][DBColumn::type]) {
            case DBColumnType::INT, DBColumnType::FLOAT: {
                l_offset = schema[i][DBColumn::data_offset];
                totalArgs += 1;
                #emit LOAD.S.alt data
                #emit LOAD.S.pri l_offset
                #emit IDXADDR
                #emit PUSH.pri
            }
            case DBColumnType::STRING: {
                l_offset = schema[i][DBColumn::data_offset];
                #emit LOAD.S.alt data
                #emit LOAD.S.pri l_offset
                #emit IDXADDR
                #emit PUSH.pri
                totalArgs += 1;
            }
            case DBColumnType::VEC2: {
                l_offset = schema[i][DBColumn::data_offset]+1;
                totalArgs += 2;
                // push Y
                #emit LOAD.S.alt data
                #emit LOAD.S.pri l_offset
                #emit IDXADDR
                #emit PUSH.pri
                l_offset--;

                // push X
                #emit LOAD.S.alt data
                #emit LOAD.S.pri l_offset
                #emit IDXADDR
                #emit PUSH.pri
            }
            
            case DBColumnType::VEC3: {
                l_offset = schema[i][DBColumn::data_offset]+2;
                totalArgs += 3;
                // push Z first
                #emit LOAD.S.alt data
                #emit LOAD.S.pri l_offset
                #emit IDXADDR
                #emit PUSH.pri
                l_offset--;

                // push Y
                #emit LOAD.S.alt data
                #emit LOAD.S.pri l_offset
                #emit IDXADDR
                #emit PUSH.pri
                l_offset--;

                // push X
                #emit LOAD.S.alt data
                #emit LOAD.S.pri l_offset
                #emit IDXADDR
                #emit PUSH.pri
            }
        }
    }

    totalArgs += 4; // add argv + argc (4)
    totalArgs = totalArgs * 4;
    // Push initial arguments
    #emit CONST.pri szMiscArray // global variable must be formatted before calling this function
    #emit PUSH.pri
    #emit PUSH.C 4096 // this szMiscArray size
    #emit CONST.pri szQuery // global variable
    #emit PUSH.pri
    #emit LOAD.pri MainConn // Push ConnHandle global variable
    #emit PUSH.pri
    #emit LOAD.S.pri totalArgs // Push total arguments
    #emit PUSH.pri
    #emit SYSREQ.C mysql_format

    // Clear stack frame
    #emit LOAD.S.pri startStackFrame
    #emit SCTRL 4

#if defined DEBUG_MODE
    printf("%s", szQuery);
#endif
    return 1;
}

stock DB::MakeDeleteRow(const table_name[56], p_id) {
    szQuery[0] = 0;
    mysql_format(MainConn, szQuery, sizeof(szQuery), "DELETE FROM `%s` WHERE id='%i' ", table_name, p_id);
#if defined DEBUG_MODE
    printf("%s", szQuery);
#endif
    return 1;
}
