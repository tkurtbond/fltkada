

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_COLOR_CHOOSER_GUARD
#define FL_COLOR_CHOOSER_GUARD


typedef void* COLORCHOOSER;


extern "C" COLORCHOOSER new_fl_color_chooser(int x, int y, int w, int h, char* label);
extern "C" void free_fl_color_chooser(COLORCHOOSER n);


extern "C" double fl_color_chooser_r(COLORCHOOSER n);
extern "C" double fl_color_chooser_g(COLORCHOOSER n);
extern "C" double fl_color_chooser_b(COLORCHOOSER n);
extern "C" int fl_color_chooser_rgb(COLORCHOOSER n, int r, int g, int b);


extern "C" double fl_color_chooser_hue(COLORCHOOSER n);
extern "C" double fl_color_chooser_saturation(COLORCHOOSER n);
extern "C" double fl_color_chooser_value(COLORCHOOSER n);
extern "C" int fl_color_chooser_hsv(COLORCHOOSER n, int h, int s, int v);


extern "C" void fl_color_chooser_hsv2rgb
    (double h, double s, double v, double &r, double &g, double &b);
extern "C" void fl_color_chooser_rgb2hsv
    (double r, double g, double b, double &h, double &s, double &v);


extern "C" int fl_color_chooser_get_mode(COLORCHOOSER n);
extern "C" void fl_color_chooser_set_mode(COLORCHOOSER n, int m);


extern "C" void fl_color_chooser_draw(COLORCHOOSER n);
extern "C" int fl_color_chooser_handle(COLORCHOOSER n, int e);


#endif


