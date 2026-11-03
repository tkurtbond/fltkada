

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_DRAW_GUARD
#define FL_DRAW_GUARD


extern "C" void fl_draw_reset_spot();
extern "C" void fl_draw_set_spot(int f, int s, int x, int y, int w, int h, void * ptr);
extern "C" void fl_draw_set_status(int x, int y, int w, int h);


extern "C" int fl_draw_can_do_alpha_blending();
extern "C" const char * fl_draw_shortcut_label(unsigned int shortcut);


extern "C" int fl_draw_recode(int kind, const char * from, char * to, int n);


extern "C" int fl_draw_clip_box(int x, int y, int w, int h, int &bx, int &by, int &bw, int &bh);
extern "C" int fl_draw_not_clipped(int x, int y, int w, int h);
extern "C" void fl_draw_pop_clip();
extern "C" void fl_draw_push_clip(int x, int y, int w, int h);
extern "C" void fl_draw_push_no_clip();
extern "C" void fl_draw_restore_clip();


extern "C" void fl_draw_overlay_clear();
extern "C" void fl_draw_overlay_rect(int x, int y, int w, int h);


extern "C" unsigned int fl_draw_get_color();
extern "C" void fl_draw_set_color(unsigned int c);
extern "C" void fl_draw_set_color2(uchar r, uchar g, uchar b);
extern "C" void fl_draw_set_cursor(int m);
extern "C" void fl_draw_set_cursor2(int m, unsigned int f, unsigned int b);
extern "C" unsigned int fl_draw_get_font();
extern "C" int fl_draw_size();
extern "C" void fl_draw_set_font(unsigned int f, int s);
extern "C" int fl_draw_height();
extern "C" int fl_draw_descent();
extern "C" int fl_draw_height2(unsigned int f, int s);
extern "C" void fl_draw_line_style(int style, int width, char * dashes);


extern "C" void fl_draw_mult_matrix(double a, double b, double c, double d, double x, double y);
extern "C" void fl_draw_pop_matrix();
extern "C" void fl_draw_push_matrix();
extern "C" void fl_draw_rotate(double d);
extern "C" void fl_draw_scale(double x);
extern "C" void fl_draw_scale2(double x, double y);
extern "C" double fl_draw_transform_dx(double x, double y);
extern "C" double fl_draw_transform_dy(double x, double y);
extern "C" double fl_draw_transform_x(double x, double y);
extern "C" double fl_draw_transform_y(double x, double y);
extern "C" void fl_draw_transformed_vertex(double xf, double yf);
extern "C" void fl_draw_translate(double x, double y);
extern "C" void fl_draw_vertex(double x, double y);


extern "C" void fl_draw_draw_image(void * data, int x, int y, int w, int h, int d, int l);
extern "C" void fl_draw_draw_image2(void * func, void * data, int x, int y, int w, int h, int d);
extern "C" void fl_draw_draw_image_mono(void * data, int x, int y, int w, int h, int d, int l);
extern "C" void fl_draw_draw_image_mono2(void * func, void * data, int x, int y, int w, int h, int d);
extern "C" int fl_draw_draw_pixmap(void * data, int x, int y, unsigned int h);
extern "C" void * fl_draw_read_image(void * data, int x, int y, int w, int h, int alpha);


extern "C" int fl_draw_add_symbol(const char *name, void *func, int scalable);
extern "C" void fl_draw_draw_text(const char *str, int n, int x, int y);
extern "C" void fl_draw_draw_text2(const char *str, int x, int y, int w, int h,
                                   unsigned align, void * img, int draw_symbols);
extern "C" void fl_draw_draw_text3(const char *str, int x, int y, int w, int h,
                                   unsigned align, void * func, void * img, int draw_symbols);
extern "C" void fl_draw_draw_text4(int angle, const char *str, int n, int x, int y);
extern "C" void fl_draw_rtl_draw(const char *str, int n, int x, int y);
extern "C" void fl_draw_draw_box(int bk, int x, int y, int w, int h, unsigned int c);
extern "C" int fl_draw_draw_symbol(const char *label, int x, int y, int w, int h, unsigned int c);
extern "C" void fl_draw_measure(const char * str, int &w, int &h, int draw_symbols);
extern "C" void fl_draw_scroll(int x, int y, int w, int h, int dx, int dy,
                               void * func, void * data);
extern "C" void fl_draw_text_extents(const char * t, int n, int &dx, int &dy, int &w, int &h);
extern "C" const char * fl_draw_expand_text(const char * str, char * buf, int maxbuf,
    double maxw, int &n, double &width, int wrap, int symbol);
extern "C" double fl_draw_width(const char *txt, int n);
extern "C" double fl_draw_width2(unsigned long c);


extern "C" void fl_draw_begin_complex_polygon();
extern "C" void fl_draw_begin_line();
extern "C" void fl_draw_begin_loop();
extern "C" void fl_draw_begin_points();
extern "C" void fl_draw_begin_polygon();


extern "C" void fl_draw_arc(double x, double y, double r, double start, double end);
extern "C" void fl_draw_arc2(int x, int y, int w, int h, double a1, double a2);
//  extern "C" void fl_draw_chord(int x, int y, int w, int h, double a1, double a2);
extern "C" void fl_draw_circle(double x, double y, double r);
extern "C" void fl_draw_curve(double x0, double y0, double x1, double y1,
                              double x2, double y2, double x3, double y3);
extern "C" void fl_draw_frame(const char *s, int x, int y, int w, int h);
extern "C" void fl_draw_gap();
extern "C" void fl_draw_line(int x0, int y0, int x1, int y1);
extern "C" void fl_draw_line2(int x0, int y0, int x1, int y1, int x2, int y2);
extern "C" void fl_draw_loop(int x0, int y0, int x1, int y1, int x2, int y2);
extern "C" void fl_draw_loop2(int x0, int y0, int x1, int y1, int x2, int y2, int x3, int y3);
extern "C" void fl_draw_pie(int x, int y, int w, int h, double a1, double a2);
extern "C" void fl_draw_point(int x, int y);
extern "C" void fl_draw_polygon(int x0, int y0, int x1, int y1, int x2, int y2);
extern "C" void fl_draw_polygon2(int x0, int y0, int x1, int y1, int x2, int y2, int x3, int y3);
extern "C" void fl_draw_rect(int x, int y, int w, int h);
extern "C" void fl_draw_rect2(int x, int y, int w, int h, unsigned int c);
extern "C" void fl_draw_rect_fill(int x, int y, int w, int h);
extern "C" void fl_draw_rect_fill2(int x, int y, int w, int h, unsigned int c);
extern "C" void fl_draw_rect_fill3(int x, int y, int w, int h, uchar r, uchar g, uchar b);
extern "C" void fl_draw_xy_line(int x0, int y0, int x1);
extern "C" void fl_draw_xy_line2(int x0, int y0, int x1, int y2);
extern "C" void fl_draw_xy_line3(int x0, int y0, int x1, int y2, int x3);
extern "C" void fl_draw_yx_line(int x0, int y0, int y1);
extern "C" void fl_draw_yx_line2(int x0, int y0, int y1, int x2);
extern "C" void fl_draw_yx_line3(int x0, int y0, int y1, int x2, int y3);


extern "C" void fl_draw_end_complex_polygon();
extern "C" void fl_draw_end_line();
extern "C" void fl_draw_end_loop();
extern "C" void fl_draw_end_points();
extern "C" void fl_draw_end_polygon();


#endif


