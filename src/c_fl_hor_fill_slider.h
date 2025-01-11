

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_HOR_FILL_SLIDER_GUARD
#define FL_HOR_FILL_SLIDER_GUARD


typedef void* HORFILLSLIDER;


extern "C" HORFILLSLIDER new_fl_hor_fill_slider(int x, int y, int w, int h, char* label);
extern "C" void free_fl_hor_fill_slider(HORFILLSLIDER s);


extern "C" void fl_hor_fill_slider_draw(HORFILLSLIDER s);
extern "C" int fl_hor_fill_slider_handle(HORFILLSLIDER s, int e);


#endif


