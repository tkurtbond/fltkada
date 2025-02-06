

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Menu_.H>
#include <FL/Fl_Menu_Item.H>
#include "c_fl_menu.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" void menu_item_callback_hook(void * cobj, void * ud);




//  Attaching all relevant hooks and friends

class My_Menu : public Fl_Menu_ {
public:
    using Fl_Menu_::Fl_Menu_;

    friend void fl_menu_draw(MENU m);
    friend int fl_menu_handle(MENU m, int e);

    void draw();
    int handle(int e);
};

void My_Menu::draw() {
    widget_draw_hook(this->user_data());
}

int My_Menu::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

MENU new_fl_menu(int x, int y, int w, int h, char* label) {
    My_Menu *m = new My_Menu(x, y, w, h, label);
    return m;
}

void free_fl_menu(MENU m) {
    if (fl_inside_callback) {
        fl_delete_widget(m);
    } else {
        delete static_cast<My_Menu*>(m);
    }
}




int fl_menu_add(MENU m, const char * t) {
    return static_cast<Fl_Menu_*>(m)->add(t);
}

int fl_menu_add2(MENU m, const char * t, unsigned long s, void * u, unsigned long f) {
    return static_cast<Fl_Menu_*>(m)->add(t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_menu_add3(MENU m, const char * t, const char * s, void * u, unsigned long f) {
    return static_cast<Fl_Menu_*>(m)->add(t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_menu_insert(MENU m, int p, const char * t, unsigned long s, void * u, unsigned long f) {
    return static_cast<Fl_Menu_*>(m)->insert(p, t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_menu_insert2(MENU m, int p, const char * t, const char * s, void * u, unsigned long f) {
    return static_cast<Fl_Menu_*>(m)->insert(p, t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

void fl_menu_copy(MENU m, void * mi) {
    static_cast<Fl_Menu_*>(m)->copy(static_cast<const Fl_Menu_Item*>(mi), 0);
}

void fl_menu_set_menu(MENU m, MENU d) {
    static_cast<Fl_Menu_*>(m)->menu(static_cast<Fl_Menu_*>(d)->menu());
}

void fl_menu_remove(MENU m, int p) {
    static_cast<Fl_Menu_*>(m)->remove(p);
}

void fl_menu_clear(MENU m) {
    static_cast<Fl_Menu_*>(m)->clear();
}

int fl_menu_clear_submenu(MENU m, int i) {
    return static_cast<Fl_Menu_*>(m)->clear_submenu(i);
}




const void * fl_menu_get_item(MENU m, int i) {
    return &(static_cast<Fl_Menu_*>(m)->menu()[i]);
}

//  find_item and find_item2 are subsumed by find_index and find_index3
//  since we need to get the index for the Ada side anyway.

int fl_menu_find_index(MENU m, const char * t) {
    return static_cast<Fl_Menu_*>(m)->find_index(t);
}

int fl_menu_find_index2(MENU m, void * i) {
    return static_cast<Fl_Menu_*>(m)->find_index(static_cast<Fl_Menu_Item*>(i));
}

int fl_menu_find_index3(MENU m, void * cb) {
    //  have to loop through the array manually since callbacks are stored in userdata
    for (int i=0; i<fl_menu_size(m); i++) {
        if (static_cast<Fl_Menu_*>(m)->menu()[i].user_data() == cb) {
            return i;
        }
    }
    return -1;
}

int fl_menu_item_pathname(MENU m, char * buf, int len, void * mi) {
    return static_cast<Fl_Menu_*>(m)->item_pathname(buf, len, static_cast<Fl_Menu_Item*>(mi));
}

int fl_menu_size(MENU m) {
    return static_cast<Fl_Menu_*>(m)->size();
}




//  mvalue is subsumed by value since we need to get the index for
//  the Ada side anyway.

const char * fl_menu_text(MENU m) {
    return static_cast<Fl_Menu_*>(m)->text();
}

int fl_menu_value(MENU m) {
    return static_cast<Fl_Menu_*>(m)->value();
}

int fl_menu_set_value(MENU m, void * i) {
    return static_cast<Fl_Menu_*>(m)->value(static_cast<Fl_Menu_Item*>(i));
}

int fl_menu_set_value2(MENU m, int p) {
    return static_cast<Fl_Menu_*>(m)->value(p);
}




void fl_menu_setonly(MENU m, void * mi) {
    static_cast<Fl_Menu_*>(m)->setonly(static_cast<Fl_Menu_Item*>(mi));
}

const char * fl_menu_text2(MENU m, int i) {
    return static_cast<Fl_Menu_*>(m)->text(i);
}

void fl_menu_replace(MENU m, int i, const char * t) {
    static_cast<Fl_Menu_*>(m)->replace(i, t);
}

void fl_menu_shortcut(MENU m, int i, unsigned long s) {
    static_cast<Fl_Menu_*>(m)->shortcut(i, s);
}

unsigned long fl_menu_get_mode(MENU m, int i) {
    return static_cast<Fl_Menu_*>(m)->mode(i);
}

void fl_menu_set_mode(MENU m, int i, unsigned long f) {
    static_cast<Fl_Menu_*>(m)->mode(i, f);
}




unsigned int fl_menu_get_textcolor(MENU m) {
    return static_cast<Fl_Menu_*>(m)->textcolor();
}

void fl_menu_set_textcolor(MENU m, unsigned int c) {
    static_cast<Fl_Menu_*>(m)->textcolor(c);
}

int fl_menu_get_textfont(MENU m) {
    return static_cast<Fl_Menu_*>(m)->textfont();
}

void fl_menu_set_textfont(MENU m, int f) {
    static_cast<Fl_Menu_*>(m)->textfont(f);
}

int fl_menu_get_textsize(MENU m) {
    return static_cast<Fl_Menu_*>(m)->textsize();
}

void fl_menu_set_textsize(MENU m, int s) {
    static_cast<Fl_Menu_*>(m)->textsize(s);
}




int fl_menu_get_down_box(MENU m) {
    return static_cast<Fl_Menu_*>(m)->down_box();
}

void fl_menu_set_down_box(MENU m, int t) {
    static_cast<Fl_Menu_*>(m)->down_box(static_cast<Fl_Boxtype>(t));
}

void fl_menu_global(MENU m) {
    static_cast<Fl_Menu_*>(m)->global();
}

int fl_menu_measure(MENU m, int i, int *h) {
    //  method actually belongs to Fl_Menu_Item
    const Fl_Menu_Item * item = static_cast<const Fl_Menu_Item*>(fl_menu_get_item(m,i));
    return item==0?0:item->measure(h, static_cast<Fl_Menu_*>(m));
}




const void * fl_menu_popup(MENU m, int x, int y, const char * t, int n) {
    //  method actually belongs to Fl_Menu_Item
    const Fl_Menu_Item * menuhead = static_cast<const Fl_Menu_Item*>(fl_menu_get_item(m, 0));
    const Fl_Menu_Item * initial  = n<0?0:static_cast<const Fl_Menu_Item*>(fl_menu_get_item(m, n));
    return menuhead->popup(x, y, t, initial, static_cast<Fl_Menu_*>(m));
}

const void * fl_menu_pulldown(MENU m, int x, int y, int w, int h, int n) {
    //  method actually belongs to Fl_Menu_Item
    const Fl_Menu_Item * menuhead = static_cast<const Fl_Menu_Item*>(fl_menu_get_item(m, 0));
    const Fl_Menu_Item * initial  = n<0?0:static_cast<const Fl_Menu_Item*>(fl_menu_get_item(m, n));
    return menuhead->pulldown(x, y, w, h, initial, static_cast<Fl_Menu_*>(m));
}

const void * fl_menu_picked(MENU m, const void * mi) {
    return static_cast<Fl_Menu_*>(m)->picked(static_cast<const Fl_Menu_Item*>(mi));
}

const void * fl_menu_find_shortcut(MENU m, void * ip, int a) {
    //  method actually belongs to Fl_Menu_Item
    const Fl_Menu_Item * dummy = static_cast<const Fl_Menu_Item*>(fl_menu_get_item(m, 0));
    return dummy==0?0:dummy->find_shortcut(static_cast<int*>(ip), static_cast<bool>(a));
}

const void * fl_menu_test_shortcut(MENU m) {
    return static_cast<Fl_Menu_*>(m)->test_shortcut();
}




void fl_menu_size2(MENU m, int w, int h) {
    static_cast<Fl_Menu_*>(m)->size(w, h);
}




void fl_menu_draw_item(MENU m, int i, int x, int y, int w, int h, int s) {
    //  method actually belongs to Fl_Menu_Item
    const Fl_Menu_Item * item = static_cast<const Fl_Menu_Item*>(fl_menu_get_item(m,i));
    if (item != 0) {
        item->draw(x, y, w, h, static_cast<Fl_Menu_*>(m), s);
    }
}

void fl_menu_draw(MENU m) {
    //  The Fl_Menu_ draw method doesn't technically exist, so...
    (void)(m);
    //  It is more convenient for this function to exist, however,
    //  even though it will likely never be called, because it simplifies
    //  and makes uniform the implementation of the Ada Menu Draw subprogram.
}

int fl_menu_handle(MENU m, int e) {
    return static_cast<My_Menu*>(m)->Fl_Menu_::handle(e);
}


