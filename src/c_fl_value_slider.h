

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_VALUE_SLIDER_GUARD
#define FL_VALUE_SLIDER_GUARD


typedef void* VALUESLIDER;


extern "C" VALUESLIDER new_fl_value_slider(int x, int y, int w, int h, char* label);
extern "C" void free_fl_value_slider(VALUESLIDER s);


extern "C" unsigned int fl_value_slider_get_textcolor(VALUESLIDER s);
extern "C" void fl_value_slider_set_textcolor(VALUESLIDER s, unsigned int t);
extern "C" int fl_value_slider_get_textfont(VALUESLIDER s);
extern "C" void fl_value_slider_set_textfont(VALUESLIDER s, int t);
extern "C" int fl_value_slider_get_textsize(VALUESLIDER s);
extern "C" void fl_value_slider_set_textsize(VALUESLIDER s, int t);


extern "C" void fl_value_slider_draw(VALUESLIDER s);
extern "C" int fl_value_slider_handle(VALUESLIDER s, int e);


#endif


