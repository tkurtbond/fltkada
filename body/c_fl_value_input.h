

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_VALUE_INPUT_GUARD
#define FL_VALUE_INPUT_GUARD


typedef void* VALUEINPUT;


extern "C" VALUEINPUT new_fl_value_input(int x, int y, int w, int h, char* label);
extern "C" void free_fl_value_input(VALUEINPUT a);


extern "C" void * fl_value_input_get_input(VALUEINPUT v);


extern "C" unsigned int fl_value_input_get_cursor_color(VALUEINPUT v);
extern "C" void fl_value_input_set_cursor_color(VALUEINPUT v, unsigned int c);


extern "C" int fl_value_input_get_shortcut(VALUEINPUT v);
extern "C" void fl_value_input_set_shortcut(VALUEINPUT v, int k);


extern "C" int fl_value_input_is_soft(VALUEINPUT a);
extern "C" void fl_value_input_set_soft(VALUEINPUT a, int t);


extern "C" unsigned int fl_value_input_get_text_color(VALUEINPUT v);
extern "C" void fl_value_input_set_text_color(VALUEINPUT v, unsigned int c);
extern "C" int fl_value_input_get_text_font(VALUEINPUT v);
extern "C" void fl_value_input_set_text_font(VALUEINPUT v, int f);
extern "C" int fl_value_input_get_text_size(VALUEINPUT v);
extern "C" void fl_value_input_set_text_size(VALUEINPUT v, int s);


extern "C" void fl_value_input_resize(VALUEINPUT v, int x, int y, int w, int h);


extern "C" void fl_value_input_draw(VALUEINPUT a);
extern "C" int fl_value_input_handle(VALUEINPUT a, int e);


#endif


