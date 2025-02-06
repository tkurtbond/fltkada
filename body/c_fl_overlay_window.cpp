

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Overlay_Window.H>
#include "c_fl_overlay_window.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" void overlay_window_draw_overlay_hook(void * ud);




//  Attaching all relevant hooks and friends

class My_Overlay_Window : public Fl_Overlay_Window {
public:
    using Fl_Overlay_Window::Fl_Overlay_Window;

    friend OVERLAYWINDOW new_fl_overlay_window(int x, int y, int w, int h, char *label);
    friend OVERLAYWINDOW new_fl_overlay_window2(int w, int h, char *label);

    friend void fl_overlay_window_draw(OVERLAYWINDOW w);
    friend int fl_overlay_window_handle(OVERLAYWINDOW w, int e);

    void draw();
    void draw_overlay();
    int handle(int e);
};

void My_Overlay_Window::draw() {
    widget_draw_hook(this->user_data());
}

void My_Overlay_Window::draw_overlay() {
    overlay_window_draw_overlay_hook(this->user_data());
}

int My_Overlay_Window::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

OVERLAYWINDOW new_fl_overlay_window(int x, int y, int w, int h, char *label) {
    My_Overlay_Window *ow = new My_Overlay_Window(x, y, w, h, label);
    return ow;
}

OVERLAYWINDOW new_fl_overlay_window2(int w, int h, char *label) {
    My_Overlay_Window *ow = new My_Overlay_Window(w, h, label);
    return ow;
}

void free_fl_overlay_window(OVERLAYWINDOW w) {
    if (fl_inside_callback) {
        fl_delete_widget(w);
    } else {
        delete static_cast<My_Overlay_Window*>(w);
    }
}




int fl_overlay_window_can_do_overlay(OVERLAYWINDOW w) {
    return static_cast<Fl_Overlay_Window*>(w)->can_do_overlay();
}

void fl_overlay_window_resize(OVERLAYWINDOW ow, int x, int y, int w, int h) {
    static_cast<Fl_Overlay_Window*>(ow)->resize(x, y, w, h);
}




void fl_overlay_window_show(OVERLAYWINDOW w) {
    static_cast<Fl_Overlay_Window*>(w)->show();
}

void fl_overlay_window_show2(OVERLAYWINDOW w, int c, void * v) {
    static_cast<Fl_Overlay_Window*>(w)->show(c, static_cast<char**>(v));
}

void fl_overlay_window_hide(OVERLAYWINDOW w) {
    static_cast<Fl_Overlay_Window*>(w)->hide();
}

void fl_overlay_window_flush(OVERLAYWINDOW w) {
    static_cast<Fl_Overlay_Window*>(w)->flush();
}




void fl_overlay_window_redraw_overlay(OVERLAYWINDOW w) {
    static_cast<Fl_Overlay_Window*>(w)->redraw_overlay();
}

void fl_overlay_window_draw(OVERLAYWINDOW w) {
    static_cast<My_Overlay_Window*>(w)->Fl_Overlay_Window::draw();
}

int fl_overlay_window_handle(OVERLAYWINDOW w, int e) {
    return static_cast<My_Overlay_Window*>(w)->Fl_Overlay_Window::handle(e);
}


