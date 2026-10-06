
callback CEFOnActionCancel(player_id, const arguments[]) {
    printf("Got Action Cancel Event");
    return 0;
}

PlayerAction::Reset(playerid) {
  PlayerAction[playerid][PlayerAction::doingAction] = false;
  format(PlayerAction[playerid][PlayerAction::title], PlayerAction::MAX_ACTION_TITLE,"-");
  PlayerAction[playerid][PlayerAction::max] = 0;
  PlayerAction[playerid][PlayerAction::value] = 0;
  return 1;
}

PlayerAction::Set(playerid, const name[], max_value, PlayerAction::Module:module=PlayerAction::NONE) {
    format(PlayerAction[playerid][PlayerAction::title],PlayerAction::MAX_ACTION_TITLE, "%s", name);
    PlayerAction[playerid][PlayerAction::doingAction] = true;
    PlayerAction[playerid][PlayerAction::module] = module;
    PlayerAction[playerid][PlayerAction::max] = max_value;
    PlayerAction[playerid][PlayerAction::value] = 0;
    PlayerAction::Update(playerid);
    return 1;
}

PlayerAction::Finish(playerid) {
  PlayerAction::Reset(playerid);
  PlayerAction::Update(playerid);
  return 1;
}


PlayerAction::Update(playerid,value=0) {
  PlayerAction[playerid][PlayerAction::value] = value;
  new Node:node_action = JsonObject();
  JsonSetBool(node_action,"isDoing", PlayerAction[playerid][PlayerAction::doingAction]);
  JsonSetString(node_action, "title", PlayerAction[playerid][PlayerAction::title]);
  JsonSetInt(node_action, "max", PlayerAction[playerid][PlayerAction::max]);
  JsonSetInt(node_action, "value", PlayerAction[playerid][PlayerAction::value]);
  
  new l_str[512];
  JsonStringify(node_action,l_str);
  cef_emit_event(playerid, "paction:updateaction", CEFSTR(l_str));
  return 1;
}

stock bool:PlayerAction::isDoingAction(playerid) {
  return PlayerAction[playerid][PlayerAction::doingAction];
}


