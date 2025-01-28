

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_PNG_Image.H>
#include "c_fl_png_image.h"




PNGIMAGE new_fl_png_image(const char * f) {
    Fl_PNG_Image *p = new Fl_PNG_Image(f);
    return p;
}

PNGIMAGE new_fl_png_image2(const char *name, void *data, int size) {
    Fl_PNG_Image *p = new Fl_PNG_Image(name, static_cast<uchar*>(data), size);
    return p;
}

void free_fl_png_image(PNGIMAGE p) {
    delete static_cast<Fl_PNG_Image*>(p);
}


