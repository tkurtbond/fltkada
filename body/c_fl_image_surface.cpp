

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Image_Surface.H>
#include <FL/Fl_RGB_Image.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Window.H>
#include <FL/fl_draw.H>
#include "c_fl_image_surface.h"




//  Remembers a mask that image() hasn't used yet.  A second mask() before
//  image() loses the first's state, a leak, and image() and the destructor
//  are the only things that free it (pofltk 137).

class My_Image_Surface : public Fl_Image_Surface {
public:
    My_Image_Surface(int w, int h, int r) : Fl_Image_Surface(w, h, r), masked(false) {}
    bool masked;
};




//  Flattened C API

IMAGESURFACE new_fl_image_surface(int w, int h, int r) {
    My_Image_Surface *s = new My_Image_Surface(w,h,r);
    return s;
}

void free_fl_image_surface(IMAGESURFACE s) {
    delete static_cast<My_Image_Surface*>(s);
}




void fl_image_surface_draw(IMAGESURFACE s, void * w, int dx, int dy) {
    static_cast<Fl_Image_Surface*>(s)->draw(static_cast<Fl_Widget*>(w),dx,dy);
}

void fl_image_surface_draw_decorated_window(IMAGESURFACE s, void * w, int dx, int dy) {
    static_cast<Fl_Image_Surface*>(s)->draw_decorated_window(static_cast<Fl_Window*>(w),dx,dy);
}




void * fl_image_surface_image(IMAGESURFACE s) {
    static_cast<My_Image_Surface*>(s)->masked = false;
    return static_cast<My_Image_Surface*>(s)->image();
}

void * fl_image_surface_highres_image(IMAGESURFACE s) {
    static_cast<My_Image_Surface*>(s)->masked = false;
    return static_cast<My_Image_Surface*>(s)->highres_image();
}




//  0 if done; 1 if m isn't 3 bytes a pixel, which both FLTK's mask readers
//  take it as, reading past a smaller one (pofltk 137); 2 if s is current,
//  which FLTK's documentation forbids; 3 if a mask hasn't been used by
//  image() yet.
int fl_image_surface_mask(IMAGESURFACE s, void * m) {
    My_Image_Surface *surface = static_cast<My_Image_Surface*>(s);
    const Fl_RGB_Image *mask = static_cast<Fl_RGB_Image*>(m);
    if (mask->d() != 3) {
        return 1;
    } else if (surface->is_current()) {
        return 2;
    } else if (surface->masked) {
        return 3;
    }
    surface->mask(mask);
    surface->masked = true;
    return 0;
}

//  rescale() calls image(), and so uses a mask, then frees the platform
//  surface, which the caller makes sure is neither current nor on FLTK's
//  stack of surfaces.
void fl_image_surface_rescale(IMAGESURFACE s) {
    static_cast<My_Image_Surface*>(s)->masked = false;
    static_cast<My_Image_Surface*>(s)->rescale();
}

//  For FLTK.Draw.Offscreens: what s holds, copied to the current surface.
void fl_image_surface_copy_offscreen(IMAGESURFACE s, int x, int y, int w, int h,
        int sx, int sy) {
    fl_copy_offscreen(x, y, w, h, static_cast<Fl_Image_Surface*>(s)->offscreen(), sx, sy);
}




void fl_image_surface_set_current(IMAGESURFACE s) {
    static_cast<Fl_Image_Surface*>(s)->set_current();
}


