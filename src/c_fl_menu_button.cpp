

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Menu_Button.H>
#include "c_fl_menu_button.h"




//  Telprot stopovers

extern "C" void menu_button_extra_init_hook
    (void * aobj, int x, int y, int w, int h, const char * l);
void fl_menu_button_extra_init(void * adaobj, int x, int y, int w, int h, const char * label) {
    menu_button_extra_init_hook(adaobj, x, y, w, h, label);
}

extern "C" void menu_button_extra_final_hook(void * aobj);
void fl_menu_button_extra_final(void * adaobj) {
    menu_button_extra_final_hook(adaobj);
}




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Menu_Button : public Fl_Menu_Button {
public:
    using Fl_Menu_Button::Fl_Menu_Button;

    friend void fl_menu_button_draw(MENUBUTTON m);
    friend int fl_menu_button_handle(MENUBUTTON m, int e);

    void draw();
    int handle(int e);
};

void My_Menu_Button::draw() {
    widget_draw_hook(this->user_data());
}

int My_Menu_Button::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

MENUBUTTON new_fl_menu_button(int x, int y, int w, int h, char* label) {
    My_Menu_Button *m = new My_Menu_Button(x, y, w, h, label);
    return m;
}

void free_fl_menu_button(MENUBUTTON m) {
    delete reinterpret_cast<My_Menu_Button*>(m);
}




void fl_menu_button_type(MENUBUTTON m, unsigned int t) {
    reinterpret_cast<Fl_Menu_Button*>(m)->type(t);
}

const void * fl_menu_button_popup(MENUBUTTON m) {
    return reinterpret_cast<Fl_Menu_Button*>(m)->popup();
}




void fl_menu_button_draw(MENUBUTTON m) {
    reinterpret_cast<My_Menu_Button*>(m)->Fl_Menu_Button::draw();
}

int fl_menu_button_handle(MENUBUTTON m, int e) {
    return reinterpret_cast<My_Menu_Button*>(m)->Fl_Menu_Button::handle(e);
}


