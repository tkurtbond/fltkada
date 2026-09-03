

//  Programmed by T. Kurt Bond and Claude Sonnet 5
//  Released into the public domain


#include <FL/Fl_Tree.H>
#include "c_fl_tree.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Tree : public Fl_Tree {
public:
    using Fl_Tree::Fl_Tree;

    friend void fl_tree_draw(TREE n);
    friend int fl_tree_handle(TREE n, int e);

    void draw();
    int handle(int e);
};

void My_Tree::draw() {
    widget_draw_hook(this->user_data());
}

int My_Tree::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
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

TREEITEM fl_tree_insert(TREE t, TREEITEM under, const char * name, int pos) {
    return static_cast<Fl_Tree*>(t)->insert(static_cast<Fl_Tree_Item*>(under), name, pos);
}

TREEITEM fl_tree_insert_above(TREE t, TREEITEM above, const char * name) {
    return static_cast<Fl_Tree*>(t)->insert_above(static_cast<Fl_Tree_Item*>(above), name);
}

void fl_tree_remove(TREE t, TREEITEM item) {
    static_cast<Fl_Tree*>(t)->remove(static_cast<Fl_Tree_Item*>(item));
}

void fl_tree_clear(TREE t) {
    static_cast<Fl_Tree*>(t)->clear();
}

void fl_tree_clear_children(TREE t, TREEITEM item) {
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




void fl_tree_draw(TREE n) {
    static_cast<My_Tree*>(n)->Fl_Tree::draw();
}

int fl_tree_handle(TREE n, int e) {
    return static_cast<My_Tree*>(n)->Fl_Tree::handle(e);
}


