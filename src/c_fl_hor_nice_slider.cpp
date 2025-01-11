

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Hor_Nice_Slider.H>
#include "c_fl_hor_nice_slider.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Hor_Nice_Slider : public Fl_Hor_Nice_Slider {
public:
    using Fl_Hor_Nice_Slider::Fl_Hor_Nice_Slider;

    friend void fl_hor_nice_slider_draw(HORNICESLIDER s);
    friend int fl_hor_nice_slider_handle(HORNICESLIDER s, int e);

    void draw();
    int handle(int e);
};

void My_Hor_Nice_Slider::draw() {
    widget_draw_hook(this->user_data());
}

int My_Hor_Nice_Slider::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

HORNICESLIDER new_fl_hor_nice_slider(int x, int y, int w, int h, char* label) {
    My_Hor_Nice_Slider *s = new My_Hor_Nice_Slider(x, y, w, h, label);
    return s;
}

void free_fl_hor_nice_slider(HORNICESLIDER s) {
    delete reinterpret_cast<My_Hor_Nice_Slider*>(s);
}




void fl_hor_nice_slider_draw(HORNICESLIDER s) {
    reinterpret_cast<My_Hor_Nice_Slider*>(s)->Fl_Hor_Nice_Slider::draw();
}

int fl_hor_nice_slider_handle(HORNICESLIDER s, int e) {
    return reinterpret_cast<My_Hor_Nice_Slider*>(s)->Fl_Hor_Nice_Slider::handle(e);
}


