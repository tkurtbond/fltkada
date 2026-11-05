

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Fl_Flex.H>
#include "c_fl_flex.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Flex : public Ada_Resizing<Fl_Flex> {
public:
    using Ada_Resizing<Fl_Flex>::Ada_Resizing;

    friend void fl_flex_draw(FLEX n);
    friend int fl_flex_handle(FLEX n, int e);

    void draw();
    int handle(int e);
};

void My_Flex::draw() {
    widget_draw_hook(this->user_data());
}

int My_Flex::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

FLEX new_fl_flex(int x, int y, int w, int h, char* label) {
    My_Flex *f = new My_Flex(x, y, w, h, label);
    return f;
}

FLEX new_fl_flex2(int x, int y, int w, int h, int d) {
    My_Flex *f = new My_Flex(x, y, w, h, d);
    return f;
}

FLEX new_fl_flex3(int w, int h, int d) {
    My_Flex *f = new My_Flex(w, h, d);
    return f;
}

FLEX new_fl_flex4(int d) {
    My_Flex *f = new My_Flex(d);
    return f;
}

void free_fl_flex(FLEX f) {
    if (fl_inside_callback) {
        fl_delete_widget(f);
    } else {
        delete static_cast<My_Flex*>(f);
    }
}




void fl_flex_end(FLEX f) {
    static_cast<Fl_Flex*>(f)->end();
}

void fl_flex_layout(FLEX f) {
    static_cast<Fl_Flex*>(f)->layout();
}

int fl_flex_get_need_layout(FLEX f) {
    return static_cast<Fl_Flex*>(f)->need_layout();
}

void fl_flex_set_need_layout(FLEX f, int s) {
    static_cast<Fl_Flex*>(f)->need_layout(s);
}




void fl_flex_set_fixed(FLEX f, void * w, int s) {
    static_cast<Fl_Flex*>(f)->fixed(static_cast<Fl_Widget*>(w), s);
}

int fl_flex_is_fixed(FLEX f, void * w) {
    return static_cast<Fl_Flex*>(f)->fixed(static_cast<Fl_Widget*>(w));
}




int fl_flex_get_margin(FLEX f) {
    return static_cast<Fl_Flex*>(f)->margin();
}

int fl_flex_get_margins(FLEX f, int * l, int * t, int * r, int * b) {
    return static_cast<Fl_Flex*>(f)->margin(l, t, r, b);
}

void fl_flex_set_margin(FLEX f, int m, int g) {
    static_cast<Fl_Flex*>(f)->margin(m, g);
}

void fl_flex_set_margins(FLEX f, int l, int t, int r, int b) {
    static_cast<Fl_Flex*>(f)->margin(l, t, r, b);
}

int fl_flex_get_gap(FLEX f) {
    return static_cast<Fl_Flex*>(f)->gap();
}

void fl_flex_set_gap(FLEX f, int g) {
    static_cast<Fl_Flex*>(f)->gap(g);
}

int fl_flex_get_spacing(FLEX f) {
    return static_cast<Fl_Flex*>(f)->spacing();
}

void fl_flex_set_spacing(FLEX f, int s) {
    static_cast<Fl_Flex*>(f)->spacing(s);
}

int fl_flex_horizontal(FLEX f) {
    return static_cast<Fl_Flex*>(f)->horizontal();
}




void fl_flex_draw(FLEX n) {
    static_cast<My_Flex*>(n)->Fl_Flex::draw();
}

int fl_flex_handle(FLEX n, int e) {
    return static_cast<My_Flex*>(n)->Fl_Flex::handle(e);
}


