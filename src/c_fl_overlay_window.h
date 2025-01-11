

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_OVERLAY_WINDOW_GUARD
#define FL_OVERLAY_WINDOW_GUARD


typedef void* OVERLAYWINDOW;


extern "C" OVERLAYWINDOW new_fl_overlay_window(int x, int y, int w, int h, char *label);
extern "C" OVERLAYWINDOW new_fl_overlay_window2(int w, int h, char *label);
extern "C" void free_fl_overlay_window(OVERLAYWINDOW w);


extern "C" int fl_overlay_window_can_do_overlay(OVERLAYWINDOW w);
extern "C" void fl_overlay_window_resize(OVERLAYWINDOW ow, int x, int y, int w, int h);


extern "C" void fl_overlay_window_show(OVERLAYWINDOW w);
extern "C" void fl_overlay_window_hide(OVERLAYWINDOW w);
extern "C" void fl_overlay_window_flush(OVERLAYWINDOW w);


extern "C" void fl_overlay_window_redraw_overlay(OVERLAYWINDOW w);
extern "C" void fl_overlay_window_draw(OVERLAYWINDOW w);
extern "C" int fl_overlay_window_handle(OVERLAYWINDOW w, int e);


#endif


