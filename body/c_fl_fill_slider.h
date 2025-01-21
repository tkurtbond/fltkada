

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_FILL_SLIDER_GUARD
#define FL_FILL_SLIDER_GUARD


typedef void* FILLSLIDER;


extern "C" FILLSLIDER new_fl_fill_slider(int x, int y, int w, int h, char* label);
extern "C" void free_fl_fill_slider(FILLSLIDER s);


extern "C" void fl_fill_slider_draw(FILLSLIDER s);
extern "C" int fl_fill_slider_handle(FILLSLIDER s, int e);


#endif


