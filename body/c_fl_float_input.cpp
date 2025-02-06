

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Float_Input.H>
#include "c_fl_float_input.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Float_Input : public Fl_Float_Input {
public:
    using Fl_Float_Input::Fl_Float_Input;

    friend void fl_float_input_draw(FLOATINPUT i);
    friend int fl_float_input_handle(FLOATINPUT i, int e);

    void draw();
    int handle(int e);
};

void My_Float_Input::draw() {
    widget_draw_hook(this->user_data());
}

int My_Float_Input::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

FLOATINPUT new_fl_float_input(int x, int y, int w, int h, char* label) {
    My_Float_Input *i = new My_Float_Input(x, y, w, h, label);
    return i;
}

void free_fl_float_input(FLOATINPUT i) {
    if (fl_inside_callback) {
        fl_delete_widget(i);
    } else {
        delete static_cast<My_Float_Input*>(i);
    }
}




void fl_float_input_draw(FLOATINPUT i) {
    static_cast<My_Float_Input*>(i)->Fl_Float_Input::draw();
}

int fl_float_input_handle(FLOATINPUT i, int e) {
    return static_cast<My_Float_Input*>(i)->Fl_Float_Input::handle(e);
}


