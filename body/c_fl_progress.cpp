

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Progress.H>
#include "c_fl_progress.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Progress : public Ada_Resizing<Fl_Progress> {
public:
    using Ada_Resizing<Fl_Progress>::Ada_Resizing;

    friend void fl_progress_draw(PROGRESS p);
    friend int fl_progress_handle(PROGRESS p, int e);

    void draw();
    int handle(int e);
};

void My_Progress::draw() {
    widget_draw_hook(this->user_data());
}

int My_Progress::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

PROGRESS new_fl_progress(int x, int y, int w, int h, char* label) {
    My_Progress *p = new My_Progress(x, y, w, h, label);
    return p;
}

void free_fl_progress(PROGRESS p) {
    if (fl_inside_callback) {
        fl_delete_widget(p);
    } else {
        delete static_cast<My_Progress*>(p);
    }
}




float fl_progress_get_minimum(PROGRESS p) {
    return static_cast<Fl_Progress*>(p)->minimum();
}

void fl_progress_set_minimum(PROGRESS p, float t) {
    static_cast<Fl_Progress*>(p)->minimum(t);
}

float fl_progress_get_maximum(PROGRESS p) {
    return static_cast<Fl_Progress*>(p)->maximum();
}

void fl_progress_set_maximum(PROGRESS p, float t) {
    static_cast<Fl_Progress*>(p)->maximum(t);
}

float fl_progress_get_value(PROGRESS p) {
    return static_cast<Fl_Progress*>(p)->value();
}

void fl_progress_set_value(PROGRESS p, float t) {
    static_cast<Fl_Progress*>(p)->value(t);
}




void fl_progress_draw(PROGRESS p) {
    static_cast<My_Progress*>(p)->Fl_Progress::draw();
}

int fl_progress_handle(PROGRESS p, int e) {
    return static_cast<My_Progress*>(p)->Fl_Progress::handle(e);
}


