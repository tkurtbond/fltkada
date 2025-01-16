

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_XPM_Image.H>
#include "c_fl_xpm_image.h"




XPMIMAGE new_fl_xpm_image(const char * f) {
    Fl_XPM_Image *j = new Fl_XPM_Image(f);
    return j;
}

void free_fl_xpm_image(XPMIMAGE j) {
    delete static_cast<Fl_XPM_Image*>(j);
}


