

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_NICE_SLIDER_GUARD
#define FL_NICE_SLIDER_GUARD


typedef void* NICESLIDER;


extern "C" NICESLIDER new_fl_nice_slider(int x, int y, int w, int h, char* label);
extern "C" void free_fl_nice_slider(NICESLIDER s);


extern "C" void fl_nice_slider_draw(NICESLIDER s);
extern "C" int fl_nice_slider_handle(NICESLIDER s, int e);


#endif


