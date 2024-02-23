

#include <FL/Fl_Gl_Window.H>
#include "c_fl_gl_window.h"
#include "c_fl_type.h"




class My_Gl_Window : public Fl_Gl_Window {
    public:
        using Fl_Gl_Window::Fl_Gl_Window;
        friend void gl_window_set_draw_hook(GLWINDOW n, void * d);
        friend void fl_gl_window_draw(GLWINDOW n);
        friend void gl_window_set_handle_hook(GLWINDOW n, void * h);
        friend int fl_gl_window_handle(GLWINDOW n, int e);
    protected:
        void draw();
        void real_draw();
        int handle(int e);
        int real_handle(int e);
        d_hook_p draw_hook;
        h_hook_p handle_hook;
};

void My_Gl_Window::draw() {
    (*draw_hook)(this->user_data());
}

void My_Gl_Window::real_draw() {
    Fl_Gl_Window::draw();
}

int My_Gl_Window::handle(int e) {
    return (*handle_hook)(this->user_data(), e);
}

int My_Gl_Window::real_handle(int e) {
    return Fl_Gl_Window::handle(e);
}

void gl_window_set_draw_hook(GLWINDOW n, void * d) {
    reinterpret_cast<My_Gl_Window*>(n)->draw_hook = reinterpret_cast<d_hook_p>(d);
}

void fl_gl_window_draw(GLWINDOW n) {
    reinterpret_cast<My_Gl_Window*>(n)->real_draw();
}

void gl_window_set_handle_hook(GLWINDOW n, void * h) {
    reinterpret_cast<My_Gl_Window*>(n)->handle_hook = reinterpret_cast<h_hook_p>(h);
}

int fl_gl_window_handle(GLWINDOW n, int e) {
    return reinterpret_cast<My_Gl_Window*>(n)->real_handle(e);
}




GLWINDOW new_fl_gl_window(int x, int y, int w, int h, char* label) {
    My_Gl_Window *gw = new My_Gl_Window(x, y, w, h, label);
    return gw;
}

GLWINDOW new_fl_gl_window2(int w, int h, char* label) {
    My_Gl_Window *gw = new My_Gl_Window(w, h, label);
    return gw;
}

void free_fl_gl_window(GLWINDOW w) {
    delete reinterpret_cast<My_Gl_Window*>(w);
}




void fl_gl_window_show(GLWINDOW w) {
    reinterpret_cast<Fl_Gl_Window*>(w)->show();
}

void fl_gl_window_hide(GLWINDOW w) {
    reinterpret_cast<Fl_Gl_Window*>(w)->hide();
}

void fl_gl_window_hide_overlay(GLWINDOW w) {
    reinterpret_cast<Fl_Gl_Window*>(w)->hide_overlay();
}

void fl_gl_window_flush(GLWINDOW w) {
    reinterpret_cast<Fl_Gl_Window*>(w)->flush();
}




int fl_gl_window_pixel_h(GLWINDOW w) {
    return reinterpret_cast<Fl_Gl_Window*>(w)->pixel_h();
}

int fl_gl_window_pixel_w(GLWINDOW w) {
    return reinterpret_cast<Fl_Gl_Window*>(w)->pixel_w();
}

float fl_gl_window_pixels_per_unit(GLWINDOW w) {
    return reinterpret_cast<Fl_Gl_Window*>(w)->pixels_per_unit();
}




unsigned int fl_gl_window_get_mode(GLWINDOW w) {
    return reinterpret_cast<Fl_Gl_Window*>(w)->mode();
}

void fl_gl_window_set_mode(GLWINDOW w, unsigned int a) {
    reinterpret_cast<Fl_Gl_Window*>(w)->mode(a);
}

int fl_gl_window_static_can_do(unsigned int m) {
    return Fl_Gl_Window::can_do(m);
}

int fl_gl_window_can_do(GLWINDOW w) {
    return reinterpret_cast<Fl_Gl_Window*>(w)->can_do();
}

int fl_gl_window_can_do_overlay(GLWINDOW w) {
    return reinterpret_cast<Fl_Gl_Window*>(w)->can_do_overlay();
}




void * fl_gl_window_get_context(GLWINDOW w) {
    return reinterpret_cast<Fl_Gl_Window*>(w)->context();
}

void fl_gl_window_set_context(GLWINDOW w, void * con, int des) {
    reinterpret_cast<Fl_Gl_Window*>(w)->context(con, des);
}

char fl_gl_window_context_valid(GLWINDOW w) {
    return reinterpret_cast<Fl_Gl_Window*>(w)->context_valid();
}

void fl_gl_window_set_context_valid(GLWINDOW w, char v) {
    reinterpret_cast<Fl_Gl_Window*>(w)->context_valid(v);
}

char fl_gl_window_valid(GLWINDOW w) {
    return reinterpret_cast<Fl_Gl_Window*>(w)->valid();
}

void fl_gl_window_set_valid(GLWINDOW w, char v) {
    reinterpret_cast<Fl_Gl_Window*>(w)->valid(v);
}

void fl_gl_window_make_current(GLWINDOW w) {
    reinterpret_cast<Fl_Gl_Window*>(w)->make_current();
}

void fl_gl_window_make_overlay_current(GLWINDOW w) {
    reinterpret_cast<Fl_Gl_Window*>(w)->make_overlay_current();
}




void fl_gl_window_ortho(GLWINDOW w) {
    reinterpret_cast<Fl_Gl_Window*>(w)->ortho();
}

void fl_gl_window_redraw_overlay(GLWINDOW w) {
    reinterpret_cast<Fl_Gl_Window*>(w)->redraw_overlay();
}

void fl_gl_window_swap_buffers(GLWINDOW w) {
    reinterpret_cast<Fl_Gl_Window*>(w)->swap_buffers();
}


