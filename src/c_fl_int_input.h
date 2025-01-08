

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_INT_INPUT_GUARD
#define FL_INT_INPUT_GUARD


typedef void* INTINPUT;


extern "C" INTINPUT new_fl_int_input(int x, int y, int w, int h, char* label);
extern "C" void free_fl_int_input(INTINPUT i);


extern "C" void fl_int_input_draw(INTINPUT i);
extern "C" int fl_int_input_handle(INTINPUT i, int e);


#endif


