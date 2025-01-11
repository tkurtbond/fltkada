

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Fill_Dial.H>
#include "c_fl_fill_dial.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Fill_Dial : public Fl_Fill_Dial {
public:
    using Fl_Fill_Dial::Fl_Fill_Dial;

    friend void fl_fill_dial_draw(FILL_DIAL v);
    friend int fl_fill_dial_handle(FILL_DIAL v, int e);

    void draw();
    int handle(int e);
};

void My_Fill_Dial::draw() {
    widget_draw_hook(this->user_data());
}

int My_Fill_Dial::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

FILL_DIAL new_fl_fill_dial(int x, int y, int w, int h, char* label) {
    My_Fill_Dial *v = new My_Fill_Dial(x, y, w, h, label);
    return v;
}

void free_fl_fill_dial(FILL_DIAL v) {
    delete reinterpret_cast<My_Fill_Dial*>(v);
}




void fl_fill_dial_draw(FILL_DIAL v) {
    reinterpret_cast<My_Fill_Dial*>(v)->Fl_Fill_Dial::draw();
}

int fl_fill_dial_handle(FILL_DIAL v, int e) {
    return reinterpret_cast<My_Fill_Dial*>(v)->Fl_Fill_Dial::handle(e);
}


