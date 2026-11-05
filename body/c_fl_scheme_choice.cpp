

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Fl_Scheme_Choice.H>
#include "c_fl_scheme_choice.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Scheme_Choice : public Ada_Resizing<Fl_Scheme_Choice> {
public:
    using Ada_Resizing<Fl_Scheme_Choice>::Ada_Resizing;

    friend void fl_scheme_choice_draw(SCHEMECHOICE n);
    friend int fl_scheme_choice_handle(SCHEMECHOICE n, int e);

    void draw();
    int handle(int e);
    static void chosen(Fl_Widget * w) {
        scheme_cb_(w, 0);
    }
};

void My_Scheme_Choice::draw() {
    widget_draw_hook(this->user_data());
}

int My_Scheme_Choice::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

SCHEMECHOICE new_fl_scheme_choice(int x, int y, int w, int h, char* label) {
    My_Scheme_Choice *c = new My_Scheme_Choice(x, y, w, h, label);
    return c;
}

void free_fl_scheme_choice(SCHEMECHOICE c) {
    if (fl_inside_callback) {
        fl_delete_widget(c);
    } else {
        delete static_cast<My_Scheme_Choice*>(c);
    }
}




void fl_scheme_choice_init_value(SCHEMECHOICE c) {
    static_cast<Fl_Scheme_Choice*>(c)->init_value();
}

//  FLTK's own callback reads the item at value(), unchecked, so with none
//  chosen it reads before the menu (FLTK-issues.md F28).
int fl_scheme_choice_switch(SCHEMECHOICE c) {
    Fl_Scheme_Choice * s = static_cast<Fl_Scheme_Choice*>(c);
    if (s->value() < 0 || s->value() >= s->size()) {
        return 0;
    }
    My_Scheme_Choice::chosen(s);
    return 1;
}




void fl_scheme_choice_draw(SCHEMECHOICE n) {
    static_cast<My_Scheme_Choice*>(n)->Fl_Scheme_Choice::draw();
}

int fl_scheme_choice_handle(SCHEMECHOICE n, int e) {
    return static_cast<My_Scheme_Choice*>(n)->Fl_Scheme_Choice::handle(e);
}


