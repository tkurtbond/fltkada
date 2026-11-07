

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_ASK_GUARD
#define FL_ASK_GUARD


extern "C" const char * fl_ask_get_cancel();
extern "C" void fl_ask_set_cancel(const char * v);
extern "C" const char * fl_ask_get_close();
extern "C" void fl_ask_set_close(const char * v);
extern "C" const char * fl_ask_get_no();
extern "C" void fl_ask_set_no(const char * v);
extern "C" const char * fl_ask_get_ok();
extern "C" void fl_ask_set_ok(const char * v);
extern "C" const char * fl_ask_get_yes();
extern "C" void fl_ask_set_yes(const char * v);


extern "C" void fl_ask_alert(const char * m);
extern "C" void fl_ask_beep(int b);
extern "C" int fl_ask_choice(const char * m, const char * a, const char * b, const char * c);
extern "C" int fl_ask_choice_n(const char * m, const char * a, const char * b, const char * c);
extern "C" const char * fl_ask_input(const char * m, const char * d);
extern "C" void fl_ask_message(const char * m);
extern "C" const char * fl_ask_password(const char * m, const char * d);


extern "C" int fl_ask_color_chooser(const char * n, double & r, double & g, double & b, int m);
extern "C" int fl_ask_color_chooser2(const char * n,
    unsigned char & r, unsigned char & g, unsigned char & b, int m);
extern "C" unsigned int fl_ask_show_colormap(unsigned int h);
extern "C" char * fl_ask_dir_chooser(const char * m, const char * d, int r);
extern "C" char * fl_ask_file_chooser(const char * m, const char * p, const char * d, int r);
extern "C" void fl_ask_file_chooser_callback(void(*cb)(const char *));
extern "C" void fl_ask_file_chooser_ok_label(const char *l);


extern "C" int fl_ask_get_message_hotspot(void);
extern "C" void fl_ask_set_message_hotspot(int v);
extern "C" void fl_ask_message_font(int f, int s);
extern "C" int fl_ask_get_message_font();
extern "C" int fl_ask_get_message_size();
extern "C" void * fl_ask_message_icon(void);
extern "C" void fl_ask_message_title(const char * t);
extern "C" void fl_ask_message_title_default(const char * t);
extern "C" void fl_ask_message_icon_label(const char * t);
extern "C" void fl_ask_message_icon_label_default(const char * t);
extern "C" void fl_ask_set_message_position(int x, int y, int c);
extern "C" void fl_ask_set_message_position_over(void * w);
extern "C" int fl_ask_get_message_position(int &x, int &y);


#endif


