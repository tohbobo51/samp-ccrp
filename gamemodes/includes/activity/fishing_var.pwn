#define Fishing:: fshg_

#define fshg_IsUsingRod(%0) GetPVarInt(%0, "IsUsingFRod")
#define fshg_SetIsUsingRod(%0,%1) SetPVarInt(%0, "IsUsingFRod", %1)

#define fshg_IsFishing(%0) GetPVarInt(%0, "IsFishing")
#define fshg_SetIsFishing(%0,%1) SetPVarInt(%0, "IsFishing", %1)

#define fshg_SetStartTime(%0,%1) SetPVarInt(%0, "FishingStartTime", %1)
#define fshg_GetStartTime(%0) GetPVarInt(%0, "FishingStartTime")

#define fshg_GotFishID(%0) GetPVarInt(%0, "GotFishID")
#define fshg_SetGotFishID(%0,%1) SetPVarInt(%0, "GotFishID", %1)

#define fshg_FishingTime(%0) GetPVarInt(%0, "FishingTime")
#define fshg_SetFishingTime(%0,%1) SetPVarInt(%0, "FishingTime", %1)

#define fshg_Finish(%0) GetPVarInt(%0, "FinishFishing")
#define fshg_SetFinish(%0,%1) SetPVarInt(%0, "FinishFishing", %1)



new Fishing::AO_ROD_DATA[attached_object_data] = {
    0.071999, // ox
    0.037999, // oy
    0.000000, // oz
    0.000000, // rx
    157.200042, // ry
    -172.000015 // rz
};




