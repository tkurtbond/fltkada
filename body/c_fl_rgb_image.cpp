

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_RGB_Image.H>
#include <FL/Fl_Pixmap.H>
#include "c_fl_rgb_image.h"




RGBIMAGE new_fl_rgb_image(void *data, int w, int h, int d, int ld) {
    Fl_RGB_Image *rgb = new Fl_RGB_Image(static_cast<uchar*>(data), w, h, d, ld);
    return rgb;
}

RGBIMAGE new_fl_rgb_image2(void *pix, unsigned int c) {
    Fl_RGB_Image *rgb = new Fl_RGB_Image(static_cast<Fl_Pixmap*>(pix), c);
    return rgb;
}

void free_fl_rgb_image(RGBIMAGE i) {
    delete static_cast<Fl_RGB_Image*>(i);
}

size_t fl_rgb_image_get_max_size() {
    return Fl_RGB_Image::max_size();
}

void fl_rgb_image_set_max_size(size_t v) {
    Fl_RGB_Image::max_size(v);
}

RGBIMAGE fl_rgb_image_copy(RGBIMAGE i, int w, int h) {
    //  virtual so disable dispatch
    return static_cast<Fl_RGB_Image*>(i)->Fl_RGB_Image::copy(w, h);
}

RGBIMAGE fl_rgb_image_copy2(RGBIMAGE i) {
    return static_cast<Fl_RGB_Image*>(i)->copy();
}




void fl_rgb_image_color_average(RGBIMAGE i, int c, float b) {
    //  virtual so disable dispatch
    static_cast<Fl_RGB_Image*>(i)->Fl_RGB_Image::color_average(c, b);
}

void fl_rgb_image_desaturate(RGBIMAGE i) {
    //  virtual so disable dispatch
    static_cast<Fl_RGB_Image*>(i)->Fl_RGB_Image::desaturate();
}




void fl_rgb_image_uncache(RGBIMAGE i) {
    //  virtual so disable dispatch
    static_cast<Fl_RGB_Image*>(i)->Fl_RGB_Image::uncache();
}




const void * fl_rgb_image_data(RGBIMAGE i) {
    return static_cast<const void*>(static_cast<Fl_RGB_Image*>(i)->array);
}




void fl_rgb_image_draw2(RGBIMAGE i, int x, int y) {
    static_cast<Fl_RGB_Image*>(i)->draw(x, y);
}

void fl_rgb_image_draw(RGBIMAGE i, int x, int y, int w, int h, int cx, int cy) {
    //  virtual so disable dispatch
    static_cast<Fl_RGB_Image*>(i)->Fl_RGB_Image::draw(x, y, w, h, cx, cy);
}


