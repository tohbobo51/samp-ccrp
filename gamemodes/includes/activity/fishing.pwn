#include <pp-hooks>
hook OnGameModeInit() {
  printf("[FISHING] Gamemode Init");
}

#include <pp-hooks>
hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(PRESSED(KEY_FIRE)) {
        if(
            Fishing::IsUsingRod(playerid) &&
            Fishing::IsAtFishingArea(playerid) &&
            !Fishing::IsFishing(playerid)
        ){
            EMIT_PlayerSystemChat(playerid, -1, "[FISHING] Fishing started.");
            cef_emit_event(playerid, "fishing:req_start_fishing");
            Fishing::SetIsFishing(playerid, 1);
            cef_focus_browser(playerid, GET_BROWSER_ID(playerid), true);
            isPlayerUIInteractable[playerid] = true;
            wait_ms(500);
            TogglePlayerControllable(playerid, false);
            ApplyAnimation(playerid,"SWORD","sword_block",50.0 ,0,1,0,1,1);
        }
        if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_SMOKE_CIGGY) {
            Buff::GivePlayerBuff(playerid, BuffType::JOINT, 10, 5);
        }
    }
}

callback OnPlayerFishingStarted(player_id, const arguments[]) {
  new l_startTime, l_fishId;
  printf("Got Starting Fishing Event");
  printf("%s",arguments);
  if(sscanf(arguments, "ii",l_startTime,l_fishId)) {
    printf("Malformed OnPlayerFishingStarted event");
    return 1;
  }
  Fishing::SetStartTime(player_id, l_startTime);
  Fishing::SetGotFishID(player_id, l_fishId);
  Fishing::SetFishingTime(player_id, 0);
  printf("Start time %i", l_startTime);
  printf("FishID %i", l_fishId);
  return 1; 
}

callback OnPlayerFishingSuccess(player_id, const arguments[]) {
  new l_finishTime, l_diffTime;
  if(sscanf(arguments, "i", l_finishTime)) {
    printf("Malformed OnPlayerFishingSuccess");
    return 1;
  }
  l_diffTime = l_finishTime - Fishing::GetStartTime(player_id);
  printf("Player %i success fishing", player_id);
  printf("FinishTime %i", l_finishTime);
  printf("Time elapsed %i", l_diffTime);
  Fishing::SetFishingTime(player_id, l_diffTime);
  ClearAnimations(player_id);
  
  // TODO Give Experience according to speed and fish types
  GivePlayerEXP(player_id, 15);
  return 1;
}

callback OnPlayerFishingFailed(player_id, const arguments[]) {
  new l_finishTime, l_diffTime;
  if(sscanf(arguments,"i",l_finishTime)) {
    printf("Malformed OnPlayerFishingFailed");
    return 1;
  }
  
  l_diffTime = l_finishTime - Fishing::GetStartTime(player_id);
  printf("Player %i failed fishing.");
  printf("FinishTime %i", l_finishTime);
  printf("Time elapsed %i", l_diffTime);
  Fishing::SetIsFishing(player_id, 0);
  Fishing::SetGotFishID(player_id,-1);
  cef_focus_browser(player_id, GET_BROWSER_ID(player_id), false);
  isPlayerUIInteractable[player_id] = false;
  TogglePlayerControllable(player_id, true);
  ClearAnimations(player_id);
  return 1; 
}

callback OnPlayerTakeFish(player_id, const arguments[]) {
  printf("PlayerID %i want to take fish",player_id);
  Fishing::SetIsFishing(player_id, 0);
  if(Fishing::GotFishID(player_id) == 0)  {
    printf("Something went wrong");
    return 1;
  }
  new fishItem[Inv::eItem];
  fishItem[Item::id] = Fishing::GotFishID(player_id);
  fishItem[Item::amount] = 1;
  fishItem[Item::durability] = 0;
  fishItem[Item::power] = 0;
  fishItem[Item::addon1] = 0;
  fishItem[Item::addon2] = 0;
  fishItem[Item::addon3] = 0;
  GivePlayerItem(player_id, fishItem);
  Fishing::SetGotFishID(player_id, 0);
  cef_emit_event(player_id, "fishing:c_fishing_finish");
  cef_focus_browser(player_id, GET_BROWSER_ID(player_id), false);
  isPlayerUIInteractable[player_id] = false;
  
  TogglePlayerControllable(player_id, true);
  return 1;
}

callback OnPlayerReleaseFish(player_id, const arguments[]) {
  EMIT_PlayerSystemChat(player_id, -1, "[FISHING] You released the fish");
  Fishing::SetGotFishID(player_id, 0);
  Fishing::SetIsFishing(player_id, 0);
  Fishing::SetStartTime(player_id, 0);
  cef_focus_browser(player_id, GET_BROWSER_ID(player_id), false);
  isPlayerUIInteractable[player_id] = false;
  
  TogglePlayerControllable(player_id, true);
  return 1; 
}

#if defined DEBUG_MODE
CMD:gotofishing(playerid, params[]) {
  SetPlayerPos(playerid, 379.9645,-2078.4736,7.8359);
  return 1;
}
CMD:startfishing(playerid, params[]) {
  cef_emit_event(playerid, "fishing:doFishing");
  return 1;
}
#endif

Fishing::IsAtFishingArea(playerid)
{
    if(IsPlayerConnected(playerid))
    {
        if(IsPlayerInRangeOfPoint(playerid,1.0,403.8266,-2088.7598,7.8359) || IsPlayerInRangeOfPoint(playerid,1.0,398.7553,-2088.7490,7.8359))
        {
            return 1;
        }
        else if(IsPlayerInRangeOfPoint(playerid,1.0,396.2197,-2088.6692,7.8359) || IsPlayerInRangeOfPoint(playerid,1.0,391.1094,-2088.7976,7.8359))
        {
            return 1;
        }
        else if(IsPlayerInRangeOfPoint(playerid,1.0,383.4157,-2088.7849,7.8359) || IsPlayerInRangeOfPoint(playerid,1.0,374.9598,-2088.7979,7.8359))
        {
            return 1;
        }
        else if(IsPlayerInRangeOfPoint(playerid,1.0,369.8107,-2088.7927,7.8359) || IsPlayerInRangeOfPoint(playerid,1.0,367.3637,-2088.7925,7.8359))
        {
            return 1;
        }
        else if(IsPlayerInRangeOfPoint(playerid,1.0,362.2244,-2088.7981,7.8359) || IsPlayerInRangeOfPoint(playerid,1.0,354.5382,-2088.7979,7.8359))
        {
            return 1;
        }
    }
    return 0;
}
