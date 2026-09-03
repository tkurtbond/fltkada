

//  Programmed by T. Kurt Bond and Claude Sonnet 5
//  Released into the public domain


#include <FL/Fl_Tree_Item.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Image.H>
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




void fl_tree_item_set_widget(TREEITEM ti, void * w) {
    static_cast<Fl_Tree_Item*>(ti)->widget(static_cast<Fl_Widget*>(w));
}

void * fl_tree_item_get_widget(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->widget();
}




void fl_tree_item_set_usericon(TREEITEM ti, void * img) {
    static_cast<Fl_Tree_Item*>(ti)->usericon(static_cast<Fl_Image*>(img));
}

void * fl_tree_item_get_usericon(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->usericon();
}

void fl_tree_item_set_userdeicon(TREEITEM ti, void * img) {
    static_cast<Fl_Tree_Item*>(ti)->userdeicon(static_cast<Fl_Image*>(img));
}

void * fl_tree_item_get_userdeicon(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->userdeicon();
}




int fl_tree_item_move_above(TREEITEM ti, TREEITEM item) {
    return static_cast<Fl_Tree_Item*>(ti)->move_above(static_cast<Fl_Tree_Item*>(item));
}

int fl_tree_item_move_below(TREEITEM ti, TREEITEM item) {
    return static_cast<Fl_Tree_Item*>(ti)->move_below(static_cast<Fl_Tree_Item*>(item));
}

int fl_tree_item_move_into(TREEITEM ti, TREEITEM item, int pos) {
    return static_cast<Fl_Tree_Item*>(ti)->move_into(static_cast<Fl_Tree_Item*>(item), pos);
}

TREEITEM fl_tree_item_deparent(TREEITEM ti, int index) {
    return static_cast<Fl_Tree_Item*>(ti)->deparent(index);
}

int fl_tree_item_reparent(TREEITEM ti, TREEITEM newchild, int index) {
    return static_cast<Fl_Tree_Item*>(ti)->reparent(static_cast<Fl_Tree_Item*>(newchild), index);
}

int fl_tree_item_swap_children(TREEITEM ti, TREEITEM a, TREEITEM b) {
    return static_cast<Fl_Tree_Item*>(ti)->swap_children
       (static_cast<Fl_Tree_Item*>(a), static_cast<Fl_Tree_Item*>(b));
}


