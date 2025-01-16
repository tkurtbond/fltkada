

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Copy_Surface.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Window.H>
#include "c_fl_copy_surface.h"




//  Flattened C API

COPYSURFACE new_fl_copy_surface(int w, int h) {
    Fl_Copy_Surface *c = new Fl_Copy_Surface(w,h);
    return c;
}

void free_fl_copy_surface(COPYSURFACE c) {
    delete static_cast<Fl_Copy_Surface*>(c);
}




int fl_copy_surface_get_w(COPYSURFACE c) {
    return static_cast<Fl_Copy_Surface*>(c)->w();
}

int fl_copy_surface_get_h(COPYSURFACE c) {
    return static_cast<Fl_Copy_Surface*>(c)->h();
}




void fl_copy_surface_draw(COPYSURFACE c, void * w, int dx, int dy) {
    static_cast<Fl_Copy_Surface*>(c)->draw(static_cast<Fl_Widget*>(w),dx,dy);
}

void fl_copy_surface_draw_decorated_window(COPYSURFACE c, void * w, int dx, int dy) {
    static_cast<Fl_Copy_Surface*>(c)->draw_decorated_window(static_cast<Fl_Window*>(w),dx,dy);
}




void fl_copy_surface_set_current(COPYSURFACE c) {
    static_cast<Fl_Copy_Surface*>(c)->set_current();
}


