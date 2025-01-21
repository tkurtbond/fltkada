

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Image_Surface.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Window.H>
#include "c_fl_image_surface.h"




//  Flattened C API

IMAGESURFACE new_fl_image_surface(int w, int h, int r) {
    Fl_Image_Surface *s = new Fl_Image_Surface(w,h,r);
    return s;
}

void free_fl_image_surface(IMAGESURFACE s) {
    delete static_cast<Fl_Image_Surface*>(s);
}




void fl_image_surface_draw(IMAGESURFACE s, void * w, int dx, int dy) {
    static_cast<Fl_Image_Surface*>(s)->draw(static_cast<Fl_Widget*>(w),dx,dy);
}

void fl_image_surface_draw_decorated_window(IMAGESURFACE s, void * w, int dx, int dy) {
    static_cast<Fl_Image_Surface*>(s)->draw_decorated_window(static_cast<Fl_Window*>(w),dx,dy);
}




void * fl_image_surface_image(IMAGESURFACE s) {
    return static_cast<Fl_Image_Surface*>(s)->image();
}

void * fl_image_surface_highres_image(IMAGESURFACE s) {
    return static_cast<Fl_Image_Surface*>(s)->highres_image();
}




void fl_image_surface_set_current(IMAGESURFACE s) {
    static_cast<Fl_Image_Surface*>(s)->set_current();
}


