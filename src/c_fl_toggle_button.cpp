

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Toggle_Button.H>
#include "c_fl_toggle_button.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Toggle_Button : public Fl_Toggle_Button {
public:
    using Fl_Toggle_Button::Fl_Toggle_Button;

    friend void fl_toggle_button_draw(TOGGLEBUTTON b);
    friend int fl_toggle_button_handle(TOGGLEBUTTON b, int e);

    void draw();
    int handle(int e);
};

void My_Toggle_Button::draw() {
    widget_draw_hook(this->user_data());
}

int My_Toggle_Button::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

TOGGLEBUTTON new_fl_toggle_button(int x, int y, int w, int h, char* label) {
    My_Toggle_Button *b = new My_Toggle_Button(x, y, w, h, label);
    return b;
}

void free_fl_toggle_button(TOGGLEBUTTON b) {
    delete reinterpret_cast<My_Toggle_Button*>(b);
}




void fl_toggle_button_draw(TOGGLEBUTTON b) {
    reinterpret_cast<My_Toggle_Button*>(b)->Fl_Toggle_Button::draw();
}

int fl_toggle_button_handle(TOGGLEBUTTON b, int e) {
    return reinterpret_cast<My_Toggle_Button*>(b)->Fl_Toggle_Button::handle(e);
}


