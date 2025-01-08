

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_MULTILINE_INPUT_GUARD
#define FL_MULTILINE_INPUT_GUARD


typedef void* MULTILINEINPUT;


extern "C" MULTILINEINPUT new_fl_multiline_input(int x, int y, int w, int h, char* label);
extern "C" void free_fl_multiline_input(MULTILINEINPUT i);


extern "C" void fl_multiline_input_draw(MULTILINEINPUT i);
extern "C" int fl_multiline_input_handle(MULTILINEINPUT i, int e);


#endif


