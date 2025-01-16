

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Cairo_Window.H>
#include <FL/Fl_Double_Window.H>
#include "c_fl_cairo_window.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Cairo_Window :
#ifdef FLTK_HAVE_CAIRO
public Fl_Cairo_Window
#else
public Fl_Double_Window
#endif
{
public:
#ifdef FLTK_HAVE_CAIRO
    using Fl_Cairo_Window::Fl_Cairo_Window;
#else
    using Fl_Double_Window::Fl_Double_Window;
#endif

    friend void fl_cairo_window_draw(CAIROWINDOW w);

    int handle(int e);
    void draw();
};


void My_Cairo_Window::draw() {
    widget_draw_hook(this->user_data());
}

int My_Cairo_Window::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API begins here

CAIROWINDOW new_fl_cairo_window(int w, int h) {
    My_Cairo_Window *c = new My_Cairo_Window(w, h);
    return c;
}

void free_fl_cairo_window(CAIROWINDOW w) {
    delete static_cast<My_Cairo_Window*>(w);
}




void fl_cairo_window_set_draw_cb(CAIROWINDOW w, void * cb) {
    #ifdef FLTK_HAVE_CAIRO
    static_cast<Fl_Cairo_Window*>(w)->set_draw_cb(reinterpret_cast<cairo_draw_cb>(cb));
    #else
    (void)(w);
    (void)(cb);
    #endif
}




void fl_cairo_window_draw(CAIROWINDOW w) {
    #ifdef FLTK_HAVE_CAIRO
    static_cast<My_Cairo_Window*>(w)->Fl_Cairo_Window::draw();
    #else
    static_cast<My_Cairo_Window*>(w)->Fl_Double_Window::draw();
    #endif
}

int fl_cairo_window_handle(CAIROWINDOW w, int e) {
    #ifdef FLTK_HAVE_CAIRO
    return static_cast<My_Cairo_Window*>(w)->Fl_Cairo_Window::handle(e);
    #else
    return static_cast<My_Cairo_Window*>(w)->Fl_Double_Window::handle(e);
    #endif
}


