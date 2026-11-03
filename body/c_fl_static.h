

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_STATIC_GUARD
#define FL_STATIC_GUARD


extern "C" void fl_static_box_draw_marshal(void * f, int x, int y, int w, int h, unsigned int t);


extern "C" const char * const fl_help_usage_string_ptr;


extern "C" void fl_static_open_display();


extern "C" int fl_static_arg(int c, void * v, int &i);
extern "C" void fl_static_args(int c, void * v);
extern "C" int fl_static_args2(int c, void * v, int &i, void * h);


extern "C" int fl_static_add_awake_handler(void * h, void * f);
extern "C" int fl_static_get_awake_handler(void * &h, void * &f);
extern "C" int fl_static_awake2(void * h, void * f);
extern "C" void fl_static_awake(void * msg);
extern "C" void fl_static_lock();
extern "C" void fl_static_unlock();


extern "C" void fl_static_add_check(void * h, void * f);
extern "C" int fl_static_has_check(void * h, void * f);
extern "C" void fl_static_remove_check(void * h, void * f);


extern "C" void fl_static_add_timeout(double s, void * h, void * f);
extern "C" int fl_static_has_timeout(void * h, void * f);
extern "C" void fl_static_remove_timeout(void * h, void * f);
extern "C" void fl_static_repeat_timeout(double s, void * h, void * f);


extern "C" void fl_static_add_clipboard_notify(void * h, void * f);
extern "C" void fl_static_remove_clipboard_notify(void * h);


extern "C" void fl_static_add_fd(int d, void * h, void * f);
extern "C" void fl_static_add_fd2(int d, int m, void * h, void * f);
extern "C" void fl_static_remove_fd(int d);
extern "C" void fl_static_remove_fd2(int d, int m);


extern "C" void fl_static_add_idle(void * h, void * f);
extern "C" int fl_static_has_idle(void * h, void * f);
extern "C" void fl_static_remove_idle(void * h, void * f);


extern "C" unsigned int fl_static_get_color2(unsigned int c);
extern "C" void fl_static_get_color(unsigned int c,
    unsigned char &r, unsigned char &g, unsigned char &b);
extern "C" void fl_static_set_color2(unsigned int t, unsigned int f);
extern "C" void fl_static_set_color(unsigned int c,
    unsigned char r, unsigned char g, unsigned char b);
extern "C" void fl_static_free_color(unsigned int c, int b);
extern "C" unsigned int fl_static_get_box_color(unsigned int t);
extern "C" void fl_static_set_box_color(unsigned int t);
extern "C" void fl_static_own_colormap();
extern "C" void fl_static_foreground(unsigned int r, unsigned int g, unsigned int b);
extern "C" void fl_static_background(unsigned int r, unsigned int g, unsigned int b);
extern "C" void fl_static_background2(unsigned int r, unsigned int g, unsigned int b);
extern "C" void fl_static_get_system_colors();
extern "C" void fl_static_get_color3(unsigned int c,
    unsigned char &r, unsigned char &g, unsigned char &b, unsigned char &a);
extern "C" void fl_static_set_color3(unsigned int c,
    unsigned char r, unsigned char g, unsigned char b, unsigned char a);


extern "C" const char * fl_static_get_font(int f);
extern "C" const char * fl_static_get_font_name(int f);
extern "C" void fl_static_set_font(int t, int f);
extern "C" void fl_static_set_font2(int t, char * s);
extern "C" int fl_static_get_font_sizes(int f, int * &a);
extern "C" int fl_static_font_size_array_get(int * a, int i);
extern "C" int fl_static_set_fonts();


extern "C" int fl_static_box_dh(int b);
extern "C" int fl_static_box_dw(int b);
extern "C" int fl_static_box_dx(int b);
extern "C" int fl_static_box_dy(int b);
extern "C" void * fl_static_get_boxtype(int t);
extern "C" void fl_static_set_boxtype(int t, int f);
extern "C" void fl_static_set_boxtype2(int t, void * f,
    unsigned char dx, unsigned char dy, unsigned char dw, unsigned char dh);
extern "C" int fl_static_draw_box_active();


extern "C" void fl_static_set_labeltype(int k, void * d, void * m);


extern "C" void fl_static_copy(const char * t, int l, int k);
extern "C" void fl_static_paste(void * r, int s);
extern "C" void fl_static_selection(void * o, char * t, int l);
extern "C" int fl_static_clipboard_contains(const char * k);


extern "C" int fl_static_dnd();
extern "C" int fl_static_get_dnd_text_ops();
extern "C" void fl_static_set_dnd_text_ops(int t);


extern "C" void fl_static_enable_im();
extern "C" void fl_static_disable_im();


extern "C" void fl_static_default_atclose(void * w, void * u);
extern "C" void * fl_static_get_first_window();
extern "C" void fl_static_set_first_window(void * w);
extern "C" void * fl_static_next_window(void * w);
extern "C" void * fl_static_modal();


extern "C" void * fl_static_readqueue();


extern "C" const char * fl_static_get_scheme();
extern "C" void fl_static_set_scheme(const char *n);
extern "C" int fl_static_is_scheme(const char *n);
extern "C" void fl_static_reload_scheme();


extern "C" int fl_static_get_option(int o);
extern "C" void fl_static_set_option(int o, int t);
extern "C" int fl_static_get_use_high_res_gl();
extern "C" void fl_static_set_use_high_res_gl(int v);


extern "C" int fl_static_get_scrollbar_size();
extern "C" void fl_static_set_scrollbar_size(int s);


#endif


