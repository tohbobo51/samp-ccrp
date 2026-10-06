public PC_OnInit() {

}


public void:OnPlayerKeyDown(player, key)
{
    // new buffer[64];
    // format(buffer, sizeof(buffer), "KeyDown: %d", key);
    // SendClientMessage(player, -1, buffer);
    switch(key) {
        case 32: { // Space
            if(PlayerAction[player][PlayerAction::doingAction]) {
                switch(PlayerAction[player][PlayerAction::module]) {
                    case PlayerAction::CUT_TREE, PlayerAction::HARVEST_TREE: {
                        JobLumber::CancelCut(player);
                    }
                }
            }
        }
        case 73: { // I
            // SendClientMessage(player, -1, "Interacting with interface");
            if(!isPlayerUIInteractable[player]) {
                isPlayerUIInteractable[player] = true;
                cef_focus_browser(player, GET_BROWSER_ID(player), true);
                cef_emit_event(player, "inventory:open");
                GUI_Emit_InventoryItems(player);
                EMIT_GetNearbyDroppedItem(player);
            }
        }

        case 88: { // X
            // SendClientMessage(player, -1, "Interacting with interface");
            if(!isPlayerUIInteractable[player]) {
                // POI::Get(player);
                isPlayerUIInteractable[player] = true;
                cef_focus_browser(player, GET_BROWSER_ID(player), true);
            }
        }

        case 84: { // T
            // printf("Player pressing T");
            ShowPlayerDialog(player, 1,0,"0","0","0", "");
            wait_ticks(1);
            ShowPlayerDialog(player, -1,0,"0","0","0", "");
            wait_ticks(1);
            if(!isPlayerUIInteractable[player]) {
                isPlayerUIInteractable[player] = true;
                cef_focus_browser(player, GET_BROWSER_ID(player), true);
                cef_emit_event(player, "chat:focus_chat");
            }
        }

        case 90: { // Z
            new l_vid = GetNearbyVehicle(player);
            // SelectObject(player);
            isPlayerUIInteractable[player] = true;
            cef_focus_browser(player, GET_BROWSER_ID(player), true);
            new Node:node = JsonObject();
            new phone_item_slot = CheckItemInInventory(player, ITEM_TOOLS_PHONE);
            new bool:has_phone = phone_item_slot > -1 ? true : false;
            new bool:near_vehicle = l_vid != INVALID_VEHICLE_ID;
            new bool:has_id = CharacterData[player][p_has_id] == 1;
            JsonSetBool(node, "has_id", has_id);
            JsonSetBool(node, "has_phone", has_phone);
            JsonSetBool(node, "near_vehicle", near_vehicle);
            new l_str[2048];
            JsonStringify(node,l_str);
            cef_emit_event(player, "radmenu:show", CEFSTR(l_str));
        }

        case 82: { // R
            // 
            if(Weapon::player_use[player][Weapon::active]) {
                if(Weapon::player_use[player][Weapon::current_ammo] > 0) {
                    EMIT_PlayerSystemChat(player, -1, "RELOAD: Masih terdapat amunisi tersisa di clip.");
                    return;
                }
                new l_weaponid = Weapon::player_use[player][Weapon::id];
                new Weapon::AmmoType:l_ammo_type = Weapon::list[l_weaponid][Weapon::ammo_type];
                if(l_weaponid == 23 && WeaponSystem::UsingTazer(player)) {
                    l_ammo_type = AmmoType::BATTERY;
                }
                new itemToCheck = Weapon::GetAmmoTypeItem(l_ammo_type);
                new ammoItemSlot = CheckItemInInventory(player, itemToCheck);
                if( ammoItemSlot == -1) {
                    EMIT_PlayerSystemChat(player, -1, "RELOAD: Kamu tidak memiliki amunisi di inventory.");
                    return;
                }
                TakePlayerItem(player, ammoItemSlot, 1);
                Weapon::player_use[player][Weapon::current_ammo] = Weapon::list[l_weaponid][Weapon::clip_size];
                ResetPlayerWeapons(player);
                EMIT_PlayerSystemChat(player, -1, "RELOAD: Berhasil");
            }
        }
    }
}
public void:OnPlayerKeyUp(player, key)
{
    // new buffer[64];
    // format(buffer, sizeof(buffer), "KeyUp: %d", key);
    // SendClientMessage(player, -1, buffer);
}
