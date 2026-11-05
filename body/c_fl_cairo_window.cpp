

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Cairo_Window.H>
#include <FL/Fl_Double_Window.H>
#include "c_fl_cairo_window.h"
#include "c_fl_window.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Cairo_Window :
#ifdef FLTK_HAVE_CAIRO
public Ada_Resizing<Fl_Cairo_Window>
#else
public Ada_Resizing<Fl_Double_Window>
#endif
{
public:
#ifdef FLTK_HAVE_CAIRO
    using Ada_Resizing<Fl_Cairo_Window>::Ada_Resizing;
#else
    using Ada_Resizing<Fl_Double_Window>::Ada_Resizing;
#endif

    ~My_Cairo_Window() { window_shape_gone(this); }

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
    if (fl_inside_callback) {
        fl_delete_widget(w);
    } else {
        delete static_cast<My_Cairo_Window*>(w);
    }
}




//  FLTK has Fl_Cairo_Window only when built with Cairo (Fl_Cairo_Window.H:26;
//  pofltk 114).  Without, this is a Double_Window, and the Ada side refuses a
//  draw callback that would never be called.

int fl_cairo_window_supported() {
    #ifdef FLTK_HAVE_CAIRO
    return 1;
    #else
    return 0;
    #endif
}

void fl_cairo_window_set_draw_cb(CAIROWINDOW w, void * cb) {
    #ifdef FLTK_HAVE_CAIRO
    static_cast<Fl_Cairo_Window*>(w)->set_draw_cb(reinterpret_cast<Fl_Cairo_Window::cairo_draw_cb>(cb));
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


