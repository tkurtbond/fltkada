

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_WINDOW_GUARD
#define FL_WINDOW_GUARD


typedef void* WINDOW;


extern "C" WINDOW new_fl_window(int x, int y, int w, int h, char* label);
extern "C" WINDOW new_fl_window2(int w, int h, char* label);
extern "C" void free_fl_window(WINDOW n);


extern "C" void fl_window_show(WINDOW n);
extern "C" void fl_window_show2(WINDOW n, int c, void * v);
extern "C" void fl_window_hide(WINDOW n);
extern "C" int fl_window_shown(WINDOW n);
extern "C" void fl_window_wait_for_expose(WINDOW n);
extern "C" void fl_window_iconize(WINDOW n);
extern "C" int fl_window_make_current(WINDOW n);


extern "C" unsigned int fl_window_fullscreen_active(WINDOW n);
extern "C" void fl_window_fullscreen(WINDOW n);
extern "C" void fl_window_fullscreen_off(WINDOW n);
extern "C" void fl_window_maximize(WINDOW n);
extern "C" void fl_window_un_maximize(WINDOW n);
extern "C" int fl_window_maximize_active(WINDOW n);
extern "C" void fl_window_fullscreen_off2(WINDOW n, int x, int y, int w, int h);
extern "C" void fl_window_fullscreen_screens(WINDOW n, int t, int b, int l, int r);


extern "C" void fl_window_set_icon(WINDOW n, void * img);
extern "C" void fl_window_icons(WINDOW n, void * imgs, int count);
extern "C" void fl_window_default_icon(void * img);
extern "C" void fl_window_default_icons(void * imgs, int count);
extern "C" const char * fl_window_get_iconlabel(WINDOW n);
extern "C" void fl_window_set_iconlabel(WINDOW n, const char * s);
extern "C" void fl_window_set_cursor(WINDOW n, int c);
extern "C" void fl_window_set_cursor2(WINDOW n, void * img, int x, int y);
extern "C" void fl_window_set_default_cursor(WINDOW n, int c);


extern "C" unsigned int fl_window_get_border(WINDOW n);
extern "C" void fl_window_set_border(WINDOW n, int b);
extern "C" void fl_window_clear_border(WINDOW n);
extern "C" unsigned int fl_window_get_override(WINDOW n);
extern "C" void fl_window_set_override(WINDOW n);
extern "C" unsigned int fl_window_modal(WINDOW n);
extern "C" unsigned int fl_window_non_modal(WINDOW n);
extern "C" void fl_window_set_modal(WINDOW n);
extern "C" void fl_window_set_non_modal(WINDOW n);
extern "C" void fl_window_clear_modal_states(WINDOW n);


extern "C" const char * fl_window_get_label(WINDOW n);
extern "C" void fl_window_copy_label(WINDOW n, char* text);
extern "C" void fl_window_hotspot(WINDOW n, int x, int y, int s);
extern "C" void fl_window_hotspot2(WINDOW n, void * i, int s);
extern "C" int fl_window_shape(WINDOW n, void * p);


extern "C" void fl_window_size_range(WINDOW n, int lw, int lh, int hw, int hh, int dw, int dh, int a);
extern "C" void fl_window_resize(WINDOW n, int x, int y, int w, int h);
extern "C" int fl_window_get_force_position(WINDOW n);
extern "C" void fl_window_set_force_position(WINDOW n, int s);
extern "C" void fl_window_free_position(WINDOW n);
extern "C" int fl_window_get_size_range(WINDOW n, int * v);
extern "C" int fl_window_get_screen_num(WINDOW n);
extern "C" void fl_window_set_screen_num(WINDOW n, int s);
extern "C" int fl_window_get_x_root(WINDOW n);
extern "C" int fl_window_get_y_root(WINDOW n);
extern "C" int fl_window_get_decorated_w(WINDOW n);
extern "C" int fl_window_get_decorated_h(WINDOW n);


extern "C" const char * fl_window_get_xclass(WINDOW n);
extern "C" void fl_window_set_xclass(WINDOW n, const char * c);
extern "C" const char * fl_window_get_default_xclass();
extern "C" void fl_window_set_default_xclass(const char * c);
extern "C" unsigned int fl_window_menu_window(WINDOW n);
extern "C" unsigned int fl_window_tooltip_window(WINDOW n);


extern "C" void fl_window_draw(WINDOW n);
extern "C" void fl_window_flush(WINDOW n);
extern "C" int fl_window_handle(WINDOW n, int e);




//  C++ linkage, for the other window shims

class Fl_Window;

//  Frees the copy of the shape image kept for a window.  Each window
//  shim's My_ class calls it from its destructor.
void window_shape_gone(const Fl_Window * w);


#endif


