

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/glut.H>
#include "c_fl_glut_window.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Glut_Window : public Fl_Glut_Window {
public:
    using Fl_Glut_Window::Fl_Glut_Window;

    friend void fl_glut_window_draw(GLUTWINDOW n);
    friend int fl_glut_window_handle(GLUTWINDOW n, int e);

    void draw();
    int handle(int e);
};

void My_Glut_Window::draw() {
    widget_draw_hook(this->user_data());
}

int My_Glut_Window::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

GLUTWINDOW new_fl_glut_window(int x, int y, int w, int h, char* label) {
    My_Glut_Window *gw = new My_Glut_Window(x, y, w, h, label);
    return gw;
}

GLUTWINDOW new_fl_glut_window2(int w, int h, char* label) {
    My_Glut_Window *gw = new My_Glut_Window(w, h, label);
    return gw;
}

void free_fl_glut_window(GLUTWINDOW w) {
    if (fl_inside_callback) {
        fl_delete_widget(w);
    } else {
        delete static_cast<My_Glut_Window*>(w);
    }
}




int fl_glut_window_get_number(GLUTWINDOW w) {
    return static_cast<Fl_Glut_Window*>(w)->number;
}

int fl_glut_window_get_menu(GLUTWINDOW w, int b) {
    return static_cast<Fl_Glut_Window*>(w)->menu[b];
}

void fl_glut_window_set_menu(GLUTWINDOW w, int b, int m) {
    static_cast<Fl_Glut_Window*>(w)->menu[b] = m;
}

void fl_glut_window_make_current(GLUTWINDOW w) {
    static_cast<Fl_Glut_Window*>(w)->make_current();
}




void fl_glut_window_draw(GLUTWINDOW n) {
    static_cast<My_Glut_Window*>(n)->Fl_Glut_Window::draw();
}

int fl_glut_window_handle(GLUTWINDOW n, int e) {
    return static_cast<My_Glut_Window*>(n)->Fl_Glut_Window::handle(e);
}


