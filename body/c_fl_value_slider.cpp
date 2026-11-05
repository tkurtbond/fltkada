

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Value_Slider.H>
#include "c_fl_value_slider.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" int valuator_format_hook(void * ud, char * buf);




//  Attaching all relevant hooks and friends

class My_Value_Slider : public Ada_Resizing<Fl_Value_Slider> {
public:
    using Ada_Resizing<Fl_Value_Slider>::Ada_Resizing;

    friend void fl_value_slider_draw(VALUESLIDER s);
    friend int fl_value_slider_handle(VALUESLIDER s, int e);

    int format(char * buf);
    void draw();
    int handle(int e);
};

int My_Value_Slider::format(char * buf) {
    return valuator_format_hook(this->user_data(), buf);
}

void My_Value_Slider::draw() {
    widget_draw_hook(this->user_data());
}

int My_Value_Slider::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

VALUESLIDER new_fl_value_slider(int x, int y, int w, int h, char* label) {
    My_Value_Slider *s = new My_Value_Slider(x, y, w, h, label);
    return s;
}

void free_fl_value_slider(VALUESLIDER s) {
    if (fl_inside_callback) {
        fl_delete_widget(s);
    } else {
        delete static_cast<My_Value_Slider*>(s);
    }
}




unsigned int fl_value_slider_get_textcolor(VALUESLIDER s) {
    return static_cast<Fl_Value_Slider*>(s)->textcolor();
}

void fl_value_slider_set_textcolor(VALUESLIDER s, unsigned int t) {
    static_cast<Fl_Value_Slider*>(s)->textcolor(t);
}

int fl_value_slider_get_textfont(VALUESLIDER s) {
    return static_cast<Fl_Value_Slider*>(s)->textfont();
}

void fl_value_slider_set_textfont(VALUESLIDER s, int t) {
    static_cast<Fl_Value_Slider*>(s)->textfont(t);
}

int fl_value_slider_get_textsize(VALUESLIDER s) {
    return static_cast<Fl_Value_Slider*>(s)->textsize();
}

void fl_value_slider_set_textsize(VALUESLIDER s, int t) {
    static_cast<Fl_Value_Slider*>(s)->textsize(t);
}




void fl_value_slider_draw(VALUESLIDER s) {
    static_cast<My_Value_Slider*>(s)->Fl_Value_Slider::draw();
}

int fl_value_slider_handle(VALUESLIDER s, int e) {
    return static_cast<My_Value_Slider*>(s)->Fl_Value_Slider::handle(e);
}


