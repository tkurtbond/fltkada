

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Box.H>
#include "c_fl_box.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Telprot stopover

extern "C" void box_extra_init_hook(void * aobj, int x, int y, int w, int h, const char * l);
void fl_box_extra_init(void * adaobj, int x, int y, int w, int h, const char * label) {
    box_extra_init_hook(adaobj, x, y, w, h, label);
}




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Box : public Ada_Resizing<Fl_Box> {
public:
    using Ada_Resizing<Fl_Box>::Ada_Resizing;

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
    if (fl_inside_callback) {
        fl_delete_widget(b);
    } else {
        delete static_cast<My_Box*>(b);
    }
}




void fl_box_draw(BOX n) {
    static_cast<My_Box*>(n)->Fl_Box::draw();
}

int fl_box_handle(BOX n, int e) {
    return static_cast<My_Box*>(n)->Fl_Box::handle(e);
}

void fl_box_resize(BOX n, int x, int y, int w, int h) {
    ada_default_resize(static_cast<Fl_Widget*>(n), x, y, w, h);
}


