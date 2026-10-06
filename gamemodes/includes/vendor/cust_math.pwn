/*--------------------------------------------------------------------------------------------------
    Function:
        AdjustVector
    Params:
        & Float: vX - x Vector to adjust
        & Float: vY - y Vector to adjust
        & Float: vZ - z Vector to adjust
        Float: oX - x Offset Vector
        Float: oY - y Offset Vector
        const Float: oZ - z Offset Vector
    Return:
        -
    Notes:
        Adjust the vector with the offset
--------------------------------------------------------------------------------------------------*/
 
stock AdjustVector(& Float: vX, & Float: vY, & Float: vZ, Float: oX, Float: oY, const Float: oZ) { // Credits Nero_3D
    static
        Float: Angle;
    Angle = -atan2(vX, vY);
    if(45.0 < Angle) {
        oX ^= oY;
        oY ^= oX;
        oX ^= oY;
        if(90.0 < Angle) {
            oX *= -1;
            if(135.0 < Angle) {
                oX *= -1;
                oX ^= oY;
                oY ^= oX;
                oX ^= oY;
                oX *= -1;
            }
        }
    } else if(Angle < 0.0) {
        oY *= -1;
        if(Angle < -45.0) {
            oX *= -1;
            oX ^= oY;
            oY ^= oX;
            oX ^= oY;
            oX *= -1;
            if(Angle < -90.0) {
                oX *= -1;
                if(Angle < -135.0) {
                    oX ^= oY;
                    oY ^= oX;
                    oX ^= oY;
                }
            }
        }
    }
    vX += oX,
    vY += oY;
    vZ += oZ;
    return false;
}
/*--------------------------------------------------------------------------------------------------
    Function:
        GetPlayerCameraWeaponVector
    Params:
        playerid - Player to get the weapon vector of
        & Float: vX - x Vector variable
        & Float: vY - y Vector variable
        & Float: vZ - z Vector variable
    Return:
        If the player is connected
    Notes:
        Gets the weapon vector of the player
 
native GetPlayerCameraWeaponVector(playerid, & Float: vX, & Float: vY, & Float: vZ);
--------------------------------------------------------------------------------------------------*/
stock GetPlayerCameraWeaponVector(playerid, & Float: vX, & Float: vY, & Float: vZ) { // Credits Nero_3D
    static
        weapon;
    if(21 < (weapon = GetPlayerWeapon(playerid)) < 39) {
        GetPlayerCameraFrontVector(playerid, vX, vY, vZ);
        switch(weapon) {
            case WEAPON_SNIPER, WEAPON_ROCKETLAUNCHER, WEAPON_HEATSEEKER: {}
            case WEAPON_RIFLE: {
                AdjustVector(vX, vY, vZ, 0.016204, 0.009899, 0.047177);
            }
            case WEAPON_AK47, WEAPON_M4: {
                AdjustVector(vX, vY, vZ, 0.026461, 0.013070, 0.069079);
            }
            default: {
                AdjustVector(vX, vY, vZ, 0.043949, 0.015922, 0.103412);
            }
        }
        return true;
    }
    else
        GetPlayerCameraFrontVector(playerid, vX, vY, vZ);
    return false;
}
stock crossp(Float:v1x, Float:v1y, Float:v1z, Float:v2x, Float:v2y, Float:v2z, &Float:output)
{
    new
        Float:c1 = (v1y * v2z) - (v1z * v2y),
        Float:c2 = (v1z * v2x) - (v1x * v2z),
        Float:c3 = (v1x * v2y) - (v1y * v2x);
    output = floatsqroot ((c1 * c1) + (c2 * c2) + (c3 * c3));
    return 0;
}



// Function to calculate the cross product of two vectors
stock CrossProduct(const Float:v1[3], const Float:v2[3], Float:result[3]) {
    result[0] = v1[1] * v2[2] - v1[2] * v2[1];
    result[1] = v1[2] * v2[0] - v1[0] * v2[2];
    result[2] = v1[0] * v2[1] - v1[1] * v2[0];
}

// stock CrossProduct(const Float:v1[], const Float:v2[], Float:result[])
// {
//     result[0] = v1[1] * v2[2] - v1[2] * v2[1];
//     result[1] = v1[2] * v2[0] - v1[0] * v2[2];
//     result[2] = v1[0] * v2[1] - v1[1] * v2[0];
// }

// Function to normalize a vector
stock NormalizeVector(Float:vector[3]) {
    new Float:length = VectorSize(vector[0],vector[1],vector[2]);
    if (length > 0.0) {
        vector[0] /= length;
        vector[1] /= length;
        vector[2] /= length;
    }
}


stock RotationVectorToQuaternion(const Float:rotationVector[], Float:quaternion[]) {
    new Float:magnitude = floatsqroot(rotationVector[0] * rotationVector[0] +
                                      rotationVector[1] * rotationVector[1] +
                                      rotationVector[2] * rotationVector[2]);

    if (magnitude < 0.0001)
    {
        quaternion[0] = 1.0;
        quaternion[1] = 0.0;
        quaternion[2] = 0.0;
        quaternion[3] = 0.0;
        return;
    }

    new Float:halfAngle = magnitude / 2.0;
    new Float:sinHalfAngle = floatsin(halfAngle);
    new Float:cosHalfAngle = floatcos(halfAngle);

    new Float:ax = rotationVector[0] / magnitude;
    new Float:ay = rotationVector[1] / magnitude;
    new Float:az = rotationVector[2] / magnitude;

    quaternion[0] = cosHalfAngle;
    quaternion[1] = ax * sinHalfAngle;
    quaternion[2] = ay * sinHalfAngle;
    quaternion[3] = az * sinHalfAngle;
}

stock VectorPitch(const Float:frontVector[3], const Float:rightVector[3], Float:pitchAngle, Float:newFrontVector[3]) {
    // Convert pitch angle from degrees to radians
    pitchAngle = pitchAngle * 3.14159265358979323846 / 180.0;

    // Create a quaternion representing the pitch rotation around the right vector
    new Float:qw = floatcos(pitchAngle / 2.0);
    new Float:qx = rightVector[0] * floatsin(pitchAngle / 2.0);
    new Float:qy = rightVector[1] * floatsin(pitchAngle / 2.0);
    new Float:qz = rightVector[2] * floatsin(pitchAngle / 2.0);

    // Convert the front vector to a quaternion (assuming w = 0)
    new Float:fw = 0.0;
    new Float:fx = frontVector[0];
    new Float:fy = frontVector[1];
    new Float:fz = frontVector[2];

    // Perform quaternion multiplication (rotation quaternion * front vector quaternion * conjugate of rotation quaternion)
    new Float:rw = qw * fw - qx * fx - qy * fy - qz * fz;
    new Float:rx = qw * fx + qx * fw + qy * fz - qz * fy;
    new Float:ry = qw * fy - qx * fz + qy * fw + qz * fx;
    new Float:rz = qw * fz + qx * fy - qy * fx + qz * fw;

    new Float:rrx = rw * qx + rx * qw + ry * qz - rz * qy;
    new Float:rry = rw * qy - rx * qz + ry * qw + rz * qx;
    new Float:rrz = rw * qz + rx * qy - ry * qx + rz * qw;

    // Extract the rotated front vector from the resulting quaternion
    newFrontVector[0] = rrx;
    newFrontVector[1] = rry;
    newFrontVector[2] = rrz;
}
