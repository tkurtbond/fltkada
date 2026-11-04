

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_XPM_Image.H>
#include "c_fl_xpm_image.h"




XPMIMAGE new_fl_xpm_image(const char * f) {
    try {
        Fl_XPM_Image *j = new Fl_XPM_Image(f);
        return j;
    } catch (...) {
        return 0;
    }
}

void free_fl_xpm_image(XPMIMAGE j) {
    delete static_cast<Fl_XPM_Image*>(j);
}


