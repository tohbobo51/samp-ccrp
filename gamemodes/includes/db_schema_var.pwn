#define DB:: db_
#define DBColumn:: dbc_
#define DBColumnType:: dbc_t_

enum db_Schema {
};

enum db_ColumnType {
    DBColumnType::PK,
    DBColumnType::INT,
    DBColumnType::FLOAT,
    DBColumnType::VEC2, // X,Y
    DBColumnType::VEC3, // X,Y,Z
    DBColumnType::STRING
};

enum db_Column {
    DBColumn::name[64],
    DB::ColumnType:DBColumn::type,
    DBColumn::data_offset,
    DBColumn::data_length
};

new Map:DB::query_fmt_cache;
