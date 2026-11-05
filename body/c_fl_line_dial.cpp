

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Line_Dial.H>
#include "c_fl_line_dial.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" int valuator_format_hook(void * ud, char * buf);




//  Attaching all relevant hooks and friends

class My_Line_Dial : public Ada_Resizing<Fl_Line_Dial> {
public:
    using Ada_Resizing<Fl_Line_Dial>::Ada_Resizing;

    friend void fl_line_dial_draw(LINEDIAL v);
    friend int fl_line_dial_handle(LINEDIAL v, int e);

    int format(char * buf);
    void draw();
    int handle(int e);
};

int My_Line_Dial::format(char * buf) {
    return valuator_format_hook(this->user_data(), buf);
}

void My_Line_Dial::draw() {
    widget_draw_hook(this->user_data());
}

int My_Line_Dial::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

LINEDIAL new_fl_line_dial(int x, int y, int w, int h, char* label) {
    My_Line_Dial *v = new My_Line_Dial(x, y, w, h, label);
    return v;
}

void free_fl_line_dial(LINEDIAL v) {
    if (fl_inside_callback) {
        fl_delete_widget(v);
    } else {
        delete static_cast<My_Line_Dial*>(v);
    }
}




void fl_line_dial_draw(LINEDIAL v) {
    static_cast<My_Line_Dial*>(v)->Fl_Line_Dial::draw();
}

int fl_line_dial_handle(LINEDIAL v, int e) {
    return static_cast<My_Line_Dial*>(v)->Fl_Line_Dial::handle(e);
}


