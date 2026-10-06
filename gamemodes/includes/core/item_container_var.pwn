#define ItemCont:: itm_cnt_


enum itm_cnt_ETakeReq {
    ItemCont::type[16],
    ItemCont::id,
    ItemCont::idx,
    ItemCont::amt
};

enum itm_cnt_EStoreReq {
    ItemCont::type[16],
    ItemCont::id,
    ItemCont::slot,
    ItemCont::amt
}
