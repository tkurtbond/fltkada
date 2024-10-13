

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_PNG_Image.H>
#include "c_fl_png_image.h"




PNG_IMAGE new_fl_png_image(const char * f) {
    Fl_PNG_Image *p = new Fl_PNG_Image(f);
    return p;
}

PNG_IMAGE new_fl_png_image2(const char *name, void *data, int size) {
    Fl_PNG_Image *p = new Fl_PNG_Image(name, reinterpret_cast<uchar*>(data), size);
    return p;
}

void free_fl_png_image(PNG_IMAGE p) {
    delete reinterpret_cast<Fl_PNG_Image*>(p);
}

