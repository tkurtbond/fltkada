

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_TABLE_ROW_GUARD
#define FL_TABLE_ROW_GUARD


typedef void* ROWTABLE;


extern "C" ROWTABLE new_fl_table_row(int x, int y, int w, int h, char * label);
extern "C" void free_fl_table_row(ROWTABLE t);


extern "C" int fl_table_row_get_rows(ROWTABLE t);
extern "C" void fl_table_row_set_rows(ROWTABLE t, int r);


extern "C" int fl_table_row_row_selected(ROWTABLE t, int r);
extern "C" int fl_table_row_select_row(ROWTABLE t, int r, int f);
extern "C" void fl_table_row_select_all_rows(ROWTABLE t, int f);
extern "C" int fl_table_row_get_type(ROWTABLE t);
extern "C" void fl_table_row_set_type(ROWTABLE t, int v);


extern "C" void fl_table_row_draw(ROWTABLE t);
extern "C" void fl_table_row_draw_cell(ROWTABLE t, int e, int r, int c, int x, int y, int w, int h);
extern "C" int fl_table_row_find_cell(ROWTABLE t, int e, int r, int c,
    int &x, int &y, int &w, int &h);
extern "C" int fl_table_row_handle(ROWTABLE t, int e);


#endif


