

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_GIF_Image.H>
#include "c_fl_gif_image.h"




GIFIMAGE new_fl_gif_image(const char * f) {
    Fl_GIF_Image *j = new Fl_GIF_Image(f);
    return j;
}

void free_fl_gif_image(GIFIMAGE j) {
    delete static_cast<Fl_GIF_Image*>(j);
}


