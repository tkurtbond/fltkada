

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/fl_draw.H>
#include <FL/Fl_Window.H>
#include "c_fl_draw.h"




void fl_draw_reset_spot() {
    fl_reset_spot();
}

void fl_draw_set_spot(int f, int s, int x, int y, int w, int h, void * ptr) {
    fl_set_spot(f, s, x, y, w, h, reinterpret_cast<Fl_Window*>(ptr));
}

void fl_draw_set_status(int x, int y, int w, int h) {
    fl_set_status(x, y, w, h);
}




int fl_draw_can_do_alpha_blending() {
    return fl_can_do_alpha_blending();
}

const char * fl_draw_shortcut_label(unsigned long shortcut) {
    return fl_shortcut_label(shortcut);
}




const char * fl_draw_latin1_to_local(const char *t, int n) {
    return fl_latin1_to_local(t, n);
}

const char * fl_draw_local_to_latin1(const char *t, int n) {
    return fl_local_to_latin1(t, n);
}

const char * fl_draw_mac_roman_to_local(const char *t, int n) {
    return fl_mac_roman_to_local(t, n);
}

const char * fl_draw_local_to_mac_roman(const char *t, int n) {
    return fl_local_to_mac_roman(t, n);
}




int fl_draw_clip_box(int x, int y, int w, int h, int &bx, int &by, int &bw, int &bh) {
    return fl_clip_box(x, y, w, h, bx, by, bw, bh);
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




void fl_draw_overlay_clear() {
    fl_overlay_clear();
}

void fl_draw_overlay_rect(int x, int y, int w, int h) {
    fl_overlay_rect(x, y, w, h);
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
    return (unsigned int)fl_font();
}

int fl_draw_size() {
    return fl_size();
}

void fl_draw_set_font(unsigned int f, int s) {
    fl_font((Fl_Font)f, (Fl_Fontsize)s);
}

int fl_draw_height() {
    return fl_height();
}

int fl_draw_descent() {
    return fl_descent();
}

int fl_draw_height2(unsigned int f, int s) {
    return fl_height(f, s);
}

void fl_draw_line_style(int style, int width, char * dashes) {
    fl_line_style(style, width, dashes);
}




void fl_draw_mult_matrix(double a, double b, double c, double d, double x, double y) {
    fl_mult_matrix(a, b, c, d, x, y);
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
    fl_draw_image(reinterpret_cast<uchar*>(data), x, y, w, h, d, l);
}

void fl_draw_draw_image2(void * func, void * data, int x, int y, int w, int h, int d) {
    fl_draw_image(reinterpret_cast<Fl_Draw_Image_Cb>(func), data, x, y, w, h, d);
}

void fl_draw_draw_image_mono(void * data, int x, int y, int w, int h, int d, int l) {
    fl_draw_image_mono(reinterpret_cast<uchar*>(data), x, y, w, h, d, l);
}

void fl_draw_draw_image_mono2(void * func, void * data, int x, int y, int w, int h, int d) {
    fl_draw_image_mono(reinterpret_cast<Fl_Draw_Image_Cb>(func), data, x, y, w, h, d);
}

void * fl_draw_read_image(void * data, int x, int y, int w, int h, int alpha) {
    return fl_read_image(reinterpret_cast<uchar*>(data), x, y, w, h, alpha);
}




typedef void (sym_hook)(Fl_Color);
typedef sym_hook* sym_hook_p;

int fl_draw_add_symbol(const char *name, void *func, int scalable) {
    return fl_add_symbol(name, reinterpret_cast<sym_hook_p>(func), scalable);
}

void fl_draw_draw_text(const char *str, int n, int x, int y) {
    fl_draw(str, n, x, y);
}

void fl_draw_draw_text2(const char *str, int x, int y, int w, int h,
                        unsigned align, void * img, int draw_symbols) {
    fl_draw(str, x, y, w, h, (Fl_Align)align, (Fl_Image*)img, draw_symbols);
}

typedef void (t_hook)(const char *, int ,int ,int);
typedef t_hook* t_hook_p;

void fl_draw_draw_text3(const char *str, int x, int y, int w, int h,
                                   unsigned align, void * func, void * img, int draw_symbols) {
    fl_draw(str, x, y, w, h, (Fl_Align)align,
        reinterpret_cast<t_hook_p>(func), (Fl_Image*)img, draw_symbols);
}

void fl_draw_draw_text4(int angle, const char *str, int n, int x, int y) {
    fl_draw(angle, str, n, x, y);
}

void fl_draw_rtl_draw(const char *str, int n, int x, int y) {
    fl_rtl_draw(str, n, x, y);
}

void fl_draw_draw_box(int bk, int x, int y, int w, int h, unsigned int c) {
    fl_draw_box((Fl_Boxtype)bk, x, y, w, h, (Fl_Color)c);
}

void fl_draw_draw_symbol(const char *label, int x, int y, int w, int h, unsigned int c) {
    fl_draw_symbol(label, x, y, w, h, (Fl_Color)c);
}

void fl_draw_measure(const char * str, int &w, int &h, int draw_symbols) {
    fl_measure(str, w, h, draw_symbols);
}

typedef void (a_hook)(void *, int, int, int, int);
typedef a_hook* a_hook_p;

void fl_draw_scroll(int x, int y, int w, int h, int dx, int dy,
                    void * func, void * data) {
    fl_scroll(x, y, w, h, dx, dy, reinterpret_cast<a_hook_p>(func), data);
}

void fl_draw_text_extents(const char * t, int n, int &dx, int &dy, int &w, int &h) {
    fl_text_extents(t, n, dx, dy, w, h);
}

double fl_draw_width(const char *txt, int n) {
    return fl_width(txt, n);
}

double fl_draw_width2(unsigned long c) {
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


