

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Hor_Slider.H>
#include "c_fl_horizontal_slider.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Horizontal_Slider : public Fl_Hor_Slider {
public:
    using Fl_Hor_Slider::Fl_Hor_Slider;

    friend void fl_horizontal_slider_draw(HORIZONTALSLIDER s);
    friend int fl_horizontal_slider_handle(HORIZONTALSLIDER s, int e);

    void draw();
    int handle(int e);
};

void My_Horizontal_Slider::draw() {
    widget_draw_hook(this->user_data());
}

int My_Horizontal_Slider::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

HORIZONTALSLIDER new_fl_horizontal_slider(int x, int y, int w, int h, char* label) {
    My_Horizontal_Slider *s = new My_Horizontal_Slider(x, y, w, h, label);
    return s;
}

void free_fl_horizontal_slider(HORIZONTALSLIDER s) {
    delete static_cast<My_Horizontal_Slider*>(s);
}




void fl_horizontal_slider_draw(HORIZONTALSLIDER s) {
    static_cast<My_Horizontal_Slider*>(s)->Fl_Hor_Slider::draw();
}

int fl_horizontal_slider_handle(HORIZONTALSLIDER s, int e) {
    return static_cast<My_Horizontal_Slider*>(s)->Fl_Hor_Slider::handle(e);
}


