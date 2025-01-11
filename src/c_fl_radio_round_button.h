

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_RADIO_ROUND_BUTTON_GUARD
#define FL_RADIO_ROUND_BUTTON_GUARD


typedef void* RADIOROUNDBUTTON;


extern "C" RADIOROUNDBUTTON new_fl_radio_round_button(int x, int y, int w, int h, char* label);
extern "C" void free_fl_radio_round_button(RADIOROUNDBUTTON b);


extern "C" void fl_radio_round_button_draw(RADIOROUNDBUTTON b);
extern "C" int fl_radio_round_button_handle(RADIOROUNDBUTTON b, int e);


#endif


