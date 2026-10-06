#define JobSweeper:: jb_swpr_
#define SweeperRoute:: jswpr_r_

#define MAX_SWEEPER_VEHICLES 4
#define MAX_SWEEPER_ROUTE 4

#define jb_swpr_IsWorking(%0) GetPVarInt(%0,"SWP_IsWorking")
#define jb_swpr_SetIsWorking(%0,%1) SetPVarInt(%0,"SWP_IsWorking",%1)

#define jb_swpr_GetRoute(%0) GetPVarInt(%0,"SWP_Route")
#define jb_swpr_SetRoute(%0,%1) SetPVarInt(%0,"SWP_Route",%1)

#define jb_swpr_GetStep(%0) GetPVarInt(%0,"SWP_Step")
#define jb_swpr_SetStep(%0,%1) SetPVarInt(%0,"SWP_Step",%1)


//SIDEJOB SWEEPER

new SweepVeh[MAX_SWEEPER_VEHICLES];

#define SWEEPERJOB 1001

enum JobSweeper::e_Route {
    SweeperRoute::id,
    SweeperRoute::name[32],
    bool:SweeperRoute::taken,
    SweeperRoute::reward
}

new JobSweeper::Route[MAX_SWEEPER_ROUTE][JobSweeper::e_Route] = {
    {1, "A", false, 58},
    {2, "B", false, 95},
    {3, "C", false, 130},
    {4, "D", false, 130}
};

new List:JobSweeper::RoutePos[MAX_SWEEPER_ROUTE];




