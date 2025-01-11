

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_REPEAT_BUTTON_GUARD
#define FL_REPEAT_BUTTON_GUARD


typedef void* REPEATBUTTON;


extern "C" REPEATBUTTON new_fl_repeat_button(int x, int y, int w, int h, char* label);
extern "C" void free_fl_repeat_button(REPEATBUTTON b);


extern "C" void fl_repeat_button_deactivate(REPEATBUTTON b);


extern "C" void fl_repeat_button_draw(REPEATBUTTON b);
extern "C" int fl_repeat_button_handle(REPEATBUTTON b, int e);


#endif


