

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Button.H>
#include "c_fl_button.h"
#include "c_fl.h"




//  Telprot stopovers

extern "C" void button_extra_init_hook(void * aobj, int x, int y, int w, int h, const char * l);
void fl_button_extra_init(void * adaobj, int x, int y, int w, int h, const char * label) {
    button_extra_init_hook(adaobj, x, y, w, h, label);
}

extern "C" void button_extra_final_hook(void * aobj);
void fl_button_extra_final(void * adaobj) {
    button_extra_final_hook(adaobj);
}




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Non-friend protected access

class Friend_Button : Fl_Button {
public:
    using Fl_Button::simulate_key_action;
};




//  Attaching all relevant hooks and friends

class My_Button : public Fl_Button {
public:
    using Fl_Button::Fl_Button;

    friend void fl_button_draw(BUTTON b);
    friend int fl_button_handle(BUTTON b, int e);

    void draw();
    int handle(int e);
};

void My_Button::draw() {
    widget_draw_hook(this->user_data());
}

int My_Button::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

BUTTON new_fl_button(int x, int y, int w, int h, char* label) {
    My_Button *b = new My_Button(x, y, w, h, label);
    return b;
}

void free_fl_button(BUTTON b) {
    if (fl_inside_callback) {
        fl_delete_widget(b);
    } else {
        delete static_cast<My_Button*>(b);
    }
}




int fl_button_get_state(BUTTON b) {
    return static_cast<Fl_Button*>(b)->Fl_Button::value();
}

void fl_button_set_state(BUTTON b, int s) {
    static_cast<Fl_Button*>(b)->Fl_Button::value(s);
}

void fl_button_set_only(BUTTON b) {
    static_cast<Fl_Button*>(b)->Fl_Button::setonly();
}




int fl_button_get_down_box(BUTTON b) {
    return static_cast<Fl_Button*>(b)->Fl_Button::down_box();
}

void fl_button_set_down_box(BUTTON b, int t) {
    static_cast<Fl_Button*>(b)->Fl_Button::down_box(static_cast<Fl_Boxtype>(t));
}

int fl_button_get_shortcut(BUTTON b) {
    return static_cast<Fl_Button*>(b)->Fl_Button::shortcut();
}

void fl_button_set_shortcut(BUTTON b, int k) {
    static_cast<Fl_Button*>(b)->Fl_Button::shortcut(k);
}




void fl_button_draw(BUTTON b) {
    static_cast<My_Button*>(b)->Fl_Button::draw();
}

int fl_button_handle(BUTTON b, int e) {
    return static_cast<My_Button*>(b)->Fl_Button::handle(e);
}




void fl_button_simulate_key_action(BUTTON b) {
    (static_cast<Fl_Button*>(b)->*(&Friend_Button::simulate_key_action))();
}


