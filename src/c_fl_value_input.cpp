

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Value_Input.H>
#include "c_fl_value_input.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Value_Input : public Fl_Value_Input {
public:
    using Fl_Value_Input::Fl_Value_Input;

    friend void fl_value_input_draw(VALUEINPUT a);
    friend int fl_value_input_handle(VALUEINPUT a, int e);

    void draw();
    int handle(int e);
};

void My_Value_Input::draw() {
    widget_draw_hook(this->user_data());
}

int My_Value_Input::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

VALUEINPUT new_fl_value_input(int x, int y, int w, int h, char* label) {
    My_Value_Input *a = new My_Value_Input(x, y, w, h, label);
    return a;
}

void free_fl_value_input(VALUEINPUT a) {
    delete reinterpret_cast<My_Value_Input*>(a);
}




void * fl_value_input_get_input(VALUEINPUT v) {
    return &(reinterpret_cast<Fl_Value_Input*>(v)->input);
}




unsigned int fl_value_input_get_cursor_color(VALUEINPUT v) {
    return reinterpret_cast<Fl_Value_Input*>(v)->cursor_color();
}

void fl_value_input_set_cursor_color(VALUEINPUT v, unsigned int c) {
    reinterpret_cast<Fl_Value_Input*>(v)->cursor_color(c);
}




int fl_value_input_get_shortcut(VALUEINPUT v) {
    return reinterpret_cast<Fl_Value_Input*>(v)->Fl_Value_Input::shortcut();
}

void fl_value_input_set_shortcut(VALUEINPUT v, int k) {
    reinterpret_cast<Fl_Value_Input*>(v)->Fl_Value_Input::shortcut(k);
}




int fl_value_input_is_soft(VALUEINPUT a) {
    return reinterpret_cast<Fl_Value_Input*>(a)->soft();
}

void fl_value_input_set_soft(VALUEINPUT a, int t) {
    reinterpret_cast<Fl_Value_Input*>(a)->soft(t);
}




unsigned int fl_value_input_get_text_color(VALUEINPUT v) {
    return reinterpret_cast<Fl_Value_Input*>(v)->textcolor();
}

void fl_value_input_set_text_color(VALUEINPUT v, unsigned int c) {
    reinterpret_cast<Fl_Value_Input*>(v)->textcolor(static_cast<Fl_Color>(c));
}

int fl_value_input_get_text_font(VALUEINPUT v) {
    return reinterpret_cast<Fl_Value_Input*>(v)->textfont();
}

void fl_value_input_set_text_font(VALUEINPUT v, int f) {
    reinterpret_cast<Fl_Value_Input*>(v)->textfont(static_cast<Fl_Font>(f));
}

int fl_value_input_get_text_size(VALUEINPUT v) {
    return reinterpret_cast<Fl_Value_Input*>(v)->textsize();
}

void fl_value_input_set_text_size(VALUEINPUT v, int s) {
    reinterpret_cast<Fl_Value_Input*>(v)->textsize(static_cast<Fl_Fontsize>(s));
}




void fl_value_input_resize(VALUEINPUT v, int x, int y, int w, int h) {
    reinterpret_cast<Fl_Value_Input*>(v)->resize(x, y, w, h);
}




void fl_value_input_draw(VALUEINPUT a) {
    reinterpret_cast<My_Value_Input*>(a)->Fl_Value_Input::draw();
}

int fl_value_input_handle(VALUEINPUT a, int e) {
    return reinterpret_cast<My_Value_Input*>(a)->Fl_Value_Input::handle(e);
}


