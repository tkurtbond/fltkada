

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_GIF_Image.H>
#include "c_fl_gif_image.h"




GIFIMAGE new_fl_gif_image(const char * f) {
    Fl_GIF_Image *j = new Fl_GIF_Image(f);
    return j;
}

GIFIMAGE new_fl_gif_image2(const char * n, void * d, size_t l) {
    Fl_GIF_Image *j = new Fl_GIF_Image((n == 0 || *n == '\0') ? 0 : n,
        static_cast<const unsigned char*>(d), l);
    return j;
}

void free_fl_gif_image(GIFIMAGE j) {
    delete static_cast<Fl_GIF_Image*>(j);
}




int fl_gif_image_get_animate() {
    return Fl_GIF_Image::animate;
}

void fl_gif_image_set_animate(int a) {
    Fl_GIF_Image::animate = a != 0;
}

int fl_gif_image_is_animated(const char * f) {
    return Fl_GIF_Image::is_animated(f);
}


