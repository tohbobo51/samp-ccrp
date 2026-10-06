/*
|================================| Extended Streamer Function |=================================|
|                                                                                               |
| Version:                                                                                      |
|    - 1.0.0-Beta                                                                                |
|                                                                                               |
| Author:                                                                                       |
| 	- Fanorisky                                                                                 |
|                                                                                               |
| Thanks to:                                                                                    |
|   - AbyssMorgan                                                                               |
| 	- Incognito                                                                                 |
| 	- Pottus                                                                                    |
| 	- IllidanS4 (IS4Code)                                                                       |
|                                                                                               |
| Required plugins:                                                                             |
| 	- Streamer                                                                                  |
| 	- YSF                                                                                       |
|                                                                                               |
|===============================================================================================|
*//*
-----------------------------------------/=/ NATIVE /=/-----------------------------------------
native Streamer_SetPosition(type, id, Float:x, Float:y, Float:z);
native Streamer_SetRotation(type, id, Float:rx, Float:ry, Float:rz);
native Streamer_GetPosition(type, id, &Float:x, &Float:y, &Float:z);
native Streamer_GetRotation(type, id, &Float:rx, &Float:ry, &Float:rz);

native Streamer_SetAttachOffset(type, id, Float:ox, Float:oy, Float:oz);
native Streamer_SetAttachOffsetRot(type, id, Float:rox, Float:roy, Float:roz);
native Streamer_GetAttachOffset(type, id, &Float:ox, &Float:oy, &Float:oz);
native Streamer_GetAttachOffsetRot(type, id, &Float:rox, &Float:roy, &Float:roz);

native GetDynamicObjectAttachedID(objectid);

native UnattachDynamicObject(objectid, sync = true);
native UpdateAttachedDynamicObject(objectid);

native GetAttachOffsetToCenterPoint(Float:ax, Float:ay, Float:az, Float:arx, Float:ary, Float:arz, 
    Float:px, Float:py, Float:pz, Float:prx, Float:pry, Float:prz, 
	&Float:RetX, &Float:RetY, &Float:RetZ, &Float:RetRX, &Float:RetRY, &Float:RetRZ, 
	bool:sync_rotation = true);
------------------------------------------------------------------------------------------------
*/

#if defined _ESF_included
	#endinput
#endif
#define _ESF_included

#include <a_samp>

#if !defined _streamer_included
    #error [INCLUDE] Required <streamer> include.
#endif

#include <YSF>

/*---------------------------------------/=/ FORWARD /=/----------------------------------------*/
forward Streamer_GetPosition(type, STREAMER_ALL_TAGS:id, &Float:x, &Float:y, &Float:z);
forward Streamer_GetRotation(type, STREAMER_ALL_TAGS:id, &Float:rx, &Float:ry, &Float:rz);

forward Streamer_GetAttachOffset(type, STREAMER_ALL_TAGS:id, &Float:ox, &Float:oy, &Float:oz);
forward Streamer_GetAttachOffsetRot(type, STREAMER_ALL_TAGS:id, &Float:orx, &Float:ory, &Float:orz);

forward FloatConvertValue(Float:rot_x, Float:rot_y, Float:rot_z, Float:sin[3], Float:cos[3]);
forward FloatEulerFix(&Float:rot_x, &Float:rot_y, &Float:rot_z);
forward FloatGetRemainder(&Float:rot_x, &Float:rot_y, &Float:rot_z);
forward FloatRemainder(&Float:remainder, Float:value);
forward GetDynamicObjectAttachedID(STREAMER_TAG_OBJECT:objectid);
/*----------------------------------------------------------------------------------------------*/
/*---------------------------------------/=/ FUNCTION /=/---------------------------------------*/
stock UnattachDynamicObject(STREAMER_TAG_OBJECT:objectid, bool:sync = true)
{
	new cObject = GetDynamicObjectAttachedID(objectid);
	if(IsValidDynamicObject(objectid))
	{
        if(cObject != 0)
    	{
    		if(sync)
    		{
                UpdateAttachedDynamicObject(objectid);
                Streamer_SetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_ATTACHED_OBJECT, 0);
    		} else Streamer_SetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_ATTACHED_OBJECT, 0);
    	}
	}
}

stock UpdateAttachedDynamicObject(STREAMER_TAG_OBJECT:objectid)
{
	// c(Center), a(attached), ua(update attached)
	new
	    cObject,
	    Float:cPos[6],
	    Float:aPos[6],
	    Float:uaPos[6];
    
    if(IsValidDynamicObject(objectid))
    {
    	cObject = GetDynamicObjectAttachedID(objectid);

    	GetDynamicObjectPos(cObject, cPos[0], cPos[1], cPos[2]);
        GetDynamicObjectRot(cObject, cPos[3], cPos[4], cPos[5]);

        if(cObject != 0)
        {
        	Streamer_GetAttachOffset(STREAMER_TYPE_OBJECT, objectid, aPos[0], aPos[1], aPos[2]);
        	Streamer_GetAttachOffsetRot(STREAMER_TYPE_OBJECT, objectid, aPos[3], aPos[4], aPos[5]);

        	GetAttachOffsetToCenterPoint(
        		aPos[0], aPos[1], aPos[2], aPos[3], aPos[4], aPos[5],
        		cPos[0], cPos[1], cPos[2], cPos[3], cPos[4], cPos[5], 
	            uaPos[0], uaPos[1], uaPos[2], uaPos[3], uaPos[4], uaPos[5]
	        ); 

            Streamer_SetPosition(STREAMER_TYPE_OBJECT, objectid, uaPos[0], uaPos[1], uaPos[2]);
            Streamer_SetRotation(STREAMER_TYPE_OBJECT, objectid, uaPos[3], uaPos[4], uaPos[5]);
        }
    }
}

stock GetAttachOffsetToCenterPoint(Float:ax, Float:ay, Float:az, Float:arx, Float:ary, Float:arz, Float:px, Float:py, Float:pz, Float:prx, Float:pry, Float:prz, 
	&Float:RetX, &Float:RetY, &Float:RetZ, &Float:RetRX, &Float:RetRY, &Float:RetRZ, bool:sync_rotation = true) 
{
    new
        Float:sin[3],
        Float:cos[3],

        Float:off_x,
        Float:off_y,
        Float:off_z;

    FloatEulerFix(prx, pry, prz);

    off_x = (px+ax) - px;
    off_y = (py+ay) - py;
    off_z = (pz+az) - pz;

    // new position
    FloatConvertValue(prx, pry, prz, sin, cos);
    RetX = px + off_x * cos[1] * cos[2] - off_x * sin[0] * sin[1] * sin[2] - off_y * cos[0] * sin[2] + off_z * sin[1] * cos[2] + off_z * sin[0] * cos[1] * sin[2];
    RetY = py + off_x * cos[1] * sin[2] + off_x * sin[0] * sin[1] * cos[2] + off_y * cos[0] * cos[2] + off_z * sin[1] * sin[2] - off_z * sin[0] * cos[1] * cos[2];
    RetZ = pz - off_x * cos[0] * sin[1] + off_y * sin[0] + off_z * cos[0] * cos[1];

    if (sync_rotation)
    {
        // new rotation
        FloatConvertValue(asin(cos[0] * cos[1]), atan2(sin[0], cos[0] * sin[1]) + arz, atan2(cos[1] * cos[2] * sin[0] - sin[1] * sin[2], cos[2] * sin[1] - cos[1] * sin[0] * -sin[2]), sin, cos);
        FloatConvertValue(asin(cos[0] * sin[1]), atan2(cos[0] * cos[1], sin[0]), atan2(cos[2] * sin[0] * sin[1] - cos[1] * sin[2], cos[1] * cos[2] + sin[0] * sin[1] * sin[2]), sin, cos);
        FloatConvertValue(atan2(sin[0], cos[0] * cos[1]) + arx, asin(cos[0] * sin[1]), atan2(cos[2] * sin[0] * sin[1] + cos[1] * sin[2], cos[1] * cos[2] - sin[0] * sin[1] * sin[2]), sin, cos);

        RetRX = asin(cos[1] * sin[0]);
        RetRY = atan2(sin[1], cos[0] * cos[1]) + ary;
        RetRZ = atan2(cos[0] * sin[2] - cos[2] * sin[0] * sin[1], cos[0] * cos[2] + sin[0] * sin[1] * sin[2]);
    }
}

stock GetAttachPointToCenterPoint(Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:px, Float:py, Float:pz, Float:prx, Float:pry, Float:prz, 
	&Float:RetX, &Float:RetY, &Float:RetZ, &Float:RetRX, &Float:RetRY, &Float:RetRZ, sync_rotation = 1) 
{
    new
        Float:sin[3],
        Float:cos[3],

        Float:off_x,
        Float:off_y,
        Float:off_z;

    FloatEulerFix(prx, pry, prz);

    off_x = x - px; // static offset
    off_y = y - py; // static offset
    off_z = z - pz; // static offset

    // new position
    FloatConvertValue(prx, pry, prz, sin, cos);
    RetX = px + off_x * cos[1] * cos[2] - off_x * sin[0] * sin[1] * sin[2] - off_y * cos[0] * sin[2] + off_z * sin[1] * cos[2] + off_z * sin[0] * cos[1] * sin[2];
    RetY = py + off_x * cos[1] * sin[2] + off_x * sin[0] * sin[1] * cos[2] + off_y * cos[0] * cos[2] + off_z * sin[1] * sin[2] - off_z * sin[0] * cos[1] * cos[2];
    RetZ = pz - off_x * cos[0] * sin[1] + off_y * sin[0] + off_z * cos[0] * cos[1];

    if (sync_rotation)
    {
        // new rotation
        FloatConvertValue(asin(cos[0] * cos[1]), atan2(sin[0], cos[0] * sin[1]) + rz, atan2(cos[1] * cos[2] * sin[0] - sin[1] * sin[2], cos[2] * sin[1] - cos[1] * sin[0] * -sin[2]), sin, cos);
        FloatConvertValue(asin(cos[0] * sin[1]), atan2(cos[0] * cos[1], sin[0]), atan2(cos[2] * sin[0] * sin[1] - cos[1] * sin[2], cos[1] * cos[2] + sin[0] * sin[1] * sin[2]), sin, cos);
        FloatConvertValue(atan2(sin[0], cos[0] * cos[1]) + rx, asin(cos[0] * sin[1]), atan2(cos[2] * sin[0] * sin[1] + cos[1] * sin[2], cos[1] * cos[2] - sin[0] * sin[1] * sin[2]), sin, cos);

        RetRX = asin(cos[1] * sin[0]);
        RetRY = atan2(sin[1], cos[0] * cos[1]) + ry;
        RetRZ = atan2(cos[0] * sin[2] - cos[2] * sin[0] * sin[1], cos[0] * cos[2] + sin[0] * sin[1] * sin[2]);
    }
}

stock Streamer_SetPosition(type, STREAMER_ALL_TAGS:id, Float:x, Float:y, Float:z)
{
	Streamer_SetFloatData(type, id, E_STREAMER_X, x);
	Streamer_SetFloatData(type, id, E_STREAMER_Y, y);
	Streamer_SetFloatData(type, id, E_STREAMER_Z, z);
}

stock Streamer_SetRotation(type, STREAMER_ALL_TAGS:id, Float:rx, Float:ry, Float:rz)
{
	Streamer_SetFloatData(type, id, E_STREAMER_R_X, rx);
	Streamer_SetFloatData(type, id, E_STREAMER_R_Y, ry);
	Streamer_SetFloatData(type, id, E_STREAMER_R_Z, rz);
}

stock Streamer_SetAttachOffset(type, STREAMER_ALL_TAGS:id, Float:x, Float:y, Float:z)
{
	Streamer_SetFloatData(type, id, E_STREAMER_ATTACH_OFFSET_X, x);
	Streamer_SetFloatData(type, id, E_STREAMER_ATTACH_OFFSET_Y, y);
	Streamer_SetFloatData(type, id, E_STREAMER_ATTACH_OFFSET_Z, z);
}

stock Streamer_SetAttachOffsetRot(type, STREAMER_ALL_TAGS:id, Float:rx, Float:ry, Float:rz)
{
	Streamer_SetFloatData(type, id, E_STREAMER_ATTACH_R_X, rx);
	Streamer_SetFloatData(type, id, E_STREAMER_ATTACH_R_Y, ry);
	Streamer_SetFloatData(type, id, E_STREAMER_ATTACH_R_Z, rz);
}

/*----------------------------------------/=/ PUBLIC /=/----------------------------------------*/

public GetDynamicObjectAttachedID(STREAMER_TAG_OBJECT:objectid)
{
	return Streamer_GetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_ATTACHED_OBJECT);
}

stock Streamer_GetPosition(type, STREAMER_ALL_TAGS:id, &Float:x, &Float:y, &Float:z)
{
	Streamer_GetFloatData(type, id, E_STREAMER_X, x);
	Streamer_GetFloatData(type, id, E_STREAMER_Y, y);
	Streamer_GetFloatData(type, id, E_STREAMER_Z, z);
	return 1;
}

public Streamer_GetRotation(type, STREAMER_ALL_TAGS:id, &Float:rx, &Float:ry, &Float:rz)
{
	Streamer_GetFloatData(type, id, E_STREAMER_R_X, rx);
	Streamer_GetFloatData(type, id, E_STREAMER_R_Y, ry);
	Streamer_GetFloatData(type, id, E_STREAMER_R_Z, rz);
	return 1;
}

public Streamer_GetAttachOffset(type, STREAMER_ALL_TAGS:id, &Float:ox, &Float:oy, &Float:oz)
{
    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, id, E_STREAMER_ATTACH_OFFSET_X, ox);
    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, id, E_STREAMER_ATTACH_OFFSET_Y, oy);
    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, id, E_STREAMER_ATTACH_OFFSET_Z, oz);
    return 1;
}

public Streamer_GetAttachOffsetRot(type, STREAMER_ALL_TAGS:id, &Float:orx, &Float:ory, &Float:orz)
{
    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, id, E_STREAMER_ATTACH_R_X, orx);
    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, id, E_STREAMER_ATTACH_R_Y, ory);
    Streamer_GetFloatData(STREAMER_TYPE_OBJECT, id, E_STREAMER_ATTACH_R_Z, orz);
    return 1;
}

//Euler
public FloatConvertValue(Float:rot_x, Float:rot_y, Float:rot_z, Float:sin[3], Float:cos[3])
{
    sin[0] = floatsin(rot_x, degrees);
    sin[1] = floatsin(rot_y, degrees);
    sin[2] = floatsin(rot_z, degrees);

    cos[0] = floatcos(rot_x, degrees);
    cos[1] = floatcos(rot_y, degrees);
    cos[2] = floatcos(rot_z, degrees);
    return 1;
}

public FloatEulerFix(&Float:rot_x, &Float:rot_y, &Float:rot_z)
{
    FloatGetRemainder(rot_x, rot_y, rot_z);
    
    if((!floatcmp(rot_x, 0.0) || 
        !floatcmp(rot_x, 360.0))
    && (!floatcmp(rot_y, 0.0) || 
        !floatcmp(rot_y, 360.0))) {
        rot_y = 0.00000002;
    }
    return 1;
}

public FloatGetRemainder(&Float:rot_x, &Float:rot_y, &Float:rot_z)
{
    FloatRemainder(rot_x, 360.0);
    FloatRemainder(rot_y, 360.0);
    FloatRemainder(rot_z, 360.0);
    return 1;
}

public FloatRemainder(&Float:remainder, Float:value)
{
    if(remainder >= value)
    {
        while(remainder >= value)
        {
            remainder = remainder - value;
        }
    }
    else if(remainder < 0.0)
    {
        while(remainder < 0.0)
        {
            remainder = remainder + value;
        }
    }
    return 1;
}
