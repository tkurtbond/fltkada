

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_TEXT_INPUT_GUARD
#define FL_TEXT_INPUT_GUARD


extern "C" void fl_text_input_extra_init
    (void * adaobj, int x, int y, int w, int h, const char * label);


typedef void* TEXTINPUT;


extern "C" TEXTINPUT new_fl_text_input(int x, int y, int w, int h, char * label);
extern "C" void free_fl_text_input(TEXTINPUT t);


extern "C" void fl_text_input_draw(TEXTINPUT t);
extern "C" int fl_text_input_handle(TEXTINPUT t, int e);


extern "C" const char * fl_text_input_get_menu_text(int which);
extern "C" void fl_text_input_set_menu_text(int which, const char * text);


#endif


