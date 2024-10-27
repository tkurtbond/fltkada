

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Widget.H>
#include <FL/Fl_Image.H>
#include "c_fl_label.h"
#include "c_fl_type.h"




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
    delete reinterpret_cast<Fl_Label*>(l);
}




void fl_label_set_value(LABEL l, const char * v) {
    reinterpret_cast<Fl_Label*>(l)->value = v;
}

int fl_label_get_font(LABEL l) {
    return reinterpret_cast<Fl_Label*>(l)->font;
}

void fl_label_set_font(LABEL l, int f) {
    reinterpret_cast<Fl_Label*>(l)->font = f;
}

int fl_label_get_size(LABEL l) {
    return reinterpret_cast<Fl_Label*>(l)->size;
}

void fl_label_set_size(LABEL l, int s) {
    reinterpret_cast<Fl_Label*>(l)->size = s;
}

unsigned int fl_label_get_color(LABEL l) {
    return reinterpret_cast<Fl_Label*>(l)->color;
}

void fl_label_set_color(LABEL l, unsigned int h) {
    reinterpret_cast<Fl_Label*>(l)->color = h;
}

int fl_label_get_type(LABEL l) {
    return (int)reinterpret_cast<Fl_Label*>(l)->type;
}

void fl_label_set_type(LABEL l, int k) {
    reinterpret_cast<Fl_Label*>(l)->type = (uchar)k;
}

unsigned int fl_label_get_align(LABEL l) {
    return reinterpret_cast<Fl_Label*>(l)->align_;
}

void fl_label_set_align(LABEL l, unsigned int p) {
    reinterpret_cast<Fl_Label*>(l)->align_ = p;
}

void fl_label_set_image(LABEL l, void * i) {
    reinterpret_cast<Fl_Label*>(l)->image = reinterpret_cast<Fl_Image*>(i);
}

void fl_label_set_deimage(LABEL l, void * i) {
    reinterpret_cast<Fl_Label*>(l)->deimage = reinterpret_cast<Fl_Image*>(i);
}




void fl_label_draw(LABEL l, int x, int y, int w, int h, unsigned int p) {
    reinterpret_cast<Fl_Label*>(l)->draw(x, y, w, h, p);
}

void fl_label_measure(LABEL l, int &w, int &h) {
    reinterpret_cast<Fl_Label*>(l)->measure(w, h);
}


