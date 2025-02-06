

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Tabs.H>
#include "c_fl_tabs.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Non-friend protected access

class Friend_Tabs : Fl_Tabs {
public:
    using Fl_Tabs::redraw_tabs;
};




//  Attaching all relevant hooks and friends

class My_Tabs : public Fl_Tabs {
public:
    using Fl_Tabs::Fl_Tabs;

    friend void fl_tabs_draw(TABS t);
    friend int fl_tabs_handle(TABS t, int e);

    void draw();
    int handle(int e);
};

void My_Tabs::draw() {
    widget_draw_hook(this->user_data());
}

int My_Tabs::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

TABS new_fl_tabs(int x, int y, int w, int h, char* label) {
    My_Tabs *t = new My_Tabs(x, y, w, h, label);
    return t;
}

void free_fl_tabs(TABS t) {
    if (fl_inside_callback) {
        fl_delete_widget(t);
    } else {
        delete static_cast<My_Tabs*>(t);
    }
}




void fl_tabs_client_area(TABS t, int * x, int * y, int * w, int * h, int i) {
    static_cast<Fl_Tabs*>(t)->client_area(*x,*y,*w,*h,i);
}




void * fl_tabs_get_push(TABS t) {
    return static_cast<Fl_Tabs*>(t)->push();
}

void fl_tabs_set_push(TABS t, void * w) {
    static_cast<Fl_Tabs*>(t)->push(static_cast<Fl_Widget*>(w));
}

void * fl_tabs_get_value(TABS t) {
    return static_cast<Fl_Tabs*>(t)->value();
}

void fl_tabs_set_value(TABS t, void * w) {
    static_cast<Fl_Tabs*>(t)->value(static_cast<Fl_Widget*>(w));
}

void * fl_tabs_which(TABS t, int x, int y) {
    return static_cast<Fl_Tabs*>(t)->which(x,y);
}




void fl_tabs_draw(TABS t) {
    static_cast<My_Tabs*>(t)->Fl_Tabs::draw();
}

void fl_tabs_redraw_tabs(TABS t) {
    (static_cast<Fl_Tabs*>(t)->*(&Friend_Tabs::redraw_tabs))();
}

int fl_tabs_handle(TABS t, int e) {
    return static_cast<My_Tabs*>(t)->Fl_Tabs::handle(e);
}


