

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <cstdlib>
#include <cstring>
#include <FL/Fl_Tooltip.H>
#include <FL/Fl_Widget.H>
#include "c_fl_tooltip.h"




void * fl_tooltip_get_current(void) {
    return Fl_Tooltip::current();
}

void fl_tooltip_set_current(void * i) {
    Fl_Tooltip::current(static_cast<Fl_Widget*>(i));
}

int fl_tooltip_enabled(void) {
    return Fl_Tooltip::enabled();
}

void fl_tooltip_enable(int v) {
    Fl_Tooltip::enable(v);
}

void fl_tooltip_disable() {
    Fl_Tooltip::disable();
}

//  Fl_Tooltip::enter_area keeps the text without copying it (Fl_Tooltip.cxx:301), so
//  this keeps a copy.  The same text must stay the same pointer, by which FLTK knows
//  the tip it is showing already (Fl_Tooltip.cxx:297).  FLTK takes a new text only
//  when it sets the current widget too (Fl_Tooltip.cxx:301); for an empty text, or
//  with tooltips disabled, it keeps the old pointer (Fl_Tooltip.cxx:290-293) and
//  may read it later.  So the old copy is freed only once FLTK holds the new one.
//  Derived from pofltk's ofl_tooltip_enter_area (pofltk 75), which freed the copy
//  on an empty text (FLTK-issues.md, F4).
//  The copy FLTK holds, freed at exit like the shim's other kept strings.
struct Kept_Tip {
    char * text;
    ~Kept_Tip() { std::free(text); }
};

static Kept_Tip kept_tip = { 0 };

void fl_tooltip_enter_area(void * i, int x, int y, int w, int h, const char * t) {
    char * & kept = kept_tip.text;
    Fl_Widget * wid = static_cast<Fl_Widget*>(i);
    if (wid == 0) {
        //  The Ada side always has a widget, and the test below needs one.
        return;
    }
    if (t == 0 || *t == '\0') {
        Fl_Tooltip::enter_area(wid, x, y, w, h, 0);
    } else if (kept != 0 && std::strcmp(kept, t) == 0) {
        Fl_Tooltip::enter_area(wid, x, y, w, h, kept);
    } else {
        size_t len = std::strlen(t) + 1;
        char * copy = static_cast<char*>(std::malloc(len));
        if (copy == 0) {
            return;
        }
        std::memcpy(copy, t, len);
        Fl_Tooltip::enter_area(wid, x, y, w, h, copy);
        if (Fl_Tooltip::current() == wid) {
            std::free(kept);
            kept = copy;
        } else {
            std::free(copy);
        }
    }
}




float fl_tooltip_get_delay(void) {
    return Fl_Tooltip::delay();
}

void fl_tooltip_set_delay(float v) {
    Fl_Tooltip::delay(v);
}

float fl_tooltip_get_hoverdelay(void) {
    return Fl_Tooltip::hoverdelay();
}

void fl_tooltip_set_hoverdelay(float v) {
    Fl_Tooltip::hoverdelay(v);
}




unsigned int fl_tooltip_get_color(void) {
    return Fl_Tooltip::color();
}

void fl_tooltip_set_color(unsigned int v) {
    Fl_Tooltip::color(v);
}

int fl_tooltip_get_margin_height(void) {
    return Fl_Tooltip::margin_height();
}

void fl_tooltip_set_margin_height(int v) {
#if FLTK_ABI_VERSION >= 10301
    Fl_Tooltip::margin_height(v);
#else
    (void)(v);
#endif
}

int fl_tooltip_get_margin_width(void) {
    return Fl_Tooltip::margin_width();
}

void fl_tooltip_set_margin_width(int v) {
#if FLTK_ABI_VERSION >= 10301
    Fl_Tooltip::margin_width(v);
#else
    (void)(v);
#endif
}

int fl_tooltip_get_wrap_width(void) {
    return Fl_Tooltip::wrap_width();
}

void fl_tooltip_set_wrap_width(int v) {
#if FLTK_ABI_VERSION >= 10301
    Fl_Tooltip::wrap_width(v);
#else
    (void)(v);
#endif
}




unsigned int fl_tooltip_get_textcolor(void) {
    return Fl_Tooltip::textcolor();
}

void fl_tooltip_set_textcolor(unsigned int v) {
    Fl_Tooltip::textcolor(v);
}

int fl_tooltip_get_font(void) {
    return Fl_Tooltip::font();
}

void fl_tooltip_set_font(int v) {
    Fl_Tooltip::font(v);
}

int fl_tooltip_get_size(void) {
    return Fl_Tooltip::size();
}

void fl_tooltip_set_size(int v) {
    Fl_Tooltip::size(v);
}


