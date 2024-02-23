

#ifndef FL_GL_WINDOW_GUARD
#define FL_GL_WINDOW_GUARD




typedef void* GLWINDOW;




extern "C" void gl_window_set_draw_hook(GLWINDOW n, void * d);
extern "C" void fl_gl_window_draw(GLWINDOW n);
extern "C" void gl_window_set_handle_hook(GLWINDOW n, void * h);
extern "C" int fl_gl_window_handle(GLWINDOW n, int e);




extern "C" GLWINDOW new_fl_gl_window(int x, int y, int w, int h, char* label);
extern "C" GLWINDOW new_fl_gl_window2(int w, int h, char* label);
extern "C" void free_fl_gl_window(GLWINDOW w);




extern "C" void fl_gl_window_show(GLWINDOW w);
extern "C" void fl_gl_window_hide(GLWINDOW w);
extern "C" void fl_gl_window_hide_overlay(GLWINDOW w);
extern "C" void fl_gl_window_flush(GLWINDOW w);


extern "C" int fl_gl_window_pixel_h(GLWINDOW w);
extern "C" int fl_gl_window_pixel_w(GLWINDOW w);
extern "C" float fl_gl_window_pixels_per_unit(GLWINDOW w);


extern "C" unsigned int fl_gl_window_get_mode(GLWINDOW w);
extern "C" void fl_gl_window_set_mode(GLWINDOW w, unsigned int a);
extern "C" int fl_gl_window_static_can_do(unsigned int m);
extern "C" int fl_gl_window_can_do(GLWINDOW w);
extern "C" int fl_gl_window_can_do_overlay(GLWINDOW w);


extern "C" void * fl_gl_window_get_context(GLWINDOW w);
extern "C" void fl_gl_window_set_context(GLWINDOW w, void * con, int des);
extern "C" char fl_gl_window_context_valid(GLWINDOW w);
extern "C" void fl_gl_window_set_context_valid(GLWINDOW w, char v);
extern "C" char fl_gl_window_valid(GLWINDOW w);
extern "C" void fl_gl_window_set_valid(GLWINDOW w, char v);
extern "C" void fl_gl_window_make_current(GLWINDOW w);
extern "C" void fl_gl_window_make_overlay_current(GLWINDOW w);


extern "C" void fl_gl_window_ortho(GLWINDOW w);
extern "C" void fl_gl_window_redraw_overlay(GLWINDOW w);
extern "C" void fl_gl_window_swap_buffers(GLWINDOW w);


#endif

