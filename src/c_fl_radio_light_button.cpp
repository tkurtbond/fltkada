

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Radio_Light_Button.H>
#include "c_fl_radio_light_button.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Radio_Light_Button : public Fl_Radio_Light_Button {
public:
    using Fl_Radio_Light_Button::Fl_Radio_Light_Button;

    friend void fl_radio_light_button_draw(RADIOLIGHTBUTTON b);
    friend int fl_radio_light_button_handle(RADIOLIGHTBUTTON b, int e);

    void draw();
    int handle(int e);
};

void My_Radio_Light_Button::draw() {
    widget_draw_hook(this->user_data());
}

int My_Radio_Light_Button::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

RADIOLIGHTBUTTON new_fl_radio_light_button(int x, int y, int w, int h, char* label) {
    My_Radio_Light_Button *b = new My_Radio_Light_Button(x, y, w, h, label);
    return b;
}

void free_fl_radio_light_button(RADIOLIGHTBUTTON b) {
    delete static_cast<My_Radio_Light_Button*>(b);
}




void fl_radio_light_button_draw(RADIOLIGHTBUTTON b) {
    static_cast<My_Radio_Light_Button*>(b)->Fl_Radio_Light_Button::draw();
}

int fl_radio_light_button_handle(RADIOLIGHTBUTTON b, int e) {
    return static_cast<My_Radio_Light_Button*>(b)->Fl_Radio_Light_Button::handle(e);
}


