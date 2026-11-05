

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Group.H>
#include <FL/Fl_Widget.H>
#include "c_fl_group.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Non-friend protected access

class Friend_Group : Fl_Group {
public:
    using Fl_Group::draw_child;
    using Fl_Group::draw_children;
    using Fl_Group::draw_outside_label;
    using Fl_Group::update_child;
};




//  Attaching all relevant hooks and friends

class My_Group : public Ada_Resizing<Fl_Group> {
public:
    using Ada_Resizing<Fl_Group>::Ada_Resizing;

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
    if (fl_inside_callback) {
        fl_delete_widget(g);
    } else {
        delete static_cast<My_Group*>(g);
    }
}




void fl_group_add(GROUP g, WIDGET item) {
    static_cast<Fl_Group*>(g)->add(static_cast<Fl_Widget*>(item));
}

void fl_group_insert(GROUP g, WIDGET item, int place) {
    static_cast<Fl_Group*>(g)->insert(*(static_cast<Fl_Widget*>(item)), place);
}

void fl_group_insert2(GROUP g, WIDGET item, WIDGET before) {
    static_cast<Fl_Group*>(g)->insert(*(static_cast<Fl_Widget*>(item)), static_cast<Fl_Widget*>(before));
}

void fl_group_remove(GROUP g, WIDGET item) {
    static_cast<Fl_Group*>(g)->remove(static_cast<Fl_Widget*>(item));
}

void fl_group_remove2(GROUP g, int place) {
    static_cast<Fl_Group*>(g)->remove(place);
}




void * fl_group_child(GROUP g, int place) {
    return static_cast<Fl_Group*>(g)->child(place);
}

int fl_group_find(GROUP g, WIDGET item) {
    return static_cast<Fl_Group*>(g)->find(static_cast<Fl_Widget*>(item));
}

int fl_group_children(GROUP g) {
    return static_cast<Fl_Group*>(g)->children();
}




unsigned int fl_group_get_clip_children(GROUP g) {
    return static_cast<Fl_Group*>(g)->clip_children();
}

void fl_group_set_clip_children(GROUP g, int c) {
    static_cast<Fl_Group*>(g)->clip_children(c);
}




void fl_group_add_resizable(GROUP g, WIDGET w) {
    Fl_Widget &ref = *(static_cast<Fl_Widget*>(w));
    static_cast<Fl_Group*>(g)->add_resizable(ref);
}

void * fl_group_get_resizable(GROUP g) {
    return static_cast<Fl_Group*>(g)->resizable();
}

void fl_group_set_resizable(GROUP g, WIDGET item) {
    static_cast<Fl_Group*>(g)->resizable(static_cast<Fl_Widget*>(item));
}

void fl_group_init_sizes(GROUP g) {
    static_cast<Fl_Group*>(g)->init_sizes();
}

void fl_group_resize(GROUP g, int x, int y, int w, int h) {
    ada_default_resize(static_cast<Fl_Widget*>(g), x, y, w, h);
}




void * fl_group_get_current() {
    return Fl_Group::current();
}

void fl_group_set_current(GROUP g) {
    Fl_Group::current(static_cast<Fl_Group*>(g));
}

void fl_group_begin(GROUP g) {
    static_cast<Fl_Group*>(g)->begin();
}

void fl_group_end(GROUP g) {
    static_cast<Fl_Group*>(g)->end();
}




void fl_group_draw(GROUP g) {
    static_cast<My_Group*>(g)->Fl_Group::draw();
}

void fl_group_draw_child(GROUP g, WIDGET w) {
    Fl_Widget &ref = *(static_cast<Fl_Widget*>(w));
    (static_cast<Fl_Group*>(g)->*(&Friend_Group::draw_child))(ref);
}

void fl_group_draw_children(GROUP g) {
    (static_cast<Fl_Group*>(g)->*(&Friend_Group::draw_children))();
}

void fl_group_draw_outside_label(GROUP g, WIDGET w) {
    Fl_Widget &ref = *(static_cast<Fl_Widget*>(w));
    (static_cast<Fl_Group*>(g)->*(&Friend_Group::draw_outside_label))(ref);
}

void fl_group_update_child(GROUP g, WIDGET w) {
    Fl_Widget &ref = *(static_cast<Fl_Widget*>(w));
    (static_cast<Fl_Group*>(g)->*(&Friend_Group::update_child))(ref);
}

int fl_group_handle(GROUP g, int e) {
    return static_cast<My_Group*>(g)->Fl_Group::handle(e);
}


