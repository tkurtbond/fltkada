

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Return_Button.H>
#include "c_fl_return_button.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Return_Button : public Fl_Return_Button {
public:
    using Fl_Return_Button::Fl_Return_Button;

    friend void fl_return_button_draw(RETURNBUTTON b);
    friend int fl_return_button_handle(RETURNBUTTON b, int e);

    void draw();
    int handle(int e);
};

void My_Return_Button::draw() {
    widget_draw_hook(this->user_data());
}

int My_Return_Button::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




// Flattened C API

RETURNBUTTON new_fl_return_button(int x, int y, int w, int h, char* label) {
    My_Return_Button *b = new My_Return_Button(x, y, w, h, label);
    return b;
}

void free_fl_return_button(RETURNBUTTON b) {
    delete static_cast<My_Return_Button*>(b);
}




void fl_return_button_draw(RETURNBUTTON b) {
    static_cast<My_Return_Button*>(b)->Fl_Return_Button::draw();
}

int fl_return_button_handle(RETURNBUTTON b, int e) {
    return static_cast<My_Return_Button*>(b)->Fl_Return_Button::handle(e);
}


