

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_GRAPHICS_DRIVER_GUARD
#define FL_GRAPHICS_DRIVER_GUARD


typedef void* GRAPHICSDRIVER;


extern "C" unsigned int fl_graphics_driver_color(GRAPHICSDRIVER g);


extern "C" int fl_graphics_driver_descent(GRAPHICSDRIVER g);
extern "C" int fl_graphics_driver_height(GRAPHICSDRIVER g);
extern "C" double fl_graphics_driver_width(GRAPHICSDRIVER g, unsigned int c);
extern "C" double fl_graphics_driver_width2(GRAPHICSDRIVER g, const char * s, int l);
extern "C" int fl_graphics_driver_get_font(GRAPHICSDRIVER g);
extern "C" int fl_graphics_driver_size(GRAPHICSDRIVER g);
extern "C" void fl_graphics_driver_set_font(GRAPHICSDRIVER g, int f, int s);


extern "C" void fl_graphics_driver_draw_scaled(GRAPHICSDRIVER g, void * i,
    int x, int y, int w, int h);


#endif


