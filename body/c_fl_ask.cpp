

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <string>
#include <FL/fl_ask.H>
#include <FL/fl_show_colormap.H>
#include <FL/Fl_File_Chooser.H>
#include <FL/Fl_Color_Chooser.H>
#include "c_fl_ask.h"




const char * fl_ask_get_cancel() {
    return fl_cancel;
}

void fl_ask_set_cancel(const char * v) {
    fl_cancel = v;
}

const char * fl_ask_get_close() {
    return fl_close;
}

void fl_ask_set_close(const char * v) {
    fl_close = v;
}

const char * fl_ask_get_no() {
    return fl_no;
}

void fl_ask_set_no(const char * v) {
    fl_no = v;
}

const char * fl_ask_get_ok() {
    return fl_ok;
}

void fl_ask_set_ok(const char * v) {
    fl_ok = v;
}

const char * fl_ask_get_yes() {
    return fl_yes;
}

void fl_ask_set_yes(const char * v) {
    fl_yes = v;
}




void fl_ask_alert(const char * m) {
    fl_alert("%s", m);
}

void fl_ask_beep(int b) {
    fl_beep(b);
}

int fl_ask_choice(const char * m, const char * a, const char * b, const char * c) {
    return fl_choice("%s", a, b, c, m);
}

int fl_ask_choice_n(const char * m, const char * a, const char * b, const char * c) {
    return fl_choice_n("%s", a, b, c, m);
}

const char * fl_ask_input(const char * m, const char * d) {
    return fl_input("%s", d, m);
}

void fl_ask_message(const char * m) {
    fl_message("%s", m);
}

const char * fl_ask_password(const char * m, const char * d) {
    return fl_password("%s", d, m);
}




int fl_ask_color_chooser(const char * n, double & r, double & g, double & b, int m) {
    return fl_color_chooser(n, r, g, b, m);
}

int fl_ask_color_chooser2(const char * n,
    unsigned char & r, unsigned char & g, unsigned char & b, int m)
{
    return fl_color_chooser(n, r, g, b, m);
}

unsigned int fl_ask_show_colormap(unsigned int h) {
    return static_cast<unsigned int>(fl_show_colormap(static_cast<Fl_Color>(h)));
}

//  fl_dir_chooser and fl_file_chooser make one Fl_File_Chooser and keep it, and
//  give it the title without copying it (fl_file_dir.cxx:116, 200).  So the title
//  is kept here, in one copy both choosers share, until the next title.  Derived
//  from pofltk's keep_title.
static std::string chooser_title;

static const char * keep_title(const char * m) {
    if (m == 0) {
        return 0;
    }
    try {
        chooser_title = m;
    } catch (...) {
        chooser_title.clear();
    }
    return chooser_title.c_str();
}

char * fl_ask_dir_chooser(const char * m, const char * d, int r) {
    return fl_dir_chooser(keep_title(m), d, r);
}

char * fl_ask_file_chooser(const char * m, const char * p, const char * d, int r) {
    return fl_file_chooser(keep_title(m), p, d, r);
}

void fl_ask_file_chooser_callback(void(*cb)(const char *)) {
    fl_file_chooser_callback(cb);
}

void fl_ask_file_chooser_ok_label(const char *l) {
    fl_file_chooser_ok_label(l);
}




int fl_ask_get_message_hotspot(void) {
    return fl_message_hotspot();
}

void fl_ask_set_message_hotspot(int v) {
    fl_message_hotspot(v);
}

void fl_ask_message_font(int f, int s) {
    fl_message_font(f, s);
}

void * fl_ask_message_icon(void) {
    return fl_message_icon();
}

void fl_ask_message_title(const char * t) {
    fl_message_title(t);
}

void fl_ask_message_title_default(const char * t) {
    fl_message_title_default(t);
}


