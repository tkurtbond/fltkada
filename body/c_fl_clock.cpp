

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Clock.H>
#include "c_fl_clock.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Clock : public Ada_Resizing<Fl_Clock> {
public:
    using Ada_Resizing<Fl_Clock>::Ada_Resizing;

    friend void fl_clock_draw(CLOCK c);
    friend int fl_clock_handle(CLOCK c, int e);

    void draw();
    int handle(int e);
};

void My_Clock::draw() {
    widget_draw_hook(this->user_data());
}

int My_Clock::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

CLOCK new_fl_clock(int x, int y, int w, int h, char* label) {
    My_Clock *c = new My_Clock(x, y, w, h, label);
    return c;
}

CLOCK new_fl_clock2(unsigned char k, int x, int y, int w, int h, char* label) {
    My_Clock *c = new My_Clock(k,x,y,w,h,label);
    return c;
}

void free_fl_clock(CLOCK c) {
    if (fl_inside_callback) {
        fl_delete_widget(c);
    } else {
        delete static_cast<My_Clock*>(c);
    }
}




void fl_clock_draw(CLOCK c) {
    static_cast<My_Clock*>(c)->Fl_Clock::draw();
}

int fl_clock_handle(CLOCK c, int e) {
    return static_cast<My_Clock*>(c)->Fl_Clock::handle(e);
}


