

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Input_.H>
#include "c_fl_input_.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Input : public Ada_Resizing<Fl_Input_> {
public:
    using Ada_Resizing<Fl_Input_>::Ada_Resizing;

    friend void fl_input_draw(INPUT i);
    friend int fl_input_handle(INPUT i, int e);

    void draw();
    int handle(int e);
};

void My_Input::draw() {
    widget_draw_hook(this->user_data());
}

int My_Input::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

INPUT new_fl_input(int x, int y, int w, int h, char* label) {
    My_Input *i = new My_Input(x, y, w, h, label);
    return i;
}

void free_fl_input(INPUT i) {
    if (fl_inside_callback) {
        fl_delete_widget(i);
    } else {
        delete static_cast<My_Input*>(i);
    }
}




int fl_input_copy(INPUT i, int c) {
    return static_cast<Fl_Input_*>(i)->copy(c);
}

int fl_input_cut(INPUT i) {
    return static_cast<Fl_Input_*>(i)->cut();
}

int fl_input_cut2(INPUT i, int b) {
    return static_cast<Fl_Input_*>(i)->cut(b);
}

int fl_input_cut3(INPUT i, int a, int b) {
    return static_cast<Fl_Input_*>(i)->cut(a,b);
}

int fl_input_copy_cuts(INPUT i) {
    return static_cast<Fl_Input_*>(i)->copy_cuts();
}

int fl_input_undo(INPUT i) {
    return static_cast<Fl_Input_*>(i)->undo();
}

int fl_input_redo(INPUT i) {
    return static_cast<Fl_Input_*>(i)->redo();
}

int fl_input_can_undo(INPUT i) {
    return static_cast<Fl_Input_*>(i)->can_undo();
}

int fl_input_can_redo(INPUT i) {
    return static_cast<Fl_Input_*>(i)->can_redo();
}




int fl_input_get_readonly(INPUT i) {
    return static_cast<Fl_Input_*>(i)->readonly();
}

void fl_input_set_readonly(INPUT i, int t) {
    static_cast<Fl_Input_*>(i)->readonly(t);
}

int fl_input_get_tab_nav(INPUT i) {
    return static_cast<Fl_Input_*>(i)->tab_nav();
}

void fl_input_set_tab_nav(INPUT i, int t) {
    static_cast<Fl_Input_*>(i)->tab_nav(t);
}

int fl_input_get_wrap(INPUT i) {
    return static_cast<Fl_Input_*>(i)->wrap();
}

void fl_input_set_wrap(INPUT i, int t) {
    static_cast<Fl_Input_*>(i)->wrap(t);
}




int fl_input_get_input_type(INPUT i) {
    return static_cast<Fl_Input_*>(i)->input_type();
}

void fl_input_set_input_type(INPUT i, int t) {
    static_cast<Fl_Input_*>(i)->input_type(t);
}

int fl_input_get_shortcut(INPUT i) {
    return static_cast<Fl_Input_*>(i)->shortcut();
}

void fl_input_set_shortcut(INPUT i, int t) {
    static_cast<Fl_Input_*>(i)->shortcut(t);
}

int fl_input_get_mark(INPUT i) {
    return static_cast<Fl_Input_*>(i)->mark();
}

int fl_input_set_mark(INPUT i, int t) {
    return static_cast<Fl_Input_*>(i)->mark(t);
}

int fl_input_get_position(INPUT i) {
    return static_cast<Fl_Input_*>(i)->insert_position();
}

int fl_input_set_position(INPUT i, int t) {
    return static_cast<Fl_Input_*>(i)->insert_position(t);
}

int fl_input_set_position2(INPUT i, int p, int m) {
    return static_cast<Fl_Input_*>(i)->insert_position(p, m);
}




unsigned int fl_input_index(INPUT i, int p) {
    return static_cast<Fl_Input_*>(i)->index(p);
}

int fl_input_insert(INPUT i, const char * s, int l) {
    return static_cast<Fl_Input_*>(i)->insert(s,l);
}

int fl_input_replace(INPUT i, int b, int e, const char * s, int l) {
    return static_cast<Fl_Input_*>(i)->replace(b,e,s,l);
}

const char * fl_input_get_value(INPUT i) {
    return static_cast<Fl_Input_*>(i)->value();
}

int fl_input_set_value(INPUT i, char * s, int len) {
    return static_cast<Fl_Input_*>(i)->value(s,len);
}




int fl_input_get_maximum_size(INPUT i) {
    return static_cast<Fl_Input_*>(i)->maximum_size();
}

void fl_input_set_maximum_size(INPUT i, int t) {
    static_cast<Fl_Input_*>(i)->maximum_size(t);
}

int fl_input_get_size(INPUT i) {
    return static_cast<Fl_Input_*>(i)->size();
}




unsigned int fl_input_get_cursor_color(INPUT i) {
    return static_cast<Fl_Input_*>(i)->cursor_color();
}

void fl_input_set_cursor_color(INPUT i, unsigned int t) {
    static_cast<Fl_Input_*>(i)->cursor_color(t);
}

unsigned int fl_input_get_textcolor(INPUT i) {
    return static_cast<Fl_Input_*>(i)->textcolor();
}

void fl_input_set_textcolor(INPUT i, unsigned int t) {
    static_cast<Fl_Input_*>(i)->textcolor(t);
}

int fl_input_get_textfont(INPUT i) {
    return static_cast<Fl_Input_*>(i)->textfont();
}

void fl_input_set_textfont(INPUT i, int t) {
    static_cast<Fl_Input_*>(i)->textfont(t);
}

int fl_input_get_textsize(INPUT i) {
    return static_cast<Fl_Input_*>(i)->textsize();
}

void fl_input_set_textsize(INPUT i, int t) {
    static_cast<Fl_Input_*>(i)->textsize(t);
}




void fl_input_set_size(INPUT i, int w, int h) {
    static_cast<Fl_Input_*>(i)->size(w,h);
}

void fl_input_resize(INPUT i, int x, int y, int w, int h) {
    ada_default_resize(static_cast<Fl_Widget*>(i), x, y, w, h);
}




void fl_input_draw(INPUT i) {
    //  This inherits directly from Fl_Widget::draw, and
    //  the Fl_Widget draw method doesn't technically exist, so...
    (void)(i);
    //  It is more convenient for this function to exist, however,
    //  even though it will likely never be called, because it simplifies
    //  and makes uniform the implementation of the Ada Input Draw subprogram.
}

int fl_input_handle(INPUT i, int e) {
    return static_cast<My_Input*>(i)->Fl_Input_::handle(e);
}


