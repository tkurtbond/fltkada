

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Line_Dial.H>
#include "c_fl_line_dial.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Line_Dial : public Fl_Line_Dial {
public:
    using Fl_Line_Dial::Fl_Line_Dial;

    friend void fl_line_dial_draw(LINE_DIAL v);
    friend int fl_line_dial_handle(LINE_DIAL v, int e);

    void draw();
    int handle(int e);
};

void My_Line_Dial::draw() {
    widget_draw_hook(this->user_data());
}

int My_Line_Dial::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

LINE_DIAL new_fl_line_dial(int x, int y, int w, int h, char* label) {
    My_Line_Dial *v = new My_Line_Dial(x, y, w, h, label);
    return v;
}

void free_fl_line_dial(LINE_DIAL v) {
    delete reinterpret_cast<My_Line_Dial*>(v);
}




void fl_line_dial_draw(LINE_DIAL v) {
    reinterpret_cast<My_Line_Dial*>(v)->Fl_Line_Dial::draw();
}

int fl_line_dial_handle(LINE_DIAL v, int e) {
    return reinterpret_cast<My_Line_Dial*>(v)->Fl_Line_Dial::handle(e);
}


