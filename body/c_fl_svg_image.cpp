

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Fl_SVG_Image.H>
#include "c_fl_svg_image.h"




//  A non-null sharedname makes FLTK also register the image as an
//  Fl_Shared_Image, so an empty name from Ada is passed on as NULL.

static const char * null_if_empty(const char * n) {
    return (n == 0 || *n == '\0') ? 0 : n;
}

SVGIMAGE new_fl_svg_image(const char * f) {
    Fl_SVG_Image *s = new Fl_SVG_Image(f);
    return s;
}

SVGIMAGE new_fl_svg_image2(const char * n, const char * d) {
    Fl_SVG_Image *s = new Fl_SVG_Image(null_if_empty(n), d);
    return s;
}

SVGIMAGE new_fl_svg_image3(const char * n, void * d, size_t l) {
    Fl_SVG_Image *s = new Fl_SVG_Image(null_if_empty(n), static_cast<const unsigned char*>(d), l);
    return s;
}

void free_fl_svg_image(SVGIMAGE s) {
    delete static_cast<Fl_SVG_Image*>(s);
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
    return static_cast<Fl_SVG_Image*>(s)->copy(w, h);
}

SVGIMAGE fl_svg_image_copy2(SVGIMAGE s) {
    return static_cast<Fl_SVG_Image*>(s)->copy();
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


