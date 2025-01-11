

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Adjuster.H>
#include "c_fl_adjuster.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Non-friend protected access

class Friend_Adjuster : Fl_Adjuster {
public:
    using Fl_Adjuster::value_damage;
};




//  Attaching all relevant hooks and friends

class My_Adjuster : public Fl_Adjuster {
public:
    using Fl_Adjuster::Fl_Adjuster;

    friend void fl_adjuster_draw(ADJUSTER a);
    friend int fl_adjuster_handle(ADJUSTER a, int e);

    void draw();
    int handle(int e);
};

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
    delete reinterpret_cast<My_Adjuster*>(a);
}




int fl_adjuster_is_soft(ADJUSTER a) {
    return reinterpret_cast<Fl_Adjuster*>(a)->soft();
}

void fl_adjuster_set_soft(ADJUSTER a, int t) {
    reinterpret_cast<Fl_Adjuster*>(a)->soft(t);
}




void fl_adjuster_value_damage(ADJUSTER a) {
    (reinterpret_cast<Fl_Adjuster*>(a)->*(&Friend_Adjuster::value_damage))();
}

void fl_adjuster_draw(ADJUSTER a) {
    reinterpret_cast<My_Adjuster*>(a)->Fl_Adjuster::draw();
}

int fl_adjuster_handle(ADJUSTER a, int e) {
    return reinterpret_cast<My_Adjuster*>(a)->Fl_Adjuster::handle(e);
}


