

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_DIAL_GUARD
#define FL_DIAL_GUARD


typedef void* DIAL;


extern "C" DIAL new_fl_dial(int x, int y, int w, int h, char* label);
extern "C" void free_fl_dial(DIAL v);


extern "C" short fl_dial_get_angle1(DIAL v);
extern "C" void fl_dial_set_angle1(DIAL v, short t);
extern "C" short fl_dial_get_angle2(DIAL v);
extern "C" void fl_dial_set_angle2(DIAL v, short t);
extern "C" void fl_dial_set_angles(DIAL v, short a, short b);


extern "C" void fl_dial_draw(DIAL v);
extern "C" void fl_dial_draw2(DIAL v, int x, int y, int w, int h);
extern "C" int fl_dial_handle(DIAL v, int e);
extern "C" int fl_dial_handle2(DIAL v, int e, int x, int y, int w, int h);


#endif


