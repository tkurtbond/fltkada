

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Color_Chooser.H>
#include "c_fl_color_chooser.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Color_Chooser : public Ada_Resizing<Fl_Color_Chooser> {
public:
    using Ada_Resizing<Fl_Color_Chooser>::Ada_Resizing;

    friend void fl_color_chooser_draw(COLORCHOOSER n);
    friend int fl_color_chooser_handle(COLORCHOOSER n, int e);

    void draw();
    int handle(int e);
};

void My_Color_Chooser::draw() {
    widget_draw_hook(this->user_data());
}

int My_Color_Chooser::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

COLORCHOOSER new_fl_color_chooser(int x, int y, int w, int h, char* label) {
    My_Color_Chooser *n = new My_Color_Chooser(x, y, w, h, label);
    return n;
}

void free_fl_color_chooser(COLORCHOOSER n) {
    if (fl_inside_callback) {
        fl_delete_widget(n);
    } else {
        delete static_cast<My_Color_Chooser*>(n);
    }
}




double fl_color_chooser_r(COLORCHOOSER n) {
    return static_cast<Fl_Color_Chooser*>(n)->r();
}

double fl_color_chooser_g(COLORCHOOSER n) {
    return static_cast<Fl_Color_Chooser*>(n)->g();
}

double fl_color_chooser_b(COLORCHOOSER n) {
    return static_cast<Fl_Color_Chooser*>(n)->b();
}

int fl_color_chooser_rgb(COLORCHOOSER n, double r, double g, double b) {
    return static_cast<Fl_Color_Chooser*>(n)->rgb(r,g,b);
}




double fl_color_chooser_hue(COLORCHOOSER n) {
    return static_cast<Fl_Color_Chooser*>(n)->hue();
}

double fl_color_chooser_saturation(COLORCHOOSER n) {
    return static_cast<Fl_Color_Chooser*>(n)->saturation();
}

double fl_color_chooser_value(COLORCHOOSER n) {
    return static_cast<Fl_Color_Chooser*>(n)->value();
}

int fl_color_chooser_hsv(COLORCHOOSER n, double h, double s, double v) {
    return static_cast<Fl_Color_Chooser*>(n)->hsv(h,s,v);
}




void fl_color_chooser_hsv2rgb(double h, double s, double v, double &r, double &g, double &b) {
    Fl_Color_Chooser::hsv2rgb(h,s,v,r,g,b);
}

void fl_color_chooser_rgb2hsv(double r, double g, double b, double &h, double &s, double &v) {
    Fl_Color_Chooser::rgb2hsv(r,g,b,h,s,v);
}




int fl_color_chooser_get_mode(COLORCHOOSER n) {
    return static_cast<Fl_Color_Chooser*>(n)->mode();
}

void fl_color_chooser_set_mode(COLORCHOOSER n, int m) {
    static_cast<Fl_Color_Chooser*>(n)->mode(m);
}




void fl_color_chooser_draw(COLORCHOOSER n) {
    static_cast<My_Color_Chooser*>(n)->Fl_Color_Chooser::draw();
}

int fl_color_chooser_handle(COLORCHOOSER n, int e) {
    return static_cast<My_Color_Chooser*>(n)->Fl_Color_Chooser::handle(e);
}


