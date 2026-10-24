

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/gl.h>
#include "c_fl_gl.h"




void fl_gl_start() {
    gl_start();
}

void fl_gl_finish() {
    gl_finish();
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


