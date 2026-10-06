#define DeathSystem:: sys_dth_

#define INJURED_TIME 120
forward DeathSystemTick();

new DeathSystem::tickTimer;

new List:DeathSystem::injured_players;
