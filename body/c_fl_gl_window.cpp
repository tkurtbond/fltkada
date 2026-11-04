

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Gl_Window.H>
#include <FL/platform.H>
#include "c_fl_gl_window.h"
#include "c_fl_window.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Gl_Window : public Fl_Gl_Window {
public:
    using Fl_Gl_Window::Fl_Gl_Window;

    ~My_Gl_Window() { window_shape_gone(this); }

    friend void fl_gl_window_draw(GLWINDOW n);
    friend int fl_gl_window_handle(GLWINDOW n, int e);

    void draw();
    int handle(int e);
};

//  How many GL windows are drawing now.  mode() inside a draw replaces the
//  context the draw is using (pofltk 111).  widget_draw_hook catches the Ada
//  side's exceptions, so the count always comes back down.
int gl_window_drawing = 0;

void My_Gl_Window::draw() {
    gl_window_drawing++;
    widget_draw_hook(this->user_data());
    gl_window_drawing--;
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
    if (fl_inside_callback) {
        fl_delete_widget(w);
    } else {
        delete static_cast<My_Gl_Window*>(w);
    }
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

//  Returns 0, and changes nothing, inside a GL window's draw.
int fl_gl_window_set_mode(GLWINDOW w, unsigned int a) {
    if (gl_window_drawing != 0) {
        return 0;
    }
    static_cast<Fl_Gl_Window*>(w)->mode(a);
    return 1;
}

//  Both ask Fl_Gl_Window_Driver::global() (Fl_Gl_Window.cxx:66), which uses
//  the display's connection without opening it: a segmentation fault with no
//  display open (pofltk 110).  Opening it first also makes global(), which is
//  made once, a Wayland driver under Wayland: made before any window, it was
//  X11's (Fl_Wayland_Gl_Window_Driver.cxx:86).
int fl_gl_window_static_can_do(unsigned int m) {
    fl_open_display();
    return Fl_Gl_Window::can_do(m);
}

int fl_gl_window_can_do(GLWINDOW w) {
    fl_open_display();
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

//  Returns 0 if the window isn't shown: on X11 there is then no window for
//  the context, and make_current crashes (Fl_Gl_Window.cxx:117, pofltk 111).
int fl_gl_window_make_current(GLWINDOW w) {
    if (!static_cast<Fl_Gl_Window*>(w)->shown()) {
        return 0;
    }
    static_cast<Fl_Gl_Window*>(w)->make_current();
    return 1;
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


