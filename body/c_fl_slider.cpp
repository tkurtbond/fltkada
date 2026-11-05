

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Slider.H>
#include "c_fl_slider.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" int valuator_format_hook(void * ud, char * buf);




//  Non-friend protected access

class Friend_Slider : Fl_Slider {
public:
    //  Really only needed for the (int,int,int,int) versions
    using Fl_Slider::draw;
    using Fl_Slider::handle;
};




//  Attaching all relevant hooks and friends

class My_Slider : public Ada_Resizing<Fl_Slider> {
public:
    using Ada_Resizing<Fl_Slider>::Ada_Resizing;

    friend void fl_slider_draw(SLIDER s);
    friend int fl_slider_handle(SLIDER s, int e);

    int format(char * buf);
    void draw();
    int handle(int e);
};

int My_Slider::format(char * buf) {
    return valuator_format_hook(this->user_data(), buf);
}

void My_Slider::draw() {
    widget_draw_hook(this->user_data());
}

int My_Slider::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

SLIDER new_fl_slider(int x, int y, int w, int h, char* label) {
    My_Slider *s = new My_Slider(x, y, w, h, label);
    return s;
}

SLIDER new_fl_slider2(unsigned char k, int x, int y, int w, int h, char * label) {
    My_Slider *s = new My_Slider(k, x, y, w, h, label);
    return s;
}

void free_fl_slider(SLIDER s) {
    if (fl_inside_callback) {
        fl_delete_widget(s);
    } else {
        delete static_cast<My_Slider*>(s);
    }
}




void fl_slider_set_bounds(SLIDER s, double a, double b) {
    static_cast<Fl_Slider*>(s)->bounds(a,b);
}

int fl_slider_get_slider(SLIDER s) {
    return static_cast<Fl_Slider*>(s)->slider();
}

void fl_slider_set_slider(SLIDER s, int t) {
    static_cast<Fl_Slider*>(s)->slider(static_cast<Fl_Boxtype>(t));
}

float fl_slider_get_slider_size(SLIDER s) {
    return static_cast<Fl_Slider*>(s)->slider_size();
}

void fl_slider_set_slider_size(SLIDER s, double t) {
    static_cast<Fl_Slider*>(s)->slider_size(t);
}

int fl_slider_scrollvalue(SLIDER s, int p, int z, int f, int t) {
    return static_cast<Fl_Slider*>(s)->scrollvalue(p,z,f,t);
}




void fl_slider_draw(SLIDER s) {
    static_cast<My_Slider*>(s)->Fl_Slider::draw();
}

void fl_slider_draw2(SLIDER s, int x, int y, int w, int h) {
    void (Fl_Slider::*mydraw)(int,int,int,int) = &Friend_Slider::draw;
    (static_cast<Fl_Slider*>(s)->*mydraw)(x, y, w, h);
}

int fl_slider_handle(SLIDER s, int e) {
    return static_cast<My_Slider*>(s)->Fl_Slider::handle(e);
}

int fl_slider_handle2(SLIDER s, int e, int x, int y, int w, int h) {
    int (Fl_Slider::*myhandle)(int,int,int,int,int) = &Friend_Slider::handle;
    return (static_cast<Fl_Slider*>(s)->*myhandle)(e, x, y, w, h);
}


