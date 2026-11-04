

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_CAIRO_WINDOW_GUARD
#define FL_CAIRO_WINDOW_GUARD


typedef void* CAIROWINDOW;


extern "C" CAIROWINDOW new_fl_cairo_window(int w, int h);
extern "C" void free_fl_cairo_window(CAIROWINDOW w);


extern "C" int fl_cairo_window_supported();
extern "C" void fl_cairo_window_set_draw_cb(CAIROWINDOW w, void * cb);


extern "C" void fl_cairo_window_draw(CAIROWINDOW w);
extern "C" int fl_cairo_window_handle(CAIROWINDOW w, int e);


#endif


