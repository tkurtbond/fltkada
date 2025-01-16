

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Multiline_Output.H>
#include "c_fl_multiline_output.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Multiline_Output : public Fl_Multiline_Output {
public:
    using Fl_Multiline_Output::Fl_Multiline_Output;

    friend void fl_multiline_output_draw(MULTILINEOUTPUT i);
    friend int fl_multiline_output_handle(MULTILINEOUTPUT i, int e);

    void draw();
    int handle(int e);
};

void My_Multiline_Output::draw() {
    widget_draw_hook(this->user_data());
}

int My_Multiline_Output::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

MULTILINEOUTPUT new_fl_multiline_output(int x, int y, int w, int h, char* label) {
    My_Multiline_Output *i = new My_Multiline_Output(x, y, w, h, label);
    return i;
}

void free_fl_multiline_output(MULTILINEOUTPUT i) {
    delete static_cast<My_Multiline_Output*>(i);
}




void fl_multiline_output_draw(MULTILINEOUTPUT i) {
    static_cast<My_Multiline_Output*>(i)->Fl_Multiline_Output::draw();
}

int fl_multiline_output_handle(MULTILINEOUTPUT i, int e) {
    return static_cast<My_Multiline_Output*>(i)->Fl_Multiline_Output::handle(e);
}


