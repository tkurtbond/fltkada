

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_LIGHT_BUTTON_GUARD
#define FL_LIGHT_BUTTON_GUARD


typedef void* LIGHTBUTTON;


extern "C" LIGHTBUTTON new_fl_light_button(int x, int y, int w, int h, char* label);
extern "C" void free_fl_light_button(LIGHTBUTTON b);


extern "C" void fl_light_button_draw(LIGHTBUTTON b);
extern "C" int fl_light_button_handle(LIGHTBUTTON b, int e);


#endif


