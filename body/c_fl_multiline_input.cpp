

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Multiline_Input.H>
#include "c_fl_multiline_input.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Multiline_Input : public Ada_Resizing<Fl_Multiline_Input> {
public:
    using Ada_Resizing<Fl_Multiline_Input>::Ada_Resizing;

    friend void fl_multiline_input_draw(MULTILINEINPUT i);
    friend int fl_multiline_input_handle(MULTILINEINPUT i, int e);

    void draw();
    int handle(int e);
};

void My_Multiline_Input::draw() {
    widget_draw_hook(this->user_data());
}

int My_Multiline_Input::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

MULTILINEINPUT new_fl_multiline_input(int x, int y, int w, int h, char* label) {
    My_Multiline_Input *i = new My_Multiline_Input(x, y, w, h, label);
    return i;
}

void free_fl_multiline_input(MULTILINEINPUT i) {
    if (fl_inside_callback) {
        fl_delete_widget(i);
    } else {
        delete static_cast<My_Multiline_Input*>(i);
    }
}




void fl_multiline_input_draw(MULTILINEINPUT i) {
    static_cast<My_Multiline_Input*>(i)->Fl_Multiline_Input::draw();
}

int fl_multiline_input_handle(MULTILINEINPUT i, int e) {
    return static_cast<My_Multiline_Input*>(i)->Fl_Multiline_Input::handle(e);
}


