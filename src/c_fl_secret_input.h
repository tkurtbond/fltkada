

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_SECRET_INPUT_GUARD
#define FL_SECRET_INPUT_GUARD


typedef void* SECRETINPUT;


extern "C" SECRETINPUT new_fl_secret_input(int x, int y, int w, int h, char* label);
extern "C" void free_fl_secret_input(SECRETINPUT i);


extern "C" void fl_secret_input_draw(SECRETINPUT i);
extern "C" int fl_secret_input_handle(SECRETINPUT i, int e);


#endif


