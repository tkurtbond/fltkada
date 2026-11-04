

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_BMP_Image.H>
#include "c_fl_bmp_image.h"
#include "c_fl_image_check.h"




//  A header FLTK would write past what it has for fails with ERR_FORMAT
//  (pofltk 87).  An image too large to allocate is 0.
BMPIMAGE new_fl_bmp_image(const char * f) {
    try {
        if (!bmp_file_ok(f)) {
            Fl_BMP_Image *b = new Fl_BMP_Image(0, static_cast<const unsigned char*>(0), 0);
            set_image_fail(b, Fl_Image::ERR_FORMAT);
            return b;
        }
        return new Fl_BMP_Image(f);
    } catch (...) {
        return 0;
    }
}

void free_fl_bmp_image(BMPIMAGE b) {
    delete static_cast<Fl_BMP_Image*>(b);
}


