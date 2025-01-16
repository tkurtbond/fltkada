

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Menu_Window.H>
#include "c_fl_menu_window.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Menu_Window : public Fl_Menu_Window {
public:
    using Fl_Menu_Window::Fl_Menu_Window;

    friend void fl_menu_window_draw(MENUWINDOW n);
    friend int fl_menu_window_handle(MENUWINDOW n, int e);

    void draw();
    int handle(int e);
};

void My_Menu_Window::draw() {
    widget_draw_hook(this->user_data());
}

int My_Menu_Window::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

MENUWINDOW new_fl_menu_window(int x, int y, int w, int h, char* label) {
    My_Menu_Window *m = new My_Menu_Window(x, y, w, h, label);
    return m;
}

MENUWINDOW new_fl_menu_window2(int w, int h, char* label) {
    My_Menu_Window *m = new My_Menu_Window(w, h, label);
    return m;
}

void free_fl_menu_window(MENUWINDOW m) {
    delete static_cast<My_Menu_Window*>(m);
}




void fl_menu_window_show(MENUWINDOW m) {
    static_cast<Fl_Menu_Window*>(m)->show();
}

void fl_menu_window_hide(MENUWINDOW m) {
    static_cast<Fl_Menu_Window*>(m)->hide();
}

void fl_menu_window_flush(MENUWINDOW m) {
    static_cast<Fl_Menu_Window*>(m)->flush();
}

void fl_menu_window_erase(MENUWINDOW m) {
    static_cast<Fl_Menu_Window*>(m)->erase();
}




void fl_menu_window_set_overlay(MENUWINDOW m) {
    static_cast<Fl_Menu_Window*>(m)->set_overlay();
}

void fl_menu_window_clear_overlay(MENUWINDOW m) {
    static_cast<Fl_Menu_Window*>(m)->clear_overlay();
}

unsigned int fl_menu_window_overlay(MENUWINDOW m) {
    return static_cast<Fl_Menu_Window*>(m)->overlay();
}




void fl_menu_window_draw(MENUWINDOW n) {
    static_cast<My_Menu_Window*>(n)->Fl_Menu_Window::draw();
}

int fl_menu_window_handle(MENUWINDOW n, int e) {
    return static_cast<My_Menu_Window*>(n)->Fl_Menu_Window::handle(e);
}


