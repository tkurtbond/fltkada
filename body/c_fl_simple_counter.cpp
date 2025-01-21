

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Simple_Counter.H>
#include "c_fl_simple_counter.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" int valuator_format_hook(void * ud, char * buf);




//  Attaching all relevant hooks and friends

class My_Simple_Counter : public Fl_Simple_Counter {
public:
    using Fl_Simple_Counter::Fl_Simple_Counter;

    friend void fl_simple_counter_draw(SIMPLECOUNTER c);
    friend int fl_simple_counter_handle(SIMPLECOUNTER c, int e);

    int format(char * buf);
    void draw();
    int handle(int e);
};

int My_Simple_Counter::format(char * buf) {
    return valuator_format_hook(this->user_data(), buf);
}

void My_Simple_Counter::draw() {
    widget_draw_hook(this->user_data());
}

int My_Simple_Counter::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

SIMPLECOUNTER new_fl_simple_counter(int x, int y, int w, int h, char* label) {
    My_Simple_Counter *c = new My_Simple_Counter(x, y, w, h, label);
    return c;
}

void free_fl_simple_counter(SIMPLECOUNTER c) {
    delete static_cast<My_Simple_Counter*>(c);
}




void fl_simple_counter_draw(SIMPLECOUNTER c) {
    static_cast<My_Simple_Counter*>(c)->Fl_Simple_Counter::draw();
}

int fl_simple_counter_handle(SIMPLECOUNTER c, int e) {
    return static_cast<My_Simple_Counter*>(c)->Fl_Simple_Counter::handle(e);
}


