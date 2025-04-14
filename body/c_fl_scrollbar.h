

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_SCROLLBAR_GUARD
#define FL_SCROLLBAR_GUARD


extern "C" void fl_scrollbar_extra_init
    (void * adaobj, int x, int y, int w, int h, const char * label);


typedef void* SCROLLBAR;


extern "C" SCROLLBAR new_fl_scrollbar(int x, int y, int w, int h, char* label);
extern "C" void free_fl_scrollbar(SCROLLBAR s);


extern "C" int fl_scrollbar_get_linesize(SCROLLBAR s);
extern "C" void fl_scrollbar_set_linesize(SCROLLBAR s, int t);
extern "C" int fl_scrollbar_get_value(SCROLLBAR s);
extern "C" void fl_scrollbar_set_value(SCROLLBAR s, int t);
extern "C" void fl_scrollbar_set_value2(SCROLLBAR s, int p, int w, int f, int t);


extern "C" void fl_scrollbar_draw(SCROLLBAR s);
extern "C" int fl_scrollbar_handle(SCROLLBAR s, int e);


#endif


