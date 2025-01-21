

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Repeat_Button.H>
#include "c_fl_repeat_button.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Repeat_Button : public Fl_Repeat_Button {
public:
    using Fl_Repeat_Button::Fl_Repeat_Button;

    friend void fl_repeat_button_draw(REPEATBUTTON b);
    friend int fl_repeat_button_handle(REPEATBUTTON b, int e);

    void draw();
    int handle(int e);
};

void My_Repeat_Button::draw() {
    widget_draw_hook(this->user_data());
}

int My_Repeat_Button::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

REPEATBUTTON new_fl_repeat_button(int x, int y, int w, int h, char* label) {
    My_Repeat_Button *b = new My_Repeat_Button(x, y, w, h, label);
    return b;
}

void free_fl_repeat_button(REPEATBUTTON b) {
    delete static_cast<My_Repeat_Button*>(b);
}




void fl_repeat_button_deactivate(REPEATBUTTON b) {
    static_cast<Fl_Repeat_Button*>(b)->deactivate();
}




void fl_repeat_button_draw(REPEATBUTTON b) {
    static_cast<My_Repeat_Button*>(b)->Fl_Repeat_Button::draw();
}

int fl_repeat_button_handle(REPEATBUTTON b, int e) {
    return static_cast<My_Repeat_Button*>(b)->Fl_Repeat_Button::handle(e);
}


