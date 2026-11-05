

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Pixmap.H>
#include <stdio.h>
#include <string.h>
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




int fl_pixmap_line_count(PIXMAP p) {
    Fl_Pixmap * x = static_cast<Fl_Pixmap*>(p);
    return x->data() == 0 ? 0 : x->count();
}

//  The length of line i, from 0, or -1 if there is no such line.  The
//  lines are XPM's, and FLTK reads as much of a line as the header line
//  says, not up to a 0.  A GIF's lines are in FLTK's compressed form,
//  whose second line is 4 bytes a color, any of which but the index can
//  be 0 (Fl_GIF_Image.cxx:432-463, fl_draw_pixmap.cxx:84-171).
int fl_pixmap_line_length(PIXMAP p, int i) {
    Fl_Pixmap * x = static_cast<Fl_Pixmap*>(p);
    const char * const * d = x->data();
    if (d == 0 || i < 0 || i >= x->count()) {
        return -1;
    }
    int w, h, ncolors, cpp;
    if (i == 0 || sscanf(d[0], "%d%d%d%d", &w, &h, &ncolors, &cpp) < 4
        || w <= 0 || h <= 0 || ncolors == 0 || (cpp != 1 && cpp != 2))
    {
        return static_cast<int>(strlen(d[i]));
    }
    if (ncolors < 0) {
        return i == 1 ? -ncolors * 4 : w * cpp;
    }
    return i <= ncolors ? static_cast<int>(strlen(d[i])) : w * cpp;
}

const char * fl_pixmap_line(PIXMAP p, int i) {
    return static_cast<Fl_Pixmap*>(p)->data()[i];
}

void fl_pixmap_draw2(PIXMAP b, int x, int y) {
    static_cast<Fl_Pixmap*>(b)->draw(x, y);
}

void fl_pixmap_draw(PIXMAP b, int x, int y, int w, int h, int cx, int cy) {
    //  virtual so disable dispatch
    static_cast<Fl_Pixmap*>(b)->Fl_Pixmap::draw(x, y, w, h, cx, cy);
}

