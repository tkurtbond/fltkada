

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Counter.H>
#include "c_fl_counter.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Counter : public Fl_Counter {
public:
    using Fl_Counter::Fl_Counter;

    friend void fl_counter_draw(COUNTER c);
    friend int fl_counter_handle(COUNTER c, int e);

    void draw();
    int handle(int e);
};

void My_Counter::draw() {
    widget_draw_hook(this->user_data());
}

int My_Counter::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

COUNTER new_fl_counter(int x, int y, int w, int h, char* label) {
    My_Counter *c = new My_Counter(x, y, w, h, label);
    return c;
}

void free_fl_counter(COUNTER c) {
    delete reinterpret_cast<My_Counter*>(c);
}




double fl_counter_get_step(COUNTER c) {
    return reinterpret_cast<Fl_Counter*>(c)->step();
}

void fl_counter_set_step_top(COUNTER c, double t) {
    reinterpret_cast<Fl_Counter*>(c)->step(t);
}

void fl_counter_set_lstep(COUNTER c, double t) {
    reinterpret_cast<Fl_Counter*>(c)->lstep(t);
}

void fl_counter_set_step_both(COUNTER c, double s, double l) {
    reinterpret_cast<Fl_Counter*>(c)->step(s, l);
}




unsigned int fl_counter_get_textcolor(COUNTER c) {
    return reinterpret_cast<Fl_Counter*>(c)->textcolor();
}

void fl_counter_set_textcolor(COUNTER c, unsigned int t) {
    reinterpret_cast<Fl_Counter*>(c)->textcolor(t);
}

int fl_counter_get_textfont(COUNTER c) {
    return reinterpret_cast<Fl_Counter*>(c)->textfont();
}

void fl_counter_set_textfont(COUNTER c, int t) {
    reinterpret_cast<Fl_Counter*>(c)->textfont(t);
}

int fl_counter_get_textsize(COUNTER c) {
    return reinterpret_cast<Fl_Counter*>(c)->textsize();
}

void fl_counter_set_textsize(COUNTER c, int t) {
    reinterpret_cast<Fl_Counter*>(c)->textsize(t);
}




void fl_counter_draw(COUNTER c) {
    reinterpret_cast<My_Counter*>(c)->Fl_Counter::draw();
}

int fl_counter_handle(COUNTER c, int e) {
    return reinterpret_cast<My_Counter*>(c)->Fl_Counter::handle(e);
}


