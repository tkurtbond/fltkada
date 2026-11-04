

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Tiled_Image.H>
#include <FL/Fl_Image.H>
#include <FL/Fl_Shared_Image.H>
#include <new>
#include "c_fl_tiled_image.h"




//  Tiles the tiled images own

namespace {

//  Fl_Tiled_Image's protected image_ and alloc_image_, reached through a
//  class derived from it.
struct Tiled_Parts : public Fl_Tiled_Image {
    static int owns(Fl_Tiled_Image * t) {
        return t->*(&Tiled_Parts::alloc_image_);
    }
    static void give(Fl_Tiled_Image * t, Fl_Image * i) {
        t->*(&Tiled_Parts::image_) = i;
        t->*(&Tiled_Parts::alloc_image_) = 1;
    }
};

//  A private copy of image i, drawn at i's size, as Fl_Tiled_Image's
//  color_average makes one (Fl_Tiled_Image.cxx:94-98).  A shared image's
//  copy is the pool's entry (Fl_Shared_Image.cxx:374-379), so the image it
//  shares is copied instead (pofltk's unpooled).  0 if it can't be made.
Fl_Image * own_copy(Fl_Image * i) {
    const Fl_Image *from = i;
    Fl_Shared_Image *s = dynamic_cast<Fl_Shared_Image*>(i);
    if (s != 0) {
        from = s->image();
    }
    if (from == 0) {
        return 0;
    }
    Fl_Image *c = 0;
    try {
        c = from->copy(from->data_w(), from->data_h());
    } catch (...) {
        return 0;
    }
    if (c != 0) {
        c->scale(i->w(), i->h(), 0, 1);
    }
    return c;
}

//  A tiled image of w by h that owns a private copy of tile i.
TILEDIMAGE owning_tiled(Fl_Image * i, int w, int h) {
    Fl_Image *own = own_copy(i);
    if (own == 0) {
        return 0;
    }
    Fl_Tiled_Image *t = new (std::nothrow) Fl_Tiled_Image(own, w, h);
    if (t == 0) {
        delete own;
        return 0;
    }
    Tiled_Parts::give(t, own);
    return t;
}

}

//  Fl_Tiled_Image keeps its tile's pointer, and color_average and
//  desaturate change it for a copy they own; a shared image's copy would be
//  the pool's entry, changed for every user and deleted while still in the
//  pool (pofltk 84).  So a shared tile is copied here first.  0 if the
//  tiled image can't be made.
TILEDIMAGE new_fl_tiled_image(void * i, int w, int h) {
    Fl_Image *tile = static_cast<Fl_Image*>(i);
    if (dynamic_cast<Fl_Shared_Image*>(tile) != 0) {
        return owning_tiled(tile, w, h);
    }
    return new (std::nothrow) Fl_Tiled_Image(tile, w, h);
}

void free_fl_tiled_image(TILEDIMAGE t) {
    delete static_cast<Fl_Tiled_Image*>(t);
}

//  Fl_Tiled_Image::copy tiles the same image, which an original that owns
//  it deletes as it goes, so the copy of such an original owns a copy of
//  the tile.  0 if the copy can't be made.
TILEDIMAGE fl_tiled_image_copy(TILEDIMAGE t, int w, int h) {
    Fl_Tiled_Image *from = static_cast<Fl_Tiled_Image*>(t);
    if (Tiled_Parts::owns(from)) {
        return owning_tiled(from->image(), w, h);
    }
    try {
        //  virtual so disable dispatch
        return from->Fl_Tiled_Image::copy(w, h);
    } catch (...) {
        return 0;
    }
}

TILEDIMAGE fl_tiled_image_copy2(TILEDIMAGE t) {
    Fl_Tiled_Image *from = static_cast<Fl_Tiled_Image*>(t);
    return fl_tiled_image_copy(t, from->w(), from->h());
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


