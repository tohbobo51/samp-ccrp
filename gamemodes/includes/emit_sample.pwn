    // printf("status_flag: %i", data[1]);

    // #emit LOAD.S.alt data
    // #emit LOAD.S.pri l_offset
    // #emit IDXADDR
    // #emit STOR.S.pri grabAddr
    // #emit LOAD.I
    // #emit STOR.S.pri grabValue
    //
    // printf("Grab Addr: %i", grabAddr);
    // printf("Grab Value: %i", grabValue);

    // Data should be in memory for amxgetaddress to work
    // at least available in current stack
    
     
    // #emit LOAD.S.alt data
    // #emit CONST.pri l_offset
    // #emit IDXADDR
    // #emit PUSH.pri
    //
    // l_offset--;
    // #emit LOAD.S.alt data
    // #emit CONST.pri l_offset
    // #emit IDXADDR
    // #emit PUSH.pri
    //
    // #emit ADDR.pri test_str
    // #emit PUSH.pri
    // #emit PUSH.C 4096            // Push size
    // #emit CONST.pri szQuery         // Push destination buffer
    // #emit PUSH.pri
    // #emit LOAD.pri  MainConn        // Push ConnHandle
    // #emit PUSH.pri
    // #emit LOAD.S.pri 24       // Push total arguments
    // #emit PUSH.pri
    // #emit SYSREQ.C mysql_format
    // #emit STACK 28
    //
    //
    // printf("%s", szQuery);
    // return 0;

// TEST BEFORE NATIVE CALL
     // totalArgs = 2;
    // #emit LOAD.S.alt data
    // #emit LOAD.S.pri l_offset
    // #emit IDXADDR
    // #emit PUSH.pri
    //
    // #emit STOR.S.pri grabAddr
    // #emit LOAD.I
    // #emit STOR.S.pri grabValue
    // printf("INT/FLOAT addr: %d data: %d column: '%s' offset: %i", grabAddr, grabValue, schema[l_offset-1][DBColumn::name], l_offset);
    //
    // l_offset--;
    // #emit LOAD.S.alt data
    // #emit LOAD.S.pri l_offset
    // #emit IDXADDR
    // #emit PUSH.pri
    //
    // #emit STOR.S.pri grabAddr
    // #emit LOAD.I
    // #emit STOR.S.pri grabValue
    // printf("INT/FLOAT addr: %d data: %d column: '%s' offset: %i", grabAddr, grabValue, schema[l_offset-1][DBColumn::name], l_offset);
    //
    // 
    // DEBUG HELPER
    // #emit STOR.S.pri grabAddr
    // #emit LOAD.I
    // #emit STOR.S.pri grabValue
    // printf("INT/FLOAT addr: %d data: %d column: '%s' offset: %i", grabAddr, grabValue, schema[i][DBColumn::name], l_offset);

#include <amxmodx>

#define PLUGIN "New Plug-In"
#define VERSION "v1.0.0beta"
#define AUTHOR "KliPPy"

#pragma semicolon true

public
plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_clcmd("say va", "cmdVa");
}

public
cmdVa() {
    pass_variadic("%s %i %s %i", "Hello world", 69, "#emit is dirty", 1337);
}

// Unfortunately, the compiler crashes if we try to SYSREQ.C a native that
// hasn't been used before in a script This is just a little fix for that
public
__may_never_be_called() { client_print(0, 0, {0}); }

pass_variadic(const szFormat[], any : ...) {

    // We want to create such native call:
    // client_print(0, print_chat, szFormat, ...);

    new iArgnum = numargs();
    // +2 because we have to pass "print_chat" and "0" to a native
    new iBytesnum = (iArgnum + 2) * 4;
    // We have to declare iArg here or we'll corrupt the stack.
    // No variable declarations/freeing can be done while we are pushing
    // parameters
    new iArg;

    // We push each "variadic" parameters to the stack
    for (iArg = iArgnum * 4 + 8; iArg > 12; iArg -= 4) {
#emit LCTRL 5
#emit LOAD.S.alt iArg
#emit ADD
#emit LOAD.I
#emit PUSH.pri
    }

// Okay, we've pushed all "variadic" parameters, let's push szFormat now
#emit PUSH.S szFormat

// We have yet to push print_chat and 0
#emit PUSH.C print_chat
#emit PUSH.C 0

// Almost done, now we have to push the the number of bytes we've previously
// pushed to the native It is equal to argument count * 4
#emit PUSH.S iBytesnum

// Finally, call the native
#emit SYSREQ.C client_print

// Now we have to free memory on stack used by parameters; we'll do it by moving
// the stack pointer up
#emit LOAD.S.pri iBytesnum
#emit ADD.C 4
#emit MOVE.alt
#emit LCTRL 4
#emit ADD
#emit SCTRL 4
}

mysql_format(DB_CONN, dest, dest_size, format, ...varargs);


mysql_format(DB_CONN, dest, dest_size, "%i %f %s", var1, var2, var3);

mysql_format(MainConn, szMiscArray,sizeof(szMiscArray),
  "INSERT INTO `vehicle` \
 (modelid, \
 fuel, \
 max_fuel, \
 health, \
 posX, \
 posY, \
 posZ, \
 angle, \
 dmg_panels, \
 dmg_doors, \
 dmg_lights, \
 dmg_tires, \
 color1, \
 color2, \
 engine_type, \
 odo_km, \
 odo_m, \
 serial, \
 key_attached, \
 plate_number \
 ) VALUES ( ");
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%i',",
             szMiscArray,vData[VehicleData::modelid]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%f',",
             szMiscArray,vData[VehicleData::fuel]); 
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%f',",
             szMiscArray,vData[VehicleData::max_fuel]); 
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%f',",
             szMiscArray,vData[VehicleData::health]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%f',",
             szMiscArray,vData[VehicleData::spawnPos][0]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%f',",
             szMiscArray,vData[VehicleData::spawnPos][1]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%f',",
             szMiscArray,vData[VehicleData::spawnPos][2]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%f',",
             szMiscArray,vData[VehicleData::health]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%i',",
             szMiscArray,vData[VehicleData::dmgStat][VehicleDmgStat::panels]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%i',",
             szMiscArray,vData[VehicleData::dmgStat][VehicleDmgStat::doors]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%i',",
             szMiscArray,vData[VehicleData::dmgStat][VehicleDmgStat::lights]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%i',",
             szMiscArray,vData[VehicleData::dmgStat][VehicleDmgStat::tires]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%i',",
             szMiscArray,vData[VehicleData::color][0]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%i',",
             szMiscArray,vData[VehicleData::color][1]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%i',",
             szMiscArray,vData[VehicleData::engineType]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%i',",
             szMiscArray,vData[VehicleData::odo_km]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%i',",
             szMiscArray,vData[VehicleData::odo_m]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%i',",
             szMiscArray,vData[VehicleData::serial]); 
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%i',",
             szMiscArray,vData[VehicleData::key_attached]);
mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),"%s '%s' )",
             szMiscArray,vData[VehicleData::plateNumber]);
    

    mysql_format(MainConn,szMiscArray, sizeof(szMiscArray), "UPDATE `vehicle` SET");
    mysql_format(MainConn,szMiscArray, sizeof(szMiscArray), 
                "%s fuel = '%f',", szMiscArray, vData[VehicleData::fuel]);
    mysql_format(MainConn,szMiscArray, sizeof(szMiscArray),
                "%s max_fuel = '%f',", szMiscArray,vData[VehicleData::max_fuel]);
    mysql_format(MainConn,szMiscArray, sizeof(szMiscArray),
                "%s health = '%f',", szMiscArray, vData[VehicleData::health]);
    mysql_format(MainConn,szMiscArray, sizeof(szMiscArray),
                "%s posX = '%f',", szMiscArray, vData[VehicleData::spawnPos][0]);
    mysql_format(MainConn,szMiscArray, sizeof(szMiscArray),
                "%s posY = '%f',", szMiscArray, vData[VehicleData::spawnPos][1]);
    mysql_format(MainConn,szMiscArray, sizeof(szMiscArray),
                "%s posZ = '%f',", szMiscArray, vData[VehicleData::spawnPos][2]);
    mysql_format(MainConn,szMiscArray, sizeof(szMiscArray),
                "%s angle = '%f',", szMiscArray, vData[VehicleData::zAngle]);
    mysql_format(MainConn, szMiscArray, sizeof(szMiscArray),
                "%s dmg_panels = '%i',", szMiscArray, vData[VehicleData::dmgStat][VehicleDmgStat::panels]);
    mysql_format(MainConn, szMiscArray, sizeof(szMiscArray),
                "%s dmg_doors = '%i',", szMiscArray, vData[VehicleData::dmgStat][VehicleDmgStat::doors]);
    mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),
                "%s dmg_lights = '%i',", szMiscArray, vData[VehicleData::dmgStat][VehicleDmgStat::lights]);
    mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),
                "%s dmg_tires = '%i',", szMiscArray, vData[VehicleData::dmgStat][VehicleDmgStat::tires]);
    mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),
                "%s color1='%i',color2='%i',",
                szMiscArray,
                vData[VehicleData::color][0],
                vData[VehicleData::color][1]);
    mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),
                "%s engine_type='%i',", szMiscArray, vData[VehicleData::engineType]);
    mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),
                "%s odo_km='%i',odo_m='%i',",
                szMiscArray,
                vData[VehicleData::odo_km], vData[VehicleData::odo_m]);
    mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),
                "%s serial='%i',", szMiscArray, vData[VehicleData::serial]);
    mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),
                "%s key_attached='%i',",szMiscArray,vData[VehicleData::key_attached]);
    mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),
                "%s params='%i',", szMiscArray, vData[VehicleData::params]);
    mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),
                "%s plate_number='%s'",szMiscArray,vData[VehicleData::plateNumber]);
    mysql_format(MainConn,szMiscArray,sizeof(szMiscArray),
                "%s WHERE id = '%i'", szMiscArray, vData[VehicleData::id]);

    DB::MakeUpdateQuery("vehicle", Vehicle::Schema, sizeof(Vehicle::Schema));
    DB::PopulateUpdateQuery(Vehicle::Schema, sizeof(Vehicle::Schema), vData);


            // cache_get_value_name_int(i, "id", vData[VehicleData::id]);
            // cache_get_value_name_int(i, "modelid", vData[VehicleData::modelid]);
            // cache_get_value_name_float(i, "health", vData[VehicleData::health]);
            // cache_get_value_name_float(i, "posX", vData[VehicleData::spawnPos][0]);
            // cache_get_value_name_float(i, "posY", vData[VehicleData::spawnPos][1]);
            // cache_get_value_name_float(i, "posZ", vData[VehicleData::spawnPos][2]);
            // cache_get_value_name_float(i, "angle", vData[VehicleData::zAngle]);
            // cache_get_value_name_int(i, 
            //                          "dmg_panels", 
            //                          vData[VehicleData::dmgStat][VehicleDmgStat::panels]);
            // cache_get_value_name_int(i, 
            //                          "dmg_doors", 
            //                          vData[VehicleData::dmgStat][VehicleDmgStat::doors]);
            // cache_get_value_name_int(i, 
            //                          "dmg_lights", 
            //                          vData[VehicleData::dmgStat][VehicleDmgStat::lights]);
            // cache_get_value_name_int(i, 
            //                          "dmg_tires", 
            //                          vData[VehicleData::dmgStat][VehicleDmgStat::tires]);
            // cache_get_value_name_int(i, "color1", vData[VehicleData::color][0]);
            // cache_get_value_name_int(i, "color2", vData[VehicleData::color][1]);
            // cache_get_value_name(i, "plate_number", vData[VehicleData::plateNumber], 10);
            // cache_get_value_name_float(i, "fuel", vData[VehicleData::fuel]);
            // cache_get_value_name_float(i, "max_fuel", vData[VehicleData::max_fuel]);
            // cache_get_value_name_int(i, "engine_type", vData[VehicleData::engineType]);
            // cache_get_value_name_int(i, "odo_km", vData[VehicleData::odo_km]);
            // cache_get_value_name_int(i, "odo_m", vData[VehicleData::odo_m]);
            // cache_get_value_name_int(i, "serial", vData[VehicleData::serial]);
            // cache_get_value_name_int(i, "params", vData[VehicleData::params]);
            // cache_get_value_name_int(i, "key_attached", vData[VehicleData::key_attached]);
