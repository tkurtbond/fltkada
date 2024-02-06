

#include <FL/Fl_Overlay_Window.H>
#include "c_fl_overlay_window.h"
#include "c_fl_type.h"




class My_Overlay_Window : public Fl_Overlay_Window {
    public:
        using Fl_Overlay_Window::Fl_Overlay_Window;
        friend void overlay_window_set_draw_hook(OVERLAYWINDOW w, void * d);
        friend void fl_overlay_window_draw(OVERLAYWINDOW w);
        friend void overlay_window_set_draw_overlay_hook(OVERLAYWINDOW w, void * d);
        friend void overlay_window_set_handle_hook(OVERLAYWINDOW w, void * h);
        friend int fl_overlay_window_handle(OVERLAYWINDOW w, int e);
        friend OVERLAYWINDOW new_fl_overlay_window(int x, int y, int w, int h, char *label);
        friend OVERLAYWINDOW new_fl_overlay_window2(int w, int h, char *label);
    protected:
        void draw();
        void real_draw();
        void draw_overlay();
        int handle(int e);
        int real_handle(int e);
        d_hook_p draw_hook;
        d_hook_p draw_overlay_hook;
        h_hook_p handle_hook;
};

void My_Overlay_Window::draw() {
    (*draw_hook)(this->user_data());
}

void My_Overlay_Window::real_draw() {
    Fl_Overlay_Window::draw();
}

void My_Overlay_Window::draw_overlay() {
    (*draw_overlay_hook)(this->user_data());
}

int My_Overlay_Window::handle(int e) {
    return (*handle_hook)(this->user_data(), e);
}

int My_Overlay_Window::real_handle(int e) {
    return Fl_Overlay_Window::handle(e);
}

void overlay_window_set_draw_hook(OVERLAYWINDOW w, void * d) {
    reinterpret_cast<My_Overlay_Window*>(w)->draw_hook = reinterpret_cast<d_hook_p>(d);
}

void fl_overlay_window_draw(OVERLAYWINDOW w) {
    reinterpret_cast<My_Overlay_Window*>(w)->real_draw();
}

void overlay_window_set_draw_overlay_hook(OVERLAYWINDOW w, void * d) {
    reinterpret_cast<My_Overlay_Window*>(w)->draw_overlay_hook = reinterpret_cast<d_hook_p>(d);
}

void overlay_window_set_handle_hook(OVERLAYWINDOW w, void * h) {
    reinterpret_cast<My_Overlay_Window*>(w)->handle_hook = reinterpret_cast<h_hook_p>(h);
}

int fl_overlay_window_handle(OVERLAYWINDOW w, int e) {
    return reinterpret_cast<My_Overlay_Window*>(w)->real_handle(e);
}




OVERLAYWINDOW new_fl_overlay_window(int x, int y, int w, int h, char *label) {
    My_Overlay_Window *ow = new My_Overlay_Window(x, y, w, h, label);
    return ow;
}

OVERLAYWINDOW new_fl_overlay_window2(int w, int h, char *label) {
    My_Overlay_Window *ow = new My_Overlay_Window(w, h, label);
    return ow;
}

void free_fl_overlay_window(OVERLAYWINDOW w) {
    delete reinterpret_cast<My_Overlay_Window*>(w);
}




int fl_overlay_window_can_do_overlay(OVERLAYWINDOW w) {
    return reinterpret_cast<Fl_Overlay_Window*>(w)->can_do_overlay();
}




void fl_overlay_window_show(OVERLAYWINDOW w) {
    reinterpret_cast<Fl_Overlay_Window*>(w)->show();
}

void fl_overlay_window_hide(OVERLAYWINDOW w) {
    reinterpret_cast<Fl_Overlay_Window*>(w)->hide();
}

void fl_overlay_window_flush(OVERLAYWINDOW w) {
    reinterpret_cast<Fl_Overlay_Window*>(w)->flush();
}




void fl_overlay_window_redraw_overlay(OVERLAYWINDOW w) {
    reinterpret_cast<Fl_Overlay_Window*>(w)->redraw_overlay();
}


