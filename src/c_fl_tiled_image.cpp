

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Tiled_Image.H>
#include <FL/Fl_Image.H>
#include "c_fl_tiled_image.h"




TILEDIMAGE new_fl_tiled_image(void * i, int w, int h) {
    Fl_Tiled_Image *t = new Fl_Tiled_Image(static_cast<Fl_Image*>(i), w, h);
    return t;
}

void free_fl_tiled_image(TILEDIMAGE t) {
    delete static_cast<Fl_Tiled_Image*>(t);
}

TILEDIMAGE fl_tiled_image_copy(TILEDIMAGE t, int w, int h) {
    //  virtual so disable dispatch
    return static_cast<Fl_Tiled_Image*>(t)->Fl_Tiled_Image::copy(w, h);
}

TILEDIMAGE fl_tiled_image_copy2(TILEDIMAGE t) {
    return static_cast<Fl_Tiled_Image*>(t)->copy();
}




void * fl_tiled_image_get_image(TILEDIMAGE t) {
    return static_cast<Fl_Tiled_Image*>(t)->image();
}




void fl_tiled_image_color_average(TILEDIMAGE t, int c, float b) {
    //  virtual so disable dispatch
    static_cast<Fl_Tiled_Image*>(t)->Fl_Tiled_Image::color_average(c, b);
}

void fl_tiled_image_desaturate(TILEDIMAGE t) {
    //  virtual so disable dispatch
    static_cast<Fl_Tiled_Image*>(t)->Fl_Tiled_Image::desaturate();
}




void fl_tiled_image_draw(TILEDIMAGE t, int x, int y) {
    static_cast<Fl_Tiled_Image*>(t)->draw(x, y);
}

void fl_tiled_image_draw2(TILEDIMAGE t, int x, int y, int w, int h, int cx, int cy) {
    //  virtual so disable dispatch
    static_cast<Fl_Tiled_Image*>(t)->Fl_Tiled_Image::draw(x, y, w, h, cx, cy);
}


