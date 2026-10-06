#include <pp-hooks>
hook OnPlayerConnect(playerid) {
    Dialog::ClearResponse(playerid);
}

stock Dialog::ClearResponse(playerid) {
    Dialog::Response[playerid][DialogResponse::response] = 0;
    Dialog::Response[playerid][DialogResponse::listitem] = -1;
    Dialog::Response[playerid][DialogResponse::inputtext][0] = 0;
    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    new p_dialogId = Dialog::GetDialogID(playerid);
    Dialog::SetDialogID(playerid, 0);
    if(dialogid == p_dialogId) {
        Dialog::Response[playerid][DialogResponse::dialogid] = dialogid;
        Dialog::Response[playerid][DialogResponse::response] = response;
        Dialog::Response[playerid][DialogResponse::listitem] = listitem;
        format(Dialog::Response[playerid][DialogResponse::inputtext], 127, "%s", inputtext);
        if(task_valid(Dialog::Task[playerid])) {
            task_set_result(Dialog::Task[playerid], response);
        }
        return 1;
    }
    return 0;
}

stock Task:Dialog::ShowAsyncDialog(playerid, Dialog::Style:style, const caption[64], const info[], const button1[], const button2[] = "") {
    Dialog::ClearResponse(playerid);
    new dialog_id = random(999) + 1;
    Dialog::SetDialogID(playerid, dialog_id);
    ShowPlayerDialog(playerid, dialog_id, _:style, caption, info, button1, button2);
    if(Dialog::Task[playerid] && task_valid(Dialog::Task[playerid])) {
        task_delete(Dialog::Task[playerid]);
    }
    Dialog::Task[playerid] = task_new();
    return Dialog::Task[playerid];
}

stock Dialog::DEBUG_Response(playerid) {
    new szInfo[1024];
    format(szInfo, sizeof(szInfo), "DIALOG RESPONSE DEBUG:\n\
    \tdialogid: %i\n\
    \tresponse: %i\n\
    \tlistitem: %i\n\
    \tinputtext: %s\n",
        Dialog::Response[playerid][DialogResponse::dialogid],
        Dialog::Response[playerid][DialogResponse::response],
        Dialog::Response[playerid][DialogResponse::listitem],
        Dialog::Response[playerid][DialogResponse::inputtext]
    );
    return 1;
}
