

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_POSITIONER_GUARD
#define FL_POSITIONER_GUARD


typedef void* POSITIONER;


extern "C" POSITIONER new_fl_positioner(int x, int y, int w, int h, char* label);
extern "C" void free_fl_positioner(POSITIONER p);


extern "C" int fl_positioner_set_value(POSITIONER p, double x, double y);


extern "C" void fl_positioner_xbounds(POSITIONER p, double l, double h);
extern "C" void fl_positioner_xstep(POSITIONER p, double a);
extern "C" double fl_positioner_get_xminimum(POSITIONER p);
extern "C" void fl_positioner_set_xminimum(POSITIONER p, double a);
extern "C" double fl_positioner_get_xmaximum(POSITIONER p);
extern "C" void fl_positioner_set_xmaximum(POSITIONER p, double a);
extern "C" double fl_positioner_get_xvalue(POSITIONER p);
extern "C" int fl_positioner_set_xvalue(POSITIONER p, double x);


extern "C" void fl_positioner_ybounds(POSITIONER p, double l, double h);
extern "C" void fl_positioner_ystep(POSITIONER p, double a);
extern "C" double fl_positioner_get_yminimum(POSITIONER p);
extern "C" void fl_positioner_set_yminimum(POSITIONER p, double a);
extern "C" double fl_positioner_get_ymaximum(POSITIONER p);
extern "C" void fl_positioner_set_ymaximum(POSITIONER p, double a);
extern "C" double fl_positioner_get_yvalue(POSITIONER p);
extern "C" int fl_positioner_set_yvalue(POSITIONER p, double y);


extern "C" void fl_positioner_draw(POSITIONER p);
extern "C" void fl_positioner_draw2(POSITIONER p, int x, int y, int w, int h);
extern "C" int fl_positioner_handle(POSITIONER p, int e);
extern "C" int fl_positioner_handle2(POSITIONER p, int e, int x, int y, int w, int h);


#endif


