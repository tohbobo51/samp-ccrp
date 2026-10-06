#define PlayerAction:: PPA_

#define PPA_MAX_ACTION_TITLE 64

enum PPA_Module {
    PlayerAction::NONE,
    PlayerAction::CUT_TREE,
    PlayerAction::HARVEST_TREE,
    PlayerAction::CRAFT_SAWMILL,
}

enum PlayerAction::e_ActionData {
    bool:PlayerAction::doingAction,
    PlayerAction::Module:PlayerAction::module,
    PlayerAction::title[PlayerAction::MAX_ACTION_TITLE],
    PlayerAction::max,
    PlayerAction::value
}

new PlayerAction[MAX_PLAYERS][PlayerAction::e_ActionData];
