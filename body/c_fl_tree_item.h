

//  Programmed by T. Kurt Bond and Claude Sonnet 5
//  Released into the public domain


#ifndef FL_TREE_ITEM_GUARD
#define FL_TREE_ITEM_GUARD


//  Fl_Tree_Item objects are always owned by the Fl_Tree (or parent item)
//  they belong to.  The one exception is a custom item (My_Tree_Item),
//  which is allocated here and freed here only if no tree ever took it.

typedef void* TREEITEM;


extern "C" const char * fl_tree_item_get_label(TREEITEM ti);
extern "C" void fl_tree_item_set_label(TREEITEM ti, const char * t);


extern "C" int fl_tree_item_is_open(TREEITEM ti);
extern "C" int fl_tree_item_is_selected(TREEITEM ti);
extern "C" int fl_tree_item_is_active(TREEITEM ti);
extern "C" void fl_tree_item_activate(TREEITEM ti, int v);
extern "C" int fl_tree_item_is_visible(TREEITEM ti);
extern "C" int fl_tree_item_is_root(TREEITEM ti);
extern "C" int fl_tree_item_has_children(TREEITEM ti);


extern "C" int fl_tree_item_children(TREEITEM ti);
extern "C" TREEITEM fl_tree_item_child(TREEITEM ti, int index);
extern "C" TREEITEM fl_tree_item_parent(TREEITEM ti);
extern "C" int fl_tree_item_depth(TREEITEM ti);
extern "C" TREEITEM fl_tree_item_next(TREEITEM ti);
extern "C" TREEITEM fl_tree_item_prev(TREEITEM ti);


extern "C" void fl_tree_item_set_widget(TREEITEM ti, void * w);
extern "C" void * fl_tree_item_get_widget(TREEITEM ti);


extern "C" void fl_tree_item_set_usericon(TREEITEM ti, void * img);
extern "C" void * fl_tree_item_get_usericon(TREEITEM ti);
extern "C" void fl_tree_item_set_userdeicon(TREEITEM ti, void * img);
extern "C" void * fl_tree_item_get_userdeicon(TREEITEM ti);
extern "C" void * fl_tree_item_tree(TREEITEM ti);
extern "C" int fl_tree_item_in_tree(TREEITEM ti);


extern "C" int fl_tree_item_move_above(TREEITEM ti, TREEITEM item);
extern "C" int fl_tree_item_move_below(TREEITEM ti, TREEITEM item);
extern "C" int fl_tree_item_move_into(TREEITEM ti, TREEITEM item, int pos);
extern "C" TREEITEM fl_tree_item_deparent(TREEITEM ti, int index);
extern "C" int fl_tree_item_reparent(TREEITEM ti, TREEITEM newchild, int index);
extern "C" int fl_tree_item_swap_children(TREEITEM ti, TREEITEM a, TREEITEM b);
extern "C" void fl_tree_item_swap_children2(TREEITEM ti, int a, int b);
extern "C" TREEITEM fl_tree_item_replace(TREEITEM ti, TREEITEM n);


extern "C" int fl_tree_item_get_labelfont(TREEITEM ti);
extern "C" void fl_tree_item_set_labelfont(TREEITEM ti, int f);
extern "C" int fl_tree_item_get_labelsize(TREEITEM ti);
extern "C" void fl_tree_item_set_labelsize(TREEITEM ti, int s);
extern "C" unsigned int fl_tree_item_get_labelfgcolor(TREEITEM ti);
extern "C" void fl_tree_item_set_labelfgcolor(TREEITEM ti, unsigned int c);
extern "C" unsigned int fl_tree_item_get_labelbgcolor(TREEITEM ti);
extern "C" void fl_tree_item_set_labelbgcolor(TREEITEM ti, unsigned int c);


extern "C" int fl_tree_item_label_x(TREEITEM ti);
extern "C" int fl_tree_item_label_y(TREEITEM ti);
extern "C" int fl_tree_item_label_w(TREEITEM ti);
extern "C" int fl_tree_item_label_h(TREEITEM ti);


extern "C" TREEITEM new_fl_tree_item_custom(void * t);
extern "C" void free_fl_tree_item_custom(TREEITEM ti);
extern "C" void fl_tree_item_custom_set_ada(TREEITEM ti, void * ud);
extern "C" int fl_tree_item_custom_draw_item_content(TREEITEM ti, int r);
extern "C" unsigned int fl_tree_item_custom_drawfgcolor(TREEITEM ti);
extern "C" unsigned int fl_tree_item_custom_drawbgcolor(TREEITEM ti);


#endif


