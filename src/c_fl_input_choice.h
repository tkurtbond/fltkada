

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_INPUT_CHOICE_GUARD
#define FL_INPUT_CHOICE_GUARD


typedef void* INPUTCHOICE;


extern "C" INPUTCHOICE new_fl_input_choice(int x, int y, int w, int h, char* label);
extern "C" void free_fl_input_choice(INPUTCHOICE n);


extern "C" void * fl_input_choice_input(INPUTCHOICE n);
extern "C" void * fl_input_choice_menubutton(INPUTCHOICE n);


extern "C" void fl_input_choice_clear(INPUTCHOICE n);


extern "C" int fl_input_choice_changed(INPUTCHOICE n);
extern "C" void fl_input_choice_clear_changed(INPUTCHOICE n);
extern "C" void fl_input_choice_set_changed(INPUTCHOICE n);
extern "C" int fl_input_choice_get_down_box(INPUTCHOICE n);
extern "C" void fl_input_choice_set_down_box(INPUTCHOICE n, int t);
extern "C" unsigned int fl_input_choice_get_textcolor(INPUTCHOICE n);
extern "C" void fl_input_choice_set_textcolor(INPUTCHOICE n, unsigned int t);
extern "C" int fl_input_choice_get_textfont(INPUTCHOICE n);
extern "C" void fl_input_choice_set_textfont(INPUTCHOICE n, int t);
extern "C" int fl_input_choice_get_textsize(INPUTCHOICE n);
extern "C" void fl_input_choice_set_textsize(INPUTCHOICE n, int t);
extern "C" const char * fl_input_choice_get_value(INPUTCHOICE n);
extern "C" void fl_input_choice_set_value(INPUTCHOICE n, const char * t);
extern "C" void fl_input_choice_set_value2(INPUTCHOICE n, int t);


extern "C" void fl_input_choice_resize(INPUTCHOICE n, int x, int y, int w, int h);


extern "C" void fl_input_choice_draw(INPUTCHOICE n);
extern "C" int fl_input_choice_handle(INPUTCHOICE n, int e);


#endif


