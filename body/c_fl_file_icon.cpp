

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#include <FL/Fl.H>
#include <FL/Fl_Anim_GIF_Image.H>
#include <FL/Fl_File_Browser.H>
#include <FL/Fl_File_Icon.H>
#include <FL/Fl_Pixmap.H>
#include <FL/Fl_RGB_Image.H>
#include <FL/Fl_Shared_Image.H>
#ifdef FLTK_USE_SVG
#include <FL/Fl_SVG_Image.H>
#endif
#include <FL/Fl_Widget.H>
#include <FL/filename.H>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include "c_fl_file_icon.h"
#include "c_fl_shared_image.h"




//  Fl_File_Icon keeps the pattern's pointer and never frees it
//  (Fl_File_Icon.cxx:71), so an icon made from Ada keeps a copy.

class My_File_Icon : public Fl_File_Icon {
public:
    My_File_Icon(char * p, int t) : Fl_File_Icon(p, t), copy(p) {}
    ~My_File_Icon() { std::free(copy); }
private:
    char *copy;
};




//  Loading

static int icon_errors = 0;

static void count_error(const char *, ...) {
    ++icon_errors;
}

//  Adds the polygon for the pixels x0 to x1 of row y of an image w by h, in
//  color c, as Fl_File_Icon::load_image does (Fl_File_Icon2.cxx:364-373).
static void add_run(Fl_File_Icon * f, Fl_Color c, int x0, int x1, int y, int w, int h) {
    f->add_color(c);
    f->add(Fl_File_Icon::POLYGON);
    f->add_vertex(x0 * 9000 / w + 1000, 9500 - y * 9000 / h);
    f->add_vertex(x1 * 9000 / w + 1000, 9500 - y * 9000 / h);
    f->add_vertex(x1 * 9000 / w + 1000, 9500 - (y + 1) * 9000 / h);
    f->add_vertex(x0 * 9000 / w + 1000, 9500 - (y + 1) * 9000 / h);
    f->add(Fl_File_Icon::END);
}

//  Adds r's rows to f, each run of one color a polygon, as
//  Fl_File_Icon::load_image does for an image of one data array
//  (Fl_File_Icon2.cxx:325-385).  A pixel of alpha 127 or under isn't drawn.
static void add_rows(Fl_File_Icon * f, const Fl_RGB_Image * r) {
    const Fl_Color none = static_cast<Fl_Color>(-1);
    const int w = r->data_w(), h = r->data_h(), d = r->d();
    const int ld = r->ld() ? r->ld() : w * d;
    for (int y = 0; y < h; y++) {
        const unsigned char *row = r->array + y * ld;
        int start = 0;
        Fl_Color c = none;
        for (int x = 0; x <= w; x++) {
            Fl_Color t = none;
            if (x < w) {
                const unsigned char *p = row + x * d;
                const int alpha = d == 2 ? p[1] : d == 4 ? p[3] : 255;
                if (alpha > 127) {
                    t = d <= 2 ? fl_rgb_color(p[0], p[0], p[0]) : fl_rgb_color(p[0], p[1], p[2]);
                }
            }
            if (t != c || x == w) {
                if (x > start && c != none) {
                    add_run(f, c, start, x, y, w, h);
                }
                c = t;
                start = x;
            }
        }
    }
}

//  Adds the picture in image m to f; false if it has no colors to add.
static bool add_image(Fl_File_Icon * f, const Fl_Image * m) {
    if (m == 0 || m->data_w() < 1 || m->data_h() < 1) {
        return false;
    }
    if (const Fl_Anim_GIF_Image *a = dynamic_cast<const Fl_Anim_GIF_Image*>(m)) {
        const Fl_RGB_Image *r = dynamic_cast<const Fl_RGB_Image*>(a->image());
        if (r == 0 || r->array == 0 || r->data_w() != a->data_w()
            || r->data_h() != a->data_h())
        {
            return false;
        }
        add_rows(f, r);
        return true;
    }
#ifdef FLTK_USE_SVG
    //  An SVG has no pixels until it is drawn or normalized
    //  (Fl_SVG_Image.cxx:411-413), as drawing would do.
    if (const Fl_SVG_Image *v = dynamic_cast<const Fl_SVG_Image*>(m)) {
        const_cast<Fl_SVG_Image*>(v)->normalize();
    }
#endif
    if (const Fl_RGB_Image *r = dynamic_cast<const Fl_RGB_Image*>(m)) {
        if (r->array == 0) {
            return false;
        }
        add_rows(f, r);
        return true;
    }
    if (const Fl_Pixmap *p = dynamic_cast<const Fl_Pixmap*>(m)) {
        Fl_RGB_Image r(p);
        if (r.data_w() < 1 || r.data_h() < 1 || r.array == 0) {
            return false;
        }
        add_rows(f, &r);
        return true;
    }
    return false;
}




//  Flattened C API

FILEICON new_fl_file_icon(const char * p, int t) {
    char *copy = strdup(p);
    if (copy == 0) {
        return 0;
    }
    try {
        return new My_File_Icon(copy, t);
    } catch (...) {
        std::free(copy);
        return 0;
    }
}

void free_fl_file_icon(FILEICON i) {
    delete static_cast<My_File_Icon*>(i);
}




void fl_file_icon_add(FILEICON i, int d) {
    static_cast<Fl_File_Icon*>(i)->add(static_cast<short>(d));
}

void fl_file_icon_add_color(FILEICON i, unsigned int c) {
    static_cast<Fl_File_Icon*>(i)->add_color(static_cast<Fl_Color>(c));
}

void fl_file_icon_add_vertex(FILEICON i, int x, int y) {
    static_cast<Fl_File_Icon*>(i)->add_vertex(x, y);
}

void fl_file_icon_clear(FILEICON i) {
    static_cast<Fl_File_Icon*>(i)->clear();
}

int fl_file_icon_size(FILEICON i) {
    return static_cast<Fl_File_Icon*>(i)->size();
}




//  Adds file f's picture to icon i: 0 if it did, 1 if f can't be read, 2
//  if f isn't a picture it can show.  An SGI .fti is read by load_fti,
//  which reports bad data only through Fl::error, and returns 0 as it
//  does for success (Fl_File_Icon2.cxx:143-293).  Anything else is read as
//  Fl_Shared_Image reads it, with FLTKAda's checks, and given the runs of
//  color load_image gives.  load_image itself reads past a bitmap and
//  crashes on other images it can't convert (pofltk 86); a bitmap, which
//  has no colors, is refused.  A bad .fti leaves the icon empty.
int fl_file_icon_load(FILEICON i, const char * f) {
    Fl_File_Icon *icon = static_cast<Fl_File_Icon*>(i);
    std::FILE *check = std::fopen(f, "rb");
    if (check == 0) {
        return 1;
    }
    std::fclose(check);
    if (std::strcmp(fl_filename_ext(f), ".fti") == 0) {
        void (*saved)(const char *, ...) = Fl::error;
        Fl::error = count_error;
        icon_errors = 0;
        int bad = icon->load_fti(f);
        Fl::error = saved;
        if (bad == 0 && icon_errors == 0) {
            return 0;
        }
        icon->clear();
        return 2;
    }
    Fl_Shared_Image *s = static_cast<Fl_Shared_Image*>(fl_shared_image_get(f, 0, 0));
    if (s == 0) {
        return 2;
    }
    bool added = false;
    try {
        added = add_image(icon, s->image());
    } catch (...) {
        added = false;
    }
    s->release();
    return added ? 0 : 2;
}

void fl_file_icon_load_system_icons() {
    Fl_File_Icon::load_system_icons();
}




FILEICON fl_file_icon_find(const char * n, int t) {
    return Fl_File_Icon::find(n, t);
}

FILEICON fl_file_icon_first() {
    return Fl_File_Icon::first();
}

FILEICON fl_file_icon_next(FILEICON i) {
    return static_cast<Fl_File_Icon*>(i)->next();
}

const char * fl_file_icon_pattern(FILEICON i) {
    return static_cast<Fl_File_Icon*>(i)->pattern();
}

int fl_file_icon_type(FILEICON i) {
    return static_cast<Fl_File_Icon*>(i)->type();
}




void fl_file_icon_draw(FILEICON i, int x, int y, int w, int h, unsigned int c, int a) {
    static_cast<Fl_File_Icon*>(i)->draw(x, y, w, h, static_cast<Fl_Color>(c), a);
}

//  Fl_File_Icon::labeltype draws the icon, and FLTK gives it no measure, so
//  fl_normal_measure reads the icon as text (Fl_File_Icon.cxx:52-55,
//  pofltk 85).
static void measure_icon(const Fl_Label *, int & w, int & h) {
    w = h = 0;
}

//  Widget w shows icon i as its label.  Fl_File_Icon::label keeps a copied
//  label marked as the widget's to free, which would then free the icon
//  (pofltk 85), so label(0) frees the text and clears the mark first.
void fl_file_icon_label(FILEICON i, void * w) {
    Fl_Widget *wd = static_cast<Fl_Widget*>(w);
    Fl::set_labeltype(_FL_ICON_LABEL, Fl_File_Icon::labeltype, measure_icon);
    wd->label(static_cast<const char *>(0));
    wd->label(_FL_ICON_LABEL, static_cast<const char *>(i));
    wd->redraw();
}




//  Fl_File_Browser::item_draw draws a line's data as its Fl_File_Icon
//  (Fl_File_Browser.cxx:273-275).  Fl_Browser::insert copies the text.
void fl_file_icon_browser_add(void * b, const char * t, FILEICON i) {
    static_cast<Fl_File_Browser*>(b)->add(t, i);
}

void fl_file_icon_browser_set(void * b, int l, FILEICON i) {
    Fl_File_Browser *br = static_cast<Fl_File_Browser*>(b);
    br->data(l, i);
    br->redraw();
}

FILEICON fl_file_icon_browser_get(void * b, int l) {
    return static_cast<Fl_File_Browser*>(b)->data(l);
}


