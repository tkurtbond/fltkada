

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Sys_Menu_Bar.H>
#include <FL/Fl_Menu_Item.H>
#include "c_fl_sys_menu_bar.h"
#include "c_fl_menuitem.h"
#include "c_fl_menu.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" void menu_item_callback_hook(void * cobj, void * ud);




//  Attaching all relevant hooks and friends

class My_Sys_Menu_Bar : public Ada_Resizing<Fl_Sys_Menu_Bar> {
public:
    using Ada_Resizing<Fl_Sys_Menu_Bar>::Ada_Resizing;

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
    plain_menu(static_cast<Fl_Menu_*>(m));
    if (fl_inside_callback) {
        fl_delete_widget(m);
    } else {
        delete static_cast<My_Sys_Menu_Bar*>(m);
    }
}




int fl_sys_menu_bar_add(SYSMENUBAR m, const char * t) {
    Item_Names names(static_cast<Fl_Menu_*>(m));
    return static_cast<Fl_Sys_Menu_Bar*>(m)->add(t);
}

int fl_sys_menu_bar_add2(SYSMENUBAR m, const char * t, int s, void * u, int f) {
    Item_Names names(static_cast<Fl_Menu_*>(m));
    return static_cast<Fl_Sys_Menu_Bar*>(m)->add(t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_sys_menu_bar_add3(SYSMENUBAR m, const char * t, const char * s, void * u, int f) {
    Item_Names names(static_cast<Fl_Menu_*>(m));
    return static_cast<Fl_Sys_Menu_Bar*>(m)->add(t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_sys_menu_bar_insert(SYSMENUBAR m, int p, const char * t, int s, void * u, int f) {
    Item_Names names(static_cast<Fl_Menu_*>(m));
    return static_cast<Fl_Sys_Menu_Bar*>(m)->insert(p, t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_sys_menu_bar_insert2(SYSMENUBAR m, int p, const char * t, const char * s, void * u, int f) {
    Item_Names names(static_cast<Fl_Menu_*>(m));
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

//  As fl_menu_remove, fl_menu_clear and fl_menu_clear_submenu, in c_fl_menu.cpp.
void fl_sys_menu_bar_remove(SYSMENUBAR m, int p) {
    fl_menu_plain_removed(m, p, 0);
    static_cast<Fl_Sys_Menu_Bar*>(m)->remove(p);
}

void fl_sys_menu_bar_clear(SYSMENUBAR m) {
    plain_menu(static_cast<Fl_Menu_*>(m));
    static_cast<Fl_Sys_Menu_Bar*>(m)->clear();
}

int fl_sys_menu_bar_clear_submenu(SYSMENUBAR m, int i) {
    fl_menu_plain_removed(m, i, 1);
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
    plain_items(const_cast<Fl_Menu_Item*>(bar->menu()), i, i + 1);
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

//  FL_SUBMENU and FL_SUBMENU_POINTER give the array its shape, so setting
//  them on an item in a menu, or clearing them on a title, makes FLTK read
//  the items in a different way (FLTKAda-BUGS.md 106).  They are kept.
void fl_sys_menu_bar_set_mode(SYSMENUBAR m, int i, int f) {
    Fl_Sys_Menu_Bar * bar = static_cast<Fl_Sys_Menu_Bar*>(m);
    const int shape = FL_SUBMENU | FL_SUBMENU_POINTER;
    bar->mode(i, (bar->mode(i) & shape) | (f & ~shape));
}




void fl_sys_menu_bar_global(SYSMENUBAR m) {
    static_cast<Fl_Sys_Menu_Bar*>(m)->global();
}

void fl_sys_menu_bar_update(SYSMENUBAR m) {
    static_cast<Fl_Sys_Menu_Bar*>(m)->update();
}




//  These do nothing except on macOS, the only system with a driver for
//  them (Fl_Sys_Menu_Bar.cxx).

void fl_sys_menu_bar_about(void (*cb)(void*, void*)) {
    Fl_Sys_Menu_Bar::about(reinterpret_cast<Fl_Callback*>(cb), 0);
}

int fl_sys_menu_bar_get_window_menu_style() {
    return Fl_Sys_Menu_Bar::window_menu_style();
}

void fl_sys_menu_bar_set_window_menu_style(int s) {
    Fl_Sys_Menu_Bar::window_menu_style(static_cast<Fl_Sys_Menu_Bar::window_menu_style_enum>(s));
}

void fl_sys_menu_bar_create_window_menu() {
    Fl_Sys_Menu_Bar::create_window_menu();
}




void fl_sys_menu_bar_draw(SYSMENUBAR m) {
    static_cast<My_Sys_Menu_Bar*>(m)->Fl_Sys_Menu_Bar::draw();
}

int fl_sys_menu_bar_handle(SYSMENUBAR m, int e) {
    return static_cast<My_Sys_Menu_Bar*>(m)->Fl_Sys_Menu_Bar::handle(e);
}


