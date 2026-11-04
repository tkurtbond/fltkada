

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_RGB_Image.H>
#include <FL/Fl_Pixmap.H>
#include <cstring>
#include <new>
#include "c_fl_rgb_image.h"




//  Fl_RGB_Image keeps the pointer it is given (Fl_Image.cxx:374-384), so it
//  is given a copy, which it owns (FLTKAda-BUGS.md 48).  The Ada side has
//  checked that data holds h rows of ld, or w * d, bytes.  Returns null
//  when out of memory.
RGBIMAGE new_fl_rgb_image(void *data, int w, int h, int d, int ld) {
    size_t row = ld ? static_cast<size_t>(ld) : static_cast<size_t>(w) * d;
    size_t n = row * h;
    uchar *copy = 0;
    if (n > 0) {
        copy = new (std::nothrow) uchar[n];
        if (copy == 0) {
            return 0;
        }
        std::memcpy(copy, data, n);
    }
    Fl_RGB_Image *rgb = new (std::nothrow) Fl_RGB_Image(copy, w, h, d, ld);
    if (rgb == 0) {
        delete[] copy;
        return 0;
    }
    rgb->alloc_array = copy != 0;
    return rgb;
}

RGBIMAGE new_fl_rgb_image2(void *pix, unsigned int c) {
    try {
        Fl_RGB_Image *rgb = new Fl_RGB_Image(static_cast<Fl_Pixmap*>(pix), c);
        return rgb;
    } catch (...) {
        return 0;
    }
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
    try {
        //  virtual so disable dispatch
        return static_cast<Fl_RGB_Image*>(i)->Fl_RGB_Image::copy(w, h);
    } catch (...) {
        return 0;
    }
}

RGBIMAGE fl_rgb_image_copy2(RGBIMAGE i) {
    try {
        return static_cast<Fl_RGB_Image*>(i)->copy();
    } catch (...) {
        return 0;
    }
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


