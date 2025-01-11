

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Wizard.H>
#include "c_fl_wizard.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Wizard : public Fl_Wizard {
public:
    using Fl_Wizard::Fl_Wizard;

    friend void fl_wizard_draw(WIZARD w);
    friend int fl_wizard_handle(WIZARD w, int e);

    void draw();
    void real_draw();
    int handle(int e);
};

void My_Wizard::draw() {
    widget_draw_hook(this->user_data());
}

void My_Wizard::real_draw() {
    // required because of Fl_Wizard::draw() being private
    // probably a bug in FLTK?
    Fl_Widget *kid = value();
    if (damage() & FL_DAMAGE_ALL) {
        if (kid) {
            draw_box(box(), x(), y(), w(), h(), kid->color());
            draw_child(*kid);
        } else {
            draw_box(box(), x(), y(), w(), h(), color());
        }
    } else if (kid) {
        update_child(*kid);
    }
}

int My_Wizard::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

WIZARD new_fl_wizard(int x, int y, int w, int h, char* label) {
    My_Wizard *g = new My_Wizard(x, y, w, h, label);
    return g;
}

void free_fl_wizard(WIZARD w) {
    delete reinterpret_cast<My_Wizard*>(w);
}




void fl_wizard_next(WIZARD w) {
    reinterpret_cast<Fl_Wizard*>(w)->next();
}

void fl_wizard_prev(WIZARD w) {
    reinterpret_cast<Fl_Wizard*>(w)->prev();
}




void * fl_wizard_get_visible(WIZARD w) {
    return reinterpret_cast<Fl_Wizard*>(w)->value();
}

void fl_wizard_set_visible(WIZARD w, void * i) {
    reinterpret_cast<Fl_Wizard*>(w)->value(reinterpret_cast<Fl_Widget*>(i));
}




void fl_wizard_draw(WIZARD w) {
    reinterpret_cast<My_Wizard*>(w)->real_draw();
}

int fl_wizard_handle(WIZARD w, int e) {
    return reinterpret_cast<My_Wizard*>(w)->Fl_Wizard::handle(e);
}


