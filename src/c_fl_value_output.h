

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_VALUE_OUTPUT_GUARD
#define FL_VALUE_OUTPUT_GUARD


typedef void* VALUEOUTPUT;


extern "C" VALUEOUTPUT new_fl_value_output(int x, int y, int w, int h, char* label);
extern "C" void free_fl_value_output(VALUEOUTPUT a);


extern "C" int fl_value_output_is_soft(VALUEOUTPUT a);
extern "C" void fl_value_output_set_soft(VALUEOUTPUT a, int t);


extern "C" unsigned int fl_value_output_get_text_color(VALUEOUTPUT v);
extern "C" void fl_value_output_set_text_color(VALUEOUTPUT v, unsigned int c);
extern "C" int fl_value_output_get_text_font(VALUEOUTPUT v);
extern "C" void fl_value_output_set_text_font(VALUEOUTPUT v, int f);
extern "C" int fl_value_output_get_text_size(VALUEOUTPUT v);
extern "C" void fl_value_output_set_text_size(VALUEOUTPUT v, int s);


extern "C" void fl_value_output_draw(VALUEOUTPUT a);
extern "C" int fl_value_output_handle(VALUEOUTPUT a, int e);


#endif


