

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Bitmap.H>
#include "c_fl_bitmap.h"




BITMAP new_fl_bitmap(void *data, int w, int h) {
    Fl_Bitmap *b = new Fl_Bitmap(reinterpret_cast<uchar*>(data), w, h);
    return b;
}

void free_fl_bitmap(BITMAP b) {
    delete reinterpret_cast<Fl_Bitmap*>(b);
}

BITMAP fl_bitmap_copy(BITMAP b, int w, int h) {
    //  virtual so disable dispatch
    return reinterpret_cast<Fl_Bitmap*>(b)->Fl_Bitmap::copy(w, h);
}

BITMAP fl_bitmap_copy2(BITMAP b) {
    return reinterpret_cast<Fl_Bitmap*>(b)->copy();
}




void fl_bitmap_uncache(BITMAP b) {
    // virtual so disable dispatch
    reinterpret_cast<Fl_Bitmap*>(b)->Fl_Bitmap::uncache();
}




void fl_bitmap_draw2(BITMAP b, int x, int y) {
    reinterpret_cast<Fl_Bitmap*>(b)->draw(x, y);
}

void fl_bitmap_draw(BITMAP b, int x, int y, int w, int h, int cx, int cy) {
    // virtual so disable dispatch
    reinterpret_cast<Fl_Bitmap*>(b)->Fl_Bitmap::draw(x, y, w, h, cx, cy);
}

