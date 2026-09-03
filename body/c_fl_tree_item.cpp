

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Tree_Item.H>
#include "c_fl_tree_item.h"




//  Flattened C API

const char * fl_tree_item_get_label(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->label();
}

void fl_tree_item_set_label(TREEITEM ti, const char * t) {
    static_cast<Fl_Tree_Item*>(ti)->label(t);
}




int fl_tree_item_is_open(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->is_open();
}

int fl_tree_item_is_selected(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->is_selected();
}

int fl_tree_item_is_active(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->is_active();
}

int fl_tree_item_is_visible(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->is_visible();
}

int fl_tree_item_is_root(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->is_root();
}

int fl_tree_item_has_children(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->has_children();
}




int fl_tree_item_children(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->children();
}

TREEITEM fl_tree_item_child(TREEITEM ti, int index) {
    return static_cast<Fl_Tree_Item*>(ti)->child(index);
}

TREEITEM fl_tree_item_parent(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->parent();
}

int fl_tree_item_depth(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->depth();
}

TREEITEM fl_tree_item_next(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->next();
}

TREEITEM fl_tree_item_prev(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->prev();
}


