

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Choice.H>
#include "c_fl_choice.h"
#include "c_fl_menuitem.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Choice : public Fl_Choice {
public:
    using Fl_Choice::Fl_Choice;

    friend void fl_choice_draw(CHOICE n);
    friend int fl_choice_handle(CHOICE n, int e);

    void draw();
    int handle(int e);
};

void My_Choice::draw() {
    widget_draw_hook(this->user_data());
}

int My_Choice::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

CHOICE new_fl_choice(int x, int y, int w, int h, char* label) {
    My_Choice *b = new My_Choice(x, y, w, h, label);
    return b;
}

void free_fl_choice(CHOICE b) {
    plain_menu(static_cast<Fl_Menu_*>(b));
    if (fl_inside_callback) {
        fl_delete_widget(b);
    } else {
        delete static_cast<My_Choice*>(b);
    }
}




int fl_choice_value(CHOICE c) {
    return static_cast<Fl_Choice*>(c)->value();
}

int fl_choice_set_value(CHOICE c, void * i) {
    return static_cast<Fl_Choice*>(c)->value(static_cast<Fl_Menu_Item*>(i));
}

int fl_choice_set_value2(CHOICE c, int p) {
    return static_cast<Fl_Choice*>(c)->value(p);
}




void fl_choice_draw(CHOICE n) {
    static_cast<My_Choice*>(n)->Fl_Choice::draw();
}

int fl_choice_handle(CHOICE n, int e) {
    return static_cast<My_Choice*>(n)->Fl_Choice::handle(e);
}


