

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Window.H>
#include <FL/Fl_RGB_Image.H>
#include "c_fl_window.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Window : public Fl_Window {
public:
    using Fl_Window::Fl_Window;

    friend void fl_window_draw(WINDOW n);
    friend int fl_window_handle(WINDOW n, int e);

    void draw();
    int handle(int e);
};

void My_Window::draw() {
    widget_draw_hook(this->user_data());
}

int My_Window::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

WINDOW new_fl_window(int x, int y, int w, int h, char* label) {
    My_Window *n = new My_Window(x, y, w, h, label);
    return n;
}

WINDOW new_fl_window2(int w, int h, char* label) {
    My_Window *n = new My_Window(w, h, label);
    return n;
}

void free_fl_window(WINDOW n) {
    delete static_cast<My_Window*>(n);
}




void fl_window_show(WINDOW n) {
    //  virtual, so disable dispatch
    static_cast<Fl_Window*>(n)->Fl_Window::show();
}

void fl_window_show2(WINDOW n, int c, void * v) {
    static_cast<Fl_Window*>(n)->show(c, static_cast<char**>(v));
}

void fl_window_hide(WINDOW n) {
    //  virtual, so disable dispatch
    static_cast<Fl_Window*>(n)->Fl_Window::hide();
}

int fl_window_shown(WINDOW n) {
    return static_cast<Fl_Window*>(n)->shown();
}

void fl_window_wait_for_expose(WINDOW n) {
    static_cast<Fl_Window*>(n)->wait_for_expose();
}

void fl_window_iconize(WINDOW n) {
    static_cast<Fl_Window*>(n)->iconize();
}

void fl_window_make_current(WINDOW n) {
    static_cast<Fl_Window*>(n)->make_current();
}

void fl_window_free_position(WINDOW n) {
    static_cast<Fl_Window*>(n)->free_position();
}




unsigned int fl_window_fullscreen_active(WINDOW n) {
    return static_cast<Fl_Window*>(n)->fullscreen_active();
}

void fl_window_fullscreen(WINDOW n) {
    static_cast<Fl_Window*>(n)->fullscreen();
}

void fl_window_fullscreen_off(WINDOW n) {
    static_cast<Fl_Window*>(n)->fullscreen_off();
}

void fl_window_fullscreen_off2(WINDOW n, int x, int y, int w, int h) {
    static_cast<Fl_Window*>(n)->fullscreen_off(x,y,w,h);
}

void fl_window_fullscreen_screens(WINDOW n, int t, int b, int l, int r) {
    static_cast<Fl_Window*>(n)->fullscreen_screens(t,b,l,r);
}




void fl_window_set_icon(WINDOW n, void * img) {
    static_cast<Fl_Window*>(n)->icon(static_cast<Fl_RGB_Image*>(img));
}

void fl_window_default_icon(void * img) {
    Fl_Window::default_icon(static_cast<Fl_RGB_Image*>(img));
}

const char * fl_window_get_iconlabel(WINDOW n) {
    return static_cast<Fl_Window*>(n)->iconlabel();
}

void fl_window_set_iconlabel(WINDOW n, const char * s) {
    static_cast<Fl_Window*>(n)->iconlabel(s);
}

void fl_window_set_cursor(WINDOW n, int c) {
    static_cast<Fl_Window*>(n)->cursor(static_cast<Fl_Cursor>(c));
}

void fl_window_set_cursor2(WINDOW n, void * img, int x, int y) {
    static_cast<Fl_Window*>(n)->cursor(static_cast<Fl_RGB_Image*>(img),x,y);
}

void fl_window_set_default_cursor(WINDOW n, int c) {
    static_cast<Fl_Window*>(n)->default_cursor(static_cast<Fl_Cursor>(c));
}




unsigned int fl_window_get_border(WINDOW n) {
    return static_cast<Fl_Window*>(n)->border();
}

void fl_window_set_border(WINDOW n, int b) {
    static_cast<Fl_Window*>(n)->border(b);
}

unsigned int fl_window_get_override(WINDOW n) {
    return static_cast<Fl_Window*>(n)->override();
}

void fl_window_set_override(WINDOW n) {
    static_cast<Fl_Window*>(n)->set_override();
}

unsigned int fl_window_modal(WINDOW n) {
    return static_cast<Fl_Window*>(n)->modal();
}

unsigned int fl_window_non_modal(WINDOW n) {
    return static_cast<Fl_Window*>(n)->non_modal();
}

void fl_window_clear_modal_states(WINDOW n) {
    static_cast<Fl_Window*>(n)->clear_modal_states();
}

void fl_window_set_modal(WINDOW n) {
    static_cast<Fl_Window*>(n)->set_modal();
}

void fl_window_set_non_modal(WINDOW n) {
    static_cast<Fl_Window*>(n)->set_non_modal();
}




const char * fl_window_get_label(WINDOW n) {
    return static_cast<Fl_Window*>(n)->label();
}

void fl_window_set_label(WINDOW n, char* text) {
    static_cast<Fl_Window*>(n)->copy_label(text);
}

void fl_window_hotspot(WINDOW n, int x, int y, int s) {
    static_cast<Fl_Window*>(n)->hotspot(x,y,s);
}

void fl_window_hotspot2(WINDOW n, void * i, int s) {
    static_cast<Fl_Window*>(n)->hotspot(static_cast<Fl_Widget*>(i),s);
}

void fl_window_size_range(WINDOW n, int lw, int lh, int hw, int hh, int dw, int dh, int a) {
    static_cast<Fl_Window*>(n)->size_range(lw, lh, hw, hh, dw, dh, a);
}

void fl_window_shape(WINDOW n, void * p) {
    static_cast<Fl_Window*>(n)->shape(static_cast<Fl_Image*>(p));
}




int fl_window_get_x_root(WINDOW n) {
    return static_cast<Fl_Window*>(n)->x_root();
}

int fl_window_get_y_root(WINDOW n) {
    return static_cast<Fl_Window*>(n)->y_root();
}

int fl_window_get_decorated_w(WINDOW n) {
    return static_cast<Fl_Window*>(n)->decorated_w();
}

int fl_window_get_decorated_h(WINDOW n) {
    return static_cast<Fl_Window*>(n)->decorated_h();
}




void fl_window_draw(WINDOW n) {
    static_cast<My_Window*>(n)->Fl_Window::draw();
}

int fl_window_handle(WINDOW n, int e) {
    return static_cast<My_Window*>(n)->Fl_Window::handle(e);
}


