

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_MULTILINE_OUTPUT_GUARD
#define FL_MULTILINE_OUTPUT_GUARD


typedef void* MULTILINEOUTPUT;


extern "C" MULTILINEOUTPUT new_fl_multiline_output(int x, int y, int w, int h, char* label);
extern "C" void free_fl_multiline_output(MULTILINEOUTPUT i);


extern "C" void fl_multiline_output_draw(MULTILINEOUTPUT i);
extern "C" int fl_multiline_output_handle(MULTILINEOUTPUT i, int e);


#endif


