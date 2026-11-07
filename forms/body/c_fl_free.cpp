

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#include <FL/Fl.H>
#include <FL/Fl_Free.H>
#include "c_fl_free.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

//  Kind is 0 for an event of FLTK's, 1 to draw, 2 for a step.
extern "C" int free_handle_hook(void * ud, int kind, int e, int x, int y);




//  Every Free's handler.  FLTK gives it the key cut to a char, and a mouse
//  event's button as 4 less the button, so neither is passed: the Ada side
//  asks FLTK.Events.  FL_FREEMEM comes from ~Fl_Free, with the widget half
//  gone and its Ada object finalized, so it isn't passed either (pofltk 105).

static int free_handler(Fl_Widget * w, int e, float x, float y, char) {
    if (e == FL_FREEMEM || w->user_data() == nullptr) {
        return 0;
    }
    int kind = e == FL_DRAW ? 1 : e == FL_STEP ? 2 : 0;
    if (kind != 0) {
        return free_handle_hook(w->user_data(), kind, 0, 0, 0);
    }
    return free_handle_hook(w->user_data(), 0, e, static_cast<int>(x), static_cast<int>(y));
}




//  Attaching all relevant hooks and friends

class My_Free : public Ada_Resizing<Fl_Free> {
public:
    My_Free(uchar k, int x, int y, int w, int h, const char * l)
        : Ada_Resizing<Fl_Free>(k, x, y, w, h, l, free_handler) {}

    friend void fl_free_draw(FREE f);
    friend int fl_free_handle(FREE f, int e);

    void draw();
    int handle(int e);
};

void My_Free::draw() {
    widget_draw_hook(this->user_data());
}

//  Fl_Free's timer calls handle(0) for a step, not handle(FL_STEP)
//  (forms_free.cxx:28, pofltk 105), and a step isn't an event the Ada
//  Handle could be given.
int My_Free::handle(int e) {
    if (e == 0) {
        return Fl_Free::handle(FL_STEP);
    }
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

FREE new_fl_free(int k, int x, int y, int w, int h, char * label) {
    My_Free *f = new My_Free(static_cast<uchar>(k), x, y, w, h, label);
    return f;
}

//  A Free deleted in a callback is deleted later, but its Ada object is
//  gone now, and its timer would go on stepping until then: with no user
//  data, free_handler ignores it.
void free_fl_free(FREE f) {
    if (fl_inside_callback) {
        static_cast<Fl_Widget*>(f)->user_data(nullptr);
        fl_delete_widget(f);
    } else {
        delete static_cast<My_Free*>(f);
    }
}




void fl_free_draw(FREE f) {
    static_cast<My_Free*>(f)->Fl_Free::draw();
}

int fl_free_handle(FREE f, int e) {
    return static_cast<My_Free*>(f)->Fl_Free::handle(e);
}


