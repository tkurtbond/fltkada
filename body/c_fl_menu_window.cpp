

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Menu_Window.H>
#include "c_fl_menu_window.h"
#include "c_fl_window.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Menu_Window : public Ada_Resizing<Fl_Menu_Window> {
public:
    using Ada_Resizing<Fl_Menu_Window>::Ada_Resizing;

    ~My_Menu_Window() { window_shape_gone(this); }

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
    if (fl_inside_callback) {
        fl_delete_widget(m);
    } else {
        delete static_cast<My_Menu_Window*>(m);
    }
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
    //  Hardware overlay planes were removed in FLTK 1.4; nothing to erase.
    (void)m;
}




void fl_menu_window_set_overlay(MENUWINDOW m) {
    //  Hardware overlay planes were removed in FLTK 1.4; no-op.
    (void)m;
}

void fl_menu_window_clear_overlay(MENUWINDOW m) {
    //  Hardware overlay planes were removed in FLTK 1.4; no-op.
    (void)m;
}

unsigned int fl_menu_window_overlay(MENUWINDOW m) {
    //  Hardware overlay planes were removed in FLTK 1.4; never overlaid.
    (void)m;
    return 0;
}




void fl_menu_window_draw(MENUWINDOW n) {
    static_cast<My_Menu_Window*>(n)->Fl_Menu_Window::draw();
}

int fl_menu_window_handle(MENUWINDOW n, int e) {
    return static_cast<My_Menu_Window*>(n)->Fl_Menu_Window::handle(e);
}


