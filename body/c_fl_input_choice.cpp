

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Input_Choice.H>
#include "c_fl_input_choice.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Input_Choice : public Ada_Resizing<Fl_Input_Choice> {
public:
    using Ada_Resizing<Fl_Input_Choice>::Ada_Resizing;

    friend void fl_input_choice_draw(INPUTCHOICE n);
    friend int fl_input_choice_handle(INPUTCHOICE n, int e);

    void draw();
    int handle(int e);
};

void My_Input_Choice::draw() {
    widget_draw_hook(this->user_data());
}

int My_Input_Choice::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  The parts' callbacks

//  FLTK's callbacks for the input and the menu button find the
//  Fl_Input_Choice through their data, the parts' user_data
//  (Fl_Input_Choice.cxx:206, 237, 266, 270).  The binding keeps each part's
//  Ada record there, so these pass the parent instead, which both parts'
//  parent() is.  FLTKAda-BUGS.md 15, FLTK-issues.md F2.

static Fl_Callback_p input_choice_input_cb = 0;
static Fl_Callback_p input_choice_menu_cb = 0;

static void input_choice_input_thunk(Fl_Widget * w, void *) {
    input_choice_input_cb(w, w->parent());
}

static void input_choice_menu_thunk(Fl_Widget * w, void *) {
    input_choice_menu_cb(w, w->parent());
}




//  Flattened C API

INPUTCHOICE new_fl_input_choice(int x, int y, int w, int h, char* label) {
    My_Input_Choice *n = new My_Input_Choice(x, y, w, h, label);
    input_choice_input_cb = n->input()->callback();
    n->input()->callback(input_choice_input_thunk);
    input_choice_menu_cb = n->menubutton()->callback();
    n->menubutton()->callback(input_choice_menu_thunk);
    return n;
}

void free_fl_input_choice(INPUTCHOICE n) {
    if (fl_inside_callback) {
        fl_delete_widget(n);
    } else {
        delete static_cast<My_Input_Choice*>(n);
    }
}




void * fl_input_choice_input(INPUTCHOICE n) {
    return static_cast<Fl_Input_Choice*>(n)->input();
}

void * fl_input_choice_menubutton(INPUTCHOICE n) {
    return static_cast<Fl_Input_Choice*>(n)->menubutton();
}




void fl_input_choice_clear(INPUTCHOICE n) {
    static_cast<Fl_Input_Choice*>(n)->clear();
}




int fl_input_choice_changed(INPUTCHOICE n) {
    return static_cast<Fl_Input_Choice*>(n)->changed();
}

void fl_input_choice_clear_changed(INPUTCHOICE n) {
    static_cast<Fl_Input_Choice*>(n)->clear_changed();
}

void fl_input_choice_set_changed(INPUTCHOICE n) {
    static_cast<Fl_Input_Choice*>(n)->set_changed();
}

int fl_input_choice_get_down_box(INPUTCHOICE n) {
    return static_cast<Fl_Input_Choice*>(n)->down_box();
}

void fl_input_choice_set_down_box(INPUTCHOICE n, int t) {
    static_cast<Fl_Input_Choice*>(n)->down_box(static_cast<Fl_Boxtype>(t));
}

unsigned int fl_input_choice_get_textcolor(INPUTCHOICE n) {
    return static_cast<Fl_Input_Choice*>(n)->textcolor();
}

void fl_input_choice_set_textcolor(INPUTCHOICE n, unsigned int t) {
    static_cast<Fl_Input_Choice*>(n)->textcolor(t);
}

int fl_input_choice_get_textfont(INPUTCHOICE n) {
    return static_cast<Fl_Input_Choice*>(n)->textfont();
}

void fl_input_choice_set_textfont(INPUTCHOICE n, int t) {
    static_cast<Fl_Input_Choice*>(n)->textfont(t);
}

int fl_input_choice_get_textsize(INPUTCHOICE n) {
    return static_cast<Fl_Input_Choice*>(n)->textsize();
}

void fl_input_choice_set_textsize(INPUTCHOICE n, int t) {
    static_cast<Fl_Input_Choice*>(n)->textsize(t);
}

const char * fl_input_choice_get_value(INPUTCHOICE n) {
    return static_cast<Fl_Input_Choice*>(n)->value();
}

void fl_input_choice_set_value(INPUTCHOICE n, const char * t) {
    static_cast<Fl_Input_Choice*>(n)->value(t);
}

void fl_input_choice_set_value2(INPUTCHOICE n, int t) {
    static_cast<Fl_Input_Choice*>(n)->value(t);
}




void fl_input_choice_resize(INPUTCHOICE n, int x, int y, int w, int h) {
    ada_default_resize(static_cast<Fl_Widget*>(n), x, y, w, h);
}




void fl_input_choice_draw(INPUTCHOICE n) {
    static_cast<My_Input_Choice*>(n)->Fl_Input_Choice::draw();
}

int fl_input_choice_handle(INPUTCHOICE n, int e) {
    return static_cast<My_Input_Choice*>(n)->Fl_Input_Choice::handle(e);
}


