

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Spinner.H>
#include "c_fl_spinner.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all hooks and friends

class My_Spinner : public Fl_Spinner {
public:
    using Fl_Spinner::Fl_Spinner;

    friend void fl_spinner_draw(SPINNER n);
    friend int fl_spinner_handle(SPINNER n, int e);

    void draw();
    int handle(int e);
};

void My_Spinner::draw() {
    widget_draw_hook(this->user_data());
}

int My_Spinner::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

SPINNER new_fl_spinner(int x, int y, int w, int h, char* label) {
    My_Spinner *n = new My_Spinner(x, y, w, h, label);
    return n;
}

void free_fl_spinner(SPINNER n) {
    delete reinterpret_cast<My_Spinner*>(n);
}




unsigned int fl_spinner_get_color(SPINNER n) {
    return reinterpret_cast<Fl_Spinner*>(n)->color();
}

void fl_spinner_set_color(SPINNER n, unsigned int t) {
    reinterpret_cast<Fl_Spinner*>(n)->color(t);
}

unsigned int fl_spinner_get_selection_color(SPINNER n) {
    return reinterpret_cast<Fl_Spinner*>(n)->selection_color();
}

void fl_spinner_set_selection_color(SPINNER n, unsigned int t) {
    reinterpret_cast<Fl_Spinner*>(n)->selection_color(t);
}

unsigned int fl_spinner_get_textcolor(SPINNER n) {
    return reinterpret_cast<Fl_Spinner*>(n)->textcolor();
}

void fl_spinner_set_textcolor(SPINNER n, unsigned int t) {
    reinterpret_cast<Fl_Spinner*>(n)->textcolor(t);
}

int fl_spinner_get_textfont(SPINNER n) {
    return reinterpret_cast<Fl_Spinner*>(n)->textfont();
}

void fl_spinner_set_textfont(SPINNER n, int t) {
    reinterpret_cast<Fl_Spinner*>(n)->textfont(t);
}

int fl_spinner_get_textsize(SPINNER n) {
    return reinterpret_cast<Fl_Spinner*>(n)->textsize();
}

void fl_spinner_set_textsize(SPINNER n, int t) {
    reinterpret_cast<Fl_Spinner*>(n)->textsize(t);
}




double fl_spinner_get_minimum(SPINNER n) {
    return reinterpret_cast<Fl_Spinner*>(n)->minimum();
}

void fl_spinner_set_minimum(SPINNER n, double t) {
    reinterpret_cast<Fl_Spinner*>(n)->minimum(t);
}

double fl_spinner_get_maximum(SPINNER n) {
    return reinterpret_cast<Fl_Spinner*>(n)->maximum();
}

void fl_spinner_set_maximum(SPINNER n, double t) {
    reinterpret_cast<Fl_Spinner*>(n)->maximum(t);
}

void fl_spinner_range(SPINNER n, double a, double b) {
    reinterpret_cast<Fl_Spinner*>(n)->range(a,b);
}

double fl_spinner_get_step(SPINNER n) {
    return reinterpret_cast<Fl_Spinner*>(n)->step();
}

void fl_spinner_set_step(SPINNER n, double t) {
    reinterpret_cast<Fl_Spinner*>(n)->step(t);
}

int fl_spinner_get_type(SPINNER n) {
    return reinterpret_cast<Fl_Spinner*>(n)->type();
}

void fl_spinner_set_type(SPINNER n, int t) {
    reinterpret_cast<Fl_Spinner*>(n)->type(t);
}

double fl_spinner_get_value(SPINNER n) {
    return reinterpret_cast<Fl_Spinner*>(n)->value();
}

void fl_spinner_set_value(SPINNER n, double t) {
    reinterpret_cast<Fl_Spinner*>(n)->value(t);
}




void fl_spinner_resize(SPINNER n, int x, int y, int w, int h) {
    reinterpret_cast<Fl_Spinner*>(n)->resize(x, y, w, h);
}




void fl_spinner_draw(SPINNER n) {
    reinterpret_cast<My_Spinner*>(n)->Fl_Spinner::draw();
}

int fl_spinner_handle(SPINNER n, int e) {
    return reinterpret_cast<My_Spinner*>(n)->Fl_Spinner::handle(e);
}


