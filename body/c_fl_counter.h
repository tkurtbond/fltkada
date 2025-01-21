

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_COUNTER_GUARD
#define FL_COUNTER_GUARD


typedef void* COUNTER;


extern "C" COUNTER new_fl_counter(int x, int y, int w, int h, char* label);
extern "C" void free_fl_counter(COUNTER c);


extern "C" double fl_counter_get_step(COUNTER c);
extern "C" void fl_counter_set_step_top(COUNTER c, double t);
extern "C" void fl_counter_set_lstep(COUNTER c, double t);
extern "C" void fl_counter_set_step_both(COUNTER c, double s, double l);


extern "C" unsigned int fl_counter_get_textcolor(COUNTER c);
extern "C" void fl_counter_set_textcolor(COUNTER c, unsigned int t);
extern "C" int fl_counter_get_textfont(COUNTER c);
extern "C" void fl_counter_set_textfont(COUNTER c, int t);
extern "C" int fl_counter_get_textsize(COUNTER c);
extern "C" void fl_counter_set_textsize(COUNTER c, int t);


extern "C" void fl_counter_draw(COUNTER c);
extern "C" int fl_counter_handle(COUNTER c, int e);


#endif


