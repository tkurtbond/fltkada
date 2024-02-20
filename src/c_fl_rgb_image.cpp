

#include <FL/Fl_RGB_Image.H>
#include <FL/Fl_Pixmap.H>
#include "c_fl_rgb_image.h"




RGB_IMAGE new_fl_rgb_image(void *data, int w, int h, int d, int ld) {
    Fl_RGB_Image *rgb = new Fl_RGB_Image(reinterpret_cast<uchar*>(data), w, h, d, ld);
    return rgb;
}

RGB_IMAGE new_fl_rgb_image2(void *pix, unsigned int c) {
    Fl_RGB_Image *rgb = new Fl_RGB_Image(reinterpret_cast<Fl_Pixmap*>(pix), c);
    return rgb;
}

void free_fl_rgb_image(RGB_IMAGE i) {
    delete reinterpret_cast<Fl_RGB_Image*>(i);
}

size_t fl_rgb_image_get_max_size() {
    return Fl_RGB_Image::max_size();
}

void fl_rgb_image_set_max_size(size_t v) {
    Fl_RGB_Image::max_size(v);
}

RGB_IMAGE fl_rgb_image_copy(RGB_IMAGE i, int w, int h) {
    //  virtual so disable dispatch
    return reinterpret_cast<Fl_RGB_Image*>(i)->Fl_RGB_Image::copy(w, h);
}

RGB_IMAGE fl_rgb_image_copy2(RGB_IMAGE i) {
    return reinterpret_cast<Fl_RGB_Image*>(i)->copy();
}




void fl_rgb_image_color_average(RGB_IMAGE i, int c, float b) {
    //  virtual so disable dispatch
    reinterpret_cast<Fl_RGB_Image*>(i)->Fl_RGB_Image::color_average(c, b);
}

void fl_rgb_image_desaturate(RGB_IMAGE i) {
    //  virtual so disable dispatch
    reinterpret_cast<Fl_RGB_Image*>(i)->Fl_RGB_Image::desaturate();
}




void fl_rgb_image_uncache(RGB_IMAGE i) {
    //  virtual so disable dispatch
    reinterpret_cast<Fl_RGB_Image*>(i)->Fl_RGB_Image::uncache();
}




void fl_rgb_image_draw2(RGB_IMAGE i, int x, int y) {
    reinterpret_cast<Fl_RGB_Image*>(i)->draw(x, y);
}

void fl_rgb_image_draw(RGB_IMAGE i, int x, int y, int w, int h, int cx, int cy) {
    //  virtual so disable dispatch
    reinterpret_cast<Fl_RGB_Image*>(i)->Fl_RGB_Image::draw(x, y, w, h, cx, cy);
}


