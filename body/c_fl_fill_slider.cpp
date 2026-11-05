

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Fill_Slider.H>
#include "c_fl_fill_slider.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" int valuator_format_hook(void * ud, char * buf);




//  Attaching all relevant hooks and friends

class My_Fill_Slider : public Ada_Resizing<Fl_Fill_Slider> {
public:
    using Ada_Resizing<Fl_Fill_Slider>::Ada_Resizing;

    friend void fl_fill_slider_draw(FILLSLIDER s);
    friend int fl_fill_slider_handle(FILLSLIDER s, int e);

    int format(char * buf);
    void draw();
    int handle(int e);
};

int My_Fill_Slider::format(char * buf) {
    return valuator_format_hook(this->user_data(), buf);
}

void My_Fill_Slider::draw() {
    widget_draw_hook(this->user_data());
}

int My_Fill_Slider::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

FILLSLIDER new_fl_fill_slider(int x, int y, int w, int h, char* label) {
    My_Fill_Slider *s = new My_Fill_Slider(x, y, w, h, label);
    return s;
}

void free_fl_fill_slider(FILLSLIDER s) {
    if (fl_inside_callback) {
        fl_delete_widget(s);
    } else {
        delete static_cast<My_Fill_Slider*>(s);
    }
}




void fl_fill_slider_draw(FILLSLIDER s) {
    static_cast<My_Fill_Slider*>(s)->Fl_Fill_Slider::draw();
}

int fl_fill_slider_handle(FILLSLIDER s, int e) {
    return static_cast<My_Fill_Slider*>(s)->Fl_Fill_Slider::handle(e);
}


