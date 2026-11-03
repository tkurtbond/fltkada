

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Fl.H>
#include <FL/Fl_Window.H>
#include <FL/platform.H>
#include <FL/gl.h>
#include "c_fl_gl.h"




//  Whether c is a window now shown.  Fl_Window::current() stays set after
//  hide(), and dangles after delete, so it is compared, never followed,
//  until this says it is safe (pofltk 111).
static bool is_shown(Fl_Window * c) {
    if (c == 0) {
        return false;
    }
    for (Fl_Window *w = Fl::first_window(); w != 0; w = Fl::next_window(w)) {
        if (w == c) {
            return true;
        }
    }
    return false;
}

//  Whether gl_start has run with no gl_finish yet.
static bool started = false;

//  gl_start uses the current window unchecked, and on Wayland crashes
//  whatever it is: Fl_Gl_Window_Driver::global() there has no window
//  (gl_start.cxx:64, pofltk 109).
int fl_gl_can_start() {
    fl_open_display();
#if defined(FLTK_USE_WAYLAND)
    return fl_wl_display() == 0;
#else
    return 1;
#endif
}

//  Returns -1 on Wayland, 0 if started already or no shown window is current.
int fl_gl_start() {
    if (!fl_gl_can_start()) {
        return -1;
    }
    if (started || !is_shown(Fl_Window::current())) {
        return 0;
    }
    gl_start();
    started = true;
    return 1;
}

int fl_gl_finish() {
    if (!started) {
        return 0;
    }
    gl_finish();
    started = false;
    return 1;
}

//  Whether FL/gl.h's text calls have a GL context: after gl_start, or with
//  a shown GL window current.  They crash with none (pofltk 111).
int fl_gl_ready() {
    if (started) {
        return 1;
    }
    Fl_Window *c = Fl_Window::current();
    return is_shown(c) && c->as_gl_window() != 0;
}




void fl_gl_color(unsigned int c) {
    gl_color(static_cast<Fl_Color>(c));
}

void fl_gl_rect(int x, int y, int w, int h) {
    gl_rect(x, y, w, h);
}

void fl_gl_rectf(int x, int y, int w, int h) {
    gl_rectf(x, y, w, h);
}




void fl_gl_font(int f, int s) {
    gl_font(f, s);
}

int fl_gl_height() {
    return gl_height();
}

int fl_gl_descent() {
    return gl_descent();
}

double fl_gl_width(const char * str, int n) {
    return gl_width(str, n);
}

double fl_gl_width2(unsigned char c) {
    return gl_width(c);
}




void fl_gl_draw(const char * str, int n) {
    gl_draw(str, n);
}

void fl_gl_draw2(const char * str, int n, int x, int y) {
    gl_draw(str, n, x, y);
}

void fl_gl_draw3(const char * str, int n, float x, float y) {
    gl_draw(str, n, x, y);
}

void fl_gl_draw4(const char * str, int x, int y, int w, int h, unsigned short a) {
    gl_draw(str, x, y, w, h, static_cast<Fl_Align>(a));
}

void fl_gl_measure(const char * str, int &x, int &y) {
    gl_measure(str, x, y);
}




void fl_gl_set_texture_pile_height(int max) {
    gl_texture_pile_height(max);
}

int fl_gl_get_texture_pile_height() {
    return gl_texture_pile_height();
}

void fl_gl_texture_reset() {
    gl_texture_reset();
}




void fl_gl_draw_image(void * data, int x, int y, int w, int h, int d, int l) {
    gl_draw_image(static_cast<uchar*>(data), x, y, w, h, d, l);
}


