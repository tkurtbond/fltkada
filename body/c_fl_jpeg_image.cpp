

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_JPEG_Image.H>
#include "c_fl_jpeg_image.h"
#include "c_fl_image_check.h"




JPEGIMAGE new_fl_jpeg_image(const char * f) {
    try {
        Fl_JPEG_Image *j = new Fl_JPEG_Image(f);
        return j;
    } catch (...) {
        return 0;
    }
}

//  Without a length FLTK reads 4096 bytes at a time past the end of data,
//  and doesn't free its source (Fl_JPEG_Image.cxx:163-169, 193-194, 304-305).
JPEGIMAGE new_fl_jpeg_image2(const char *n, void *data, int size) {
    try {
        Fl_JPEG_Image *j = new Fl_JPEG_Image(null_if_empty(n), static_cast<uchar*>(data), size);
        return j;
    } catch (...) {
        return 0;
    }
}

void free_fl_jpeg_image(JPEGIMAGE j) {
    delete_unless_pooled(static_cast<Fl_JPEG_Image*>(j));
}

