

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_PNM_Image.H>
#include "c_fl_pnm_image.h"




PNMIMAGE new_fl_pnm_image(const char * f) {
    Fl_PNM_Image *p = new Fl_PNM_Image(f);
    return p;
}

void free_fl_pnm_image(PNMIMAGE p) {
    delete static_cast<Fl_PNM_Image*>(p);
}

