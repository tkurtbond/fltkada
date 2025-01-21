

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_SLIDER_GUARD
#define FL_SLIDER_GUARD


typedef void* SLIDER;


extern "C" SLIDER new_fl_slider(int x, int y, int w, int h, char* label);
extern "C" SLIDER new_fl_slider2(unsigned char k, int x, int y, int w, int h, char * label);
extern "C" void free_fl_slider(SLIDER s);


extern "C" void fl_slider_set_bounds(SLIDER s, double a, double b);
extern "C" int fl_slider_get_slider(SLIDER s);
extern "C" void fl_slider_set_slider(SLIDER s, int t);
extern "C" float fl_slider_get_slider_size(SLIDER s);
extern "C" void fl_slider_set_slider_size(SLIDER s, double t);
extern "C" int fl_slider_scrollvalue(SLIDER s, int p, int z, int f, int t);


extern "C" void fl_slider_draw(SLIDER s);
extern "C" void fl_slider_draw2(SLIDER s, int x, int y, int w, int h);
extern "C" int fl_slider_handle(SLIDER s, int e);
extern "C" int fl_slider_handle2(SLIDER s, int e, int x, int y, int w, int h);


#endif


