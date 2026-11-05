

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_CLOCK_OUTPUT_GUARD
#define FL_CLOCK_OUTPUT_GUARD


typedef void* CLOCKOUTPUT;


extern "C" CLOCKOUTPUT new_fl_clock_output(int x, int y, int w, int h, char* label);
extern "C" void free_fl_clock_output(CLOCKOUTPUT c);


extern "C" int fl_clock_output_get_hour(CLOCKOUTPUT c);
extern "C" int fl_clock_output_get_minute(CLOCKOUTPUT c);
extern "C" int fl_clock_output_get_second(CLOCKOUTPUT c);


extern "C" unsigned long fl_clock_output_get_value(CLOCKOUTPUT c);
extern "C" void fl_clock_output_set_value(CLOCKOUTPUT c, unsigned long v);
extern "C" void fl_clock_output_set_value2(CLOCKOUTPUT c, int h, int m, int s);


extern "C" int fl_clock_output_get_shadow(CLOCKOUTPUT c);
extern "C" void fl_clock_output_set_shadow(CLOCKOUTPUT c, int s);


extern "C" void fl_clock_output_draw(CLOCKOUTPUT c);
extern "C" void fl_clock_output_draw2(CLOCKOUTPUT c, int x, int y, int w, int h);
extern "C" int fl_clock_output_handle(CLOCKOUTPUT c, int e);


#endif


