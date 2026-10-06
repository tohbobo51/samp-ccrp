#define Dialog:: dlg_
#define DialogResponse:: dlg_r_

#define dlg_SetDialogID(%0,%1) SetPVarInt(%0,"DLG_ID",%1)
#define dlg_GetDialogID(%0) GetPVarInt(%0,"DLG_ID")

enum dlg_Style {
    Dialog::MSGBOX,
    Dialog::INPUT,
    Dialog::LIST,
    Dialog::PASSWORD,
    Dialog::TABLIST,
    Dialog::TABLIST_H
};

enum dlg_Info {
    Dialog::id,
    Dialog::taskId
};

enum dlg_r_Info {
    DialogResponse::dialogid,
    DialogResponse::response,
    DialogResponse::listitem,
    DialogResponse::inputtext[128]
};

new dlg_Response[MAX_PLAYERS][DialogResponse::Info];
new Task:dlg_Task[MAX_PLAYERS];
