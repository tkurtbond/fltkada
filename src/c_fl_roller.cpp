

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Roller.H>
#include "c_fl_roller.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Roller : public Fl_Roller {
public:
    using Fl_Roller::Fl_Roller;

    friend void fl_roller_draw(ROLLER r);
    friend int fl_roller_handle(ROLLER r, int e);

    void draw();
    int handle(int e);
};

void My_Roller::draw() {
    widget_draw_hook(this->user_data());
}

int My_Roller::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

ROLLER new_fl_roller(int x, int y, int w, int h, char* label) {
    My_Roller *r = new My_Roller(x, y, w, h, label);
    return r;
}

void free_fl_roller(ROLLER r) {
    delete reinterpret_cast<My_Roller*>(r);
}




void fl_roller_draw(ROLLER r) {
    reinterpret_cast<My_Roller*>(r)->Fl_Roller::draw();
}

int fl_roller_handle(ROLLER r, int e) {
    return reinterpret_cast<My_Roller*>(r)->Fl_Roller::handle(e);
}


