

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Clock.H>
#include "c_fl_clock_output.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Non-friend protected access

class Friend_Clock_Output : Fl_Clock_Output {
public:
    //  Really only needed for the (int,int,int,int) version
    using Fl_Clock_Output::draw;
};




//  Attaching all relevant hooks and friends

class My_Clock_Output : public Fl_Clock_Output {
public:
    using Fl_Clock_Output::Fl_Clock_Output;

    friend void fl_clock_output_draw(CLOCK_OUTPUT c);
    friend int fl_clock_output_handle(CLOCK_OUTPUT c, int e);

    void draw();
    int handle(int e);
};

void My_Clock_Output::draw() {
    widget_draw_hook(this->user_data());
}

int My_Clock_Output::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

CLOCK_OUTPUT new_fl_clock_output(int x, int y, int w, int h, char* label) {
    My_Clock_Output *c = new My_Clock_Output(x, y, w, h, label);
    return c;
}

void free_fl_clock_output(CLOCK_OUTPUT c) {
    delete reinterpret_cast<My_Clock_Output*>(c);
}




int fl_clock_output_get_hour(CLOCK_OUTPUT c) {
    return reinterpret_cast<Fl_Clock_Output*>(c)->Fl_Clock_Output::hour();
}

int fl_clock_output_get_minute(CLOCK_OUTPUT c) {
    return reinterpret_cast<Fl_Clock_Output*>(c)->Fl_Clock_Output::minute();
}

int fl_clock_output_get_second(CLOCK_OUTPUT c) {
    return reinterpret_cast<Fl_Clock_Output*>(c)->Fl_Clock_Output::second();
}


unsigned long fl_clock_output_get_value(CLOCK_OUTPUT c) {
    return reinterpret_cast<Fl_Clock_Output*>(c)->Fl_Clock_Output::value();
}

void fl_clock_output_set_value(CLOCK_OUTPUT c, unsigned long v) {
    reinterpret_cast<Fl_Clock_Output*>(c)->Fl_Clock_Output::value(v);
}

void fl_clock_output_set_value2(CLOCK_OUTPUT c, int h, int m, int s) {
    reinterpret_cast<Fl_Clock_Output*>(c)->Fl_Clock_Output::value(h,m,s);
}




void fl_clock_output_draw(CLOCK_OUTPUT c) {
    reinterpret_cast<My_Clock_Output*>(c)->Fl_Clock_Output::draw();
}

void fl_clock_output_draw2(CLOCK_OUTPUT c, int x, int y, int w, int h) {
    void (Fl_Clock_Output::*mydraw)(int,int,int,int) = &Friend_Clock_Output::draw;
    (reinterpret_cast<Fl_Clock_Output*>(c)->*mydraw)(x, y, w, h);
}

int fl_clock_output_handle(CLOCK_OUTPUT c, int e) {
    return reinterpret_cast<My_Clock_Output*>(c)->Fl_Clock_Output::handle(e);
}


