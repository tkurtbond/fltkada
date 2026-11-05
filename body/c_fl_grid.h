

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#ifndef FL_GRID_GUARD
#define FL_GRID_GUARD


#include <cstddef>


typedef void* GRID;


extern "C" const unsigned short fl_grid_center;
extern "C" const unsigned short fl_grid_top;
extern "C" const unsigned short fl_grid_bottom;
extern "C" const unsigned short fl_grid_left;
extern "C" const unsigned short fl_grid_right;
extern "C" const unsigned short fl_grid_horizontal;
extern "C" const unsigned short fl_grid_vertical;
extern "C" const unsigned short fl_grid_fill;
extern "C" const unsigned short fl_grid_proportional;
extern "C" const unsigned short fl_grid_top_left;
extern "C" const unsigned short fl_grid_top_right;
extern "C" const unsigned short fl_grid_bottom_left;
extern "C" const unsigned short fl_grid_bottom_right;


extern "C" GRID new_fl_grid(int x, int y, int w, int h, char * label);
extern "C" void free_fl_grid(GRID g);


extern "C" void fl_grid_set_layout(GRID g, int r, int c, int m, int p);
extern "C" void fl_grid_layout(GRID g);
extern "C" void fl_grid_clear_layout(GRID g);
extern "C" int fl_grid_get_need_layout(GRID g);
extern "C" void fl_grid_set_need_layout(GRID g, int s);
extern "C" int fl_grid_rows(GRID g);
extern "C" int fl_grid_cols(GRID g);


extern "C" int fl_grid_get_margin(GRID g, int * l, int * t, int * r, int * b);
extern "C" void fl_grid_set_margin(GRID g, int l, int t, int r, int b);
extern "C" void fl_grid_get_gap(GRID g, int * r, int * c);
extern "C" void fl_grid_set_gap(GRID g, int r, int c);


extern "C" int fl_grid_set_widget(GRID g, void * w, int r, int c, unsigned short a);
extern "C" int fl_grid_set_widget2(GRID g, void * w, int r, int c, int rs, int cs,
    unsigned short a);


extern "C" void * fl_grid_cell_widget(GRID g, int r, int c);
extern "C" int fl_grid_get_cell(GRID g, void * w, int * r, int * c, int * rs, int * cs,
    unsigned short * a, int * mw, int * mh);
extern "C" int fl_grid_set_cell_align(GRID g, void * w, unsigned short a);
extern "C" int fl_grid_set_cell_minimum_size(GRID g, void * w, int mw, int mh);


extern "C" void fl_grid_set_col_width(GRID g, int c, int v);
extern "C" void fl_grid_set_col_width2(GRID g, const int * v, size_t s);
extern "C" int fl_grid_get_col_width(GRID g, int c);
extern "C" void fl_grid_set_col_weight(GRID g, int c, int v);
extern "C" void fl_grid_set_col_weight2(GRID g, const int * v, size_t s);
extern "C" int fl_grid_get_col_weight(GRID g, int c);
extern "C" void fl_grid_set_col_gap(GRID g, int c, int v);
extern "C" void fl_grid_set_col_gap2(GRID g, const int * v, size_t s);
extern "C" int fl_grid_get_col_gap(GRID g, int c);
extern "C" int fl_grid_computed_col_width(GRID g, int c);


extern "C" void fl_grid_set_row_height(GRID g, int r, int v);
extern "C" void fl_grid_set_row_height2(GRID g, const int * v, size_t s);
extern "C" int fl_grid_get_row_height(GRID g, int r);
extern "C" void fl_grid_set_row_weight(GRID g, int r, int v);
extern "C" void fl_grid_set_row_weight2(GRID g, const int * v, size_t s);
extern "C" int fl_grid_get_row_weight(GRID g, int r);
extern "C" void fl_grid_set_row_gap(GRID g, int r, int v);
extern "C" void fl_grid_set_row_gap2(GRID g, const int * v, size_t s);
extern "C" int fl_grid_get_row_gap(GRID g, int r);
extern "C" int fl_grid_computed_row_height(GRID g, int r);


extern "C" void fl_grid_show_grid(GRID g, int s);
extern "C" void fl_grid_show_grid2(GRID g, int s, unsigned int c);
extern "C" void fl_grid_debug(GRID g, int l);


extern "C" void fl_grid_draw(GRID n);
extern "C" int fl_grid_handle(GRID n, int e);


#endif


