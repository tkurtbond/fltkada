

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#ifndef FL_GL_GUARD
#define FL_GL_GUARD


extern "C" int fl_gl_can_start();
extern "C" int fl_gl_start();
extern "C" int fl_gl_finish();
extern "C" int fl_gl_ready();


extern "C" void fl_gl_color(unsigned int c);
extern "C" void fl_gl_rect(int x, int y, int w, int h);
extern "C" void fl_gl_rectf(int x, int y, int w, int h);


extern "C" void fl_gl_font(int f, int s);
extern "C" int fl_gl_height();
extern "C" int fl_gl_descent();
extern "C" double fl_gl_width(const char * str, int n);
extern "C" double fl_gl_width2(unsigned char c);


extern "C" void fl_gl_draw(const char * str, int n);
extern "C" void fl_gl_draw2(const char * str, int n, int x, int y);
extern "C" void fl_gl_draw3(const char * str, int n, float x, float y);
extern "C" void fl_gl_draw4(const char * str, int x, int y, int w, int h, unsigned short a);
extern "C" void fl_gl_measure(const char * str, int &x, int &y);


extern "C" void fl_gl_set_texture_pile_height(int max);
extern "C" int fl_gl_get_texture_pile_height();
extern "C" void fl_gl_texture_reset();


extern "C" void fl_gl_draw_image(void * data, int x, int y, int w, int h, int d, int l);


#endif


