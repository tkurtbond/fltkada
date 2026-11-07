

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


//  The part of cairo FLTK.Cairo binds, as pofltk's FlCairo.cpp does.


#include <cairo.h>
#include "c_fl_cairo.h"




//  Conversions

static cairo_t * cr(CAIROCONTEXT c) {
    return static_cast<cairo_t*>(c);
}

static cairo_pattern_t * pat(CAIROPATTERN p) {
    return static_cast<cairo_pattern_t*>(p);
}




//  Flattened C API

int fl_cairo_status(CAIROCONTEXT c) {
    return cairo_status(cr(c));
}

void fl_cairo_save(CAIROCONTEXT c) {
    cairo_save(cr(c));
}

void fl_cairo_restore(CAIROCONTEXT c) {
    cairo_restore(cr(c));
}




void fl_cairo_translate(CAIROCONTEXT c, double x, double y) {
    cairo_translate(cr(c), x, y);
}

void fl_cairo_scale(CAIROCONTEXT c, double x, double y) {
    cairo_scale(cr(c), x, y);
}

void fl_cairo_rotate(CAIROCONTEXT c, double angle) {
    cairo_rotate(cr(c), angle);
}




void fl_cairo_set_line_width(CAIROCONTEXT c, double width) {
    cairo_set_line_width(cr(c), width);
}

void fl_cairo_set_antialias(CAIROCONTEXT c, int mode) {
    cairo_set_antialias(cr(c), static_cast<cairo_antialias_t>(mode));
}

void fl_cairo_set_source_rgba(CAIROCONTEXT c, double r, double g, double b, double a) {
    cairo_set_source_rgba(cr(c), r, g, b, a);
}

void fl_cairo_set_source(CAIROCONTEXT c, CAIROPATTERN p) {
    cairo_set_source(cr(c), pat(p));
}




void fl_cairo_new_path(CAIROCONTEXT c) {
    cairo_new_path(cr(c));
}

void fl_cairo_close_path(CAIROCONTEXT c) {
    cairo_close_path(cr(c));
}

void fl_cairo_move_to(CAIROCONTEXT c, double x, double y) {
    cairo_move_to(cr(c), x, y);
}

void fl_cairo_line_to(CAIROCONTEXT c, double x, double y) {
    cairo_line_to(cr(c), x, y);
}

void fl_cairo_curve_to(CAIROCONTEXT c, double x1, double y1, double x2, double y2, double x3,
        double y3) {
    cairo_curve_to(cr(c), x1, y1, x2, y2, x3, y3);
}

void fl_cairo_rectangle(CAIROCONTEXT c, double x, double y, double w, double h) {
    cairo_rectangle(cr(c), x, y, w, h);
}

void fl_cairo_arc(CAIROCONTEXT c, double x, double y, double radius, double from, double to) {
    cairo_arc(cr(c), x, y, radius, from, to);
}




void fl_cairo_stroke(CAIROCONTEXT c) {
    cairo_stroke(cr(c));
}

void fl_cairo_stroke_preserve(CAIROCONTEXT c) {
    cairo_stroke_preserve(cr(c));
}

void fl_cairo_fill(CAIROCONTEXT c) {
    cairo_fill(cr(c));
}

void fl_cairo_fill_preserve(CAIROCONTEXT c) {
    cairo_fill_preserve(cr(c));
}

void fl_cairo_paint(CAIROCONTEXT c) {
    cairo_paint(cr(c));
}

void fl_cairo_clip(CAIROCONTEXT c) {
    cairo_clip(cr(c));
}




void fl_cairo_select_font_face(CAIROCONTEXT c, const char * family, int slant, int weight) {
    cairo_select_font_face(cr(c), family, static_cast<cairo_font_slant_t>(slant),
        static_cast<cairo_font_weight_t>(weight));
}

void fl_cairo_set_font_size(CAIROCONTEXT c, double size) {
    cairo_set_font_size(cr(c), size);
}

void fl_cairo_show_text(CAIROCONTEXT c, const char * text) {
    cairo_show_text(cr(c), text);
}

void fl_cairo_text_path(CAIROCONTEXT c, const char * text) {
    cairo_text_path(cr(c), text);
}

void fl_cairo_text_extents(CAIROCONTEXT c, const char * text, double * e) {
    //  X and Y bearing, width, height, X and Y advance
    cairo_text_extents_t t;
    cairo_text_extents(cr(c), text, &t);
    e[0] = t.x_bearing;
    e[1] = t.y_bearing;
    e[2] = t.width;
    e[3] = t.height;
    e[4] = t.x_advance;
    e[5] = t.y_advance;
}




CAIROPATTERN fl_cairo_pattern_create_linear(double x0, double y0, double x1, double y1) {
    return cairo_pattern_create_linear(x0, y0, x1, y1);
}

CAIROPATTERN fl_cairo_pattern_create_radial(double x0, double y0, double r0, double x1, double y1,
        double r1) {
    return cairo_pattern_create_radial(x0, y0, r0, x1, y1, r1);
}

void fl_cairo_pattern_add_color_stop_rgba(CAIROPATTERN p, double offset, double r, double g,
        double b, double a) {
    cairo_pattern_add_color_stop_rgba(pat(p), offset, r, g, b, a);
}

void fl_cairo_pattern_set_extend(CAIROPATTERN p, int extend) {
    cairo_pattern_set_extend(pat(p), static_cast<cairo_extend_t>(extend));
}

int fl_cairo_pattern_status(CAIROPATTERN p) {
    return cairo_pattern_status(pat(p));
}

void fl_cairo_pattern_destroy(CAIROPATTERN p) {
    cairo_pattern_destroy(pat(p));
}

