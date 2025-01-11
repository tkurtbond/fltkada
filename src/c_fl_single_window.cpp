

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Single_Window.H>
#include "c_fl_single_window.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Single_Window : public Fl_Single_Window {
public:
    using Fl_Single_Window::Fl_Single_Window;

    friend void fl_single_window_draw(SINGLEWINDOW n);
    friend int fl_single_window_handle(SINGLEWINDOW n, int e);

    void draw();
    int handle(int e);
};

void My_Single_Window::draw() {
    widget_draw_hook(this->user_data());
}

int My_Single_Window::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

SINGLEWINDOW new_fl_single_window(int x, int y, int w, int h, char* label) {
    My_Single_Window *sw = new My_Single_Window(x, y, w, h, label);
    return sw;
}

SINGLEWINDOW new_fl_single_window2(int x, int y, char* label) {
    My_Single_Window *sw = new My_Single_Window(x, y, label);
    return sw;
}

void free_fl_single_window(SINGLEWINDOW w) {
    delete reinterpret_cast<My_Single_Window*>(w);
}




void fl_single_window_show(SINGLEWINDOW w) {
    reinterpret_cast<Fl_Single_Window*>(w)->show();
}

void fl_single_window_flush(SINGLEWINDOW w) {
    reinterpret_cast<Fl_Single_Window*>(w)->flush();
}




void fl_single_window_make_current(SINGLEWINDOW w) {
    reinterpret_cast<Fl_Single_Window*>(w)->Fl_Window::make_current();
}




void fl_single_window_draw(SINGLEWINDOW n) {
    reinterpret_cast<My_Single_Window*>(n)->Fl_Single_Window::draw();
}

int fl_single_window_handle(SINGLEWINDOW n, int e) {
    return reinterpret_cast<My_Single_Window*>(n)->Fl_Single_Window::handle(e);
}


