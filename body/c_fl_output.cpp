

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Output.H>
#include "c_fl_output.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Output : public Fl_Output {
public:
    using Fl_Output::Fl_Output;

    friend void fl_output_draw(OUTPUTT i);
    friend int fl_output_handle(OUTPUTT i, int e);

    void draw();
    int handle(int e);
};

void My_Output::draw() {
    widget_draw_hook(this->user_data());
}

int My_Output::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

OUTPUTT new_fl_output(int x, int y, int w, int h, char* label) {
    My_Output *i = new My_Output(x, y, w, h, label);
    return i;
}

void free_fl_output(OUTPUTT i) {
    delete static_cast<My_Output*>(i);
}




void fl_output_draw(OUTPUTT i) {
    static_cast<My_Output*>(i)->Fl_Output::draw();
}

int fl_output_handle(OUTPUTT i, int e) {
    return static_cast<My_Output*>(i)->Fl_Output::handle(e);
}


