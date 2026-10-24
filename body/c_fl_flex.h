

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#ifndef FL_FLEX_GUARD
#define FL_FLEX_GUARD


typedef void* FLEX;


extern "C" FLEX new_fl_flex(int x, int y, int w, int h, char * label);
extern "C" FLEX new_fl_flex2(int x, int y, int w, int h, int d);
extern "C" FLEX new_fl_flex3(int w, int h, int d);
extern "C" FLEX new_fl_flex4(int d);
extern "C" void free_fl_flex(FLEX f);


extern "C" void fl_flex_end(FLEX f);
extern "C" void fl_flex_layout(FLEX f);
extern "C" int fl_flex_get_need_layout(FLEX f);
extern "C" void fl_flex_set_need_layout(FLEX f, int s);


extern "C" void fl_flex_set_fixed(FLEX f, void * w, int s);
extern "C" int fl_flex_is_fixed(FLEX f, void * w);


extern "C" int fl_flex_get_margin(FLEX f);
extern "C" int fl_flex_get_margins(FLEX f, int * l, int * t, int * r, int * b);
extern "C" void fl_flex_set_margin(FLEX f, int m, int g);
extern "C" void fl_flex_set_margins(FLEX f, int l, int t, int r, int b);
extern "C" int fl_flex_get_gap(FLEX f);
extern "C" void fl_flex_set_gap(FLEX f, int g);
extern "C" int fl_flex_get_spacing(FLEX f);
extern "C" void fl_flex_set_spacing(FLEX f, int s);
extern "C" int fl_flex_horizontal(FLEX f);


extern "C" void fl_flex_draw(FLEX n);
extern "C" int fl_flex_handle(FLEX n, int e);


#endif


