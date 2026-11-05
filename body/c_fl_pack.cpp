

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Pack.H>
#include "c_fl_pack.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Pack : public Ada_Resizing<Fl_Pack> {
public:
    using Ada_Resizing<Fl_Pack>::Ada_Resizing;

    friend void fl_pack_draw(PACK n);
    friend int fl_pack_handle(PACK n, int e);

    void draw();
    int handle(int e);
};

void My_Pack::draw() {
    widget_draw_hook(this->user_data());
}

int My_Pack::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

PACK new_fl_pack(int x, int y, int w, int h, char* label) {
    My_Pack *b = new My_Pack(x, y, w, h, label);
    return b;
}

void free_fl_pack(PACK p) {
    if (fl_inside_callback) {
        fl_delete_widget(p);
    } else {
        delete static_cast<My_Pack*>(p);
    }
}




int fl_pack_get_spacing(PACK p) {
    return static_cast<Fl_Pack*>(p)->spacing();
}

void fl_pack_set_spacing(PACK p, int t) {
    static_cast<Fl_Pack*>(p)->spacing(t);
}




void fl_pack_draw(PACK n) {
    static_cast<My_Pack*>(n)->Fl_Pack::draw();
}

int fl_pack_handle(PACK n, int e) {
    return static_cast<My_Pack*>(n)->Fl_Pack::handle(e);
}


