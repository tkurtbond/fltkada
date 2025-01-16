

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Value_Output.H>
#include "c_fl_value_output.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Value_Output : public Fl_Value_Output {
public:
    using Fl_Value_Output::Fl_Value_Output;

    friend void fl_value_output_draw(VALUEOUTPUT a);
    friend int fl_value_output_handle(VALUEOUTPUT a, int e);

    void draw();
    int handle(int e);
};

void My_Value_Output::draw() {
    widget_draw_hook(this->user_data());
}

int My_Value_Output::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

VALUEOUTPUT new_fl_value_output(int x, int y, int w, int h, char* label) {
    My_Value_Output *a = new My_Value_Output(x, y, w, h, label);
    return a;
}

void free_fl_value_output(VALUEOUTPUT a) {
    delete static_cast<My_Value_Output*>(a);
}




int fl_value_output_is_soft(VALUEOUTPUT a) {
    return static_cast<Fl_Value_Output*>(a)->soft();
}

void fl_value_output_set_soft(VALUEOUTPUT a, int t) {
    static_cast<Fl_Value_Output*>(a)->soft(t);
}




unsigned int fl_value_output_get_text_color(VALUEOUTPUT v) {
    return static_cast<Fl_Value_Output*>(v)->textcolor();
}

void fl_value_output_set_text_color(VALUEOUTPUT v, unsigned int c) {
    static_cast<Fl_Value_Output*>(v)->textcolor(static_cast<Fl_Color>(c));
}

int fl_value_output_get_text_font(VALUEOUTPUT v) {
    return static_cast<Fl_Value_Output*>(v)->textfont();
}

void fl_value_output_set_text_font(VALUEOUTPUT v, int f) {
    static_cast<Fl_Value_Output*>(v)->textfont(static_cast<Fl_Font>(f));
}

int fl_value_output_get_text_size(VALUEOUTPUT v) {
    return static_cast<Fl_Value_Output*>(v)->textsize();
}

void fl_value_output_set_text_size(VALUEOUTPUT v, int s) {
    static_cast<Fl_Value_Output*>(v)->textsize(static_cast<Fl_Fontsize>(s));
}




void fl_value_output_draw(VALUEOUTPUT a) {
    static_cast<My_Value_Output*>(a)->Fl_Value_Output::draw();
}

int fl_value_output_handle(VALUEOUTPUT a, int e) {
    return static_cast<My_Value_Output*>(a)->Fl_Value_Output::handle(e);
}


