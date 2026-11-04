

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_PNG_Image.H>
#include "c_fl_png_image.h"
#include "c_fl_image_check.h"




PNGIMAGE new_fl_png_image(const char * f) {
    try {
        Fl_PNG_Image *p = new Fl_PNG_Image(f);
        return p;
    } catch (...) {
        return 0;
    }
}

PNGIMAGE new_fl_png_image2(const char *name, void *data, int size) {
    try {
        Fl_PNG_Image *p = new Fl_PNG_Image(null_if_empty(name), static_cast<uchar*>(data), size);
        return p;
    } catch (...) {
        return 0;
    }
}

void free_fl_png_image(PNGIMAGE p) {
    delete_unless_pooled(static_cast<Fl_PNG_Image*>(p));
}


