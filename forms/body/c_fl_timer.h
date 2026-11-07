

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FL_TIMER_GUARD
#define FL_TIMER_GUARD


typedef void* TIMER;


extern "C" TIMER new_fl_timer(int k, int x, int y, int w, int h, char * label);
extern "C" void free_fl_timer(TIMER t);


extern "C" double fl_timer_get_value(TIMER t);
extern "C" void fl_timer_set_value(TIMER t, double v);
extern "C" int fl_timer_counts_up(TIMER t);
extern "C" void fl_timer_set_counts_up(TIMER t, int u);
extern "C" int fl_timer_is_suspended(TIMER t);
extern "C" void fl_timer_set_suspended(TIMER t, int s);


extern "C" void fl_timer_draw(TIMER t);
extern "C" int fl_timer_handle(TIMER t, int e);


#endif


