

//  Programmed by T. Kurt Bond and Claude Sonnet 5
//  Released into the public domain


#ifndef FL_TREE_ITEM_GUARD
#define FL_TREE_ITEM_GUARD


//  Fl_Tree_Item objects are always owned by the Fl_Tree (or parent item)
//  they belong to; this layer never allocates or frees one on its own,
//  so unlike most other bound classes there is no new_fl_/free_fl_ pair
//  here.

typedef void* TREEITEM;


extern "C" const char * fl_tree_item_get_label(TREEITEM ti);
extern "C" void fl_tree_item_set_label(TREEITEM ti, const char * t);


extern "C" int fl_tree_item_is_open(TREEITEM ti);
extern "C" int fl_tree_item_is_selected(TREEITEM ti);
extern "C" int fl_tree_item_is_active(TREEITEM ti);
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


extern "C" int fl_tree_item_move_above(TREEITEM ti, TREEITEM item);
extern "C" int fl_tree_item_move_below(TREEITEM ti, TREEITEM item);
extern "C" int fl_tree_item_move_into(TREEITEM ti, TREEITEM item, int pos);
extern "C" TREEITEM fl_tree_item_deparent(TREEITEM ti, int index);
extern "C" int fl_tree_item_reparent(TREEITEM ti, TREEITEM newchild, int index);
extern "C" int fl_tree_item_swap_children(TREEITEM ti, TREEITEM a, TREEITEM b);


#endif


