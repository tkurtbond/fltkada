

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Shared_Image.H>
#include <FL/Fl_RGB_Image.H>
#include "c_fl_shared_image.h"
#include "c_fl_image_check.h"
#include <FL/Fl_XBM_Image.H>
#include <FL/Fl_PNM_Image.H>
#include "c_fl_pnm_image.h"




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

//  The protected image_, alloc_image_ and update, named through a derived
//  class, as members of Fl_Shared_Image, which any Fl_Shared_Image has.
struct Shared_Inside : Fl_Shared_Image {
    static void put(Fl_Shared_Image * s, Fl_Image * i) {
        Fl_Image * Fl_Shared_Image::*image = &Shared_Inside::image_;
        int Fl_Shared_Image::*alloc = &Shared_Inside::alloc_image_;
        void (Fl_Shared_Image::*sync)() = &Shared_Inside::update;
        if (s->*alloc) {
            delete (s->*image);
        }
        s->*image = i;
        s->*alloc = 1;
        (s->*sync)();
    }
    //  One more reference to s, which release gives back.
    static void take(Fl_Shared_Image * s) {
        int Fl_Shared_Image::*count = &Shared_Inside::refcount_;
        ++(s->*count);
    }
};

//  A file that has gone bad, as above, is left as it was.  reload puts the
//  file's image, at the file's size, in an entry scaled from it
//  (Fl_Shared_Image.cxx:277-321), but the pool is sorted and searched by
//  data size (:95-105, 498-520), so the entry gets a copy at its own size
//  back.  pofltk 83.
void fl_shared_image_reload(SHAREDIMAGE i) {
    Fl_Shared_Image *s = static_cast<Fl_Shared_Image*>(i);
    try {
        if (shared_file_ok(s->name())) {
            int dw = s->data_w(), dh = s->data_h();
            s->reload();
            own_xbm(s);
            if (!s->original() && s->image() != 0
                && (s->data_w() != dw || s->data_h() != dh))
            {
                Fl_Image *c = s->image()->copy(dw, dh);
                if (c != 0 && c->data_w() == dw && c->data_h() == dh) {
                    Shared_Inside::put(s, c);
                } else {
                    delete c;
                }
            }
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

//  fl_register_images' handler, fl_check_images, loads a PNM with
//  Fl_PNM_Image, which doesn't scale a binary one with a maxval under 255
//  (pofltk 45).  This handler loads a P5 or P6 and scales it.  It is added
//  at elaboration, so it comes before fl_check_images, which FLTK adds when
//  fl_register_images is first called, by FLTKAda or by FLTK itself
//  (Fl_Help_Dialog.cxx:207, Fl_File_Icon2.cxx:651), since Fl_Shared_Image
//  tries its handlers in the order they were added
//  (Fl_Shared_Image.cxx:297-304).  Until fl_register_images is called it
//  loads nothing, as FLTK would.
static Fl_Image * scaled_pnm_handler(const char * name, uchar * header, int headerlen) {
    if (!Fl_Image::register_images_done || headerlen < 2 || header[0] != 'P'
        || (header[1] != '5' && header[1] != '6'))
    {
        return 0;
    }
    try {
        Fl_PNM_Image * p = new Fl_PNM_Image(name);
        pnm_scale_samples(p, name);
        return p;
    } catch (...) {
        return 0;
    }
}

void fl_shared_image_add_pnm_handler() {
    Fl_Shared_Image::add_handler(&scaled_pnm_handler);
}

//  FLTK.Images.Shared.Add_Handler's list, in Ada, which answers with the
//  Fl_Image of an Ada image, or 0.  pofltk 95.
extern "C" void * shared_image_ask_hook(const char * name, const unsigned char * header, int n);

//  The program's handlers, which are one handler to FLTK.  The pool gets a
//  copy of the image a handler gives, at its size, so that stays the
//  program's: FLTK deletes what a handler returns with the pool's entry
//  (Fl_Shared_Image.cxx:306-316).  A shared image is copied from its
//  image, since a copy of a Fl_Shared_Image is another of the pool's
//  entries (:374-379).
static Fl_Image * ada_handler(const char * name, uchar * header, int headerlen) {
    Fl_Image *given = static_cast<Fl_Image*>(shared_image_ask_hook(name, header, headerlen));
    if (given == 0) {
        return 0;
    }
    try {
        const Fl_Image *from = given;
        if (Fl_Shared_Image *s = dynamic_cast<Fl_Shared_Image*>(given)) {
            from = s->image();
        }
        if (from == 0) {
            return 0;
        }
        Fl_Image *c = from->copy();
        if (c != 0) {
            c->scale(given->w(), given->h(), 0, 1);
        }
        return c;
    } catch (...) {
        return 0;
    }
}

//  FLTK ignores a handler it has already (Fl_Shared_Image.cxx:656-659).
void fl_shared_image_add_ada_handler() {
    Fl_Shared_Image::add_handler(&ada_handler);
}

int fl_shared_image_pool_count() {
    return Fl_Shared_Image::num_images();
}

//  The pool's entry k, with a reference for the caller.
SHAREDIMAGE fl_shared_image_pool_take(int k) {
    if (k < 0 || k >= Fl_Shared_Image::num_images()) {
        return 0;
    }
    Fl_Shared_Image *s = Fl_Shared_Image::images()[k];
    Shared_Inside::take(s);
    return s;
}


