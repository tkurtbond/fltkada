

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_HOR_VALUE_SLIDER_GUARD
#define FL_HOR_VALUE_SLIDER_GUARD


typedef void* HORVALUESLIDER;


extern "C" HORVALUESLIDER new_fl_hor_value_slider(int x, int y, int w, int h, char* label);
extern "C" void free_fl_hor_value_slider(HORVALUESLIDER s);


extern "C" void fl_hor_value_slider_draw(HORVALUESLIDER s);
extern "C" int fl_hor_value_slider_handle(HORVALUESLIDER s, int e);


#endif


