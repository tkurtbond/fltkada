

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <cstring>
#include <new>
#include <set>
#include <string>
#include <FL/Fl.H>
#include <FL/Fl_Device.H>
#include <FL/fl_draw.H>
#include <FL/Fl_Graphics_Driver.H>
#include <FL/Fl_Rect.H>
#include <FL/Fl_Window.H>
#include <FL/Fl_Widget_Surface.H>
#include "c_fl_draw.h"
#include "c_fl_static.h"




//  Text before any font is set crashes FLTK 1.4.5: the drivers' draw() and
//  descent() use font_descriptor() without checking it, and it is 0 until
//  fl_font is called (pofltk 1).  Each text function sets FLTK's normal font
//  first if there is none.  From pofltk's ensure_font.

static void ensure_font() {
    if (fl_graphics_driver->font_descriptor() == 0 && fl_size() <= 0) {
        fl_font(FL_HELVETICA, FL_NORMAL_SIZE);
    }
}




//  Overlays and scrolling work on the current window's pixels, and crash
//  FLTK 1.4.5 with none (pofltk 124).  Fl_Window::current() stays set after
//  that window is hidden and dangles after it is deleted (pofltk 111), so it
//  is only compared with the windows shown, never followed.  From pofltk's
//  on_window and on_surface.

static bool on_window() {
    Fl_Window *c = Fl_Window::current();
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

static bool on_surface() {
    return Fl_Surface_Device::surface() != Fl_Display_Device::display_device();
}




void fl_draw_reset_spot() {
    fl_reset_spot();
}

void fl_draw_set_spot(int f, int s, int x, int y, int w, int h, void * ptr) {
    fl_set_spot(f, s, x, y, w, h, static_cast<Fl_Window*>(ptr));
}

void fl_draw_set_status(int x, int y, int w, int h) {
    fl_set_status(x, y, w, h);
}




int fl_draw_can_do_alpha_blending() {
    return fl_can_do_alpha_blending();
}

const char * fl_draw_shortcut_label(unsigned int shortcut) {
    return fl_shortcut_label(shortcut);
}




//  FLTK's Mac Roman conversions (fl_encoding_mac_roman.cxx:60-102) take
//  their buffer to be big enough when it isn't, so the first call with n > 0
//  writes through a null pointer, and local_to_mac_roman never moves on from
//  the first byte.  Neither ends the result with a NUL (pofltk 126).  Both
//  encodings have one byte a character, so this asks for one at a time,
//  after a call with n = 0 has made the buffer.  It returns 1 if FLTK's
//  malloc fails.
int fl_draw_recode(int kind, const char * from, char * to, int n) {
    typedef const char * (*Recode)(const char *, int);
    static const Recode recode[] = {fl_latin1_to_local, fl_local_to_latin1,
        fl_mac_roman_to_local, fl_local_to_mac_roman};
    if (kind < 0 || kind > 3) {
        return 1;
    }
    Recode f = recode[kind];
    f(from, 0);
    for (int i = 0; i < n; i++) {
        const char * r = f(from + i, 1);
        if (r == 0) {
            return 1;
        }
        to[i] = r[0];
    }
    return 0;
}




//  Cairo's clip_box compares the box with the clip, not the result with the
//  box, so its result is the reverse of its documentation, and for a box
//  wholly outside it returns before setting H (pofltk 2).  The outputs are
//  zeroed first, an empty result is 0 by 0, and "changed" is worked out
//  here.
int fl_draw_clip_box(int x, int y, int w, int h, int &bx, int &by, int &bw, int &bh) {
    bx = 0;
    by = 0;
    bw = 0;
    bh = 0;
    fl_clip_box(x, y, w, h, bx, by, bw, bh);
    if (bw <= 0 || bh <= 0) {
        bx = 0;
        by = 0;
        bw = 0;
        bh = 0;
    }
    return bx != x || by != y || bw != w || bh != h;
}

int fl_draw_not_clipped(int x, int y, int w, int h) {
    return fl_not_clipped(x, y, w, h);
}

void fl_draw_pop_clip() {
    fl_pop_clip();
}

void fl_draw_push_clip(int x, int y, int w, int h) {
    fl_push_clip(x, y, w, h);
}

void fl_draw_push_no_clip() {
    fl_push_no_clip();
}

void fl_draw_restore_clip() {
    fl_restore_clip();
}




int fl_draw_overlay_clear() {
    if (!on_window() || on_surface()) {
        return 0;
    }
    fl_overlay_clear();
    return 1;
}

int fl_draw_overlay_rect(int x, int y, int w, int h) {
    if (!on_window() || on_surface()) {
        return 0;
    }
    fl_overlay_rect(x, y, w, h);
    return 1;
}

//  These use the graphics driver's Cairo context, which is null with
//  nothing to draw on: fl_antialias always crashes then (pofltk 124), and
//  fl_override_scale and fl_restore_scale do when the scale isn't 1
//  (Fl_Cairo_Graphics_Driver.cxx:1493-1518).  Each returns 0 then.
int fl_draw_get_antialias(int &a) {
    if (!on_window() && !on_surface()) {
        return 0;
    }
    a = fl_antialias();
    return 1;
}

int fl_draw_set_antialias(int a) {
    if (!on_window() && !on_surface()) {
        return 0;
    }
    fl_antialias(a);
    return 1;
}

int fl_draw_override_scale(float &s) {
    if (!on_window() && !on_surface()) {
        return 0;
    }
    s = fl_override_scale();
    return 1;
}

int fl_draw_restore_scale(float s) {
    if (!on_window() && !on_surface()) {
        return 0;
    }
    fl_restore_scale(s);
    return 1;
}




unsigned int fl_draw_get_color() {
    return fl_color();
}

void fl_draw_set_color(unsigned int c) {
    fl_color(c);
}

void fl_draw_set_color2(uchar r, uchar g, uchar b) {
    fl_color(r, g, b);
}

void fl_draw_set_cursor(int m) {
    fl_cursor((Fl_Cursor)m);
}

void fl_draw_set_cursor2(int m, unsigned int f, unsigned int b) {
    fl_cursor((Fl_Cursor)m, f, b);
}

unsigned int fl_draw_get_font() {
    ensure_font();
    return (unsigned int)fl_font();
}

int fl_draw_size() {
    ensure_font();
    return fl_size();
}

void fl_draw_set_font(unsigned int f, int s) {
    fl_static_grow_fonts(static_cast<int>(f));
    fl_font((Fl_Font)f, (Fl_Fontsize)s);
}

int fl_draw_height() {
    ensure_font();
    return fl_height();
}

int fl_draw_descent() {
    ensure_font();
    return fl_descent();
}

int fl_draw_height2(unsigned int f, int s) {
    fl_static_grow_fonts(static_cast<int>(f));
    return fl_height(f, s);
}

void fl_draw_line_style(int style, int width, char * dashes) {
    fl_line_style(style, width, dashes);
}




void fl_draw_mult_matrix(double a, double b, double c, double d, double x, double y) {
    fl_mult_matrix(a, b, c, d, x, y);
}

void fl_draw_load_identity() {
    fl_load_identity();
}

void fl_draw_load_matrix(double a, double b, double c, double d, double x, double y) {
    fl_load_matrix(a, b, c, d, x, y);
}

void fl_draw_pop_matrix() {
    fl_pop_matrix();
}

void fl_draw_push_matrix() {
    fl_push_matrix();
}

void fl_draw_rotate(double d) {
    fl_rotate(d);
}

void fl_draw_scale(double x) {
    fl_scale(x);
}

void fl_draw_scale2(double x, double y) {
    fl_scale(x, y);
}

double fl_draw_transform_dx(double x, double y) {
    return fl_transform_dx(x, y);
}

double fl_draw_transform_dy(double x, double y) {
    return fl_transform_dy(x, y);
}

double fl_draw_transform_x(double x, double y) {
    return fl_transform_x(x, y);
}

double fl_draw_transform_y(double x, double y) {
    return fl_transform_y(x, y);
}

void fl_draw_transformed_vertex(double xf, double yf) {
    fl_transformed_vertex(xf, yf);
}

void fl_draw_translate(double x, double y) {
    fl_translate(x, y);
}

void fl_draw_vertex(double x, double y) {
    fl_vertex(x, y);
}




void fl_draw_draw_image(void * data, int x, int y, int w, int h, int d, int l) {
    fl_draw_image(static_cast<uchar*>(data), x, y, w, h, d, l);
}

void fl_draw_draw_image2(void * func, void * data, int x, int y, int w, int h, int d) {
    fl_draw_image(reinterpret_cast<Fl_Draw_Image_Cb>(func), data, x, y, w, h, d);
}

void fl_draw_draw_image_mono(void * data, int x, int y, int w, int h, int d, int l) {
    fl_draw_image_mono(static_cast<uchar*>(data), x, y, w, h, d, l);
}

void fl_draw_draw_image_mono2(void * func, void * data, int x, int y, int w, int h, int d) {
    fl_draw_image_mono(reinterpret_cast<Fl_Draw_Image_Cb>(func), data, x, y, w, h, d);
}

int fl_draw_draw_pixmap(void * data, int x, int y, unsigned int h) {
    return fl_draw_pixmap(static_cast<char * const *>(data), x, y, static_cast<Fl_Color>(h));
}

//  The size of what is drawn on: a shown window that is current, or a
//  surface such as an Fl_Image_Surface.  False if nothing is, or its size
//  can't be told.
static bool drawn_on(int &w, int &h) {
    Fl_Surface_Device *d = Fl_Surface_Device::surface();
    if (d != Fl_Display_Device::display_device()) {
        Fl_Widget_Surface *s = dynamic_cast<Fl_Widget_Surface*>(d);
        return s != 0 && s->printable_rect(&w, &h) == 0;
    }
    Fl_Window *c = Fl_Window::current();
    for (Fl_Window *o = Fl::first_window(); c != 0 && o != 0; o = Fl::next_window(o)) {
        if (o == c) {
            w = c->w();
            h = c->h();
            return true;
        }
    }
    return false;
}

//  fl_read_image doesn't clip: X11 writes past its image, and Wayland reads
//  past its buffer, for a rectangle partly or wholly outside what is drawn
//  on, and what is read is stretched to the size asked for (pofltk 127).
//  So only the part inside is read, and put in its place in data, which is
//  w * h pixels, all zero elsewhere.  0 if nothing is drawn on, or FLTK
//  couldn't read it.
void * fl_draw_read_image(void * data, int x, int y, int w, int h, int alpha) {
    int sw, sh;
    if (!drawn_on(sw, sh)) {
        return 0;
    }
    uchar *out = static_cast<uchar*>(data);
    int depth = alpha ? 4 : 3;
    if (w <= 0 || h <= 0) {
        return out;
    }
    std::memset(out, 0, static_cast<size_t>(w) * h * depth);
    int left = x < 0 ? 0 : x;
    int top = y < 0 ? 0 : y;
    int right = x < sw - w ? x + w : sw;
    int bottom = y < sh - h ? y + h : sh;
    if (right <= left || bottom <= top) {
        return out;
    }
    int cw = right - left, ch = bottom - top;
    uchar *part = fl_read_image(0, left, top, cw, ch, alpha);
    if (part == 0) {
        return 0;
    }
    for (int r = 0; r < ch; r++) {
        std::memcpy(out + ((static_cast<size_t>(top - y + r) * w) + (left - x)) * depth,
            part + static_cast<size_t>(r) * cw * depth,
            static_cast<size_t>(cw) * depth);
    }
    delete[] part;
    return out;
}

//  What window win shows of x, y, w, h, clipped to it: X11's
//  fl_capture_window writes past its image, and Wayland's reads past the
//  draw buffer, for a rectangle partly off the window or of no size
//  (pofltk 127).  0 if win isn't shown or nothing of it is inside.
void * fl_draw_capture_window(void * win, int x, int y, int w, int h) {
    Fl_Window *window = static_cast<Fl_Window*>(win);
    if (!window || !window->shown() || w <= 0 || h <= 0) {
        return 0;
    }
    int right = x < window->w() - w ? x + w : window->w();
    int bottom = y < window->h() - h ? y + h : window->h();
    int left = x < 0 ? 0 : x;
    int top = y < 0 ? 0 : y;
    if (right <= left || bottom <= top) {
        return 0;
    }
    return fl_capture_window(window, left, top, right - left, bottom - top);
}




typedef void (sym_hook)(Fl_Color);
typedef sym_hook* sym_hook_p;

//  fl_symbols.cxx hashes a name's bytes as chars, and a byte from 0x80 on makes the
//  index into its table negative where char is signed (pofltk 123).
static bool symbol_name_ascii(const char *s) {
    for (; *s; s++) {
        if (static_cast<unsigned char>(*s) >= 0x80) {
            return false;
        }
    }
    return true;
}

//  fl_add_symbol keeps the name's pointer for good (fl_symbols.cxx), so the names
//  are kept here.
static std::set<std::string> symbol_names;

//  0 if the name is refused or the table is full.  An empty name would replace the
//  default symbol.  A name that starts the way fl_draw_symbol's modifiers do, or
//  that holds an @, could never be found again.  Derived from pofltk's
//  ofl_draw_add_symbol.
int fl_draw_add_symbol(const char *name, void *func, int scalable) {
    char a = name[0];
    if (a == '\0' || !symbol_name_ascii(name) || std::strchr(name, '@') != 0) {
        return 0;
    }
    char b = name[1];
    if (a == '#' || a == '$' || a == '%' || (a >= '0' && a <= '9')) {
        return 0;
    }
    if ((a == '-' || a == '+') && b >= '1' && b <= '9') {
        return 0;
    }
    try {
        return fl_add_symbol(symbol_names.insert(name).first->c_str(),
            reinterpret_cast<sym_hook_p>(func), scalable);
    } catch (const std::bad_alloc &) {
        return 0;
    }
}

void fl_draw_draw_text(const char *str, int n, int x, int y) {
    ensure_font();
    fl_draw(str, n, x, y);
}

void fl_draw_draw_text2(const char *str, int x, int y, int w, int h,
                        unsigned align, void * img, int draw_symbols) {
    ensure_font();
    fl_draw(str, x, y, w, h, (Fl_Align)align, (Fl_Image*)img, draw_symbols);
}

typedef void (t_hook)(const char *, int ,int ,int);
typedef t_hook* t_hook_p;

void fl_draw_draw_text3(const char *str, int x, int y, int w, int h,
                                   unsigned align, void * func, void * img, int draw_symbols) {
    ensure_font();
    fl_draw(str, x, y, w, h, (Fl_Align)align,
        reinterpret_cast<t_hook_p>(func), (Fl_Image*)img, draw_symbols);
}

void fl_draw_draw_text4(int angle, const char *str, int n, int x, int y) {
    ensure_font();
    fl_draw(angle, str, n, x, y);
}

void fl_draw_rtl_draw(const char *str, int n, int x, int y) {
    ensure_font();
    fl_rtl_draw(str, n, x, y);
}

void fl_draw_draw_box(int bk, int x, int y, int w, int h, unsigned int c) {
    fl_draw_box((Fl_Boxtype)bk, x, y, w, h, (Fl_Color)c);
}

int fl_draw_draw_symbol(const char *label, int x, int y, int w, int h, unsigned int c) {
    if (!symbol_name_ascii(label)) {
        return 0;
    }
    return fl_draw_symbol(label, x, y, w, h, (Fl_Color)c);
}

void fl_draw_measure(const char * str, int &w, int &h, int draw_symbols) {
    ensure_font();
    fl_measure(str, w, h, draw_symbols);
}

typedef void (a_hook)(void *, int, int, int, int);
typedef a_hook* a_hook_p;

//  fl_scroll moves pixels of the current window.  A surface has none of
//  them, so there the whole area is drawn again.  Returns 0 if there is
//  neither a surface nor a shown current window.
int fl_draw_scroll(int x, int y, int w, int h, int dx, int dy,
                    void * func, void * data) {
    if (dx == 0 && dy == 0) {
        return on_surface() || on_window() ? 1 : 0;
    }
    if (on_surface()) {
        reinterpret_cast<a_hook_p>(func)(data, x, y, w, h);
        return 1;
    }
    if (!on_window()) {
        return 0;
    }
    fl_scroll(x, y, w, h, dx, dy, reinterpret_cast<a_hook_p>(func), data);
    return 1;
}

void fl_draw_text_extents(const char * t, int n, int &dx, int &dy, int &w, int &h) {
    ensure_font();
    fl_text_extents(t, n, dx, dy, w, h);
}

const char * fl_draw_expand_text(const char * str, char * buf, int maxbuf,
    double maxw, int &n, double &width, int wrap, int symbol)
{
    ensure_font();
    return fl_expand_text(str, buf, maxbuf, maxw, n, width, wrap, symbol);
}

double fl_draw_width(const char *txt, int n) {
    ensure_font();
    return fl_width(txt, n);
}

double fl_draw_width2(unsigned long c) {
    ensure_font();
    return fl_width(c);
}




void fl_draw_begin_complex_polygon() {
    fl_begin_complex_polygon();
}

void fl_draw_begin_line() {
    fl_begin_line();
}

void fl_draw_begin_loop() {
    fl_begin_loop();
}

void fl_draw_begin_points() {
    fl_begin_points();
}

void fl_draw_begin_polygon() {
    fl_begin_polygon();
}




void fl_draw_arc(double x, double y, double r, double start, double end) {
    fl_arc(x, y, r, start, end);
}

void fl_draw_arc2(int x, int y, int w, int h, double a1, double a2) {
    fl_arc(x, y, w, h, a1, a2);
}

//  function does not yet exist
//  void fl_draw_chord(int x, int y, int w, int h, double a1, double a2) {
//      function does not yet exist
//      fl_chord(x, y, w, h, a1, a2);
//  }

void fl_draw_circle(double x, double y, double r) {
    fl_circle(x, y, r);
}

void fl_draw_curve(double x0, double y0, double x1, double y1,
                   double x2, double y2, double x3, double y3) {
    fl_curve(x0, y0, x1, y1, x2, y2, x3, y3);
}

void fl_draw_frame(const char *s, int x, int y, int w, int h) {
    fl_frame(s, x, y, w, h);
}

void fl_draw_frame2(const char *s, int x, int y, int w, int h) {
    fl_frame2(s, x, y, w, h);
}

void fl_draw_rounded_rect(int x, int y, int w, int h, int r) {
    fl_rounded_rect(x, y, w, h, r);
}

void fl_draw_rounded_rectf(int x, int y, int w, int h, int r) {
    fl_rounded_rectf(x, y, w, h, r);
}

void fl_draw_focus_rect(int x, int y, int w, int h) {
    fl_focus_rect(x, y, w, h);
}

void fl_draw_draw_box_focus(int bk, int x, int y, int w, int h, unsigned int fg, unsigned int bg) {
    fl_draw_box_focus(static_cast<Fl_Boxtype>(bk), x, y, w, h, fg, bg);
}

void fl_draw_draw_check(int x, int y, int w, int h, unsigned int c) {
    fl_draw_check(Fl_Rect(x, y, w, h), c);
}

void fl_draw_draw_radio(int x, int y, int d, unsigned int c) {
    fl_draw_radio(x, y, d, c);
}

void fl_draw_draw_arrow(int x, int y, int w, int h, int t, int o, unsigned int c) {
    fl_draw_arrow(Fl_Rect(x, y, w, h), static_cast<Fl_Arrow_Type>(t),
        static_cast<Fl_Orientation>(o), c);
}

void fl_draw_gap() {
    fl_gap();
}

void fl_draw_line(int x0, int y0, int x1, int y1) {
    fl_line(x0, y0, x1, y1);
}

void fl_draw_line2(int x0, int y0, int x1, int y1, int x2, int y2) {
    fl_line(x0, y0, x1, y1, x2, y2);
}

void fl_draw_loop(int x0, int y0, int x1, int y1, int x2, int y2) {
    fl_loop(x0, y0, x1, y1, x2, y2);
}

void fl_draw_loop2(int x0, int y0, int x1, int y1, int x2, int y2, int x3, int y3) {
    fl_loop(x0, y0, x1, y1, x2, y2, x3, y3);
}

void fl_draw_pie(int x, int y, int w, int h, double a1, double a2) {
    fl_pie(x, y, w, h, a1, a2);
}

void fl_draw_point(int x, int y) {
    fl_point(x, y);
}

void fl_draw_polygon(int x0, int y0, int x1, int y1, int x2, int y2) {
    fl_polygon(x0, y0, x1, y1, x2, y2);
}

void fl_draw_polygon2(int x0, int y0, int x1, int y1, int x2, int y2, int x3, int y3) {
    fl_polygon(x0, y0, x1, y1, x2, y2, x3, y3);
}

void fl_draw_rect(int x, int y, int w, int h) {
    fl_rect(x, y, w, h);
}

void fl_draw_rect2(int x, int y, int w, int h, unsigned int c) {
    fl_rect(x, y, w, h, c);
}

void fl_draw_rect_fill(int x, int y, int w, int h) {
    fl_rectf(x, y, w, h);
}

void fl_draw_rect_fill2(int x, int y, int w, int h, unsigned int c) {
    fl_rectf(x, y, w, h, (Fl_Color)c);
}

void fl_draw_rect_fill3(int x, int y, int w, int h, uchar r, uchar g, uchar b) {
    fl_rectf(x, y, w, h, r, g, b);
}

void fl_draw_xy_line(int x0, int y0, int x1) {
    fl_xyline(x0, y0, x1);
}

void fl_draw_xy_line2(int x0, int y0, int x1, int y2) {
    fl_xyline(x0, y0, x1, y2);
}

void fl_draw_xy_line3(int x0, int y0, int x1, int y2, int x3) {
    fl_xyline(x0, y0, x1, y2, x3);
}

void fl_draw_yx_line(int x0, int y0, int y1) {
    fl_yxline(x0, y0, y1);
}

void fl_draw_yx_line2(int x0, int y0, int y1, int x2) {
    fl_yxline(x0, y0, y1, x2);
}

void fl_draw_yx_line3(int x0, int y0, int y1, int x2, int y3) {
    fl_yxline(x0, y0, y1, x2, y3);
}




void fl_draw_end_complex_polygon() {
    fl_end_complex_polygon();
}

void fl_draw_end_line() {
    fl_end_line();
}

void fl_draw_end_loop() {
    fl_end_loop();
}

void fl_draw_end_points() {
    fl_end_points();
}

void fl_draw_end_polygon() {
    fl_end_polygon();
}


