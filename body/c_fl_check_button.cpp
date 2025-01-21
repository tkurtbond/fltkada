

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Check_Button.H>
#include "c_fl_check_button.h"




//  Telprot stopovers

extern "C" void check_button_extra_init_hook
    (void * aobj, int x, int y, int w, int h, const char * l);
void fl_check_button_extra_init (void * adaobj, int x, int y, int w, int h, const char * label) {
    check_button_extra_init_hook(adaobj, x, y, w, h, label);
}

extern "C" void check_button_extra_final_hook(void * aobj);
void fl_check_button_extra_final(void * adaobj) {
    check_button_extra_final_hook(adaobj);
}




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Check_Button : public Fl_Check_Button {
public:
    using Fl_Check_Button::Fl_Check_Button;

    friend void fl_check_button_draw(CHECKBUTTON b);
    friend int fl_check_button_handle(CHECKBUTTON b, int e);

    void draw();
    int handle(int e);
};

void My_Check_Button::draw() {
    widget_draw_hook(this->user_data());
}

int My_Check_Button::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

CHECKBUTTON new_fl_check_button(int x, int y, int w, int h, char* label) {
    My_Check_Button *b = new My_Check_Button(x, y, w, h, label);
    return b;
}

void free_fl_check_button(CHECKBUTTON b) {
    delete static_cast<My_Check_Button*>(b);
}




void fl_check_button_draw(CHECKBUTTON b) {
    static_cast<My_Check_Button*>(b)->Fl_Check_Button::draw();
}

int fl_check_button_handle(CHECKBUTTON b, int e) {
    return static_cast<My_Check_Button*>(b)->Fl_Check_Button::handle(e);
}


