

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_COPY_SURFACE_GUARD
#define FL_COPY_SURFACE_GUARD


typedef void* COPYSURFACE;


extern "C" COPYSURFACE new_fl_copy_surface(int w, int h);
extern "C" void free_fl_copy_surface(COPYSURFACE c);


extern "C" int fl_copy_surface_get_w(COPYSURFACE c);
extern "C" int fl_copy_surface_get_h(COPYSURFACE c);


extern "C" void fl_copy_surface_draw(COPYSURFACE c, void * w, int dx, int dy);
extern "C" void fl_copy_surface_draw_decorated_window(COPYSURFACE c, void * w, int dx, int dy);


extern "C" void fl_copy_surface_set_current(COPYSURFACE c);


#endif


