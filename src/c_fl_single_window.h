

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_SINGLE_WINDOW_GUARD
#define FL_SINGLE_WINDOW_GUARD


typedef void* SINGLEWINDOW;


extern "C" SINGLEWINDOW new_fl_single_window(int x, int y, int w, int h, char* label);
extern "C" SINGLEWINDOW new_fl_single_window2(int x, int y, char* label);
extern "C" void free_fl_single_window(SINGLEWINDOW w);


extern "C" void fl_single_window_show(SINGLEWINDOW w);
extern "C" void fl_single_window_flush(SINGLEWINDOW w);


extern "C" void fl_single_window_make_current(SINGLEWINDOW w);


extern "C" void fl_single_window_draw(SINGLEWINDOW n);
extern "C" int fl_single_window_handle(SINGLEWINDOW n, int e);


#endif


