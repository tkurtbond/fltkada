

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_File_Input.H>
#include "c_fl_file_input.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_File_Input : public Ada_Resizing<Fl_File_Input> {
public:
    using Ada_Resizing<Fl_File_Input>::Ada_Resizing;

    friend void fl_file_input_draw(FILEINPUT i);
    friend int fl_file_input_handle(FILEINPUT i, int e);

    void draw();
    int handle(int e);
};

void My_File_Input::draw() {
    widget_draw_hook(this->user_data());
}

int My_File_Input::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

FILEINPUT new_fl_file_input(int x, int y, int w, int h, char* label) {
    My_File_Input *i = new My_File_Input(x, y, w, h, label);
    return i;
}

void free_fl_file_input(FILEINPUT i) {
    if (fl_inside_callback) {
        fl_delete_widget(i);
    } else {
        delete static_cast<My_File_Input*>(i);
    }
}




int fl_file_input_get_down_box(FILEINPUT i) {
    return static_cast<Fl_File_Input*>(i)->down_box();
}

void fl_file_input_set_down_box(FILEINPUT i, int t) {
    static_cast<Fl_File_Input*>(i)->down_box(static_cast<Fl_Boxtype>(t));
}

unsigned int fl_file_input_get_errorcolor(FILEINPUT i) {
    return static_cast<Fl_File_Input*>(i)->errorcolor();
}

void fl_file_input_set_errorcolor(FILEINPUT i, unsigned int t) {
    static_cast<Fl_File_Input*>(i)->errorcolor(t);
}




const char * fl_file_input_get_value(FILEINPUT i) {
    return static_cast<Fl_File_Input*>(i)->value();
}

int fl_file_input_set_value(FILEINPUT i, const char * s, int len) {
    return static_cast<Fl_File_Input*>(i)->value(s,len);
}




void fl_file_input_draw(FILEINPUT i) {
    static_cast<My_File_Input*>(i)->Fl_File_Input::draw();
}

int fl_file_input_handle(FILEINPUT i, int e) {
    return static_cast<My_File_Input*>(i)->Fl_File_Input::handle(e);
}


