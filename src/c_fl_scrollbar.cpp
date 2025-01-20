

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Scrollbar.H>
#include "c_fl_scrollbar.h"




//  Telprot stopovers

extern "C" void scrollbar_extra_init_hook(void * aobj, int x, int y, int w, int h, const char * l);
void fl_scrollbar_extra_init (void * adaobj, int x, int y, int w, int h, const char * label) {
    scrollbar_extra_init_hook(adaobj, x, y, w, h, label);
}

extern "C" void scrollbar_extra_final_hook(void * aobj);
void fl_scrollbar_extra_final(void * adaobj) {
    scrollbar_extra_final_hook(adaobj);
}




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" int valuator_format_hook(void * ud, char * buf);




//  Attaching all relevant hooks and friends

class My_Scrollbar : public Fl_Scrollbar {
public:
    using Fl_Scrollbar::Fl_Scrollbar;

    friend void fl_scrollbar_draw(SCROLLBAR s);
    friend int fl_scrollbar_handle(SCROLLBAR s, int e);

    int format(char * buf);
    void draw();
    int handle(int e);
};

int My_Scrollbar::format(char * buf) {
    return valuator_format_hook(this->user_data(), buf);
}

void My_Scrollbar::draw() {
    widget_draw_hook(this->user_data());
}

int My_Scrollbar::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

SCROLLBAR new_fl_scrollbar(int x, int y, int w, int h, char* label) {
    My_Scrollbar *s = new My_Scrollbar(x, y, w, h, label);
    return s;
}

void free_fl_scrollbar(SCROLLBAR s) {
    delete static_cast<My_Scrollbar*>(s);
}




int fl_scrollbar_get_linesize(SCROLLBAR s) {
    return static_cast<Fl_Scrollbar*>(s)->linesize();
}

void fl_scrollbar_set_linesize(SCROLLBAR s, int t) {
    static_cast<Fl_Scrollbar*>(s)->linesize(t);
}

int fl_scrollbar_get_value(SCROLLBAR s) {
    return static_cast<Fl_Scrollbar*>(s)->value();
}

void fl_scrollbar_set_value(SCROLLBAR s, int t) {
    static_cast<Fl_Scrollbar*>(s)->value(t);
}

void fl_scrollbar_set_value2(SCROLLBAR s, int p, int w, int f, int t) {
    static_cast<Fl_Scrollbar*>(s)->value(p,w,f,t);
}




void fl_scrollbar_draw(SCROLLBAR s) {
    static_cast<My_Scrollbar*>(s)->Fl_Scrollbar::draw();
}

int fl_scrollbar_handle(SCROLLBAR s, int e) {
    return static_cast<My_Scrollbar*>(s)->Fl_Scrollbar::handle(e);
}


