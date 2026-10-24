

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Shared_Image.H>
#include <FL/Fl_RGB_Image.H>
#include "c_fl_shared_image.h"




SHAREDIMAGE fl_shared_image_get(const char * f, int w, int h) {
    return Fl_Shared_Image::get(f, w, h);
}

SHAREDIMAGE fl_shared_image_get2(void * r) {
    return Fl_Shared_Image::get(static_cast<Fl_RGB_Image*>(r), 0);
}

SHAREDIMAGE fl_shared_image_find(const char * n, int w, int h) {
    return Fl_Shared_Image::find(n, w, h);
}

void fl_shared_image_release(SHAREDIMAGE i) {
    static_cast<Fl_Shared_Image*>(i)->release();
}

SHAREDIMAGE fl_shared_image_copy(SHAREDIMAGE i, int w, int h) {
    //  virtual so disable dispatch
    return static_cast<Fl_Shared_Image*>(i)->Fl_Shared_Image::copy(w, h);
}

SHAREDIMAGE fl_shared_image_copy2(SHAREDIMAGE i) {
    return static_cast<Fl_Shared_Image*>(i)->copy();
}




void fl_shared_image_color_average(SHAREDIMAGE i, int c, float b) {
    //  virtual so disable dispatch
    static_cast<Fl_Shared_Image*>(i)->Fl_Shared_Image::color_average(c, b);
}

void fl_shared_image_desaturate(SHAREDIMAGE i) {
    //  virtual so disable dispatch
    static_cast<Fl_Shared_Image*>(i)->Fl_Shared_Image::desaturate();
}




int fl_shared_image_num_images() {
    return Fl_Shared_Image::num_images();
}

const char * fl_shared_image_name(SHAREDIMAGE i) {
    return static_cast<Fl_Shared_Image*>(i)->name();
}

int fl_shared_image_original(SHAREDIMAGE i) {
    return static_cast<Fl_Shared_Image*>(i)->original();
}

int fl_shared_image_refcount(SHAREDIMAGE i) {
    return static_cast<Fl_Shared_Image*>(i)->refcount();
}

void fl_shared_image_reload(SHAREDIMAGE i) {
    static_cast<Fl_Shared_Image*>(i)->reload();
}

void fl_shared_image_uncache(SHAREDIMAGE i) {
    //  virtual so disable dispatch
    static_cast<Fl_Shared_Image*>(i)->uncache();
}




void fl_shared_image_scaling_algorithm(int v) {
    Fl_Shared_Image::scaling_algorithm(static_cast<Fl_RGB_Scaling>(v));
}

void fl_shared_image_scale(SHAREDIMAGE i, int w, int h, int p, int e) {
    static_cast<Fl_Shared_Image*>(i)->scale(w, h, p, e);
}

void fl_shared_image_draw(SHAREDIMAGE i, int x, int y, int w, int h, int cx, int cy) {
    //  virtual so disable dispatch
    static_cast<Fl_Shared_Image*>(i)->Fl_Shared_Image::draw(x, y, w, h, cx, cy);
}

void fl_shared_image_draw2(SHAREDIMAGE i, int x, int y) {
    static_cast<Fl_Shared_Image*>(i)->draw(x, y);
}




void fl_shared_image_register_images() {
    fl_register_images();
}


