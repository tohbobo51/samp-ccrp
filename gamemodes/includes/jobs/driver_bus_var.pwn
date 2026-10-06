#define JobsBus:: jb_bus_
#define BusRoute:: jbus_r_

#define MAX_DRIVERSBUS_VEHICLES 4
#define MAX_DRIVERSBUS_ROUTE 4

#define jb_bus_IsWorking(%0) GetPVarInt(%0,"BUS_IsWorking")
#define jb_bus_SetIsWorking(%0,%1) SetPVarInt(%0,"BUS_IsWorking",%1)

#define jb_bus_GetRoute(%0) GetPVarInt(%0,"BUS_Route")
#define jb_bus_SetRoute(%0,%1) SetPVarInt(%0,"BUS_Route",%1)

#define jb_bus_GetStep(%0) GetPVarInt(%0,"BUS_Step")
#define jb_bus_SetStep(%0,%1) SetPVarInt(%0,"BUS_Step",%1)


//SIDEJOB SWEEPER

new BusVeh[MAX_DRIVERSBUS_VEHICLES];

#define DRIVERS_BUSJOBS 2001

enum JobsBus::e_Route {
    BusRoute::id,
    BusRoute::name[32],
    bool:BusRoute::taken,
    BusRoute::reward
}

new JobsBus::Route[MAX_DRIVERSBUS_ROUTE][JobsBus::e_Route] = {
    {1, "A", false, 58},
    {2, "B", false, 95},
    {3, "C", false, 130},
    {4, "D", false, 130}
};

new List:JobsBus::RoutePos[MAX_DRIVERSBUS_ROUTE];





