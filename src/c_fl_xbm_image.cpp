

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_XBM_Image.H>
#include "c_fl_xbm_image.h"




XBMIMAGE new_fl_xbm_image(const char * f) {
    Fl_XBM_Image *b = new Fl_XBM_Image(f);
    return b;
}

void free_fl_xbm_image(XBMIMAGE b) {
    delete static_cast<Fl_XBM_Image*>(b);
}


