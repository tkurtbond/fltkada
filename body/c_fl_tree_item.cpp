

//  Programmed by T. Kurt Bond and Claude Sonnet 5
//  Released into the public domain


#include <FL/Fl_Tree.H>
#include <FL/Fl_Tree_Item.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Image.H>
#include "c_fl_tree_item.h"
#include "c_fl_tree.h"




//  Exports from Ada

extern "C" int tree_item_draw_content_hook(void * ud, int r);
extern "C" void tree_item_gone_hook(void * ud);




//  Attaching all relevant hooks and friends

//  A custom item, whose draw_item_content dispatches to Ada.  ada_obj is
//  cleared when the Ada object goes away first, and the Ada object is
//  told when the tree deletes the item first.

class My_Tree_Item : public Fl_Tree_Item {
public:
    using Fl_Tree_Item::Fl_Tree_Item;
    using Fl_Tree_Item::drawfgcolor;
    using Fl_Tree_Item::drawbgcolor;
    ~My_Tree_Item();
    int draw_item_content(int r);
    void * ada_obj = nullptr;
};

My_Tree_Item::~My_Tree_Item() {
    if (ada_obj != nullptr) {
        tree_item_gone_hook(ada_obj);
    }
}

int My_Tree_Item::draw_item_content(int r) {
    if (ada_obj == nullptr) {
        return Fl_Tree_Item::draw_item_content(r);
    }
    return tree_item_draw_content_hook(ada_obj, r);
}




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

//  The tree item ti belongs to, and whether ti is in it: a custom item
//  isn't until a tree takes it.
void * fl_tree_item_tree(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->tree();
}

int fl_tree_item_in_tree(TREEITEM ti) {
    Fl_Tree_Item * it = static_cast<Fl_Tree_Item*>(ti);
    Fl_Tree * tr = it->tree();
    while (it->parent() != 0) {
        it = it->parent();
    }
    return tr != 0 && tr->root() == it;
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

void fl_tree_item_swap_children2(TREEITEM ti, int a, int b) {
    static_cast<Fl_Tree_Item*>(ti)->swap_children(a, b);
}



//  Replacing deletes the item, so the tree forgets it first (pofltk 41
//  and 42).
TREEITEM fl_tree_item_replace(TREEITEM ti, TREEITEM n) {
    Fl_Tree_Item * old = static_cast<Fl_Tree_Item*>(ti);
    fl_tree_forget(old->tree(), old, 0);
    return static_cast<Fl_Tree_Item*>(ti)->replace(static_cast<Fl_Tree_Item*>(n));
}




int fl_tree_item_get_labelfont(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->labelfont();
}

void fl_tree_item_set_labelfont(TREEITEM ti, int f) {
    static_cast<Fl_Tree_Item*>(ti)->labelfont(f);
}

int fl_tree_item_get_labelsize(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->labelsize();
}

void fl_tree_item_set_labelsize(TREEITEM ti, int s) {
    static_cast<Fl_Tree_Item*>(ti)->labelsize(s);
}

unsigned int fl_tree_item_get_labelfgcolor(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->labelfgcolor();
}

void fl_tree_item_set_labelfgcolor(TREEITEM ti, unsigned int c) {
    static_cast<Fl_Tree_Item*>(ti)->labelfgcolor(c);
}

unsigned int fl_tree_item_get_labelbgcolor(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->labelbgcolor();
}

void fl_tree_item_set_labelbgcolor(TREEITEM ti, unsigned int c) {
    static_cast<Fl_Tree_Item*>(ti)->labelbgcolor(c);
}




int fl_tree_item_label_x(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->label_x();
}

int fl_tree_item_label_y(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->label_y();
}

int fl_tree_item_label_w(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->label_w();
}

int fl_tree_item_label_h(TREEITEM ti) {
    return static_cast<Fl_Tree_Item*>(ti)->label_h();
}




TREEITEM new_fl_tree_item_custom(void * t) {
    My_Tree_Item *ti = new My_Tree_Item(static_cast<Fl_Tree*>(t));
    return ti;
}

//  Once an item is in a tree the tree owns it, so it is only detached
void free_fl_tree_item_custom(TREEITEM ti) {
    My_Tree_Item *i = static_cast<My_Tree_Item*>(ti);
    i->ada_obj = nullptr;
    if (i->parent() == nullptr && (i->tree() == nullptr || i->tree()->root() != i)) {
        delete i;
    }
}

void fl_tree_item_custom_set_ada(TREEITEM ti, void * ud) {
    static_cast<My_Tree_Item*>(ti)->ada_obj = ud;
}

int fl_tree_item_custom_draw_item_content(TREEITEM ti, int r) {
    return static_cast<My_Tree_Item*>(ti)->Fl_Tree_Item::draw_item_content(r);
}

unsigned int fl_tree_item_custom_drawfgcolor(TREEITEM ti) {
    return static_cast<My_Tree_Item*>(ti)->drawfgcolor();
}

unsigned int fl_tree_item_custom_drawbgcolor(TREEITEM ti) {
    return static_cast<My_Tree_Item*>(ti)->drawbgcolor();
}
