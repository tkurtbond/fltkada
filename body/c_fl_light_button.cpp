

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Light_Button.H>
#include "c_fl_light_button.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Light_Button : public Ada_Resizing<Fl_Light_Button> {
public:
    using Ada_Resizing<Fl_Light_Button>::Ada_Resizing;

    friend void fl_light_button_draw(LIGHTBUTTON b);
    friend int fl_light_button_handle(LIGHTBUTTON b, int e);

    void draw();
    int handle(int e);
};

void My_Light_Button::draw() {
    widget_draw_hook(this->user_data());
}

int My_Light_Button::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

LIGHTBUTTON new_fl_light_button(int x, int y, int w, int h, char* label) {
    My_Light_Button *b = new My_Light_Button(x, y, w, h, label);
    return b;
}

void free_fl_light_button(LIGHTBUTTON b) {
    if (fl_inside_callback) {
        fl_delete_widget(b);
    } else {
        delete static_cast<My_Light_Button*>(b);
    }
}




void fl_light_button_draw(LIGHTBUTTON b) {
    static_cast<My_Light_Button*>(b)->Fl_Light_Button::draw();
}

int fl_light_button_handle(LIGHTBUTTON b, int e) {
    return static_cast<My_Light_Button*>(b)->Fl_Light_Button::handle(e);
}


