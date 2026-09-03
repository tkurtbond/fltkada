

//  Programmed by Jedidiah Barber
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


#endif


