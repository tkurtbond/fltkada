

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Positioner.H>
#include "c_fl_positioner.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Non-friend protected access

class Friend_Positioner : Fl_Positioner {
public:
    //  Really only needed for the versions with (x,y,w,h)
    using Fl_Positioner::draw;
    using Fl_Positioner::handle;
};




//  Attaching all relevant hooks and friends

class My_Positioner : public Fl_Positioner {
public:
    using Fl_Positioner::Fl_Positioner;

    friend void fl_positioner_draw(POSITIONER p);
    friend int fl_positioner_handle(POSITIONER p, int e);

    void draw();
    int handle(int e);
};

void My_Positioner::draw() {
    widget_draw_hook(this->user_data());
}

int My_Positioner::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

POSITIONER new_fl_positioner(int x, int y, int w, int h, char* label) {
    My_Positioner *p = new My_Positioner(x, y, w, h, label);
    return p;
}

void free_fl_positioner(POSITIONER p) {
    if (fl_inside_callback) {
        fl_delete_widget(p);
    } else {
        delete static_cast<My_Positioner*>(p);
    }
}




int fl_positioner_set_value(POSITIONER p, double x, double y) {
    return static_cast<Fl_Positioner*>(p)->value(x, y);
}




void fl_positioner_xbounds(POSITIONER p, double l, double h) {
    static_cast<Fl_Positioner*>(p)->xbounds(l, h);
}

void fl_positioner_xstep(POSITIONER p, double a) {
    static_cast<Fl_Positioner*>(p)->xstep(a);
}

double fl_positioner_get_xminimum(POSITIONER p) {
    return static_cast<Fl_Positioner*>(p)->xminimum();
}

void fl_positioner_set_xminimum(POSITIONER p, double a) {
    static_cast<Fl_Positioner*>(p)->xminimum(a);
}

double fl_positioner_get_xmaximum(POSITIONER p) {
    return static_cast<Fl_Positioner*>(p)->xmaximum();
}

void fl_positioner_set_xmaximum(POSITIONER p, double a) {
    static_cast<Fl_Positioner*>(p)->xmaximum(a);
}

double fl_positioner_get_xvalue(POSITIONER p) {
    return static_cast<Fl_Positioner*>(p)->xvalue();
}

int fl_positioner_set_xvalue(POSITIONER p, double x) {
    return static_cast<Fl_Positioner*>(p)->xvalue(x);
}




void fl_positioner_ybounds(POSITIONER p, double l, double h) {
    static_cast<Fl_Positioner*>(p)->ybounds(l, h);
}

void fl_positioner_ystep(POSITIONER p, double a) {
    static_cast<Fl_Positioner*>(p)->ystep(a);
}

double fl_positioner_get_yminimum(POSITIONER p) {
    return static_cast<Fl_Positioner*>(p)->yminimum();
}

void fl_positioner_set_yminimum(POSITIONER p, double a) {
    static_cast<Fl_Positioner*>(p)->yminimum(a);
}

double fl_positioner_get_ymaximum(POSITIONER p) {
    return static_cast<Fl_Positioner*>(p)->ymaximum();
}

void fl_positioner_set_ymaximum(POSITIONER p, double a) {
    static_cast<Fl_Positioner*>(p)->ymaximum(a);
}

double fl_positioner_get_yvalue(POSITIONER p) {
    return static_cast<Fl_Positioner*>(p)->yvalue();
}

int fl_positioner_set_yvalue(POSITIONER p, double y) {
    return static_cast<Fl_Positioner*>(p)->yvalue(y);
}




void fl_positioner_draw(POSITIONER p) {
    static_cast<My_Positioner*>(p)->Fl_Positioner::draw();
}

void fl_positioner_draw2(POSITIONER p, int x, int y, int w, int h) {
    void (Fl_Positioner::*mydraw)(int,int,int,int) = &Friend_Positioner::draw;
    (static_cast<Fl_Positioner*>(p)->*mydraw)(x, y, w, h);
}

int fl_positioner_handle(POSITIONER p, int e) {
    return static_cast<My_Positioner*>(p)->Fl_Positioner::handle(e);
}

int fl_positioner_handle2(POSITIONER p, int e, int x, int y, int w, int h) {
    int (Fl_Positioner::*myhandle)(int,int,int,int,int) = &Friend_Positioner::handle;
    return (static_cast<Fl_Positioner*>(p)->*myhandle)(e, x, y, w, h);
}


