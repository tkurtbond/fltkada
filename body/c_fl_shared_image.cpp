

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Shared_Image.H>
#include <FL/Fl_RGB_Image.H>
#include "c_fl_shared_image.h"
#include "c_fl_image_check.h"
#include <FL/Fl_XBM_Image.H>




//  A file whose header FLTK would write past what it has for isn't read
//  (pofltk 87, 88), and gives 0 as one FLTK can't read does.  So does
//  memory too short for the image.
namespace {

//  Fl_Shared_Image::reload reads an XBM with Fl_XBM_Image (Fl_Shared_Image.cxx:297),
//  which allocates the bits and leaves alloc_array 0 (Fl_XBM_Image.cxx:76-77),
//  so Fl_Bitmap never deletes them (Fl_Bitmap.cxx:104).  Every shared XBM
//  leaked (pofltk 81).
void own_xbm(Fl_Shared_Image * s) {
    if (s == 0) {
        return;
    }
    Fl_XBM_Image *x = dynamic_cast<Fl_XBM_Image*>(const_cast<Fl_Image*>(s->image()));
    if (x != 0 && x->array != 0 && x->alloc_array == 0) {
        x->alloc_array = 1;
    }
}

}

//  The original, which get (0, 0) returns (Fl_Shared_Image.cxx:579-602),
//  is held while it is owned and the size asked for is got.
SHAREDIMAGE fl_shared_image_get(const char * f, int w, int h) {
    try {
        if (Fl_Shared_Image::find(f, w, h) == 0 && !shared_file_ok(f)) {
            return 0;
        }
        Fl_Shared_Image *original = Fl_Shared_Image::get(f, 0, 0);
        if (original == 0) {
            return 0;
        }
        own_xbm(original);
        Fl_Shared_Image *result = Fl_Shared_Image::get(f, w, h);
        original->release();
        return result;
    } catch (...) {
        return 0;
    }
}

SHAREDIMAGE fl_shared_image_get2(void * r) {
    try {
        //  A copy, which the pool owns: the image given may go first
        //  (Fl_Shared_Image.cxx:629-635), as pofltk shares it.
        Fl_RGB_Image *c = static_cast<Fl_RGB_Image*>(static_cast<Fl_RGB_Image*>(r)->copy());
        if (c == 0) {
            return 0;
        }
        return Fl_Shared_Image::get(c, 1);
    } catch (...) {
        return 0;
    }
}

SHAREDIMAGE fl_shared_image_find(const char * n, int w, int h) {
    return Fl_Shared_Image::find(n, w, h);
}

void fl_shared_image_release(SHAREDIMAGE i) {
    static_cast<Fl_Shared_Image*>(i)->release();
}

SHAREDIMAGE fl_shared_image_copy(SHAREDIMAGE i, int w, int h) {
    try {
        //  virtual so disable dispatch
        return static_cast<Fl_Shared_Image*>(i)->Fl_Shared_Image::copy(w, h);
    } catch (...) {
        return 0;
    }
}

SHAREDIMAGE fl_shared_image_copy2(SHAREDIMAGE i) {
    try {
        return static_cast<Fl_Shared_Image*>(i)->copy();
    } catch (...) {
        return 0;
    }
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

//  A file that has gone bad, as above, is left as it was.
void fl_shared_image_reload(SHAREDIMAGE i) {
    Fl_Shared_Image *s = static_cast<Fl_Shared_Image*>(i);
    try {
        if (shared_file_ok(s->name())) {
            s->reload();
            own_xbm(s);
        }
    } catch (...) {
    }
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


