

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Sys_Menu_Bar.H>
#include <FL/Fl_Menu_Item.H>
#include "c_fl_sys_menu_bar.h"




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
    delete static_cast<My_Sys_Menu_Bar*>(m);
}




int fl_sys_menu_bar_add(SYSMENUBAR m, const char * t) {
    return static_cast<Fl_Sys_Menu_Bar*>(m)->add(t);
}

int fl_sys_menu_bar_add2(SYSMENUBAR m, const char * t, unsigned long s, void * u, unsigned long f) {
    return static_cast<Fl_Sys_Menu_Bar*>(m)->add(t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_sys_menu_bar_add3(SYSMENUBAR m, const char * t, const char * s, void * u, unsigned long f) {
    return static_cast<Fl_Sys_Menu_Bar*>(m)->add(t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_sys_menu_bar_insert(SYSMENUBAR m, int p, const char * t, unsigned long s,
    void * u, unsigned long f)
{
    return static_cast<Fl_Sys_Menu_Bar*>(m)->insert(p, t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_sys_menu_bar_insert2(SYSMENUBAR m, int p, const char * t, const char * s,
    void * u, unsigned long f)
{
    return static_cast<Fl_Sys_Menu_Bar*>(m)->insert(p, t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

void fl_sys_menu_bar_set_menu(SYSMENUBAR m, void * d) {
    static_cast<Fl_Sys_Menu_Bar*>(m)->menu(static_cast<Fl_Menu_*>(d)->menu());
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

void fl_sys_menu_bar_replace(SYSMENUBAR m, int i, const char * t) {
    static_cast<Fl_Sys_Menu_Bar*>(m)->replace(i, t);
}

void fl_sys_menu_bar_shortcut(SYSMENUBAR m, int i, unsigned long s) {
    static_cast<Fl_Sys_Menu_Bar*>(m)->shortcut(i, s);
}

unsigned long fl_sys_menu_bar_get_mode(SYSMENUBAR m, int i) {
    return static_cast<Fl_Sys_Menu_Bar*>(m)->mode(i);
}

void fl_sys_menu_bar_set_mode(SYSMENUBAR m, int i, unsigned long f) {
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


