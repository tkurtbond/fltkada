

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_HOR_NICE_SLIDER_GUARD
#define FL_HOR_NICE_SLIDER_GUARD


typedef void* HORNICESLIDER;


extern "C" HORNICESLIDER new_fl_hor_nice_slider(int x, int y, int w, int h, char* label);
extern "C" void free_fl_hor_nice_slider(HORNICESLIDER s);


extern "C" void fl_hor_nice_slider_draw(HORNICESLIDER s);
extern "C" int fl_hor_nice_slider_handle(HORNICESLIDER s, int e);


#endif


