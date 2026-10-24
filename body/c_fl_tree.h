

//  Programmed by T. Kurt Bond and Claude Sonnet 5
//  Released into the public domain


#ifndef FL_TREE_GUARD
#define FL_TREE_GUARD


#include "c_fl_tree_item.h"


typedef void* TREE;


extern "C" TREE new_fl_tree(int x, int y, int w, int h, char * label);
extern "C" void free_fl_tree(TREE t);


extern "C" void fl_tree_draw(TREE n);
extern "C" int fl_tree_handle(TREE n, int e);


extern "C" TREEITEM fl_tree_add(TREE t, const char * path);
extern "C" TREEITEM fl_tree_add_item(TREE t, const char * path, TREEITEM item);
extern "C" TREEITEM fl_tree_insert(TREE t, TREEITEM under, const char * name, int pos);
extern "C" TREEITEM fl_tree_insert_above(TREE t, TREEITEM above, const char * name);
extern "C" void fl_tree_remove(TREE t, TREEITEM item);
extern "C" void fl_tree_clear(TREE t);
extern "C" void fl_tree_clear_children(TREE t, TREEITEM item);
extern "C" TREEITEM fl_tree_find_item(TREE t, const char * path);


extern "C" TREEITEM fl_tree_root(TREE t);
extern "C" void fl_tree_set_root_label(TREE t, const char * label);


extern "C" TREEITEM fl_tree_callback_item(TREE t);
extern "C" int fl_tree_callback_reason(TREE t);
extern "C" int fl_tree_item_pathname(TREE t, char * buf, int len, TREEITEM i);


extern "C" TREEITEM fl_tree_first(TREE t);
extern "C" TREEITEM fl_tree_last(TREE t);


extern "C" void fl_tree_open(TREE t, TREEITEM item);
extern "C" void fl_tree_close(TREE t, TREEITEM item);
extern "C" void fl_tree_open_toggle(TREE t, TREEITEM item);


extern "C" void fl_tree_select(TREE t, TREEITEM item);
extern "C" void fl_tree_deselect(TREE t, TREEITEM item);
extern "C" int fl_tree_select_all(TREE t);
extern "C" int fl_tree_deselect_all(TREE t);


extern "C" int fl_tree_selected_count(TREE t);
extern "C" void fl_tree_selected_fill(TREE t, TREEITEM * buf, int max);


extern "C" int fl_tree_get_show_root(TREE t);
extern "C" void fl_tree_set_show_root(TREE t, int val);
extern "C" int fl_tree_get_show_collapse(TREE t);
extern "C" void fl_tree_set_show_collapse(TREE t, int val);
extern "C" int fl_tree_get_select_mode(TREE t);
extern "C" void fl_tree_set_select_mode(TREE t, int val);
extern "C" int fl_tree_get_connector_style(TREE t);
extern "C" void fl_tree_set_connector_style(TREE t, int val);
extern "C" int fl_tree_get_sort_order(TREE t);
extern "C" void fl_tree_set_sort_order(TREE t, int val);
extern "C" int fl_tree_get_item_label_font(TREE t);
extern "C" void fl_tree_set_item_label_font(TREE t, int val);
extern "C" int fl_tree_get_item_label_size(TREE t);
extern "C" void fl_tree_set_item_label_size(TREE t, int val);
extern "C" unsigned int fl_tree_get_item_label_color(TREE t);
extern "C" void fl_tree_set_item_label_color(TREE t, unsigned int val);
extern "C" int fl_tree_get_margin_left(TREE t);
extern "C" void fl_tree_set_margin_left(TREE t, int val);
extern "C" int fl_tree_get_widget_margin_left(TREE t);
extern "C" void fl_tree_set_widget_margin_left(TREE t, int val);
extern "C" int fl_tree_get_line_spacing(TREE t);
extern "C" void fl_tree_set_line_spacing(TREE t, int val);
extern "C" int fl_tree_get_item_draw_mode(TREE t);
extern "C" void fl_tree_set_item_draw_mode(TREE t, int val);
extern "C" int fl_tree_get_select_box(TREE t);
extern "C" void fl_tree_set_select_box(TREE t, int val);


extern "C" void fl_tree_show_self(TREE t);


#endif


