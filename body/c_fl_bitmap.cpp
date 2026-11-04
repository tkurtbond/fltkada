

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Bitmap.H>
#include <cstring>
#include <new>
#include "c_fl_bitmap.h"




//  Fl_Bitmap keeps the pointer it is given (Fl_Bitmap.H:48-49), so it is
//  given a copy, which it owns (FLTKAda-BUGS.md 48).  The Ada side has
//  checked that data holds h rows of (w + 7) / 8 bytes.  Returns null when
//  out of memory.
BITMAP new_fl_bitmap(void *data, int w, int h) {
    size_t n = static_cast<size_t>((w + 7) / 8) * h;
    uchar *copy = 0;
    if (n > 0) {
        copy = new (std::nothrow) uchar[n];
        if (copy == 0) {
            return 0;
        }
        std::memcpy(copy, data, n);
    }
    Fl_Bitmap *b = new (std::nothrow) Fl_Bitmap(copy, w, h);
    if (b == 0) {
        delete[] copy;
        return 0;
    }
    b->alloc_array = copy != 0;
    return b;
}

void free_fl_bitmap(BITMAP b) {
    delete static_cast<Fl_Bitmap*>(b);
}

BITMAP fl_bitmap_copy(BITMAP b, int w, int h) {
    try {
        //  virtual so disable dispatch
        return static_cast<Fl_Bitmap*>(b)->Fl_Bitmap::copy(w, h);
    } catch (...) {
        return 0;
    }
}

BITMAP fl_bitmap_copy2(BITMAP b) {
    try {
        return static_cast<Fl_Bitmap*>(b)->copy();
    } catch (...) {
        return 0;
    }
}




void fl_bitmap_uncache(BITMAP b) {
    // virtual so disable dispatch
    static_cast<Fl_Bitmap*>(b)->Fl_Bitmap::uncache();
}




const void * fl_bitmap_data(BITMAP b) {
    return static_cast<const void*>(static_cast<Fl_Bitmap*>(b)->array);
}




void fl_bitmap_draw2(BITMAP b, int x, int y) {
    static_cast<Fl_Bitmap*>(b)->draw(x, y);
}

void fl_bitmap_draw(BITMAP b, int x, int y, int w, int h, int cx, int cy) {
    // virtual so disable dispatch
    static_cast<Fl_Bitmap*>(b)->Fl_Bitmap::draw(x, y, w, h, cx, cy);
}


