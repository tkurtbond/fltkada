

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Gl_Window.H>
#include "c_fl_gl_window.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Gl_Window : public Fl_Gl_Window {
public:
    using Fl_Gl_Window::Fl_Gl_Window;

    friend void fl_gl_window_draw(GLWINDOW n);
    friend int fl_gl_window_handle(GLWINDOW n, int e);

    void draw();
    int handle(int e);
};

void My_Gl_Window::draw() {
    widget_draw_hook(this->user_data());
}

int My_Gl_Window::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

GLWINDOW new_fl_gl_window(int x, int y, int w, int h, char* label) {
    My_Gl_Window *gw = new My_Gl_Window(x, y, w, h, label);
    return gw;
}

GLWINDOW new_fl_gl_window2(int w, int h, char* label) {
    My_Gl_Window *gw = new My_Gl_Window(w, h, label);
    return gw;
}

void free_fl_gl_window(GLWINDOW w) {
    delete static_cast<My_Gl_Window*>(w);
}




void fl_gl_window_show(GLWINDOW w) {
    static_cast<Fl_Gl_Window*>(w)->show();
}

void fl_gl_window_show2(GLWINDOW w, int c, void * v) {
    static_cast<Fl_Gl_Window*>(w)->show(c, static_cast<char**>(v));
}

void fl_gl_window_hide(GLWINDOW w) {
    static_cast<Fl_Gl_Window*>(w)->hide();
}

void fl_gl_window_hide_overlay(GLWINDOW w) {
    static_cast<Fl_Gl_Window*>(w)->hide_overlay();
}

void fl_gl_window_flush(GLWINDOW w) {
    static_cast<Fl_Gl_Window*>(w)->flush();
}




int fl_gl_window_pixel_h(GLWINDOW w) {
    return static_cast<Fl_Gl_Window*>(w)->pixel_h();
}

int fl_gl_window_pixel_w(GLWINDOW w) {
    return static_cast<Fl_Gl_Window*>(w)->pixel_w();
}

float fl_gl_window_pixels_per_unit(GLWINDOW w) {
    return static_cast<Fl_Gl_Window*>(w)->pixels_per_unit();
}

void fl_gl_window_resize(GLWINDOW gw, int x, int y, int w, int h) {
    static_cast<Fl_Gl_Window*>(gw)->resize(x, y, w, h);
}




unsigned int fl_gl_window_get_mode(GLWINDOW w) {
    return static_cast<Fl_Gl_Window*>(w)->mode();
}

void fl_gl_window_set_mode(GLWINDOW w, unsigned int a) {
    static_cast<Fl_Gl_Window*>(w)->mode(a);
}

int fl_gl_window_static_can_do(unsigned int m) {
    return Fl_Gl_Window::can_do(m);
}

int fl_gl_window_can_do(GLWINDOW w) {
    return static_cast<Fl_Gl_Window*>(w)->can_do();
}

int fl_gl_window_can_do_overlay(GLWINDOW w) {
    return static_cast<Fl_Gl_Window*>(w)->can_do_overlay();
}




void * fl_gl_window_get_context(GLWINDOW w) {
    return static_cast<Fl_Gl_Window*>(w)->context();
}

void fl_gl_window_set_context(GLWINDOW w, void * con, int des) {
    static_cast<Fl_Gl_Window*>(w)->context(con, des);
}

char fl_gl_window_context_valid(GLWINDOW w) {
    return static_cast<Fl_Gl_Window*>(w)->context_valid();
}

void fl_gl_window_set_context_valid(GLWINDOW w, char v) {
    static_cast<Fl_Gl_Window*>(w)->context_valid(v);
}

char fl_gl_window_valid(GLWINDOW w) {
    return static_cast<Fl_Gl_Window*>(w)->valid();
}

void fl_gl_window_set_valid(GLWINDOW w, char v) {
    static_cast<Fl_Gl_Window*>(w)->valid(v);
}

void fl_gl_window_invalidate(GLWINDOW w) {
    static_cast<Fl_Gl_Window*>(w)->invalidate();
}

void fl_gl_window_make_current(GLWINDOW w) {
    static_cast<Fl_Gl_Window*>(w)->make_current();
}

void fl_gl_window_make_overlay_current(GLWINDOW w) {
    static_cast<Fl_Gl_Window*>(w)->make_overlay_current();
}




void fl_gl_window_ortho(GLWINDOW w) {
    static_cast<Fl_Gl_Window*>(w)->ortho();
}

void fl_gl_window_redraw_overlay(GLWINDOW w) {
    static_cast<Fl_Gl_Window*>(w)->redraw_overlay();
}

void fl_gl_window_swap_buffers(GLWINDOW w) {
    static_cast<Fl_Gl_Window*>(w)->swap_buffers();
}




void fl_gl_window_draw(GLWINDOW n) {
    static_cast<My_Gl_Window*>(n)->Fl_Gl_Window::draw();
}

int fl_gl_window_handle(GLWINDOW n, int e) {
    return static_cast<My_Gl_Window*>(n)->Fl_Gl_Window::handle(e);
}


