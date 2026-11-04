

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/fl_config.h>
#include "c_fl_svg_image.h"




//  An FLTK built without SVG may still install Fl_SVG_Image.H, but then
//  libfltk_images has no Fl_SVG_Image, so nothing here may name it.  FLTK's
//  own sources test the macro with #ifdef (Fl_SVG_Image.cxx:19,
//  fl_images_core.cxx:127), and so does this: CMake's FLTK_OPTION_SVG=OFF
//  writes "#define FLTK_USE_SVG 0" and still builds the class (pofltk 73).
//  Without it, fl_svg_image_available gives 0, the constructors give null,
//  and the Ada side raises Unsupported_Error before calling them.

#ifdef FLTK_USE_SVG

#include <FL/Fl_SVG_Image.H>
#include "c_fl_image_check.h"

int fl_svg_image_available() {
    return 1;
}




//  A non-null sharedname makes FLTK also register the image as an
//  Fl_Shared_Image, so an empty name from Ada is passed on as NULL
//  (null_if_empty, c_fl_image_check.h).

SVGIMAGE new_fl_svg_image(const char * f) {
    try {
        Fl_SVG_Image *s = new Fl_SVG_Image(f);
        return s;
    } catch (...) {
        return 0;
    }
}

SVGIMAGE new_fl_svg_image2(const char * n, const char * d) {
    try {
        Fl_SVG_Image *s = new Fl_SVG_Image(null_if_empty(n), d);
        return s;
    } catch (...) {
        return 0;
    }
}

SVGIMAGE new_fl_svg_image3(const char * n, void * d, size_t l) {
    try {
        Fl_SVG_Image *s = new Fl_SVG_Image(null_if_empty(n), static_cast<const unsigned char*>(d), l);
        return s;
    } catch (...) {
        return 0;
    }
}

void free_fl_svg_image(SVGIMAGE s) {
    delete_unless_pooled(static_cast<Fl_SVG_Image*>(s));
}




int fl_svg_image_get_proportional(SVGIMAGE s) {
    return static_cast<Fl_SVG_Image*>(s)->proportional;
}

void fl_svg_image_set_proportional(SVGIMAGE s, int p) {
    static_cast<Fl_SVG_Image*>(s)->proportional = p != 0;
}

void fl_svg_image_resize(SVGIMAGE s, int w, int h) {
    static_cast<Fl_SVG_Image*>(s)->resize(w, h);
}

void fl_svg_image_normalize(SVGIMAGE s) {
    static_cast<Fl_SVG_Image*>(s)->normalize();
}




SVGIMAGE fl_svg_image_copy(SVGIMAGE s, int w, int h) {
    try {
        return static_cast<Fl_SVG_Image*>(s)->copy(w, h);
    } catch (...) {
        return 0;
    }
}

SVGIMAGE fl_svg_image_copy2(SVGIMAGE s) {
    try {
        return static_cast<Fl_SVG_Image*>(s)->copy();
    } catch (...) {
        return 0;
    }
}




void fl_svg_image_color_average(SVGIMAGE s, int c, float b) {
    static_cast<Fl_SVG_Image*>(s)->color_average(c, b);
}

void fl_svg_image_desaturate(SVGIMAGE s) {
    static_cast<Fl_SVG_Image*>(s)->desaturate();
}




void fl_svg_image_draw(SVGIMAGE s, int x, int y, int w, int h, int cx, int cy) {
    static_cast<Fl_SVG_Image*>(s)->draw(x, y, w, h, cx, cy);
}

#else

int fl_svg_image_available() {
    return 0;
}

SVGIMAGE new_fl_svg_image(const char *) {
    return 0;
}

SVGIMAGE new_fl_svg_image2(const char *, const char *) {
    return 0;
}

SVGIMAGE new_fl_svg_image3(const char *, void *, size_t) {
    return 0;
}

//  No SVGIMAGE can exist, so the rest are never called with one.

void free_fl_svg_image(SVGIMAGE) {
}

int fl_svg_image_get_proportional(SVGIMAGE) {
    return 0;
}

void fl_svg_image_set_proportional(SVGIMAGE, int) {
}

void fl_svg_image_resize(SVGIMAGE, int, int) {
}

void fl_svg_image_normalize(SVGIMAGE) {
}

SVGIMAGE fl_svg_image_copy(SVGIMAGE, int, int) {
    return 0;
}

SVGIMAGE fl_svg_image_copy2(SVGIMAGE) {
    return 0;
}

void fl_svg_image_color_average(SVGIMAGE, int, float) {
}

void fl_svg_image_desaturate(SVGIMAGE) {
}

void fl_svg_image_draw(SVGIMAGE, int, int, int, int, int, int) {
}

#endif


