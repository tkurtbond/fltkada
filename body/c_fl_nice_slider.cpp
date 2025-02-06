

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Nice_Slider.H>
#include "c_fl_nice_slider.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" int valuator_format_hook(void * ud, char * buf);




//  Attaching all relevant hooks and friends

class My_Nice_Slider : public Fl_Nice_Slider {
public:
    using Fl_Nice_Slider::Fl_Nice_Slider;

    friend void fl_nice_slider_draw(NICESLIDER s);
    friend int fl_nice_slider_handle(NICESLIDER s, int e);

    int format(char * buf);
    void draw();
    int handle(int e);
};

int My_Nice_Slider::format(char * buf) {
    return valuator_format_hook(this->user_data(), buf);
}

void My_Nice_Slider::draw() {
    widget_draw_hook(this->user_data());
}

int My_Nice_Slider::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

NICESLIDER new_fl_nice_slider(int x, int y, int w, int h, char* label) {
    My_Nice_Slider *s = new My_Nice_Slider(x, y, w, h, label);
    return s;
}

void free_fl_nice_slider(NICESLIDER s) {
    if (fl_inside_callback) {
        fl_delete_widget(s);
    } else {
        delete static_cast<My_Nice_Slider*>(s);
    }
}




void fl_nice_slider_draw(NICESLIDER s) {
    static_cast<My_Nice_Slider*>(s)->Fl_Nice_Slider::draw();
}

int fl_nice_slider_handle(NICESLIDER s, int e) {
    return static_cast<My_Nice_Slider*>(s)->Fl_Nice_Slider::handle(e);
}


