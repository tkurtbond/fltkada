

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Fl.H>
#include <FL/Fl_Window.H>
#include <FL/platform.H>
#include <FL/fl_draw.H>
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




//  gl_draw makes a texture as wide as its text, and text with no width, as
//  a line feed or a zero-width space, crashes in making it: an
//  Fl_Image_Surface 0 wide (gl_draw.cxx, compute_texture and
//  alpha_mask_for_string; pofltk 134).  So text is drawn only if it has a
//  width.
static void draw_some(const char * str, int n) {
    if (gl_width(str, n) > 0) {
        gl_draw(str, n);
    }
}

//  gl_draw_invert in gl_draw.cxx, which the boxed gl_draw gives fl_draw
//  for each line.
static void draw_line(const char * str, int n, int x, int y) {
    glRasterPos2i(x, -y);
    draw_some(str, n);
}

void fl_gl_draw(const char * str, int n) {
    draw_some(str, n);
}

void fl_gl_draw2(const char * str, int n, int x, int y) {
    glRasterPos2i(x, y);
    draw_some(str, n);
}

void fl_gl_draw3(const char * str, int n, float x, float y) {
    glRasterPos2f(x, y);
    draw_some(str, n);
}

void fl_gl_draw4(const char * str, int x, int y, int w, int h, unsigned short a) {
    //  As gl_draw (str, x, y, w, h, align) does.
    fl_draw(str, x, -y - h, w, h, static_cast<Fl_Align>(a), draw_line, 0, 0);
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




//  FLTK's gl_draw_image draws depths 1 and 2 as GL_RGB, and leaves
//  GL_UNPACK_ALIGNMENT at its default of 4, so rows not a multiple of 4
//  bytes are taken as padded.  Either way it reads past the data
//  (FLTK-issues.md, F40).  This draws as it does, with a format for each
//  depth and the rows unpadded, restoring what it changes.  The Ada side
//  checks d is 1 to 4, w and h are positive, and the data is long enough.
void fl_gl_draw_image(void * data, int x, int y, int w, int h, int d, int l) {
    static const GLenum formats[4] = {GL_LUMINANCE, GL_LUMINANCE_ALPHA, GL_RGB, GL_RGBA};
    GLint row_length, alignment, skip_rows, skip_pixels;
    glGetIntegerv(GL_UNPACK_ROW_LENGTH, &row_length);
    glGetIntegerv(GL_UNPACK_ALIGNMENT, &alignment);
    glGetIntegerv(GL_UNPACK_SKIP_ROWS, &skip_rows);
    glGetIntegerv(GL_UNPACK_SKIP_PIXELS, &skip_pixels);
    glPixelStorei(GL_UNPACK_ROW_LENGTH, l == 0 ? w : l / d);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
    glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
    glRasterPos2i(x, y);
    glDrawPixels(w, h, formats[d - 1], GL_UNSIGNED_BYTE, data);
    glPixelStorei(GL_UNPACK_ROW_LENGTH, row_length);
    glPixelStorei(GL_UNPACK_ALIGNMENT, alignment);
    glPixelStorei(GL_UNPACK_SKIP_ROWS, skip_rows);
    glPixelStorei(GL_UNPACK_SKIP_PIXELS, skip_pixels);
}


