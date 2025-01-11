

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Double_Window.H>
#include "c_fl_double_window.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Double_Window : public Fl_Double_Window {
public:
    using Fl_Double_Window::Fl_Double_Window;

    friend void fl_double_window_draw(DOUBLEWINDOW n);
    friend int fl_double_window_handle(DOUBLEWINDOW n, int e);

    void draw();
    int handle(int e);
};

void My_Double_Window::draw() {
    widget_draw_hook(this->user_data());
}

int My_Double_Window::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

DOUBLEWINDOW new_fl_double_window(int x, int y, int w, int h, char* label) {
    My_Double_Window *d = new My_Double_Window(x, y, w, h, label);
    return d;
}

DOUBLEWINDOW new_fl_double_window2(int w, int h, char* label) {
    My_Double_Window *d = new My_Double_Window(w, h, label);
    return d;
}

void free_fl_double_window(DOUBLEWINDOW d) {
    delete reinterpret_cast<My_Double_Window*>(d);
}




void fl_double_window_show(DOUBLEWINDOW d) {
    reinterpret_cast<Fl_Double_Window*>(d)->show();
}

void fl_double_window_hide(DOUBLEWINDOW d) {
    reinterpret_cast<Fl_Double_Window*>(d)->hide();
}

void fl_double_window_flush(DOUBLEWINDOW d) {
    reinterpret_cast<Fl_Double_Window*>(d)->flush();
}




void fl_double_window_resize(DOUBLEWINDOW d, int x, int y, int w, int h) {
    reinterpret_cast<Fl_Double_Window*>(d)->resize(x, y, w, h);
}




void fl_double_window_draw(DOUBLEWINDOW n) {
    reinterpret_cast<My_Double_Window*>(n)->Fl_Double_Window::draw();
}

int fl_double_window_handle(DOUBLEWINDOW n, int e) {
    return reinterpret_cast<My_Double_Window*>(n)->Fl_Double_Window::handle(e);
}


