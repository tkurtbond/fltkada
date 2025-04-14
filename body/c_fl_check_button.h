

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_CHECK_BUTTON_GUARD
#define FL_CHECK_BUTTON_GUARD


extern "C" void fl_check_button_extra_init
    (void * adaobj, int x, int y, int w, int h, const char * label);


typedef void* CHECKBUTTON;


extern "C" CHECKBUTTON new_fl_check_button(int x, int y, int w, int h, char* label);
extern "C" void free_fl_check_button(CHECKBUTTON b);


extern "C" void fl_check_button_draw(CHECKBUTTON b);
extern "C" int fl_check_button_handle(CHECKBUTTON b, int e);


#endif


