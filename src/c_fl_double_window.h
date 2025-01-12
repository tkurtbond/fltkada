

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_DOUBLE_WINDOW_GUARD
#define FL_DOUBLE_WINDOW_GUARD


typedef void* DOUBLEWINDOW;


extern "C" DOUBLEWINDOW new_fl_double_window(int x, int y, int w, int h, char* label);
extern "C" DOUBLEWINDOW new_fl_double_window2(int w, int h, char* label);
extern "C" void free_fl_double_window(DOUBLEWINDOW d);


extern "C" void fl_double_window_show(DOUBLEWINDOW d);
extern "C" void fl_double_window_show2(DOUBLEWINDOW d, int c, void * v);
extern "C" void fl_double_window_hide(DOUBLEWINDOW d);
extern "C" void fl_double_window_flush(DOUBLEWINDOW d);
extern "C" void fl_double_window_flush2(DOUBLEWINDOW d, int e);


extern "C" void fl_double_window_resize(DOUBLEWINDOW d, int x, int y, int w, int h);


extern "C" void fl_double_window_draw(DOUBLEWINDOW n);
extern "C" int fl_double_window_handle(DOUBLEWINDOW n, int e);


#endif


