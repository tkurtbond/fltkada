

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_ROUND_BUTTON_GUARD
#define FL_ROUND_BUTTON_GUARD


typedef void* ROUNDBUTTON;


extern "C" ROUNDBUTTON new_fl_round_button(int x, int y, int w, int h, char* label);
extern "C" void free_fl_round_button(ROUNDBUTTON b);


extern "C" void fl_round_button_draw(ROUNDBUTTON b);
extern "C" int fl_round_button_handle(ROUNDBUTTON b, int e);


#endif


