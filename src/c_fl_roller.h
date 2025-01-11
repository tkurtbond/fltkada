

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_ROLLER_GUARD
#define FL_ROLLER_GUARD


typedef void* ROLLER;


extern "C" ROLLER new_fl_roller(int x, int y, int w, int h, char* label);
extern "C" void free_fl_roller(ROLLER r);


extern "C" void fl_roller_draw(ROLLER r);
extern "C" int fl_roller_handle(ROLLER r, int e);


#endif


