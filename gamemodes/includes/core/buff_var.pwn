#define Buff:: buff_
#define BuffType:: buff_t_
#define MAX_BUFF_SLOT 4

enum Buff::TYPE {
    BuffType::NONE,
    BuffType::FOOD,
    BuffType::STAMINA,
    BuffType::JOINT
}

enum Buff::param {
  bool:Buff::isActive,
  Buff::TYPE:Buff::type,
  Buff::duration,
  Buff::value,
}

new CharacterBuff[MAX_PLAYERS][MAX_BUFF_SLOT][Buff::param];

