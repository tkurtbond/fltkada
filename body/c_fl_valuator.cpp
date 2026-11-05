

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Valuator.H>
#include "c_fl_valuator.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" int valuator_format_hook(void * ud, char * buf);




//  Non-friend protected access

class Friend_Valuator : Fl_Valuator {
public:
    using Fl_Valuator::value_damage;
};




//  Attaching all relevant hooks and friends

class My_Valuator : public Ada_Resizing<Fl_Valuator> {
public:
    using Ada_Resizing<Fl_Valuator>::Ada_Resizing;
    friend VALUATOR new_fl_valuator(int x, int y, int w, int h, char* label);

    friend void fl_valuator_draw(VALUATOR v);
    friend int fl_valuator_handle(VALUATOR v, int e);

    int format(char * buf);
    void draw();
    int handle(int e);
};

int My_Valuator::format(char * buf) {
    return valuator_format_hook(this->user_data(), buf);
}

void My_Valuator::draw() {
    widget_draw_hook(this->user_data());
}

int My_Valuator::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

VALUATOR new_fl_valuator(int x, int y, int w, int h, char* label) {
    My_Valuator *v = new My_Valuator(x, y, w, h, label);
    return v;
}

void free_fl_valuator(VALUATOR v) {
    if (fl_inside_callback) {
        fl_delete_widget(v);
    } else {
        delete static_cast<My_Valuator*>(v);
    }
}




int fl_valuator_format(VALUATOR v, char * buf) {
    return static_cast<Fl_Valuator*>(v)->Fl_Valuator::format(buf);
}




double fl_valuator_clamp(VALUATOR v, double a) {
    return static_cast<Fl_Valuator*>(v)->clamp(a);
}

double fl_valuator_round(VALUATOR v, double a) {
    return static_cast<Fl_Valuator*>(v)->round(a);
}

double fl_valuator_increment(VALUATOR v, double a, int s) {
    return static_cast<Fl_Valuator*>(v)->increment(a,s);
}




double fl_valuator_get_minimum(VALUATOR v) {
    return static_cast<Fl_Valuator*>(v)->minimum();
}

void fl_valuator_set_minimum(VALUATOR v, double t) {
    static_cast<Fl_Valuator*>(v)->minimum(t);
}

double fl_valuator_get_maximum(VALUATOR v) {
    return static_cast<Fl_Valuator*>(v)->maximum();
}

void fl_valuator_set_maximum(VALUATOR v, double t) {
    static_cast<Fl_Valuator*>(v)->maximum(t);
}

double fl_valuator_get_step(VALUATOR v) {
    return static_cast<Fl_Valuator*>(v)->step();
}

void fl_valuator_set_step_top(VALUATOR v, double t) {
    static_cast<Fl_Valuator*>(v)->step(t);
}

void fl_valuator_set_step_bottom(VALUATOR v, int b) {
    static_cast<Fl_Valuator*>(v)->step(b);
}

void fl_valuator_set_step(VALUATOR v, double t, int b) {
    static_cast<Fl_Valuator*>(v)->step(t, b);
}

double fl_valuator_get_value(VALUATOR v) {
    return static_cast<Fl_Valuator*>(v)->value();
}

void fl_valuator_set_value(VALUATOR v, double t) {
    static_cast<Fl_Valuator*>(v)->value(t);
}

void fl_valuator_bounds(VALUATOR v, double a, double b) {
    static_cast<Fl_Valuator*>(v)->bounds(a,b);
}

void fl_valuator_precision(VALUATOR v, int s) {
    static_cast<Fl_Valuator*>(v)->precision(s);
}

void fl_valuator_range(VALUATOR v, double a, double b) {
    static_cast<Fl_Valuator*>(v)->range(a,b);
}




void fl_valuator_value_damage(VALUATOR v) {
    (static_cast<Fl_Valuator*>(v)->*(&Friend_Valuator::value_damage))();
}

void fl_valuator_draw(VALUATOR v) {
    //  The Fl_Valuator draw method doesn't technically exist, so...
    (void)(v);
    //  It is more convenient for this function to exist, however,
    //  even though it will likely never be called, because it simplifies
    //  and makes uniform the implementation of the Ada Valuator Draw subprogram.
}

int fl_valuator_handle(VALUATOR v, int e) {
    return static_cast<My_Valuator*>(v)->Fl_Valuator::handle(e);
}


