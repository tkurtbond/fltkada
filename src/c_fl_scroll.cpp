

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Scroll.H>
#include "c_fl_scroll.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Scroll : public Fl_Scroll {
public:
    using Fl_Scroll::Fl_Scroll;

    friend void fl_scroll_draw(SCROLL s);
    friend int fl_scroll_handle(SCROLL s, int e);

    void draw();
    int handle(int e);
};

void My_Scroll::draw() {
    widget_draw_hook(this->user_data());
}

int My_Scroll::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

SCROLL new_fl_scroll(int x, int y, int w, int h, char* label) {
    My_Scroll *s = new My_Scroll(x, y, w, h, label);
    return s;
}

void free_fl_scroll(SCROLL s) {
    delete reinterpret_cast<My_Scroll*>(s);
}




void fl_scroll_clear(SCROLL s) {
    reinterpret_cast<Fl_Scroll*>(s)->clear();
}




void fl_scroll_to(SCROLL s, int x, int y) {
    reinterpret_cast<Fl_Scroll*>(s)->scroll_to(x, y);
}

void fl_scroll_set_type(SCROLL s, int t) {
    reinterpret_cast<Fl_Scroll*>(s)->type(t);
}




int fl_scroll_get_size(SCROLL s) {
    return reinterpret_cast<Fl_Scroll*>(s)->scrollbar_size();
}

void fl_scroll_set_size(SCROLL s, int t) {
    reinterpret_cast<Fl_Scroll*>(s)->scrollbar_size(t);
}

int fl_scroll_xposition(SCROLL s) {
    return reinterpret_cast<Fl_Scroll*>(s)->xposition();
}

int fl_scroll_yposition(SCROLL s) {
    return reinterpret_cast<Fl_Scroll*>(s)->yposition();
}




void fl_scroll_draw(SCROLL s) {
    reinterpret_cast<My_Scroll*>(s)->Fl_Scroll::draw();
}

int fl_scroll_handle(SCROLL s, int e) {
    return reinterpret_cast<My_Scroll*>(s)->Fl_Scroll::handle(e);
}


