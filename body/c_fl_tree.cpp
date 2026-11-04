

//  Programmed by T. Kurt Bond and Claude Sonnet 5
//  Released into the public domain


#include <FL/Fl_Tree.H>
#include "c_fl_tree.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Items the tree forgets as they go

//  Fl_Tree's private _lastselect, the last item clicked, reached through
//  an explicit instantiation, which may name a private member
//  ([temp.explicit]).  From pofltk's Reach.

template <class Tag, typename Tag::type M> struct Reach {
    friend typename Tag::type member(Tag) { return M; }
};

struct Last_Select {
    typedef Fl_Tree_Item * Fl_Tree::*type;
    friend type member(Last_Select);
};

template struct Reach<Last_Select, &Fl_Tree::_lastselect>;

//  How many times items have been removed, by any tree.
static unsigned long removals = 0;

//  Whether p is top, or below top when below is set.
static bool under(Fl_Tree_Item * p, Fl_Tree_Item * top, bool below) {
    if (below && p != 0) {
        p = p->parent();
    }
    for (; p != 0; p = p->parent()) {
        if (p == top) {
            return true;
        }
    }
    return false;
}

//  An item's widget is a child of the tree, which FLTK leaves there when
//  the item goes, still taking events where it was last drawn (pofltk
//  58).  The widget belongs to the Ada program, so it is taken out of the
//  tree rather than deleted.
static void drop_widgets(Fl_Tree * tr, Fl_Tree_Item * it, bool self) {
    for (int i = it->children(); i-- > 0;) {
        drop_widgets(tr, it->child(i), true);
    }
    Fl_Widget * w = it->widget();
    if (self && w != 0) {
        it->widget(0);
        if (w->parent() == tr) {
            tr->Fl_Group::remove(w);
        }
    }
}

//  Fl_Tree::remove forgets only the item it is given as the last one
//  clicked, and replace and clear_children forget nothing; none of them
//  forgets the callback item (pofltk 41 and 42).  So before items go,
//  the tree forgets either of them that is among them, and their widgets
//  leave the tree.
void fl_tree_forget(TREE t, TREEITEM item, int below) {
    Fl_Tree * tr = static_cast<Fl_Tree*>(t);
    Fl_Tree_Item * top = static_cast<Fl_Tree_Item*>(item);
    if (tr == 0 || top == 0) {
        return;
    }
    Fl_Tree_Item *& last = tr->*member(Last_Select());
    if (under(last, top, below != 0)) {
        last = 0;
    }
    if (under(tr->callback_item(), top, below != 0)) {
        tr->callback_item(0);
    }
    drop_widgets(tr, top, below == 0);
    ++removals;
}




//  Attaching all relevant hooks and friends

class My_Tree : public Fl_Tree {
public:
    using Fl_Tree::Fl_Tree;

    friend void fl_tree_draw(TREE n);
    friend int fl_tree_handle(TREE n, int e);

    void draw();
    int handle(int e);

protected:
    void on_remove(int index);
};

void My_Tree::draw() {
    widget_draw_hook(this->user_data());
}

int My_Tree::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}

//  A widget leaving the tree, finalized or added to another group, is no
//  longer its item's, which FLTK would otherwise go on drawing (pofltk
//  58).
void My_Tree::on_remove(int index) {
    Fl_Widget * w = child(index);
    for (Fl_Tree_Item * i = first(); i != 0; i = next(i)) {
        if (i->widget() == w) {
            i->widget(0);
            recalc_tree();
            break;
        }
    }
    Fl_Tree::on_remove(index);
}




//  Flattened C API

TREE new_fl_tree(int x, int y, int w, int h, char * label) {
    My_Tree *t = new My_Tree(x, y, w, h, label);
    return t;
}

void free_fl_tree(TREE t) {
    if (fl_inside_callback) {
        fl_delete_widget(t);
    } else {
        delete static_cast<My_Tree*>(t);
    }
}




TREEITEM fl_tree_add(TREE t, const char * path) {
    return static_cast<Fl_Tree*>(t)->add(path);
}

TREEITEM fl_tree_add_item(TREE t, const char * path, TREEITEM item) {
    return static_cast<Fl_Tree*>(t)->add(path, static_cast<Fl_Tree_Item*>(item));
}

TREEITEM fl_tree_insert(TREE t, TREEITEM under, const char * name, int pos) {
    return static_cast<Fl_Tree*>(t)->insert(static_cast<Fl_Tree_Item*>(under), name, pos);
}

TREEITEM fl_tree_insert_above(TREE t, TREEITEM above, const char * name) {
    return static_cast<Fl_Tree*>(t)->insert_above(static_cast<Fl_Tree_Item*>(above), name);
}

//  Whether an item of tree t shows img as its user icon, or as the one it
//  shows while inactive (pofltk 78).
int fl_tree_shows_icon(TREE t, void * img) {
    Fl_Tree * tr = static_cast<Fl_Tree*>(t);
    for (Fl_Tree_Item * it = tr->first(); it != 0; it = it->next()) {
        if (it->usericon() == img || it->userdeicon() == img) {
            return 1;
        }
    }
    return 0;
}

void fl_tree_remove(TREE t, TREEITEM item) {
    fl_tree_forget(t, item, 0);
    static_cast<Fl_Tree*>(t)->remove(static_cast<Fl_Tree_Item*>(item));
}

void fl_tree_clear(TREE t) {
    fl_tree_forget(t, static_cast<Fl_Tree*>(t)->root(), 0);
    static_cast<Fl_Tree*>(t)->clear();
}

void fl_tree_clear_children(TREE t, TREEITEM item) {
    fl_tree_forget(t, item, 1);
    static_cast<Fl_Tree*>(t)->clear_children(static_cast<Fl_Tree_Item*>(item));
}

TREEITEM fl_tree_find_item(TREE t, const char * path) {
    return static_cast<Fl_Tree*>(t)->find_item(path);
}




TREEITEM fl_tree_root(TREE t) {
    return static_cast<Fl_Tree*>(t)->root();
}

void fl_tree_set_root_label(TREE t, const char * label) {
    static_cast<Fl_Tree*>(t)->root_label(label);
}




TREEITEM fl_tree_callback_item(TREE t) {
    return static_cast<Fl_Tree*>(t)->callback_item();
}

int fl_tree_callback_reason(TREE t) {
    return static_cast<Fl_Tree*>(t)->callback_reason();
}

int fl_tree_item_pathname(TREE t, char * buf, int len, TREEITEM i) {
    return static_cast<Fl_Tree*>(t)->item_pathname(buf, len, static_cast<Fl_Tree_Item*>(i));
}




TREEITEM fl_tree_first(TREE t) {
    return static_cast<Fl_Tree*>(t)->first();
}

TREEITEM fl_tree_last(TREE t) {
    return static_cast<Fl_Tree*>(t)->last();
}




void fl_tree_open(TREE t, TREEITEM item) {
    static_cast<Fl_Tree*>(t)->open(static_cast<Fl_Tree_Item*>(item));
}

void fl_tree_close(TREE t, TREEITEM item) {
    static_cast<Fl_Tree*>(t)->close(static_cast<Fl_Tree_Item*>(item));
}

void fl_tree_open_toggle(TREE t, TREEITEM item) {
    static_cast<Fl_Tree*>(t)->open_toggle(static_cast<Fl_Tree_Item*>(item));
}




void fl_tree_select(TREE t, TREEITEM item) {
    static_cast<Fl_Tree*>(t)->select(static_cast<Fl_Tree_Item*>(item));
}

void fl_tree_deselect(TREE t, TREEITEM item) {
    static_cast<Fl_Tree*>(t)->deselect(static_cast<Fl_Tree_Item*>(item));
}

int fl_tree_select_all(TREE t) {
    return static_cast<Fl_Tree*>(t)->select_all(0);
}

int fl_tree_deselect_all(TREE t) {
    return static_cast<Fl_Tree*>(t)->deselect_all(0);
}




int fl_tree_selected_count(TREE t) {
    Fl_Tree_Item_Array items;
    static_cast<Fl_Tree*>(t)->get_selected_items(items);
    return items.total();
}

void fl_tree_selected_fill(TREE t, TREEITEM * buf, int max) {
    Fl_Tree_Item_Array items;
    static_cast<Fl_Tree*>(t)->get_selected_items(items);
    int count = items.total();
    if (count > max) {
        count = max;
    }
    for (int i = 0; i < count; i++) {
        buf[i] = items[i];
    }
}




int fl_tree_get_show_root(TREE t) {
    return static_cast<Fl_Tree*>(t)->showroot();
}

void fl_tree_set_show_root(TREE t, int val) {
    static_cast<Fl_Tree*>(t)->showroot(val);
}

int fl_tree_get_show_collapse(TREE t) {
    return static_cast<Fl_Tree*>(t)->showcollapse();
}

void fl_tree_set_show_collapse(TREE t, int val) {
    static_cast<Fl_Tree*>(t)->showcollapse(val);
}

int fl_tree_get_select_mode(TREE t) {
    return static_cast<int>(static_cast<Fl_Tree*>(t)->selectmode());
}

void fl_tree_set_select_mode(TREE t, int val) {
    static_cast<Fl_Tree*>(t)->selectmode(static_cast<Fl_Tree_Select>(val));
}

int fl_tree_get_connector_style(TREE t) {
    return static_cast<int>(static_cast<Fl_Tree*>(t)->connectorstyle());
}

void fl_tree_set_connector_style(TREE t, int val) {
    static_cast<Fl_Tree*>(t)->connectorstyle(static_cast<Fl_Tree_Connector>(val));
}

int fl_tree_get_sort_order(TREE t) {
    return static_cast<int>(static_cast<Fl_Tree*>(t)->sortorder());
}

void fl_tree_set_sort_order(TREE t, int val) {
    static_cast<Fl_Tree*>(t)->sortorder(static_cast<Fl_Tree_Sort>(val));
}

int fl_tree_get_item_label_font(TREE t) {
    return static_cast<Fl_Tree*>(t)->item_labelfont();
}

void fl_tree_set_item_label_font(TREE t, int val) {
    static_cast<Fl_Tree*>(t)->item_labelfont(val);
}

int fl_tree_get_item_label_size(TREE t) {
    return static_cast<Fl_Tree*>(t)->item_labelsize();
}

void fl_tree_set_item_label_size(TREE t, int val) {
    static_cast<Fl_Tree*>(t)->item_labelsize(val);
}

unsigned int fl_tree_get_item_label_color(TREE t) {
    return static_cast<Fl_Tree*>(t)->item_labelfgcolor();
}

void fl_tree_set_item_label_color(TREE t, unsigned int val) {
    static_cast<Fl_Tree*>(t)->item_labelfgcolor(val);
}

int fl_tree_get_margin_left(TREE t) {
    return static_cast<Fl_Tree*>(t)->marginleft();
}

void fl_tree_set_margin_left(TREE t, int val) {
    static_cast<Fl_Tree*>(t)->marginleft(val);
}

int fl_tree_get_widget_margin_left(TREE t) {
    return static_cast<Fl_Tree*>(t)->widgetmarginleft();
}

void fl_tree_set_widget_margin_left(TREE t, int val) {
    static_cast<Fl_Tree*>(t)->widgetmarginleft(val);
}

int fl_tree_get_line_spacing(TREE t) {
    return static_cast<Fl_Tree*>(t)->linespacing();
}

void fl_tree_set_line_spacing(TREE t, int val) {
    static_cast<Fl_Tree*>(t)->linespacing(val);
}

int fl_tree_get_item_draw_mode(TREE t) {
    return static_cast<Fl_Tree*>(t)->item_draw_mode();
}

void fl_tree_set_item_draw_mode(TREE t, int val) {
    static_cast<Fl_Tree*>(t)->item_draw_mode(val);
}

int fl_tree_get_select_box(TREE t) {
    return static_cast<int>(static_cast<Fl_Tree*>(t)->selectbox());
}

void fl_tree_set_select_box(TREE t, int val) {
    static_cast<Fl_Tree*>(t)->selectbox(static_cast<Fl_Boxtype>(val));
}




void fl_tree_show_self(TREE t) {
    static_cast<Fl_Tree*>(t)->show_self();
}




void fl_tree_draw(TREE n) {
    static_cast<My_Tree*>(n)->Fl_Tree::draw();
}

//  Fl_Tree::handle makes the item pushed the last one clicked after the
//  callback, which may have removed it, and a drag then moves it (pofltk
//  59).  So after an event in which items were removed, the last one
//  clicked is forgotten unless it is still in the tree.
int fl_tree_handle(TREE n, int e) {
    unsigned long before = removals;
    My_Tree * t = static_cast<My_Tree*>(n);
    int r = t->Fl_Tree::handle(e);
    if (removals != before) {
        Fl_Tree_Item *& last = t->*member(Last_Select());
        Fl_Tree_Item * i = t->first();
        while (i != 0 && i != last) {
            i = t->next(i);
        }
        if (i == 0) {
            last = 0;
        }
    }
    return r;
}


