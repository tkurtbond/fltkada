

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Secret_Input.H>
#include "c_fl_secret_input.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Secret_Input : public Fl_Secret_Input {
public:
    using Fl_Secret_Input::Fl_Secret_Input;

    friend void fl_secret_input_draw(SECRETINPUT i);
    friend int fl_secret_input_handle(SECRETINPUT i, int e);

    void draw();
    int handle(int e);
};

void My_Secret_Input::draw() {
    widget_draw_hook(this->user_data());
}

int My_Secret_Input::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

SECRETINPUT new_fl_secret_input(int x, int y, int w, int h, char* label) {
    My_Secret_Input *i = new My_Secret_Input(x, y, w, h, label);
    return i;
}

void free_fl_secret_input(SECRETINPUT i) {
    if (fl_inside_callback) {
        fl_delete_widget(i);
    } else {
        delete static_cast<My_Secret_Input*>(i);
    }
}




void fl_secret_input_draw(SECRETINPUT i) {
    static_cast<My_Secret_Input*>(i)->Fl_Secret_Input::draw();
}

int fl_secret_input_handle(SECRETINPUT i, int e) {
    return static_cast<My_Secret_Input*>(i)->Fl_Secret_Input::handle(e);
}


