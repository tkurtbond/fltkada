

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <string>
#include <FL/Fl_Input.H>
#include "c_fl_input.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Telprot stopover

extern "C" void text_input_extra_init_hook(void * aobj, int x, int y, int w, int h, const char * l);
void fl_text_input_extra_init(void * adaobj, int x, int y, int w, int h, const char * label) {
    text_input_extra_init_hook(adaobj, x, y, w, h, label);
}




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Text_Input : public Ada_Resizing<Fl_Input> {
public:
    using Ada_Resizing<Fl_Input>::Ada_Resizing;

    friend void fl_text_input_draw(TEXTINPUT t);
    friend int fl_text_input_handle(TEXTINPUT t, int e);

    void draw();
    int handle(int e);
};

void My_Text_Input::draw() {
    widget_draw_hook(this->user_data());
}

int My_Text_Input::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

TEXTINPUT new_fl_text_input(int x, int y, int w, int h, char * label) {
    My_Text_Input * t = new My_Text_Input(x, y, w, h, label);
    return t;
}

void free_fl_text_input(TEXTINPUT t) {
    if (fl_inside_callback) {
        fl_delete_widget(t);
    } else {
        delete static_cast<My_Text_Input*>(t);
    }
}




void fl_text_input_draw(TEXTINPUT t) {
    static_cast<My_Text_Input*>(t)->Fl_Input::draw();
}

int fl_text_input_handle(TEXTINPUT t, int e) {
    return static_cast<My_Text_Input*>(t)->Fl_Input::handle(e);
}




//  The menu an input or a text display pops up on the right button.
//  FLTK keeps these pointers and labels the menu from them each time
//  it opens it, so the texts are copied here and kept.

static const char ** menu_text_ptr(int which) {
    switch (which) {
    case 0: return &Fl_Input::cut_menu_text;
    case 1: return &Fl_Input::copy_menu_text;
    default: return &Fl_Input::paste_menu_text;
    }
}

const char * fl_text_input_get_menu_text(int which) {
    return *menu_text_ptr(which);
}

void fl_text_input_set_menu_text(int which, const char * text) {
    static std::string kept[3];
    int i = which < 0 || which > 2 ? 2 : which;
    kept[i] = text;
    *menu_text_ptr(i) = kept[i].c_str();
}


