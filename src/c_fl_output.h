

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_OUTPUT_GUARD
#define FL_OUTPUT_GUARD


//  using just "OUTPUT" doesn't compile for some reason
//  some sort of name clash?
typedef void* OUTPUTT;


extern "C" OUTPUTT new_fl_output(int x, int y, int w, int h, char* label);
extern "C" void free_fl_output(OUTPUTT i);


extern "C" void fl_output_draw(OUTPUTT i);
extern "C" int fl_output_handle(OUTPUTT i, int e);


#endif


