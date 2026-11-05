

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Adjuster.H>
#include "c_fl_adjuster.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" int valuator_format_hook(void * ud, char * buf);




//  Non-friend protected access

class Friend_Adjuster : Fl_Adjuster {
public:
    using Fl_Adjuster::value_damage;
};




//  Attaching all relevant hooks and friends

class My_Adjuster : public Ada_Resizing<Fl_Adjuster> {
public:
    using Ada_Resizing<Fl_Adjuster>::Ada_Resizing;

    friend void fl_adjuster_draw(ADJUSTER a);
    friend int fl_adjuster_handle(ADJUSTER a, int e);

    int format(char * buf);
    void draw();
    int handle(int e);
};

int My_Adjuster::format(char * buf) {
    return valuator_format_hook(this->user_data(), buf);
}

void My_Adjuster::draw() {
    widget_draw_hook(this->user_data());
}

int My_Adjuster::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

ADJUSTER new_fl_adjuster(int x, int y, int w, int h, char* label) {
    My_Adjuster *a = new My_Adjuster(x, y, w, h, label);
    return a;
}

void free_fl_adjuster(ADJUSTER a) {
    if (fl_inside_callback) {
        fl_delete_widget(a);
    } else {
        delete static_cast<My_Adjuster*>(a);
    }
}




int fl_adjuster_is_soft(ADJUSTER a) {
    return static_cast<Fl_Adjuster*>(a)->soft();
}

void fl_adjuster_set_soft(ADJUSTER a, int t) {
    static_cast<Fl_Adjuster*>(a)->soft(t);
}




void fl_adjuster_value_damage(ADJUSTER a) {
    (static_cast<Fl_Adjuster*>(a)->*(&Friend_Adjuster::value_damage))();
}

void fl_adjuster_draw(ADJUSTER a) {
    static_cast<My_Adjuster*>(a)->Fl_Adjuster::draw();
}

int fl_adjuster_handle(ADJUSTER a, int e) {
    return static_cast<My_Adjuster*>(a)->Fl_Adjuster::handle(e);
}


