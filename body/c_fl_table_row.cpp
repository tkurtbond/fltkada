

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Table_Row.H>
#include "c_fl_table_row.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" void table_draw_cell_hook(void * ud, int e, int r, int c, int x, int y, int w, int h);




//  Non-friend protected access

class Friend_Table_Row : Fl_Table_Row {
public:
    using Fl_Table_Row::find_cell;
};




//  Attaching all relevant hooks and friends

class My_Table_Row : public Fl_Table_Row {
public:
    using Fl_Table_Row::Fl_Table_Row;

    friend void fl_table_row_draw(ROWTABLE t);
    friend void fl_table_row_draw_cell(ROWTABLE t, int e, int r, int c, int x, int y, int w, int h);
    friend int fl_table_row_handle(ROWTABLE t, int e);

    void draw();
    void draw_cell(Fl_Table::TableContext e, int r=0, int c=0, int x=0, int y=0, int w=0, int h=0);
    int handle(int e);
};

void My_Table_Row::draw() {
    widget_draw_hook(this->user_data());
}

void My_Table_Row::draw_cell(Fl_Table::TableContext e, int r, int c, int x, int y, int w, int h) {
    table_draw_cell_hook(this->user_data(), static_cast<int>(e), r, c, x, y, w, h);
}

int My_Table_Row::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

ROWTABLE new_fl_table_row(int x, int y, int w, int h, char * label) {
    My_Table_Row *t = new My_Table_Row(x, y, w, h, label);
    return t;
}

void free_fl_table_row(ROWTABLE t) {
    if (fl_inside_callback) {
        fl_delete_widget(t);
    } else {
        delete static_cast<My_Table_Row*>(t);
    }
}




int fl_table_row_get_rows(ROWTABLE t) {
    return static_cast<Fl_Table_Row*>(t)->rows();
}

void fl_table_row_set_rows(ROWTABLE t, int r) {
    static_cast<Fl_Table_Row*>(t)->rows(r);
}




int fl_table_row_row_selected(ROWTABLE t, int r) {
    return static_cast<Fl_Table_Row*>(t)->row_selected(r);
}

int fl_table_row_select_row(ROWTABLE t, int r, int f) {
    return static_cast<Fl_Table_Row*>(t)->select_row(r, f);
}

void fl_table_row_select_all_rows(ROWTABLE t, int f) {
    static_cast<Fl_Table_Row*>(t)->select_all_rows(f);
}

int fl_table_row_get_type(ROWTABLE t) {
    return static_cast<int>(static_cast<Fl_Table_Row*>(t)->type());
}

void fl_table_row_set_type(ROWTABLE t, int v) {
    static_cast<Fl_Table_Row*>(t)->type(static_cast<Fl_Table_Row::TableRowSelectMode>(v));
}




void fl_table_row_draw(ROWTABLE t) {
    static_cast<My_Table_Row*>(t)->Fl_Table_Row::draw();
}

void fl_table_row_draw_cell(ROWTABLE t, int e, int r, int c, int x, int y, int w, int h) {
    static_cast<My_Table_Row*>(t)->Fl_Table_Row::draw_cell
        (static_cast<Fl_Table::TableContext>(e), r, c, x, y, w, h);
}

int fl_table_row_find_cell(ROWTABLE t, int e, int r, int c, int &x, int &y, int &w, int &h) {
    return (static_cast<Fl_Table_Row*>(t)->*(&Friend_Table_Row::find_cell))
        (static_cast<Fl_Table::TableContext>(e), r, c, x, y, w, h);
}

int fl_table_row_handle(ROWTABLE t, int e) {
    return static_cast<My_Table_Row*>(t)->Fl_Table_Row::handle(e);
}


