// GAMEMODE INIT
forward OnGetListItems(Request:id, E_HTTP_STATUS:status, Node:node);

// Interval
forward SecondInterval();
forward MinuteInterval();

forward HungerInterval();

// CEF FORWARDS
forward OnCEFGUIEscape(player_id, const arguments[]);
forward OnCEFGUIReady(player_id, const arguments[]);

// AUTH
forward OnLoginTokenCheck(playerid);
forward OnCEFGUIPlayCharacter(playerid, const arguments[]);
forward OnCharacterLoaded(playerid);
forward OnCharacterDataLoaded(playerid);

// Inventory
forward OnCharacterInventoryLoaded(playerid, task_id);
forward OnGUIPlayerDropItem(playerid, const arguments[]);
forward OnGUIPlayerTakeItem(playerid, const arguments[]);
forward OnGUIPlayerInventoryUse(playerid, const arguments[]);


// Misc
forward OnGetUserCursorClick(playerid, const arguments[]);


forward Float:GetDistance(const Float:p_pos1[3], const Float:p_pos2[3]);
forward Float:SV_Char_GetHealth(playerid);
forward Float:FromCents(amount);
