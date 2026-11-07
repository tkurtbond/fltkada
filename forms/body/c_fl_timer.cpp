

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#include <FL/Fl_Timer.H>
#include "c_fl_timer.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Timer : public Ada_Resizing<Fl_Timer> {
public:
    using Ada_Resizing<Fl_Timer>::Ada_Resizing;

    friend void fl_timer_draw(TIMER t);
    friend int fl_timer_handle(TIMER t, int e);

    void draw();
    int handle(int e);
};

void My_Timer::draw() {
    widget_draw_hook(this->user_data());
}

int My_Timer::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

TIMER new_fl_timer(int k, int x, int y, int w, int h, char * label) {
    My_Timer *t = new My_Timer(static_cast<uchar>(k), x, y, w, h, label);
    return t;
}

//  A timer deleted in a callback is deleted later, but its Ada object is
//  gone now, and running out would call back to it: it is stopped.
void free_fl_timer(TIMER t) {
    if (fl_inside_callback) {
        static_cast<Fl_Timer*>(t)->suspended(1);
        fl_delete_widget(t);
    } else {
        delete static_cast<My_Timer*>(t);
    }
}




double fl_timer_get_value(TIMER t) {
    return static_cast<Fl_Timer*>(t)->value();
}

void fl_timer_set_value(TIMER t, double v) {
    static_cast<Fl_Timer*>(t)->value(v);
}

//  Direction 0 shows the time left, against FLTK's header, which says it
//  counts up (pofltk 107).
int fl_timer_counts_up(TIMER t) {
    return static_cast<Fl_Timer*>(t)->direction() != 0;
}

void fl_timer_set_counts_up(TIMER t, int u) {
    static_cast<Fl_Timer*>(t)->direction(u != 0);
}

int fl_timer_is_suspended(TIMER t) {
    return static_cast<Fl_Timer*>(t)->suspended() != 0;
}

void fl_timer_set_suspended(TIMER t, int s) {
    static_cast<Fl_Timer*>(t)->suspended(s != 0);
}




void fl_timer_draw(TIMER t) {
    static_cast<My_Timer*>(t)->Fl_Timer::draw();
}

int fl_timer_handle(TIMER t, int e) {
    return static_cast<My_Timer*>(t)->Fl_Timer::handle(e);
}


