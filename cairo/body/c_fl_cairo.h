

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FL_CAIRO_GUARD
#define FL_CAIRO_GUARD


typedef void* CAIROCONTEXT;
typedef void* CAIROPATTERN;


extern "C" int fl_cairo_status(CAIROCONTEXT c);
extern "C" void fl_cairo_save(CAIROCONTEXT c);
extern "C" void fl_cairo_restore(CAIROCONTEXT c);

extern "C" void fl_cairo_translate(CAIROCONTEXT c, double x, double y);
extern "C" void fl_cairo_scale(CAIROCONTEXT c, double x, double y);
extern "C" void fl_cairo_rotate(CAIROCONTEXT c, double angle);

extern "C" void fl_cairo_set_line_width(CAIROCONTEXT c, double width);
extern "C" void fl_cairo_set_antialias(CAIROCONTEXT c, int mode);
extern "C" void fl_cairo_set_source_rgba(CAIROCONTEXT c, double r, double g, double b, double a);
extern "C" void fl_cairo_set_source(CAIROCONTEXT c, CAIROPATTERN p);

extern "C" void fl_cairo_new_path(CAIROCONTEXT c);
extern "C" void fl_cairo_close_path(CAIROCONTEXT c);
extern "C" void fl_cairo_move_to(CAIROCONTEXT c, double x, double y);
extern "C" void fl_cairo_line_to(CAIROCONTEXT c, double x, double y);
extern "C" void fl_cairo_curve_to(CAIROCONTEXT c, double x1, double y1, double x2, double y2,
        double x3, double y3);
extern "C" void fl_cairo_rectangle(CAIROCONTEXT c, double x, double y, double w, double h);
extern "C" void fl_cairo_arc(CAIROCONTEXT c, double x, double y, double radius, double from,
        double to);

extern "C" void fl_cairo_stroke(CAIROCONTEXT c);
extern "C" void fl_cairo_stroke_preserve(CAIROCONTEXT c);
extern "C" void fl_cairo_fill(CAIROCONTEXT c);
extern "C" void fl_cairo_fill_preserve(CAIROCONTEXT c);
extern "C" void fl_cairo_paint(CAIROCONTEXT c);
extern "C" void fl_cairo_clip(CAIROCONTEXT c);

extern "C" void fl_cairo_select_font_face(CAIROCONTEXT c, const char * family, int slant,
        int weight);
extern "C" void fl_cairo_set_font_size(CAIROCONTEXT c, double size);
extern "C" void fl_cairo_show_text(CAIROCONTEXT c, const char * text);
extern "C" void fl_cairo_text_path(CAIROCONTEXT c, const char * text);
extern "C" void fl_cairo_text_extents(CAIROCONTEXT c, const char * text, double * e);

extern "C" CAIROPATTERN fl_cairo_pattern_create_linear(double x0, double y0, double x1, double y1);
extern "C" CAIROPATTERN fl_cairo_pattern_create_radial(double x0, double y0, double r0, double x1,
        double y1, double r1);
extern "C" void fl_cairo_pattern_add_color_stop_rgba(CAIROPATTERN p, double offset, double r,
        double g, double b, double a);
extern "C" void fl_cairo_pattern_set_extend(CAIROPATTERN p, int extend);
extern "C" int fl_cairo_pattern_status(CAIROPATTERN p);
extern "C" void fl_cairo_pattern_destroy(CAIROPATTERN p);


#endif
