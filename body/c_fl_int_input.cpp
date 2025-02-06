

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Int_Input.H>
#include "c_fl_int_input.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Int_Input : public Fl_Int_Input {
public:
    using Fl_Int_Input::Fl_Int_Input;

    friend void fl_int_input_draw(INTINPUT i);
    friend int fl_int_input_handle(INTINPUT i, int e);

    void draw();
    int handle(int e);
};

void My_Int_Input::draw() {
    widget_draw_hook(this->user_data());
}

int My_Int_Input::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

INTINPUT new_fl_int_input(int x, int y, int w, int h, char* label) {
    My_Int_Input *i = new My_Int_Input(x, y, w, h, label);
    return i;
}

void free_fl_int_input(INTINPUT i) {
    if (fl_inside_callback) {
        fl_delete_widget(i);
    } else {
        delete static_cast<My_Int_Input*>(i);
    }
}




void fl_int_input_draw(INTINPUT i) {
    static_cast<My_Int_Input*>(i)->Fl_Int_Input::draw();
}

int fl_int_input_handle(INTINPUT i, int e) {
    return static_cast<My_Int_Input*>(i)->Fl_Int_Input::handle(e);
}


