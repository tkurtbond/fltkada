

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_HORIZONTAL_SLIDER_GUARD
#define FL_HORIZONTAL_SLIDER_GUARD


typedef void* HORIZONTALSLIDER;


extern "C" HORIZONTALSLIDER new_fl_horizontal_slider(int x, int y, int w, int h, char* label);
extern "C" void free_fl_horizontal_slider(HORIZONTALSLIDER s);


extern "C" void fl_horizontal_slider_draw(HORIZONTALSLIDER s);
extern "C" int fl_horizontal_slider_handle(HORIZONTALSLIDER s, int e);


#endif


