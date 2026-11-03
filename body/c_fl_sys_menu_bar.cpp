

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Sys_Menu_Bar.H>
#include <FL/Fl_Menu_Item.H>
#include "c_fl_sys_menu_bar.h"
#include "c_fl_menu.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" void menu_item_callback_hook(void * cobj, void * ud);




//  Attaching all relevant hooks and friends

class My_Sys_Menu_Bar : public Fl_Sys_Menu_Bar {
public:
    using Fl_Sys_Menu_Bar::Fl_Sys_Menu_Bar;

    friend void fl_sys_menu_bar_draw(SYSMENUBAR m);
    friend int fl_sys_menu_bar_handle(SYSMENUBAR m, int e);

    void draw();
    int handle(int e);
};

void My_Sys_Menu_Bar::draw() {
    widget_draw_hook(this->user_data());
}

int My_Sys_Menu_Bar::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

SYSMENUBAR new_fl_sys_menu_bar(int x, int y, int w, int h, char* label) {
    My_Sys_Menu_Bar *m = new My_Sys_Menu_Bar(x, y, w, h, label);
    return m;
}

void free_fl_sys_menu_bar(SYSMENUBAR m) {
    if (fl_inside_callback) {
        fl_delete_widget(m);
    } else {
        delete static_cast<My_Sys_Menu_Bar*>(m);
    }
}




int fl_sys_menu_bar_add(SYSMENUBAR m, const char * t) {
    return static_cast<Fl_Sys_Menu_Bar*>(m)->add(t);
}

int fl_sys_menu_bar_add2(SYSMENUBAR m, const char * t, int s, void * u, int f) {
    return static_cast<Fl_Sys_Menu_Bar*>(m)->add(t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_sys_menu_bar_add3(SYSMENUBAR m, const char * t, const char * s, void * u, int f) {
    return static_cast<Fl_Sys_Menu_Bar*>(m)->add(t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_sys_menu_bar_insert(SYSMENUBAR m, int p, const char * t, int s, void * u, int f) {
    return static_cast<Fl_Sys_Menu_Bar*>(m)->insert(p, t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_sys_menu_bar_insert2(SYSMENUBAR m, int p, const char * t, const char * s, void * u, int f) {
    return static_cast<Fl_Sys_Menu_Bar*>(m)->insert(p, t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

//  Gives the bar its own copy of the donor's items, as fl_menu_set_menu
//  does for any menu (FLTKAda-BUGS.md 38).  Fl_Sys_Menu_Bar::menu hides
//  Fl_Menu_::menu, but off macOS its driver only calls Fl_Menu_Bar::menu
//  (Fl_Sys_Menu_Bar_Driver.H:42); update() then tells any native bar.
int fl_sys_menu_bar_set_menu(SYSMENUBAR m, void * d) {
    int result = fl_menu_set_menu(m, d);
    static_cast<Fl_Sys_Menu_Bar*>(m)->update();
    return result;
}

void fl_sys_menu_bar_remove(SYSMENUBAR m, int p) {
    static_cast<Fl_Sys_Menu_Bar*>(m)->remove(p);
}

void fl_sys_menu_bar_clear(SYSMENUBAR m) {
    static_cast<Fl_Sys_Menu_Bar*>(m)->clear();
}

int fl_sys_menu_bar_clear_submenu(SYSMENUBAR m, int i) {
    return static_cast<Fl_Sys_Menu_Bar*>(m)->clear_submenu(i);
}




const void * fl_sys_menu_bar_get_item(SYSMENUBAR m, int i) {
    return &(static_cast<Fl_Sys_Menu_Bar*>(m)->menu()[i]);
}




void fl_sys_menu_bar_setonly(SYSMENUBAR m, void * mi) {
    static_cast<Fl_Sys_Menu_Bar*>(m)->setonly(static_cast<Fl_Menu_Item*>(mi));
}

//  As fl_menu_replace, in c_fl_menu.cpp.
int fl_sys_menu_bar_replace(SYSMENUBAR m, int i, const char * t, const char ** o) {
    Fl_Sys_Menu_Bar * bar = static_cast<Fl_Sys_Menu_Bar*>(m);
    *o = 0;
    if (i < 0 || i >= bar->size()) {
        return 0;
    }
    *o = bar->menu()[i].text;
    bar->replace(i, t);
    return bar->menu()[i].text == t;
}

void fl_sys_menu_bar_shortcut(SYSMENUBAR m, int i, int s) {
    static_cast<Fl_Sys_Menu_Bar*>(m)->shortcut(i, s);
}

int fl_sys_menu_bar_get_mode(SYSMENUBAR m, int i) {
    return static_cast<Fl_Sys_Menu_Bar*>(m)->mode(i);
}

void fl_sys_menu_bar_set_mode(SYSMENUBAR m, int i, int f) {
    static_cast<Fl_Sys_Menu_Bar*>(m)->mode(i, f);
}




void fl_sys_menu_bar_global(SYSMENUBAR m) {
    static_cast<Fl_Sys_Menu_Bar*>(m)->global();
}

void fl_sys_menu_bar_update(SYSMENUBAR m) {
#if FLTK_ABI_VERSION >= 10304
    static_cast<Fl_Sys_Menu_Bar*>(m)->update();
#else
    (void)(m);
#endif
}




void fl_sys_menu_bar_draw(SYSMENUBAR m) {
    static_cast<My_Sys_Menu_Bar*>(m)->Fl_Sys_Menu_Bar::draw();
}

int fl_sys_menu_bar_handle(SYSMENUBAR m, int e) {
    return static_cast<My_Sys_Menu_Bar*>(m)->Fl_Sys_Menu_Bar::handle(e);
}


