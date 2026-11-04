

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_SCREEN_GUARD
#define FL_SCREEN_GUARD


extern "C" const int fl_enum_mode_rgb;
extern "C" const int fl_enum_mode_rgb8;
extern "C" const int fl_enum_mode_double;
extern "C" const int fl_enum_mode_index;


extern "C" void fl_screen_display(const char * v);
extern "C" int fl_screen_visual(int mode);


extern "C" int fl_screen_x();
extern "C" int fl_screen_y();
extern "C" int fl_screen_w();
extern "C" int fl_screen_h();


extern "C" int fl_screen_count();
extern "C" void fl_screen_dpi(float &h, float &v, int n);


extern "C" int fl_screen_scaling_supported();
extern "C" float fl_screen_get_scale(int n);
extern "C" void fl_screen_set_scale(int n, float f);
extern "C" void fl_screen_keyboard_scaling(int v);


extern "C" int fl_screen_num(int x, int y);
extern "C" int fl_screen_num2(int x, int y, int w, int h);


extern "C" void fl_screen_work_area(int &x, int &y, int &w, int &h, int px, int py);
extern "C" void fl_screen_work_area2(int &x, int &y, int &w, int &h, int n);
extern "C" void fl_screen_work_area3(int &x, int &y, int &w, int &h);


extern "C" void fl_screen_xywh(int &x, int &y, int &w, int &h, int px, int py);
extern "C" void fl_screen_xywh2(int &x, int &y, int &w, int &h, int n);
extern "C" void fl_screen_xywh3(int &x, int &y, int &w, int &h);
extern "C" void fl_screen_xywh4(int &x, int &y, int &w, int &h, int px, int py, int pw, int ph);


extern "C" int fl_screen_get_damage();
extern "C" void fl_screen_set_damage(int v);
extern "C" void fl_screen_flush();
extern "C" void fl_screen_redraw();


#endif


