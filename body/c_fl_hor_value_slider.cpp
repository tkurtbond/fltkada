

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Hor_Value_Slider.H>
#include "c_fl_hor_value_slider.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" int valuator_format_hook(void * ud, char * buf);




//  Attaching all relevant hooks and friends

class My_Hor_Value_Slider : public Fl_Hor_Value_Slider {
public:
    using Fl_Hor_Value_Slider::Fl_Hor_Value_Slider;

    friend void fl_hor_value_slider_draw(HORVALUESLIDER s);
    friend int fl_hor_value_slider_handle(HORVALUESLIDER s, int e);

    int format(char * buf);
    void draw();
    int handle(int e);
};

int My_Hor_Value_Slider::format(char * buf) {
    return valuator_format_hook(this->user_data(), buf);
}

void My_Hor_Value_Slider::draw() {
    widget_draw_hook(this->user_data());
}

int My_Hor_Value_Slider::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

HORVALUESLIDER new_fl_hor_value_slider(int x, int y, int w, int h, char* label) {
    My_Hor_Value_Slider *s = new My_Hor_Value_Slider(x, y, w, h, label);
    return s;
}

void free_fl_hor_value_slider(HORVALUESLIDER s) {
    delete static_cast<My_Hor_Value_Slider*>(s);
}




void fl_hor_value_slider_draw(HORVALUESLIDER s) {
    static_cast<My_Hor_Value_Slider*>(s)->Fl_Hor_Value_Slider::draw();
}

int fl_hor_value_slider_handle(HORVALUESLIDER s, int e) {
    return static_cast<My_Hor_Value_Slider*>(s)->Fl_Hor_Value_Slider::handle(e);
}


