

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_GIF_Image.H>
#include "c_fl_gif_image.h"
#include "c_fl_image_check.h"




//  A GIF FLTK would write past what it has for fails with ERR_FORMAT
//  (pofltk 88).  An image too large to allocate is 0.
static Fl_GIF_Image * refused_gif() {
    Fl_GIF_Image *j = new Fl_GIF_Image(0, static_cast<const unsigned char*>(0), 0);
    set_image_fail(j, Fl_Image::ERR_FORMAT);
    return j;
}

GIFIMAGE new_fl_gif_image(const char * f) {
    try {
        if (!gif_file_ok(f, false)) {
            return refused_gif();
        }
        return new Fl_GIF_Image(f);
    } catch (...) {
        return 0;
    }
}

GIFIMAGE new_fl_gif_image2(const char * n, void * d, size_t l) {
    const unsigned char *data = static_cast<const unsigned char*>(d);
    try {
        if (!gif_data_ok(data, l, false)) {
            return refused_gif();
        }
        return new Fl_GIF_Image((n == 0 || *n == '\0') ? 0 : n, data, l);
    } catch (...) {
        return 0;
    }
}

void free_fl_gif_image(GIFIMAGE j) {
    delete static_cast<Fl_GIF_Image*>(j);
}




int fl_gif_image_get_animate() {
    return Fl_GIF_Image::animate;
}

void fl_gif_image_set_animate(int a) {
    Fl_GIF_Image::animate = a != 0;
}

//  It loads the animation (Fl_Anim_GIF_Image.cxx:1025), so it is checked
//  first (pofltk 88).
int fl_gif_image_is_animated(const char * f) {
    try {
        return gif_file_ok(f, true) && Fl_GIF_Image::is_animated(f);
    } catch (...) {
        return 0;
    }
}


