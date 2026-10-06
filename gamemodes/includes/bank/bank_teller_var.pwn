#define BankTeller:: bnk_tllr_

#define bnk_tllr_IsUsingTeller(%0) GetPVarInt(%0,"BNK_TLLR_Using")
#define bnk_tllr_SetUsingTeller(%0,%1) SetPVarInt(%0,"BNK_TLLR_Using",%1)
#define bnk_tllr_SetTellerID(%0,%1) SetPVarInt(%0,"BNK_TLLR_TellerID",%1)
#define bnk_tllr_GetTellerID(%0) GetPVarInt(%0,"BNK_TLLR_TellerID")

enum BankTeller::e_Teller {
    BankTeller::id,
    Float:BankTeller::pos[3],
    BankTeller::intId,
    BankTeller::vwId,
    bool:BankTeller::used,
    BankTeller::pickupId,
    Text3D:BankTeller::textId,
    BankTeller::areaId,
}

new BankTeller::Schema[][DB::Column] = {
    {"id", DBColumnType::PK, BankTeller::id},
    {"pos", DBColumnType::VEC3, BankTeller::pos},
    {"interior", DBColumnType::INT, BankTeller::intId},
    {"vw", DBColumnType::INT, BankTeller::vwId}
};

new List:BankTeller::teller_list;
