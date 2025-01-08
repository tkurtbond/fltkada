

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_FLOAT_INPUT_GUARD
#define FL_FLOAT_INPUT_GUARD


typedef void* FLOATINPUT;


extern "C" FLOATINPUT new_fl_float_input(int x, int y, int w, int h, char* label);
extern "C" void free_fl_float_input(FLOATINPUT i);


extern "C" void fl_float_input_draw(FLOATINPUT i);
extern "C" int fl_float_input_handle(FLOATINPUT i, int e);


#endif


