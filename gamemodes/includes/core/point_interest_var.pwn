#define POI:: poi_

enum poi_eType {
    POI_DROPITEM = 1,
    POI_SHOP,
    POI_PLANT
};

enum poi_eInfo {
    poi_eType:POI::type,
    POI::id,
    Float:POI::px,
    Float:POI::py,
    Float:POI::pz,
    POI::title[56],
    POI::ext1,
    POI::ext2,
    POI::ext3
};


stock POI::Debug(info[POI::eInfo]) {
    printf("type %i", _:info[POI::type]);
    printf("title: %s", info[POI::title]);
    printf("px: %f py: %f pz: %f", info[POI::px], info[POI::py], info[POI::pz]);
    printf("ext1: %i ext2: %i ext3: %i", info[POI::ext1], info[POI::ext2], info[POIT::ext3]);
}


