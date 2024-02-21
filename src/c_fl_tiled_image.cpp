

#include <FL/Fl_Tiled_Image.H>
#include <FL/Fl_Image.H>
#include "c_fl_tiled_image.h"




TILED_IMAGE new_fl_tiled_image(void * i, int w, int h) {
    Fl_Tiled_Image *t = new Fl_Tiled_Image(reinterpret_cast<Fl_Image*>(i), w, h);
    return t;
}

void free_fl_tiled_image(TILED_IMAGE t) {
    delete reinterpret_cast<Fl_Tiled_Image*>(t);
}

TILED_IMAGE fl_tiled_image_copy(TILED_IMAGE t, int w, int h) {
    //  virtual so disable dispatch
    return reinterpret_cast<Fl_Tiled_Image*>(t)->Fl_Tiled_Image::copy(w, h);
}

TILED_IMAGE fl_tiled_image_copy2(TILED_IMAGE t) {
    return reinterpret_cast<Fl_Tiled_Image*>(t)->copy();
}




void * fl_tiled_image_get_image(TILED_IMAGE t) {
    return reinterpret_cast<Fl_Tiled_Image*>(t)->image();
}




void fl_tiled_image_color_average(TILED_IMAGE t, int c, float b) {
    //  virtual so disable dispatch
    reinterpret_cast<Fl_Tiled_Image*>(t)->Fl_Tiled_Image::color_average(c, b);
}

void fl_tiled_image_desaturate(TILED_IMAGE t) {
    //  virtual so disable dispatch
    reinterpret_cast<Fl_Tiled_Image*>(t)->Fl_Tiled_Image::desaturate();
}




void fl_tiled_image_draw(TILED_IMAGE t, int x, int y) {
    reinterpret_cast<Fl_Tiled_Image*>(t)->draw(x, y);
}

void fl_tiled_image_draw2(TILED_IMAGE t, int x, int y, int w, int h, int cx, int cy) {
    //  virtual so disable dispatch
    reinterpret_cast<Fl_Tiled_Image*>(t)->Fl_Tiled_Image::draw(x, y, w, h, cx, cy);
}


