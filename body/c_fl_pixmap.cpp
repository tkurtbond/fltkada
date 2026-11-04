

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Pixmap.H>
#include "c_fl_pixmap.h"




PIXMAP new_fl_pixmap(void * d) {
    try {
        Fl_Pixmap *p = new Fl_Pixmap(static_cast<char**>(d));
        return p;
    } catch (...) {
        return 0;
    }
}

void free_fl_pixmap(PIXMAP b) {
    delete static_cast<Fl_Pixmap*>(b);
}




PIXMAP fl_pixmap_copy(PIXMAP b, int w, int h) {
    try {
        //  virtual so disable dispatch
        return static_cast<Fl_Pixmap*>(b)->Fl_Pixmap::copy(w, h);
    } catch (...) {
        return 0;
    }
}

PIXMAP fl_pixmap_copy2(PIXMAP b) {
    try {
        return static_cast<Fl_Pixmap*>(b)->copy();
    } catch (...) {
        return 0;
    }
}




void fl_pixmap_color_average(PIXMAP p, int c, float b) {
    //  virtual so disable dispatch
    static_cast<Fl_Pixmap*>(p)->Fl_Pixmap::color_average(c, b);
}

void fl_pixmap_desaturate(PIXMAP p) {
    //  virtual so disable dispatch
    static_cast<Fl_Pixmap*>(p)->Fl_Pixmap::desaturate();
}




void fl_pixmap_uncache(PIXMAP p) {
    //  virtual so disable dispatch
    static_cast<Fl_Pixmap*>(p)->Fl_Pixmap::uncache();
}




void fl_pixmap_draw2(PIXMAP b, int x, int y) {
    static_cast<Fl_Pixmap*>(b)->draw(x, y);
}

void fl_pixmap_draw(PIXMAP b, int x, int y, int w, int h, int cx, int cy) {
    //  virtual so disable dispatch
    static_cast<Fl_Pixmap*>(b)->Fl_Pixmap::draw(x, y, w, h, cx, cy);
}

