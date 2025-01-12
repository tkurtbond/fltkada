

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Group.H>
#include <FL/Fl_Widget.H>
#include "c_fl_group.h"
#include "c_fl_widget.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Group : public Fl_Group {
public:
    using Fl_Group::Fl_Group;

    friend void fl_group_draw(GROUP g);
    friend int fl_group_handle(GROUP g, int e);

    void draw();
    int handle(int e);
};

void My_Group::draw() {
    widget_draw_hook(this->user_data());
}

int My_Group::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

GROUP new_fl_group(int x, int y, int w, int h, char* label) {
    My_Group *g = new My_Group(x, y, w, h, label);
    return g;
}

void free_fl_group(GROUP g) {
    delete reinterpret_cast<My_Group*>(g);
}




void fl_group_end(GROUP g) {
    reinterpret_cast<Fl_Group*>(g)->end();
}




void fl_group_add(GROUP g, WIDGET item) {
    reinterpret_cast<Fl_Group*>(g)->add(reinterpret_cast<Fl_Widget*>(item));
}

void fl_group_insert(GROUP g, WIDGET item, int place) {
    reinterpret_cast<Fl_Group*>(g)->insert(*(reinterpret_cast<Fl_Widget*>(item)), place);
}

void fl_group_insert2(GROUP g, WIDGET item, WIDGET before) {
    reinterpret_cast<Fl_Group*>(g)->insert(*(reinterpret_cast<Fl_Widget*>(item)), reinterpret_cast<Fl_Widget*>(before));
}

void fl_group_remove(GROUP g, WIDGET item) {
    reinterpret_cast<Fl_Group*>(g)->remove(reinterpret_cast<Fl_Widget*>(item));
}

void fl_group_remove2(GROUP g, int place) {
    reinterpret_cast<Fl_Group*>(g)->remove(place);
}




void * fl_group_child(GROUP g, int place) {
    return reinterpret_cast<Fl_Group*>(g)->child(place);
}

int fl_group_find(GROUP g, WIDGET item) {
    return reinterpret_cast<Fl_Group*>(g)->find(reinterpret_cast<Fl_Widget*>(item));
}

int fl_group_children(GROUP g) {
    return reinterpret_cast<Fl_Group*>(g)->children();
}




unsigned int fl_group_get_clip_children(GROUP g) {
    return reinterpret_cast<Fl_Group*>(g)->clip_children();
}

void fl_group_set_clip_children(GROUP g, int c) {
    reinterpret_cast<Fl_Group*>(g)->clip_children(c);
}




void * fl_group_get_resizable(GROUP g) {
    return reinterpret_cast<Fl_Group*>(g)->resizable();
}

void fl_group_set_resizable(GROUP g, WIDGET item) {
    reinterpret_cast<Fl_Group*>(g)->resizable(reinterpret_cast<Fl_Widget*>(item));
}

void fl_group_init_sizes(GROUP g) {
    reinterpret_cast<Fl_Group*>(g)->init_sizes();
}




void * fl_group_get_current() {
    return Fl_Group::current();
}

void fl_group_set_current(GROUP g) {
    Fl_Group::current(reinterpret_cast<Fl_Group*>(g));
}




void fl_group_draw(GROUP g) {
    reinterpret_cast<My_Group*>(g)->Fl_Group::draw();
}

int fl_group_handle(GROUP g, int e) {
    return reinterpret_cast<My_Group*>(g)->Fl_Group::handle(e);
}


