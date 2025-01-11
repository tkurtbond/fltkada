

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Round_Clock.H>
#include "c_fl_round_clock.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Round_Clock : public Fl_Round_Clock {
public:
    using Fl_Round_Clock::Fl_Round_Clock;

    friend void fl_round_clock_draw(ROUNDCLOCK c);
    friend int fl_round_clock_handle(ROUNDCLOCK c, int e);

    void draw();
    int handle(int e);
};

void My_Round_Clock::draw() {
    widget_draw_hook(this->user_data());
}

int My_Round_Clock::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

ROUNDCLOCK new_fl_round_clock(int x, int y, int w, int h, char* label) {
    My_Round_Clock *c = new My_Round_Clock(x, y, w, h, label);
    return c;
}

void free_fl_round_clock(ROUNDCLOCK c) {
    delete reinterpret_cast<My_Round_Clock*>(c);
}




void fl_round_clock_draw(ROUNDCLOCK c) {
    reinterpret_cast<My_Round_Clock*>(c)->Fl_Round_Clock::draw();
}

int fl_round_clock_handle(ROUNDCLOCK c, int e) {
    return reinterpret_cast<My_Round_Clock*>(c)->Fl_Round_Clock::handle(e);
}


