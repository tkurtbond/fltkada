

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Chart.H>
#include "c_fl_chart.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Chart : public Fl_Chart {
public:
    using Fl_Chart::Fl_Chart;

    friend void fl_chart_draw(CHART n);
    friend int fl_chart_handle(CHART n, int e);

    void draw();
    int handle(int e);
};

void My_Chart::draw() {
    widget_draw_hook(this->user_data());
}

int My_Chart::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

CHART new_fl_chart(int x, int y, int w, int h, char* label) {
    My_Chart *b = new My_Chart(x, y, w, h, label);
    return b;
}

void free_fl_chart(CHART b) {
    delete reinterpret_cast<My_Chart*>(b);
}




void fl_chart_add(CHART b, double v, char * s, unsigned int c) {
    reinterpret_cast<Fl_Chart*>(b)->add(v,s,c);
}

void fl_chart_insert(CHART b, int i, double v, char * s, unsigned int c) {
    reinterpret_cast<Fl_Chart*>(b)->insert(i,v,s,c);
}

void fl_chart_replace(CHART b, int i, double v, char * s, unsigned int c) {
    reinterpret_cast<Fl_Chart*>(b)->replace(i,v,s,c);
}

void fl_chart_clear(CHART b) {
    reinterpret_cast<Fl_Chart*>(b)->clear();
}




int fl_chart_get_autosize(CHART b) {
    return reinterpret_cast<Fl_Chart*>(b)->autosize();
}

void fl_chart_set_autosize(CHART b, int a) {
    reinterpret_cast<Fl_Chart*>(b)->autosize(a);
}

void fl_chart_get_bounds(CHART b, double * l, double * u) {
    reinterpret_cast<Fl_Chart*>(b)->bounds(l,u);
}

void fl_chart_set_bounds(CHART b, double l, double u) {
    reinterpret_cast<Fl_Chart*>(b)->bounds(l,u);
}

int fl_chart_get_maxsize(CHART b) {
    return reinterpret_cast<Fl_Chart*>(b)->maxsize();
}

void fl_chart_set_maxsize(CHART b, int m) {
    reinterpret_cast<Fl_Chart*>(b)->maxsize(m);
}

int fl_chart_size(CHART b) {
    return reinterpret_cast<Fl_Chart*>(b)->size();
}




void fl_chart_size2(CHART b, int w, int h) {
    reinterpret_cast<Fl_Chart*>(b)->size(w, h);
}




unsigned int fl_chart_get_textcolor(CHART b) {
    return reinterpret_cast<Fl_Chart*>(b)->textcolor();
}

void fl_chart_set_textcolor(CHART b, unsigned int c) {
    reinterpret_cast<Fl_Chart*>(b)->textcolor(c);
}

int fl_chart_get_textfont(CHART b) {
    return reinterpret_cast<Fl_Chart*>(b)->textfont();
}

void fl_chart_set_textfont(CHART b, int f) {
    reinterpret_cast<Fl_Chart*>(b)->textfont(f);
}

int fl_chart_get_textsize(CHART b) {
    return reinterpret_cast<Fl_Chart*>(b)->textsize();
}

void fl_chart_set_textsize(CHART b, int s) {
    reinterpret_cast<Fl_Chart*>(b)->textsize(s);
}




void fl_chart_draw(CHART n) {
    reinterpret_cast<My_Chart*>(n)->Fl_Chart::draw();
}

int fl_chart_handle(CHART n, int e) {
    return reinterpret_cast<My_Chart*>(n)->Fl_Chart::handle(e);
}


