

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_JPEG_Image.H>
#include "c_fl_jpeg_image.h"




JPEGIMAGE new_fl_jpeg_image(const char * f) {
    Fl_JPEG_Image *j = new Fl_JPEG_Image(f);
    return j;
}

JPEGIMAGE new_fl_jpeg_image2(const char *n, void *data) {
    Fl_JPEG_Image *j = new Fl_JPEG_Image(n, static_cast<uchar*>(data));
    return j;
}

void free_fl_jpeg_image(JPEGIMAGE j) {
    delete static_cast<Fl_JPEG_Image*>(j);
}

