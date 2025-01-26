

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Table.H>
#include "c_fl_table.h"




//  Enum and macro constants

const int fl_context_none       = Fl_Table::CONTEXT_NONE;
const int fl_context_startpage  = Fl_Table::CONTEXT_STARTPAGE;
const int fl_context_endpage    = Fl_Table::CONTEXT_ENDPAGE;
const int fl_context_row_header = Fl_Table::CONTEXT_ROW_HEADER;
const int fl_context_col_header = Fl_Table::CONTEXT_COL_HEADER;
const int fl_context_cell       = Fl_Table::CONTEXT_CELL;
const int fl_context_table      = Fl_Table::CONTEXT_TABLE;
const int fl_context_rc_resize  = Fl_Table::CONTEXT_RC_RESIZE;




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" void table_draw_cell_hook(void * ud, int e, int r, int c, int x, int y, int w, int h);




//  Non-friend protected access

class Friend_Table : Fl_Table {
public:
    using Fl_Table::hscrollbar;
    using Fl_Table::vscrollbar;
    using Fl_Table::table;

    using Fl_Table::is_fltk_container;

    using Fl_Table::scroll_cb;

    using Fl_Table::col_scroll_position;
    using Fl_Table::row_scroll_position;

    using Fl_Table::change_cursor;
    using Fl_Table::ResizeFlag;
    using Fl_Table::cursor2rowcol;

    using Fl_Table::recalc_dimensions;
    using Fl_Table::table_resized;
    using Fl_Table::table_scrolled;

    using Fl_Table::redraw_range;
    using Fl_Table::damage_zone;
    using Fl_Table::find_cell;
    using Fl_Table::get_bounds;
    using Fl_Table::row_col_clamp;
};




//  Attaching all relevant hooks and friends

class My_Table : public Fl_Table {
public:
    using Fl_Table::Fl_Table;

    friend void fl_table_draw(TABLE t);
    friend void fl_table_draw_cell(TABLE t, int e, int r, int c, int x, int y, int w, int h);
    friend int fl_table_handle(TABLE t, int e);

    void draw();
    void draw_cell(Fl_Table::TableContext e, int r=0, int c=0, int x=0, int y=0, int w=0, int h=0);
    int handle(int e);
};

void My_Table::draw() {
    widget_draw_hook(this->user_data());
}

void My_Table::draw_cell(Fl_Table::TableContext e, int r, int c, int x, int y, int w, int h) {
    table_draw_cell_hook(this->user_data(), static_cast<int>(e), r, c, x, y, w, h);
}

int My_Table::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

TABLE new_fl_table(int x, int y, int w, int h, char * label) {
    My_Table *t = new My_Table(x, y, w, h, label);
    return t;
}

void free_fl_table(TABLE t) {
    delete static_cast<My_Table*>(t);
}




void * fl_table_hscrollbar(TABLE t) {
    return (static_cast<Fl_Table*>(t)->*(&Friend_Table::hscrollbar));
}

void * fl_table_vscrollbar(TABLE t) {
    return (static_cast<Fl_Table*>(t)->*(&Friend_Table::vscrollbar));
}

void * fl_table_table(TABLE t) {
    return (static_cast<Fl_Table*>(t)->*(&Friend_Table::table));
}




void fl_table_add(TABLE t, void * w) {
    static_cast<Fl_Table*>(t)->add(static_cast<Fl_Widget*>(w));
}

void fl_table_insert(TABLE t, void * w, int p) {
    Fl_Widget &ref = *(static_cast<Fl_Widget*>(w));
    static_cast<Fl_Table*>(t)->insert(ref, p);
}

void fl_table_insert2(TABLE t, void * w, void * b) {
    Fl_Widget &ref = *(static_cast<Fl_Widget*>(w));
    static_cast<Fl_Table*>(t)->insert(ref, static_cast<Fl_Widget*>(b));
}

void fl_table_remove(TABLE t, void * w) {
    Fl_Widget &ref = *(static_cast<Fl_Widget*>(w));
    static_cast<Fl_Table*>(t)->remove(ref);
}




void * fl_table_child(TABLE t, int p) {
    return static_cast<Fl_Table*>(t)->child(p);
}

int fl_table_find(TABLE t, void * w) {
    return static_cast<Fl_Table*>(t)->find(static_cast<Fl_Widget*>(w));
}

int fl_table_children(TABLE t) {
    return static_cast<Fl_Table*>(t)->children();
}

int fl_table_is_fltk_container(TABLE t) {
    return (static_cast<Fl_Table*>(t)->*(&Friend_Table::is_fltk_container))();
}




void fl_table_begin(TABLE t) {
    static_cast<Fl_Table*>(t)->begin();
}

void fl_table_end(TABLE t) {
    static_cast<Fl_Table*>(t)->end();
}




void fl_table_set_callback(TABLE t, void * f) {
    static_cast<Fl_Table*>(t)->callback
        (reinterpret_cast<Fl_Callback_p>(f), static_cast<Fl_Table*>(t)->user_data());
}

int fl_table_callback_col(TABLE t) {
    return static_cast<Fl_Table*>(t)->callback_col();
}

int fl_table_callback_row(TABLE t) {
    return static_cast<Fl_Table*>(t)->callback_row();
}

int fl_table_callback_context(TABLE t) {
    return static_cast<Fl_Table*>(t)->callback_context();
}

void fl_table_do_callback(TABLE t, int x, int r, int c) {
    static_cast<Fl_Table*>(t)->do_callback(static_cast<Fl_Table::TableContext>(x), r, c);
}

void fl_table_when(TABLE t, unsigned int w) {
    static_cast<Fl_Table*>(t)->when(static_cast<Fl_When>(w));
}

void fl_table_scroll_cb(void * s, TABLE t) {
    Friend_Table::scroll_cb(static_cast<Fl_Widget*>(s), t);
}




int fl_table_get_col_header(TABLE t) {
    return static_cast<Fl_Table*>(t)->col_header();
}

void fl_table_set_col_header(TABLE t, int f) {
    static_cast<Fl_Table*>(t)->col_header(f);
}

unsigned int fl_table_get_col_header_color(TABLE t) {
    return static_cast<Fl_Table*>(t)->col_header_color();
}

void fl_table_set_col_header_color(TABLE t, unsigned int c) {
    static_cast<Fl_Table*>(t)->col_header_color(static_cast<Fl_Color>(c));
}

int fl_table_get_col_header_height(TABLE t) {
    return static_cast<Fl_Table*>(t)->col_header_height();
}

void fl_table_set_col_header_height(TABLE t, int h) {
    static_cast<Fl_Table*>(t)->col_header_height(h);
}

int fl_table_get_col_width(TABLE t, int c) {
    return static_cast<Fl_Table*>(t)->col_width(c);
}

void fl_table_set_col_width(TABLE t, int c, int w) {
    static_cast<Fl_Table*>(t)->col_width(c, w);
}

void fl_table_col_width_all(TABLE t, int w) {
    static_cast<Fl_Table*>(t)->col_width_all(w);
}

int fl_table_get_cols(TABLE t) {
    return static_cast<Fl_Table*>(t)->cols();
}

void fl_table_set_cols(TABLE t, int c) {
    static_cast<Fl_Table*>(t)->cols(c);
}

int fl_table_get_col_position(TABLE t) {
    return static_cast<Fl_Table*>(t)->col_position();
}

void fl_table_set_col_position(TABLE t, int c) {
    static_cast<Fl_Table*>(t)->col_position(c);
}

long fl_table_col_scroll_position(TABLE t, int c) {
    return (static_cast<Fl_Table*>(t)->*(&Friend_Table::col_scroll_position))(c);
}

int fl_table_get_col_resize(TABLE t) {
    return static_cast<Fl_Table*>(t)->col_resize();
}

void fl_table_set_col_resize(TABLE t, int f) {
    static_cast<Fl_Table*>(t)->col_resize(f);
}

int fl_table_get_col_resize_min(TABLE t) {
    return static_cast<Fl_Table*>(t)->col_resize_min();
}

void fl_table_set_col_resize_min(TABLE t, int v) {
    static_cast<Fl_Table*>(t)->col_resize_min(v);
}




int fl_table_get_row_header(TABLE t) {
    return static_cast<Fl_Table*>(t)->row_header();
}

void fl_table_set_row_header(TABLE t, int f) {
    static_cast<Fl_Table*>(t)->row_header(f);
}

unsigned int fl_table_get_row_header_color(TABLE t) {
    return static_cast<Fl_Table*>(t)->row_header_color();
}

void fl_table_set_row_header_color(TABLE t, unsigned int c) {
    static_cast<Fl_Table*>(t)->row_header_color(static_cast<Fl_Color>(c));
}

int fl_table_get_row_header_width(TABLE t) {
    return static_cast<Fl_Table*>(t)->row_header_width();
}

void fl_table_set_row_header_width(TABLE t, int w) {
    static_cast<Fl_Table*>(t)->row_header_width(w);
}

int fl_table_get_row_height(TABLE t, int r) {
    return static_cast<Fl_Table*>(t)->row_height(r);
}

void fl_table_set_row_height(TABLE t, int r, int h) {
    static_cast<Fl_Table*>(t)->row_height(r, h);
}

void fl_table_row_height_all(TABLE t, int h) {
    static_cast<Fl_Table*>(t)->row_height_all(h);
}

int fl_table_get_rows(TABLE t) {
    return static_cast<Fl_Table*>(t)->rows();
}

void fl_table_set_rows(TABLE t, int r) {
    static_cast<Fl_Table*>(t)->rows(r);
}

int fl_table_get_row_position(TABLE t) {
    return static_cast<Fl_Table*>(t)->row_position();
}

void fl_table_set_row_position(TABLE t, int r) {
    static_cast<Fl_Table*>(t)->row_position(r);
}

long fl_table_row_scroll_position(TABLE t, int r) {
    return (static_cast<Fl_Table*>(t)->*(&Friend_Table::row_scroll_position))(r);
}

int fl_table_get_row_resize(TABLE t) {
    return static_cast<Fl_Table*>(t)->row_resize();
}

void fl_table_set_row_resize(TABLE t, int f) {
    static_cast<Fl_Table*>(t)->row_resize(f);
}

int fl_table_get_row_resize_min(TABLE t) {
    return static_cast<Fl_Table*>(t)->row_resize_min();
}

void fl_table_set_row_resize_min(TABLE t, int v) {
    static_cast<Fl_Table*>(t)->row_resize_min(v);
}

int fl_table_get_top_row(TABLE t) {
    return static_cast<Fl_Table*>(t)->top_row();
}

void fl_table_set_top_row(TABLE t, int r) {
    static_cast<Fl_Table*>(t)->top_row(r);
}




void fl_table_change_cursor(TABLE t, int c) {
    (static_cast<Fl_Table*>(t)->*(&Friend_Table::change_cursor))(static_cast<Fl_Cursor>(c));
}

int fl_table_cursor2rowcol(TABLE t, int &r, int &c, int &f) {
    Friend_Table::ResizeFlag ref;
    return (static_cast<Fl_Table*>(t)->*(&Friend_Table::cursor2rowcol))(r, c, ref);
    f = static_cast<int>(ref);
}

void fl_table_visible_cells(TABLE t, int &r1, int &r2, int &c1, int &c2) {
    static_cast<Fl_Table*>(t)->visible_cells(r1, r2, c1, c2);
}

void fl_table_get_selection(TABLE t, int &rt, int &cl, int &rb, int &cr) {
    static_cast<Fl_Table*>(t)->get_selection(rt, cl, rb, cr);
}

void fl_table_set_selection(TABLE t, int rt, int cl, int rb, int cr) {
    static_cast<Fl_Table*>(t)->set_selection(rt, cl, rb, cr);
}

int fl_table_is_selected(TABLE t, int r, int c) {
    return static_cast<Fl_Table*>(t)->is_selected(r, c);
}

int fl_table_move_cursor(TABLE t, int r, int c, int s) {
    return static_cast<Fl_Table*>(t)->move_cursor(r, c, s);
}

int fl_table_get_tab_cell_nav(TABLE t) {
#if FLTK_ABI_VERSION >= 10303
    return static_cast<Fl_Table*>(t)->tab_cell_nav();
#else
    (void)(t);
    return 0;
#endif
}

void fl_table_set_tab_cell_nav(TABLE t, int v) {
#if FLTK_ABI_VERSION >= 10303
    static_cast<Fl_Table*>(t)->tab_cell_nav(v);
#else
    (void)(t);
    (void)(v);
#endif
}

int fl_table_get_table_box(TABLE t) {
    return static_cast<Fl_Table*>(t)->table_box();
}

void fl_table_set_table_box(TABLE t, int v) {
    static_cast<Fl_Table*>(t)->table_box(static_cast<Fl_Boxtype>(v));
}




int fl_table_get_scrollbar_size(TABLE t) {
#if FLTK_ABI_VERSION >= 10301
    return static_cast<Fl_Table*>(t)->scrollbar_size();
#else
    (void)(t);
    return 0;
#endif
}

void fl_table_set_scrollbar_size(TABLE t, int v) {
#if FLTK_ABI_VERSION >= 10301
    static_cast<Fl_Table*>(t)->scrollbar_size(v);
#else
    (void)(t);
    (void)(v);
#endif
}

void fl_table_resize(TABLE t, int x, int y, int w, int h) {
    static_cast<Fl_Table*>(t)->resize(x, y, w, h);
}

int fl_table_is_interactive_resize(TABLE t) {
    return static_cast<Fl_Table*>(t)->is_interactive_resize();
}

void fl_table_init_sizes(TABLE t) {
    static_cast<Fl_Table*>(t)->init_sizes();
}

void fl_table_recalc_dimensions(TABLE t) {
    (static_cast<Fl_Table*>(t)->*(&Friend_Table::recalc_dimensions))();
}

void fl_table_table_resized(TABLE t) {
    (static_cast<Fl_Table*>(t)->*(&Friend_Table::table_resized))();
}

void fl_table_table_scrolled(TABLE t) {
    (static_cast<Fl_Table*>(t)->*(&Friend_Table::table_scrolled))();
}




void fl_table_draw(TABLE t) {
    static_cast<My_Table*>(t)->Fl_Table::draw();
}

void fl_table_draw_cell(TABLE t, int e, int r, int c, int x, int y, int w, int h) {
    static_cast<My_Table*>(t)->Fl_Table::draw_cell
        (static_cast<Fl_Table::TableContext>(e), r, c, x, y, w, h);
}

void fl_table_redraw_range(TABLE t, int rt, int rb, int cl, int cr) {
    (static_cast<Fl_Table*>(t)->*(&Friend_Table::redraw_range))(rt, rb, cl, cr);
}

void fl_table_damage_zone(TABLE t, int rt, int cl, int rb, int cr, int rr, int rc) {
    (static_cast<Fl_Table*>(t)->*(&Friend_Table::damage_zone))(rt, cl, rb, cr, rr, rc);
}

int fl_table_find_cell(TABLE t, int e, int r, int c, int &x, int &y, int &w, int &h) {
    return (static_cast<Fl_Table*>(t)->*(&Friend_Table::find_cell))
        (static_cast<Fl_Table::TableContext>(e), r, c, x, y, w, h);
}

void fl_table_get_bounds(TABLE t, int e, int &x, int &y, int &w, int &h) {
    (static_cast<Fl_Table*>(t)->*(&Friend_Table::get_bounds))
        (static_cast<Fl_Table::TableContext>(e), x, y, w, h);
}

int fl_table_row_col_clamp(TABLE t, int e, int &r, int &c) {
    return (static_cast<Fl_Table*>(t)->*(&Friend_Table::row_col_clamp))
        (static_cast<Fl_Table::TableContext>(e), r, c);
}

int fl_table_handle(TABLE t, int e) {
    return static_cast<My_Table*>(t)->Fl_Table::handle(e);
}


