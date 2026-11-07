

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


//  A double window drawn with cairo, after pofltk's src/cairo/FlCairo.cpp.
//  It isn't Fl_Cairo_Window, which only an FLTK built for it has.  X11's
//  way of making a context needs nothing of FLTK but the window, and
//  Wayland's needs only fl_wl_gc(), so this window draws on every FLTK
//  with either, and with a context of its own (pofltk 114).


#include <FL/Fl.H>
#include <FL/Fl_Double_Window.H>
#include <FL/Fl_Device.H>
#include <FL/platform.H>
#include <cairo.h>
#if defined(FLTK_USE_X11)
#include <cairo-xlib.h>
#endif
#include "c_fl_cairo_drawn_window.h"
#include "c_fl_window.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);
extern "C" void cairo_drawn_window_draw_hook(void * ud, void * cr);




//  Making a context

//  A context on the surface FLTK is drawing this window on: the offscreen
//  buffer, whatever the back end.  A cairo error stays in its context, so
//  one made for each draw keeps a program's errors, and any save it
//  leaves, out of the next draw and out of FLTK's own drawing.  Null where
//  FLTK has neither X11 nor Wayland.
static cairo_t * make_context(Fl_Window * w) {
#if defined(FLTK_USE_WAYLAND)
    if (fl_wl_display()) {
        cairo_t *fltk = fl_wl_gc();
        cairo_t *c = cairo_create(cairo_get_target(fltk));
        cairo_matrix_t m;
        //  The display's scale
        cairo_get_matrix(fltk, &m);
        cairo_set_matrix(c, &m);
        return c;
    }
#endif
#if defined(FLTK_USE_X11)
    float scale = Fl::screen_scale(w->screen_num());
    cairo_surface_t *s = cairo_xlib_surface_create
        (fl_display, fl_window, fl_visual->visual,
         static_cast<int>(w->w() * scale), static_cast<int>(w->h() * scale));
    cairo_t *c = cairo_create(s);
    //  The context holds the surface
    cairo_surface_destroy(s);
    cairo_scale(c, scale, scale);
    return c;
#else
    (void)w;
    return nullptr;
#endif
}




//  Attaching all relevant hooks and friends

//  Cairo's part comes after the widgets', where Fl_Cairo_Window's is, so
//  that the default Draw has it and an overriding Draw that calls its
//  parent's has it too.
class Cairo_Drawn : public Fl_Double_Window {
public:
    using Fl_Double_Window::Fl_Double_Window;

    void draw() override {
        Fl_Double_Window::draw();
        //  On another surface fl_window and fl_wl_gc() aren't that
        //  surface's (pofltk 114)
        if (this->user_data() == nullptr ||
            Fl_Surface_Device::surface() != Fl_Display_Device::display_device())
        {
            return;
        }
        cairo_t *c = make_context(this);
        if (c == nullptr) {
            return;
        }
        //  The hook keeps any Ada exception, and returns
        cairo_drawn_window_draw_hook(this->user_data(), c);
        cairo_surface_flush(cairo_get_target(c));
        cairo_destroy(c);
    }
};

class My_Cairo_Drawn_Window : public Ada_Resizing<Cairo_Drawn> {
public:
    using Ada_Resizing<Cairo_Drawn>::Ada_Resizing;

    ~My_Cairo_Drawn_Window() { window_shape_gone(this); }

    friend void fl_cairo_drawn_window_draw(CAIRODRAWNWINDOW n);
    friend int fl_cairo_drawn_window_handle(CAIRODRAWNWINDOW n, int e);

    void draw();
    int handle(int e);
};

void My_Cairo_Drawn_Window::draw() {
    widget_draw_hook(this->user_data());
}

int My_Cairo_Drawn_Window::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

int fl_cairo_drawn_window_supported() {
#if defined(FLTK_USE_X11) || defined(FLTK_USE_WAYLAND)
    return 1;
#else
    return 0;
#endif
}




CAIRODRAWNWINDOW new_fl_cairo_drawn_window(int x, int y, int w, int h, char* label) {
    My_Cairo_Drawn_Window *d = new My_Cairo_Drawn_Window(x, y, w, h, label);
    return d;
}

CAIRODRAWNWINDOW new_fl_cairo_drawn_window2(int w, int h, char* label) {
    My_Cairo_Drawn_Window *d = new My_Cairo_Drawn_Window(w, h, label);
    return d;
}

void free_fl_cairo_drawn_window(CAIRODRAWNWINDOW d) {
    if (fl_inside_callback) {
        fl_delete_widget(d);
    } else {
        delete static_cast<My_Cairo_Drawn_Window*>(d);
    }
}




void fl_cairo_drawn_window_draw(CAIRODRAWNWINDOW n) {
    static_cast<My_Cairo_Drawn_Window*>(n)->Cairo_Drawn::draw();
}

int fl_cairo_drawn_window_handle(CAIRODRAWNWINDOW n, int e) {
    return static_cast<My_Cairo_Drawn_Window*>(n)->Cairo_Drawn::handle(e);
}

