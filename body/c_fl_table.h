

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_TABLE_GUARD
#define FL_TABLE_GUARD


extern "C" const int fl_context_none;
extern "C" const int fl_context_startpage;
extern "C" const int fl_context_endpage;
extern "C" const int fl_context_row_header;
extern "C" const int fl_context_col_header;
extern "C" const int fl_context_cell;
extern "C" const int fl_context_table;
extern "C" const int fl_context_rc_resize;


typedef void* TABLE;


extern "C" TABLE new_fl_table(int x, int y, int w, int h, char * label);
extern "C" void free_fl_table(TABLE t);


extern "C" void * fl_table_hscrollbar(TABLE t);
extern "C" void * fl_table_vscrollbar(TABLE t);
extern "C" void * fl_table_table(TABLE t);


extern "C" void fl_table_add(TABLE t, void * w);
extern "C" void fl_table_insert(TABLE t, void * w, int p);
extern "C" void fl_table_insert2(TABLE t, void * w, void * b);
extern "C" void fl_table_remove(TABLE t, void * w);


extern "C" void * fl_table_child(TABLE t, int p);
extern "C" int fl_table_find(TABLE t, void * w);
extern "C" int fl_table_children(TABLE t);
extern "C" int fl_table_is_fltk_container(TABLE t);


extern "C" void fl_table_begin(TABLE t);
extern "C" void fl_table_end(TABLE t);


extern "C" void fl_table_set_callback(TABLE t, void * f);
extern "C" int fl_table_callback_col(TABLE t);
extern "C" int fl_table_callback_row(TABLE t);
extern "C" int fl_table_callback_context(TABLE t);
extern "C" void fl_table_do_callback(TABLE t, int x, int r, int c);
extern "C" void fl_table_when(TABLE t, unsigned char w);
extern "C" void fl_table_scroll_cb(void * s, TABLE t);


extern "C" int fl_table_get_col_header(TABLE t);
extern "C" void fl_table_set_col_header(TABLE t, int f);
extern "C" unsigned int fl_table_get_col_header_color(TABLE t);
extern "C" void fl_table_set_col_header_color(TABLE t, unsigned int c);
extern "C" int fl_table_get_col_header_height(TABLE t);
extern "C" void fl_table_set_col_header_height(TABLE t, int h);
extern "C" int fl_table_get_col_width(TABLE t, int c);
extern "C" void fl_table_set_col_width(TABLE t, int c, int w);
extern "C" void fl_table_col_width_all(TABLE t, int w);
extern "C" int fl_table_get_cols(TABLE t);
extern "C" void fl_table_set_cols(TABLE t, int c);
extern "C" int fl_table_get_col_position(TABLE t);
extern "C" void fl_table_set_col_position(TABLE t, int c);
extern "C" long fl_table_col_scroll_position(TABLE t, int c);
extern "C" int fl_table_get_col_resize(TABLE t);
extern "C" void fl_table_set_col_resize(TABLE t, int f);
extern "C" int fl_table_get_col_resize_min(TABLE t);
extern "C" void fl_table_set_col_resize_min(TABLE t, int v);


extern "C" int fl_table_get_row_header(TABLE t);
extern "C" void fl_table_set_row_header(TABLE t, int f);
extern "C" unsigned int fl_table_get_row_header_color(TABLE t);
extern "C" void fl_table_set_row_header_color(TABLE t, unsigned int c);
extern "C" int fl_table_get_row_header_width(TABLE t);
extern "C" void fl_table_set_row_header_width(TABLE t, int w);
extern "C" int fl_table_get_row_height(TABLE t, int r);
extern "C" void fl_table_set_row_height(TABLE t, int r, int h);
extern "C" void fl_table_row_height_all(TABLE t, int h);
extern "C" int fl_table_get_rows(TABLE t);
extern "C" void fl_table_set_rows(TABLE t, int r);
extern "C" int fl_table_get_row_position(TABLE t);
extern "C" void fl_table_set_row_position(TABLE t, int r);
extern "C" long fl_table_row_scroll_position(TABLE t, int r);
extern "C" int fl_table_get_row_resize(TABLE t);
extern "C" void fl_table_set_row_resize(TABLE t, int f);
extern "C" int fl_table_get_row_resize_min(TABLE t);
extern "C" void fl_table_set_row_resize_min(TABLE t, int v);
extern "C" int fl_table_get_top_row(TABLE t);
extern "C" void fl_table_set_top_row(TABLE t, int r);


extern "C" void fl_table_change_cursor(TABLE t, int c);
extern "C" int fl_table_cursor2rowcol(TABLE t, int &r, int &c, int &f);
extern "C" void fl_table_visible_cells(TABLE t, int &r1, int &r2, int &c1, int &c2);
extern "C" void fl_table_get_selection(TABLE t, int &rt, int &cl, int &rb, int &cr);
extern "C" void fl_table_set_selection(TABLE t, int rt, int cl, int rb, int cr);
extern "C" int fl_table_is_selected(TABLE t, int r, int c);
extern "C" int fl_table_move_cursor(TABLE t, int r, int c, int s);
extern "C" int fl_table_get_tab_cell_nav(TABLE t);
extern "C" void fl_table_set_tab_cell_nav(TABLE t, int v);
extern "C" int fl_table_get_table_box(TABLE t);
extern "C" void fl_table_set_table_box(TABLE t, int v);


extern "C" int fl_table_get_scrollbar_size(TABLE t);
extern "C" void fl_table_set_scrollbar_size(TABLE t, int v);
extern "C" void fl_table_resize(TABLE t, int x, int y, int w, int h);
extern "C" int fl_table_is_interactive_resize(TABLE t);
extern "C" void fl_table_init_sizes(TABLE t);
extern "C" void fl_table_recalc_dimensions(TABLE t);
extern "C" void fl_table_table_resized(TABLE t);
extern "C" void fl_table_table_scrolled(TABLE t);


extern "C" void fl_table_draw(TABLE t);
extern "C" void fl_table_draw_cell(TABLE t, int e, int r, int c, int x, int y, int w, int h);
extern "C" void fl_table_redraw_range(TABLE t, int rt, int rb, int cl, int cr);
extern "C" void fl_table_damage_zone(TABLE t, int rt, int cl, int rb, int cr, int rr, int rc);
extern "C" int fl_table_find_cell(TABLE t, int e, int r, int c, int &x, int &y, int &w, int &h);
extern "C" void fl_table_get_bounds(TABLE t, int e, int &x, int &y, int &w, int &h);
extern "C" int fl_table_row_col_clamp(TABLE t, int e, int &r, int &c);
extern "C" int fl_table_handle(TABLE t, int e);


#endif


