

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Box.H>
#include "c_fl_box.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Box : public Fl_Box {
public:
    using Fl_Box::Fl_Box;

    friend void fl_box_draw(BOX n);
    friend int fl_box_handle(BOX n, int e);

    void draw();
    int handle(int e);
};

void My_Box::draw() {
    widget_draw_hook(this->user_data());
}

int My_Box::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

BOX new_fl_box(int x, int y, int w, int h, char* label) {
    My_Box *b = new My_Box(x, y, w, h, label);
    return b;
}

BOX new_fl_box2(int k, int x, int y, int w, int h, char * label) {
    My_Box *b = new My_Box(static_cast<Fl_Boxtype>(k), x, y, w, h, label);
    return b;
}

void free_fl_box(BOX b) {
    delete static_cast<My_Box*>(b);
}




void fl_box_draw(BOX n) {
    static_cast<My_Box*>(n)->Fl_Box::draw();
}

int fl_box_handle(BOX n, int e) {
    return static_cast<My_Box*>(n)->Fl_Box::handle(e);
}


