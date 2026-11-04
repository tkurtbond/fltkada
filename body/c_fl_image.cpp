

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Image.H>
#include "c_fl_image.h"




//  Enums, macros, and constants

const int fl_image_err_no_image    = Fl_Image::ERR_NO_IMAGE;
const int fl_image_err_file_access = Fl_Image::ERR_FILE_ACCESS;
const int fl_image_err_format      = Fl_Image::ERR_FORMAT;




//  Non-friend protected access

class Friend_Image : Fl_Image {
public:
    using Fl_Image::draw_empty;
};




//  Flattened C API

IMAGE new_fl_image(int w, int h, int d) {
    try {
        Fl_Image *i = new Fl_Image(w, h, d);
        return i;
    } catch (...) {
        return 0;
    }
}

void free_fl_image(IMAGE i) {
    delete static_cast<Fl_Image*>(i);
}




int fl_image_get_rgb_scaling() {
    return Fl_Image::RGB_scaling();
}

void fl_image_set_rgb_scaling(int t) {
    Fl_Image::RGB_scaling(static_cast<Fl_RGB_Scaling>(t));
}

int fl_image_get_scaling_algorithm() {
    return Fl_Image::scaling_algorithm();
}

void fl_image_set_scaling_algorithm(int t) {
    Fl_Image::scaling_algorithm(static_cast<Fl_RGB_Scaling>(t));
}

IMAGE fl_image_copy(IMAGE i, int w, int h) {
    try {
        //  virtual so disable dispatch
        return static_cast<Fl_Image*>(i)->Fl_Image::copy(w, h);
    } catch (...) {
        return 0;
    }
}

IMAGE fl_image_copy2(IMAGE i) {
    try {
        return static_cast<Fl_Image*>(i)->copy();
    } catch (...) {
        return 0;
    }
}




void fl_image_color_average(IMAGE i, int c, float b) {
    //  virtual so disable dispatch
    static_cast<Fl_Image*>(i)->Fl_Image::color_average(c, b);
}

void fl_image_desaturate(IMAGE i) {
    //  virtual so disable dispatch
    static_cast<Fl_Image*>(i)->Fl_Image::desaturate();
}




void fl_image_inactive(IMAGE i) {
    static_cast<Fl_Image*>(i)->inactive();
}

int fl_image_fail(IMAGE i) {
    return static_cast<Fl_Image*>(i)->fail();
}

void fl_image_uncache(IMAGE i) {
    //  virtual so disable dispatch
    static_cast<Fl_Image*>(i)->Fl_Image::uncache();
}




int fl_image_w(IMAGE i) {
    return static_cast<Fl_Image*>(i)->w();
}

int fl_image_h(IMAGE i) {
    return static_cast<Fl_Image*>(i)->h();
}

int fl_image_d(IMAGE i) {
    return static_cast<Fl_Image*>(i)->d();
}

int fl_image_ld(IMAGE i) {
    return static_cast<Fl_Image*>(i)->ld();
}

void fl_image_scale(IMAGE i, int w, int h, int p, int e) {
    static_cast<Fl_Image*>(i)->scale(w, h, p, e);
}




const void * fl_image_data(IMAGE i) {
    return static_cast<Fl_Image*>(i)->data();
}

int fl_image_count(IMAGE i) {
    return static_cast<Fl_Image*>(i)->count();
}




void fl_image_draw(IMAGE i, int x, int y) {
    static_cast<Fl_Image*>(i)->draw(x, y);
}

void fl_image_draw2(IMAGE i, int x, int y, int w, int h, int cx, int cy) {
    //  virtual so disable dispatch
    static_cast<Fl_Image*>(i)->Fl_Image::draw(x, y, w, h, cx, cy);
}

void fl_image_draw_empty(IMAGE i, int x, int y) {
    (static_cast<Fl_Image*>(i)->*(&Friend_Image::draw_empty))(x, y);
}


