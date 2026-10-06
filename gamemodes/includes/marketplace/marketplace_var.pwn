#define Marketplace:: mktplc_

new Float:Marketplace::zone[] = {
	1096.0,-1417.0,1061.0,-1493.0,1049.0,-1558.0,1120.0,-1558.0,1182.0,-1558.0,1182.0,-1418.0,1096.0,-1417.0
};

new Marketplace::area;

enum Marketplace::eInfo {
    Marketplace::id,
    Marketplace::name[56],
    Float:Marketplace::pos[3],
    Marketplace::int,
    Marketplace::vw,
    Marketplace::actor_id,
    Float:Marketplace::facing,
    Marketplace::with_actor,
    Marketplace::actor_skin,
    Marketplace::actor_name[254]
};

new List:Marketplace::list;


new Marketplace::Schema[][DB::Column] = {
    {"id", DBColumnType::PK, _:Marketplace::id},
    {"name", DBColumnType::STRING, _:Marketplace::name, 56},
    {"pos", DBColumnType::VEC3, _:Marketplace::pos},
    {"int", DBColumnType::INT, _:Marketplace::int},
    {"vw", DBColumnType::INT, _:Marketplace::vw},
    {"with_actor", DBColumnType::INT, _:Marketplace::with_actor},
    {"facing", DBColumnType::FLOAT, _:Marketplace::facing},
    {"actor_skin", DBColumnType::INT, _:Marketplace::actor_skin},
    {"actor_name", DBColumnType::STRING, _:Marketplace::actor_name, 254}
};
