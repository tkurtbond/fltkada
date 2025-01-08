

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Input.H>
#include "c_fl_input.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Text_Input : public Fl_Input {
public:
    using Fl_Input::Fl_Input;

    friend void fl_text_input_draw(TEXTINPUT t);
    friend int fl_text_input_handle(TEXTINPUT t, int e);

    void draw();
    int handle(int e);
};

void My_Text_Input::draw() {
    widget_draw_hook(this->user_data());
}

int My_Text_Input::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

TEXTINPUT new_fl_text_input(int x, int y, int w, int h, char * label) {
    My_Text_Input * t = new My_Text_Input(x, y, w, h, label);
    return t;
}

void free_fl_text_input(TEXTINPUT t) {
    delete reinterpret_cast<My_Text_Input*>(t);
}




void fl_text_input_draw(TEXTINPUT t) {
    reinterpret_cast<My_Text_Input*>(t)->Fl_Input::draw();
}

int fl_text_input_handle(TEXTINPUT t, int e) {
    return reinterpret_cast<My_Text_Input*>(t)->Fl_Input::handle(e);
}


