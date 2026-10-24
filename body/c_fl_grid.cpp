

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Fl_Grid.H>
#include "c_fl_grid.h"
#include "c_fl.h"




//  Exports to Ada

const unsigned short fl_grid_center       = FL_GRID_CENTER;
const unsigned short fl_grid_top          = FL_GRID_TOP;
const unsigned short fl_grid_bottom       = FL_GRID_BOTTOM;
const unsigned short fl_grid_left         = FL_GRID_LEFT;
const unsigned short fl_grid_right        = FL_GRID_RIGHT;
const unsigned short fl_grid_horizontal   = FL_GRID_HORIZONTAL;
const unsigned short fl_grid_vertical     = FL_GRID_VERTICAL;
const unsigned short fl_grid_fill         = FL_GRID_FILL;
const unsigned short fl_grid_proportional = FL_GRID_PROPORTIONAL;
const unsigned short fl_grid_top_left     = FL_GRID_TOP_LEFT;
const unsigned short fl_grid_top_right    = FL_GRID_TOP_RIGHT;
const unsigned short fl_grid_bottom_left  = FL_GRID_BOTTOM_LEFT;
const unsigned short fl_grid_bottom_right = FL_GRID_BOTTOM_RIGHT;




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Grid : public Fl_Grid {
public:
    using Fl_Grid::Fl_Grid;

    friend void fl_grid_draw(GRID n);
    friend int fl_grid_handle(GRID n, int e);

    void draw();
    int handle(int e);
};

void My_Grid::draw() {
    widget_draw_hook(this->user_data());
}

int My_Grid::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

GRID new_fl_grid(int x, int y, int w, int h, char* label) {
    My_Grid *g = new My_Grid(x, y, w, h, label);
    return g;
}

void free_fl_grid(GRID g) {
    if (fl_inside_callback) {
        fl_delete_widget(g);
    } else {
        delete static_cast<My_Grid*>(g);
    }
}




void fl_grid_set_layout(GRID g, int r, int c, int m, int p) {
    static_cast<Fl_Grid*>(g)->layout(r, c, m, p);
}

void fl_grid_layout(GRID g) {
    static_cast<Fl_Grid*>(g)->layout();
}

void fl_grid_clear_layout(GRID g) {
    static_cast<Fl_Grid*>(g)->clear_layout();
}

int fl_grid_get_need_layout(GRID g) {
    return static_cast<Fl_Grid*>(g)->need_layout();
}

void fl_grid_set_need_layout(GRID g, int s) {
    static_cast<Fl_Grid*>(g)->need_layout(s);
}

int fl_grid_rows(GRID g) {
    return static_cast<Fl_Grid*>(g)->rows();
}

int fl_grid_cols(GRID g) {
    return static_cast<Fl_Grid*>(g)->cols();
}




int fl_grid_get_margin(GRID g, int * l, int * t, int * r, int * b) {
    return static_cast<Fl_Grid*>(g)->margin(l, t, r, b);
}

void fl_grid_set_margin(GRID g, int l, int t, int r, int b) {
    static_cast<Fl_Grid*>(g)->margin(l, t, r, b);
}

void fl_grid_get_gap(GRID g, int * r, int * c) {
    static_cast<Fl_Grid*>(g)->gap(r, c);
}

void fl_grid_set_gap(GRID g, int r, int c) {
    static_cast<Fl_Grid*>(g)->gap(r, c);
}




int fl_grid_set_widget(GRID g, void * w, int r, int c, unsigned short a) {
    return static_cast<Fl_Grid*>(g)->widget(static_cast<Fl_Widget*>(w), r, c, a) != 0;
}

int fl_grid_set_widget2(GRID g, void * w, int r, int c, int rs, int cs,
    unsigned short a) {
    return static_cast<Fl_Grid*>(g)->widget(static_cast<Fl_Widget*>(w), r, c, rs, cs, a) != 0;
}




void fl_grid_set_col_width(GRID g, int c, int v) {
    static_cast<Fl_Grid*>(g)->col_width(c, v);
}

void fl_grid_set_col_width2(GRID g, const int * v, size_t s) {
    static_cast<Fl_Grid*>(g)->col_width(v, s);
}

int fl_grid_get_col_width(GRID g, int c) {
    return static_cast<Fl_Grid*>(g)->col_width(c);
}

void fl_grid_set_col_weight(GRID g, int c, int v) {
    static_cast<Fl_Grid*>(g)->col_weight(c, v);
}

void fl_grid_set_col_weight2(GRID g, const int * v, size_t s) {
    static_cast<Fl_Grid*>(g)->col_weight(v, s);
}

int fl_grid_get_col_weight(GRID g, int c) {
    return static_cast<Fl_Grid*>(g)->col_weight(c);
}

void fl_grid_set_col_gap(GRID g, int c, int v) {
    static_cast<Fl_Grid*>(g)->col_gap(c, v);
}

void fl_grid_set_col_gap2(GRID g, const int * v, size_t s) {
    static_cast<Fl_Grid*>(g)->col_gap(v, s);
}

int fl_grid_get_col_gap(GRID g, int c) {
    return static_cast<Fl_Grid*>(g)->col_gap(c);
}

int fl_grid_computed_col_width(GRID g, int c) {
    return static_cast<Fl_Grid*>(g)->computed_col_width(c);
}




void fl_grid_set_row_height(GRID g, int r, int v) {
    static_cast<Fl_Grid*>(g)->row_height(r, v);
}

void fl_grid_set_row_height2(GRID g, const int * v, size_t s) {
    static_cast<Fl_Grid*>(g)->row_height(v, s);
}

int fl_grid_get_row_height(GRID g, int r) {
    return static_cast<Fl_Grid*>(g)->row_height(r);
}

void fl_grid_set_row_weight(GRID g, int r, int v) {
    static_cast<Fl_Grid*>(g)->row_weight(r, v);
}

void fl_grid_set_row_weight2(GRID g, const int * v, size_t s) {
    static_cast<Fl_Grid*>(g)->row_weight(v, s);
}

int fl_grid_get_row_weight(GRID g, int r) {
    return static_cast<Fl_Grid*>(g)->row_weight(r);
}

void fl_grid_set_row_gap(GRID g, int r, int v) {
    static_cast<Fl_Grid*>(g)->row_gap(r, v);
}

void fl_grid_set_row_gap2(GRID g, const int * v, size_t s) {
    static_cast<Fl_Grid*>(g)->row_gap(v, s);
}

int fl_grid_get_row_gap(GRID g, int r) {
    return static_cast<Fl_Grid*>(g)->row_gap(r);
}

int fl_grid_computed_row_height(GRID g, int r) {
    return static_cast<Fl_Grid*>(g)->computed_row_height(r);
}




void fl_grid_show_grid(GRID g, int s) {
    static_cast<Fl_Grid*>(g)->show_grid(s);
}

void fl_grid_show_grid2(GRID g, int s, unsigned int c) {
    static_cast<Fl_Grid*>(g)->show_grid(s, c);
}

void fl_grid_debug(GRID g, int l) {
    static_cast<Fl_Grid*>(g)->debug(l);
}




void fl_grid_draw(GRID n) {
    static_cast<My_Grid*>(n)->Fl_Grid::draw();
}

int fl_grid_handle(GRID n, int e) {
    return static_cast<My_Grid*>(n)->Fl_Grid::handle(e);
}


