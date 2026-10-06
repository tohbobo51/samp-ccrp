callback CEFOnPlayerText(player_id, const arguments[]) {
  if(arguments[0] == 47) { // Emulating command from WebUI
    PC_EmulateCommand(player_id, arguments);
    return 1;
  }
  if(isSpawned[player_id]) {
    new message[1024];
    format(message, sizeof(message), "%s says: %s", GetName(player_id), arguments);
    SendProximityMessage(PLAYER_TEXT_CHAT_RADIUS, player_id, "says",arguments, -1);
    SetPlayerChatBubble(player_id, message, -1,PLAYER_TEXT_CHAT_RADIUS, 5000);
  }
  return 1;
}

EMIT_PlayerChat(targetid,senderid, color, const type[], const msg[]) {
  new Node:node_chat = JsonObject();
  JsonSetInt(node_chat,"uid", CharacterInfo[senderid][CharacterInfo::id]);
  JsonSetInt(node_chat,"color", color);
  JsonSetString(node_chat,"type", sprintf("%s",type));
  JsonSetString(node_chat,"msg", sprintf("%s",msg));
  JsonSetString(node_chat,"name", GetName(senderid));

  szChat[0] = 0;
  JsonStringify(node_chat,szChat);
  cef_emit_event(targetid, "chat:recvchat", CEFSTR(szChat));
  return 1;   
}

EMIT_PlayerChatCat(targetid,senderid, color, const type[], const cat[], const msg[]) {
  new Node:node_chat = JsonObject();
  JsonSetInt(node_chat,"uid", CharacterInfo[senderid][CharacterInfo::id]);
  JsonSetInt(node_chat,"color", color);
  JsonSetString(node_chat,"type", sprintf("%s",type));
  JsonSetString(node_chat,"msg", sprintf("%s",msg));
  JsonSetString(node_chat,"name", GetName(senderid));
  JsonSetString(node_chat,"cat", sprintf("%s",cat));

  szChat[0] = 0;
  JsonStringify(node_chat,szChat);
  cef_emit_event(targetid, "chat:recvchat", CEFSTR(szChat));
  return 1;
}

EMIT_PlayerSystemChat(playerid, color, const msg[]) {
  new Node:node_chat = JsonObject();
  JsonSetInt(node_chat,"uid", CharacterInfo[playerid][CharacterInfo::id]);
  JsonSetInt(node_chat,"color", color);
  JsonSetString(node_chat,"type", sprintf("%s","sys"));
  JsonSetString(node_chat,"msg", sprintf("%s",msg));
  JsonSetString(node_chat,"name", sprintf("%s", "SYSTEM"));

  szChat[0] = 0;
  JsonStringify(node_chat,szChat);
  cef_emit_event(playerid, "chat:recvchat", CEFSTR(szChat));
  return 1;
}

EMIT_FactionChat(playerid, const msg[]) {
  new Node:node_chat = JsonObject();
  JsonSetInt(node_chat,"uid", CharacterInfo[playerid][CharacterInfo::id]);
  JsonSetInt(node_chat,"color", 0xc1cdc1ff);
  JsonSetString(node_chat,"type", sprintf("%s","fac"));
  JsonSetString(node_chat,"msg", sprintf("%s",msg));
  JsonSetString(node_chat,"name", sprintf("%s", "FACTION"));

  szChat[0] = 0;
  JsonStringify(node_chat,szChat);
  cef_emit_event(playerid, "chat:recvchat", CEFSTR(szChat));
  return 1;
}

EMIT_RadioChat(playerid, const channel[], const msg[]) {
  new Node:node_chat = JsonObject();
  JsonSetInt(node_chat,"uid", CharacterInfo[playerid][CharacterInfo::id]);
  JsonSetInt(node_chat,"color", 0xc1cdc1ff);
  JsonSetString(node_chat,"type", sprintf("%s","rad"));
  JsonSetString(node_chat,"msg", sprintf("%s",msg));
  JsonSetString(node_chat,"name", sprintf("%s %s", "RADIO", channel));

  szChat[0] = 0;
  JsonStringify(node_chat,szChat);
  cef_emit_event(playerid, "chat:recvchat", CEFSTR(szChat));
  return 1;
}
