

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_ROUND_CLOCK_GUARD
#define FL_ROUND_CLOCK_GUARD


typedef void* ROUNDCLOCK;


extern "C" ROUNDCLOCK new_fl_round_clock(int x, int y, int w, int h, char* label);
extern "C" void free_fl_round_clock(ROUNDCLOCK c);


extern "C" void fl_round_clock_draw(ROUNDCLOCK c);
extern "C" int fl_round_clock_handle(ROUNDCLOCK c, int e);


#endif


