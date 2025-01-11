

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Dial.H>
#include "c_fl_dial.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Non-friend protected access

class Friend_Dial : Fl_Dial {
public:
    //  Really only needed for the (int,int,int,int) versions
    using Fl_Dial::draw;
    using Fl_Dial::handle;
};




//  Attaching all relevant hooks and friends

class My_Dial : public Fl_Dial {
public:
    using Fl_Dial::Fl_Dial;

    friend void fl_dial_draw(DIAL v);
    friend int fl_dial_handle(DIAL v, int e);

    void draw();
    int handle(int e);
};

void My_Dial::draw() {
    widget_draw_hook(this->user_data());
}

int My_Dial::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

DIAL new_fl_dial(int x, int y, int w, int h, char* label) {
    My_Dial *v = new My_Dial(x, y, w, h, label);
    return v;
}

void free_fl_dial(DIAL v) {
    delete reinterpret_cast<My_Dial*>(v);
}




short fl_dial_get_angle1(DIAL v) {
    return reinterpret_cast<Fl_Dial*>(v)->angle1();
}

void fl_dial_set_angle1(DIAL v, short t) {
    reinterpret_cast<Fl_Dial*>(v)->angle1(t);
}

short fl_dial_get_angle2(DIAL v) {
    return reinterpret_cast<Fl_Dial*>(v)->angle2();
}

void fl_dial_set_angle2(DIAL v, short t) {
    reinterpret_cast<Fl_Dial*>(v)->angle2(t);
}

void fl_dial_set_angles(DIAL v, short a, short b) {
    reinterpret_cast<Fl_Dial*>(v)->angles(a,b);
}




void fl_dial_draw(DIAL v) {
    reinterpret_cast<My_Dial*>(v)->Fl_Dial::draw();
}

void fl_dial_draw2(DIAL v, int x, int y, int w, int h) {
    void (Fl_Dial::*mydraw)(int,int,int,int) = &Friend_Dial::draw;
    (reinterpret_cast<Fl_Dial*>(v)->*mydraw)(x, y, w, h);
}

int fl_dial_handle(DIAL v, int e) {
    return reinterpret_cast<My_Dial*>(v)->Fl_Dial::handle(e);
}

int fl_dial_handle2(DIAL v, int e, int x, int y, int w, int h) {
    int (Fl_Dial::*myhandle)(int,int,int,int,int) = &Friend_Dial::handle;
    return (reinterpret_cast<Fl_Dial*>(v)->*myhandle)(e, x, y, w, h);
}


