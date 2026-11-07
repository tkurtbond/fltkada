

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FL_CAIRO_DRAWN_WINDOW_GUARD
#define FL_CAIRO_DRAWN_WINDOW_GUARD


typedef void* CAIRODRAWNWINDOW;


extern "C" int fl_cairo_drawn_window_supported();


extern "C" CAIRODRAWNWINDOW new_fl_cairo_drawn_window(int x, int y, int w, int h, char* label);
extern "C" CAIRODRAWNWINDOW new_fl_cairo_drawn_window2(int w, int h, char* label);
extern "C" void free_fl_cairo_drawn_window(CAIRODRAWNWINDOW d);


extern "C" void fl_cairo_drawn_window_draw(CAIRODRAWNWINDOW n);
extern "C" int fl_cairo_drawn_window_handle(CAIRODRAWNWINDOW n, int e);


#endif

