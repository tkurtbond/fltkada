

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Hor_Fill_Slider.H>
#include "c_fl_hor_fill_slider.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" int valuator_format_hook(void * ud, char * buf);




//  Attaching all relevant hooks and friends

class My_Hor_Fill_Slider : public Fl_Hor_Fill_Slider {
public:
    using Fl_Hor_Fill_Slider::Fl_Hor_Fill_Slider;

    friend void fl_hor_fill_slider_draw(HORFILLSLIDER s);
    friend int fl_hor_fill_slider_handle(HORFILLSLIDER s, int e);

    int format(char * buf);
    void draw();
    int handle(int e);
};

int My_Hor_Fill_Slider::format(char * buf) {
    return valuator_format_hook(this->user_data(), buf);
}

void My_Hor_Fill_Slider::draw() {
    widget_draw_hook(this->user_data());
}

int My_Hor_Fill_Slider::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

HORFILLSLIDER new_fl_hor_fill_slider(int x, int y, int w, int h, char* label) {
    My_Hor_Fill_Slider *s = new My_Hor_Fill_Slider(x, y, w, h, label);
    return s;
}

void free_fl_hor_fill_slider(HORFILLSLIDER s) {
    delete static_cast<My_Hor_Fill_Slider*>(s);
}




void fl_hor_fill_slider_draw(HORFILLSLIDER s) {
    static_cast<My_Hor_Fill_Slider*>(s)->Fl_Hor_Fill_Slider::draw();
}

int fl_hor_fill_slider_handle(HORFILLSLIDER s, int e) {
    return static_cast<My_Hor_Fill_Slider*>(s)->Fl_Hor_Fill_Slider::handle(e);
}


