

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Fl_Anim_GIF_Image.H>
#include <FL/Fl_Widget.H>
#include <FL/fl_utf8.h>
#include <stdio.h>
#include <set>
#include "c_fl_anim_gif_image.h"
#include "c_fl_image_check.h"




//  A GIF of one empty screen and no image.  An animation that FLTK would
//  read past what it has for (pofltk 88) loads this instead, which leaves
//  it invalid, failed with ERR_FORMAT and cleared, as any bad file does
//  (Fl_Anim_GIF_Image.cxx:1041-1080).
static const unsigned char no_frames[] = {'G', 'I', 'F', '8', '9', 'a', 1, 0, 1, 0, 0, 0, 0, ';'};

//  A file that can't be read fails with ERR_FORMAT, not ERR_FILE_ACCESS:
//  Fl_Anim_GIF_Image::load sets ERR_FORMAT on any failure, over what
//  Fl_GIF_Image set (Fl_Anim_GIF_Image.cxx:1072-1076, F25), and no_frames
//  is a format failure too.  This puts the access failure back.
//  Fl_Image::ld(int) is protected; a pointer to it may be formed through
//  a derived class.
struct Set_Ld : Fl_Anim_GIF_Image {
    static void to(Fl_Anim_GIF_Image * a, int v) {
        void (Fl_Image::*set)(int) = &Set_Ld::ld;
        (a->*set)(v);
    }
};

static void mark_access(Fl_Anim_GIF_Image * a, const char * f) {
    if (a->valid() || f == 0) {
        return;
    }
    FILE *fp = fl_fopen(f, "rb");
    if (fp == 0) {
        Set_Ld::to(a, Fl_Image::ERR_FILE_ACCESS);
    } else {
        fclose(fp);
    }
}

static bool anim_ok(const char * n, const void * d, size_t s) {
    return d == 0 ? gif_file_ok(n, true) : gif_data_ok(static_cast<const unsigned char*>(d), s,
                                                       true);
}




//  Animations that forget a canvas as it goes

//  Fl_Anim_GIF_Image's private canvas_, reached through an explicit
//  instantiation, which may name a private member ([temp.explicit]).
//  From pofltk's Reach, as in c_fl_tree.cpp.

namespace {

template <class Tag, typename Tag::type M> struct Reach {
    friend typename Tag::type member(Tag) { return M; }
};

struct Canvas_Of {
    typedef Fl_Widget * Fl_Anim_GIF_Image::*type;
    friend type member(Canvas_Of);
};

template struct Reach<Canvas_Of, &Fl_Anim_GIF_Image::canvas_>;

//  The animations that have a canvas.
typedef std::set<Fl_Anim_GIF_Image*> Anim_Set;

Anim_Set & with_canvas() {
    static Anim_Set anims;
    return anims;
}

void note_canvas(Fl_Anim_GIF_Image * a) {
    if (a->canvas() != 0) {
        with_canvas().insert(a);
    } else {
        with_canvas().erase(a);
    }
}

}

//  An animation keeps its canvas's pointer, and its timer sets the frame
//  and redraws the canvas (Fl_Anim_GIF_Image.cxx:1195-1205), so a canvas
//  that goes first would be used after it is freed (pofltk 62).  A widget
//  about to be freed calls this, from fl_widget_forget, and every
//  animation showing in it forgets it.  canvas(0) would clear the image of
//  the widget, which is going anyway.
void anim_gif_canvas_gone(const Fl_Widget * w) {
    Anim_Set & anims = with_canvas();
    for (Anim_Set::iterator it = anims.begin(); it != anims.end(); ) {
        if ((*it)->canvas() == w) {
            (*it)->*member(Canvas_Of()) = 0;
            anims.erase(it++);
        } else {
            ++it;
        }
    }
}

//  An image too large to allocate is 0.
ANIMGIFIMAGE new_fl_anim_gif_image(const char * f, void * c, unsigned short l) {
    try {
        Fl_Anim_GIF_Image *a = anim_ok(f, 0, 0)
            ? new Fl_Anim_GIF_Image(f, static_cast<Fl_Widget*>(c), l)
            : new Fl_Anim_GIF_Image(f, no_frames, sizeof no_frames, static_cast<Fl_Widget*>(c), l);
        mark_access(a, f);
        note_canvas(a);
        return a;
    } catch (...) {
        return 0;
    }
}

ANIMGIFIMAGE new_fl_anim_gif_image2(const char * n, void * d, size_t s,
    void * c, unsigned short l) {
    try {
        const bool ok = anim_ok(n, d, s);
        Fl_Anim_GIF_Image *a = new Fl_Anim_GIF_Image(null_if_empty(n),
            ok ? static_cast<const unsigned char*>(d) : no_frames, ok ? s : sizeof no_frames,
            static_cast<Fl_Widget*>(c), l);
        note_canvas(a);
        return a;
    } catch (...) {
        return 0;
    }
}

ANIMGIFIMAGE new_fl_anim_gif_image3() {
    try {
        return new Fl_Anim_GIF_Image();
    } catch (...) {
        return 0;
    }
}

//  An animation that goes first leaves its canvas showing no image, rather
//  than the freed animation.
void free_fl_anim_gif_image(ANIMGIFIMAGE a) {
    Fl_Anim_GIF_Image *an = static_cast<Fl_Anim_GIF_Image*>(a);
    Fl_Widget *c = an->canvas();
    if (c != 0 && c->image() == an) {
        c->image(0);
    }
    with_canvas().erase(an);
    delete an;
}




int fl_anim_gif_image_get_loop() {
    return Fl_Anim_GIF_Image::loop;
}

void fl_anim_gif_image_set_loop(int v) {
    Fl_Anim_GIF_Image::loop = v != 0;
}

double fl_anim_gif_image_get_min_delay() {
    return Fl_Anim_GIF_Image::min_delay;
}

void fl_anim_gif_image_set_min_delay(double v) {
    Fl_Anim_GIF_Image::min_delay = v;
}

int fl_anim_gif_image_frame_count(const char * n, void * d, size_t s) {
    try {
        if (!anim_ok(n, d, s)) {
            return 0;
        }
        return Fl_Anim_GIF_Image::frame_count(null_if_empty(n),
            static_cast<const unsigned char*>(d), s);
    } catch (...) {
        return 0;
    }
}




//  Memory short for a frame is a load that fails.
int fl_anim_gif_image_load(ANIMGIFIMAGE a, const char * n, void * d, size_t s) {
    Fl_Anim_GIF_Image *an = static_cast<Fl_Anim_GIF_Image*>(a);
    try {
        if (!anim_ok(n, d, s)) {
            an->load(null_if_empty(n), no_frames, sizeof no_frames);
            if (d == 0) {
                mark_access(an, n);
            }
            return 0;
        }
        int ok = an->load(null_if_empty(n), static_cast<const unsigned char*>(d), s);
        if (d == 0) {
            mark_access(an, n);
        }
        return ok;
    } catch (...) {
        an->load(null_if_empty(n), no_frames, sizeof no_frames);
        return 0;
    }
}

int fl_anim_gif_image_valid(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->valid();
}

const char * fl_anim_gif_image_name(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->name();
}




void * fl_anim_gif_image_get_canvas(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->canvas();
}

void fl_anim_gif_image_set_canvas(ANIMGIFIMAGE a, void * c, unsigned short l) {
    static_cast<Fl_Anim_GIF_Image*>(a)->canvas(static_cast<Fl_Widget*>(c), l);
    note_canvas(static_cast<Fl_Anim_GIF_Image*>(a));
}

int fl_anim_gif_image_canvas_w(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->canvas_w();
}

int fl_anim_gif_image_canvas_h(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->canvas_h();
}




int fl_anim_gif_image_frames(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->frames();
}

int fl_anim_gif_image_get_frame(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->frame();
}

void fl_anim_gif_image_set_frame(ANIMGIFIMAGE a, int f) {
    static_cast<Fl_Anim_GIF_Image*>(a)->frame(f);
}

void * fl_anim_gif_image_image(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->image();
}

void * fl_anim_gif_image_image2(ANIMGIFIMAGE a, int f) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->image(f);
}

double fl_anim_gif_image_get_delay(ANIMGIFIMAGE a, int f) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->delay(f);
}

void fl_anim_gif_image_set_delay(ANIMGIFIMAGE a, int f, double v) {
    static_cast<Fl_Anim_GIF_Image*>(a)->delay(f, v);
}

int fl_anim_gif_image_frame_x(ANIMGIFIMAGE a, int f) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->frame_x(f);
}

int fl_anim_gif_image_frame_y(ANIMGIFIMAGE a, int f) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->frame_y(f);
}

int fl_anim_gif_image_frame_w(ANIMGIFIMAGE a, int f) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->frame_w(f);
}

int fl_anim_gif_image_frame_h(ANIMGIFIMAGE a, int f) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->frame_h(f);
}




int fl_anim_gif_image_is_animated(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->is_animated();
}

int fl_anim_gif_image_playing(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->playing();
}

int fl_anim_gif_image_start(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->start();
}

int fl_anim_gif_image_stop(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->stop();
}

int fl_anim_gif_image_next(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->next();
}

double fl_anim_gif_image_get_speed(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->speed();
}

void fl_anim_gif_image_set_speed(ANIMGIFIMAGE a, double v) {
    static_cast<Fl_Anim_GIF_Image*>(a)->speed(v);
}

int fl_anim_gif_image_get_frame_uncache(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->frame_uncache();
}

void fl_anim_gif_image_set_frame_uncache(ANIMGIFIMAGE a, int v) {
    static_cast<Fl_Anim_GIF_Image*>(a)->frame_uncache(v != 0);
}

int fl_anim_gif_image_debug(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->debug();
}




void fl_anim_gif_image_resize(ANIMGIFIMAGE a, int w, int h) {
    static_cast<Fl_Anim_GIF_Image*>(a)->resize(w, h);
}

void fl_anim_gif_image_resize2(ANIMGIFIMAGE a, double s) {
    static_cast<Fl_Anim_GIF_Image*>(a)->resize(s);
}




//  copy starts the copy whenever the original has a frame
//  (Fl_Anim_GIF_Image.cxx:764-765), which a stopped animation also has,
//  and start moves it on a frame.  So a copy of a stopped animation is
//  stopped again, and put back on the original's frame.  pofltk 64.
static Fl_Image * stopped_like(const Fl_Anim_GIF_Image * a, Fl_Image * c) {
    Fl_Anim_GIF_Image * g = dynamic_cast<Fl_Anim_GIF_Image*>(c);
    if (g != 0 && !a->playing() && g->playing()) {
        g->stop();
        if (a->frame() >= 0 && a->frame() < g->frames()) {
            g->frame(a->frame());
        }
    }
    return c;
}

ANIMGIFIMAGE fl_anim_gif_image_copy(ANIMGIFIMAGE a, int w, int h) {
    try {
        Fl_Anim_GIF_Image * g = static_cast<Fl_Anim_GIF_Image*>(a);
        return stopped_like(g, g->copy(w, h));
    } catch (...) {
        return 0;
    }
}

ANIMGIFIMAGE fl_anim_gif_image_copy2(ANIMGIFIMAGE a) {
    try {
        Fl_Anim_GIF_Image * g = static_cast<Fl_Anim_GIF_Image*>(a);
        return stopped_like(g, g->copy());
    } catch (...) {
        return 0;
    }
}




void fl_anim_gif_image_color_average(ANIMGIFIMAGE a, int c, float b) {
    static_cast<Fl_Anim_GIF_Image*>(a)->color_average(c, b);
}

void fl_anim_gif_image_desaturate(ANIMGIFIMAGE a) {
    static_cast<Fl_Anim_GIF_Image*>(a)->desaturate();
}

void fl_anim_gif_image_uncache(ANIMGIFIMAGE a) {
    static_cast<Fl_Anim_GIF_Image*>(a)->uncache();
}




void fl_anim_gif_image_draw(ANIMGIFIMAGE a, int x, int y, int w, int h,
    int cx, int cy) {
    static_cast<Fl_Anim_GIF_Image*>(a)->draw(x, y, w, h, cx, cy);
}


