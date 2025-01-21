

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_RADIO_BUTTON_GUARD
#define FL_RADIO_BUTTON_GUARD


typedef void* RADIOBUTTON;


extern "C" RADIOBUTTON new_fl_radio_button(int x, int y, int w, int h, char* label);
extern "C" void free_fl_radio_button(RADIOBUTTON b);


extern "C" void fl_radio_button_draw(RADIOBUTTON b);
extern "C" int fl_radio_button_handle(RADIOBUTTON b, int e);


#endif


