

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Widget.H>
#include <FL/Fl_Image.H>
#include "c_fl_label.h"




LABEL new_fl_label(const char * v, int f, int s, unsigned int h, int k, unsigned int p) {
    Fl_Label *l = new Fl_Label;
    l->value = v;
    l->font = f;
    l->size = s;
    l->color = h;
    l->align_ = p;
    l->type = (uchar)k;
    return l;
}

void free_fl_label(LABEL l) {
    delete static_cast<Fl_Label*>(l);
}




const char * fl_label_get_value(LABEL l) {
    return static_cast<Fl_Label*>(l)->value;
}

void fl_label_set_value(LABEL l, const char * v) {
    static_cast<Fl_Label*>(l)->value = v;
}

int fl_label_get_font(LABEL l) {
    return static_cast<Fl_Label*>(l)->font;
}

void fl_label_set_font(LABEL l, int f) {
    static_cast<Fl_Label*>(l)->font = f;
}

int fl_label_get_size(LABEL l) {
    return static_cast<Fl_Label*>(l)->size;
}

void fl_label_set_size(LABEL l, int s) {
    static_cast<Fl_Label*>(l)->size = s;
}

unsigned int fl_label_get_color(LABEL l) {
    return static_cast<Fl_Label*>(l)->color;
}

void fl_label_set_color(LABEL l, unsigned int h) {
    static_cast<Fl_Label*>(l)->color = h;
}

int fl_label_get_type(LABEL l) {
    return (int)static_cast<Fl_Label*>(l)->type;
}

void fl_label_set_type(LABEL l, int k) {
    static_cast<Fl_Label*>(l)->type = (uchar)k;
}

unsigned int fl_label_get_align(LABEL l) {
    return static_cast<Fl_Label*>(l)->align_;
}

void fl_label_set_align(LABEL l, unsigned int p) {
    static_cast<Fl_Label*>(l)->align_ = p;
}

void fl_label_set_image(LABEL l, void * i) {
    static_cast<Fl_Label*>(l)->image = static_cast<Fl_Image*>(i);
}

void fl_label_set_deimage(LABEL l, void * i) {
    static_cast<Fl_Label*>(l)->deimage = static_cast<Fl_Image*>(i);
}




void fl_label_draw(LABEL l, int x, int y, int w, int h, unsigned int p) {
    static_cast<Fl_Label*>(l)->draw(x, y, w, h, p);
}

void fl_label_measure(LABEL l, int &w, int &h) {
    static_cast<Fl_Label*>(l)->measure(w, h);
}


