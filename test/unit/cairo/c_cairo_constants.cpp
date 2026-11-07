//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.
//
//  Written by tools/gen-constants.py; edit that, not this.


//  FLTK's value of each constant the Ada test, fltk-test_cairo_constants.adb,
//  checks, in the same order.


#include <cairo.h>


extern "C" const long long c_cairo_constants[];

extern "C" const long long c_cairo_constants[] =
{
    //  Font slants (cairo_font_slant_t)
    CAIRO_FONT_SLANT_NORMAL,
    CAIRO_FONT_SLANT_ITALIC,
    CAIRO_FONT_SLANT_OBLIQUE,
    //  Font weights (cairo_font_weight_t)
    CAIRO_FONT_WEIGHT_NORMAL,
    CAIRO_FONT_WEIGHT_BOLD,
    //  Antialiasing (cairo_antialias_t)
    CAIRO_ANTIALIAS_DEFAULT,
    CAIRO_ANTIALIAS_NONE,
    CAIRO_ANTIALIAS_GRAY,
    CAIRO_ANTIALIAS_SUBPIXEL,
    CAIRO_ANTIALIAS_FAST,
    CAIRO_ANTIALIAS_GOOD,
    CAIRO_ANTIALIAS_BEST,
    //  Pattern extends (cairo_extend_t)
    CAIRO_EXTEND_NONE,
    CAIRO_EXTEND_REPEAT,
    CAIRO_EXTEND_REFLECT,
    CAIRO_EXTEND_PAD
};
