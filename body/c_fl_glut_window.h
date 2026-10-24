

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#ifndef FL_GLUT_WINDOW_GUARD
#define FL_GLUT_WINDOW_GUARD


typedef void* GLUTWINDOW;


extern "C" GLUTWINDOW new_fl_glut_window(int x, int y, int w, int h, char* label);
extern "C" GLUTWINDOW new_fl_glut_window2(int w, int h, char* label);
extern "C" void free_fl_glut_window(GLUTWINDOW w);


extern "C" int fl_glut_window_get_number(GLUTWINDOW w);
extern "C" int fl_glut_window_get_menu(GLUTWINDOW w, int b);
extern "C" void fl_glut_window_set_menu(GLUTWINDOW w, int b, int m);
extern "C" void fl_glut_window_make_current(GLUTWINDOW w);


extern "C" void fl_glut_window_draw(GLUTWINDOW n);
extern "C" int fl_glut_window_handle(GLUTWINDOW n, int e);


#endif


