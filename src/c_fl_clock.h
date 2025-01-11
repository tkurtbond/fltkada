

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_CLOCK_GUARD
#define FL_CLOCK_GUARD


typedef void* CLOCK;


extern "C" CLOCK new_fl_clock(int x, int y, int w, int h, char* label);
extern "C" CLOCK new_fl_clock2(unsigned char k, int x, int y, int w, int h, char* label);
extern "C" void free_fl_clock(CLOCK c);


extern "C" void fl_clock_draw(CLOCK c);
extern "C" int fl_clock_handle(CLOCK c, int e);


#endif


