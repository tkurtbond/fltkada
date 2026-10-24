

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Fl_Terminal.H>
#include <cstdlib>
#include <string>
#include "c_fl_terminal.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Terminal : public Fl_Terminal {
public:
    using Fl_Terminal::Fl_Terminal;

    //  Fl_Terminal::error_char only stores the pointer it is given,
    //  so the string it points to is kept alive here.
    std::string error_store;

    friend void fl_terminal_set_cursor_row(TERMINAL t, int r);
    friend void fl_terminal_set_cursor_col(TERMINAL t, int c);
    friend int fl_terminal_get_selection(TERMINAL t, int * srow, int * scol,
        int * erow, int * ecol);

    friend void fl_terminal_draw(TERMINAL n);
    friend int fl_terminal_handle(TERMINAL n, int e);

    void draw();
    int handle(int e);
};

void My_Terminal::draw() {
    widget_draw_hook(this->user_data());
}

int My_Terminal::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

TERMINAL new_fl_terminal(int x, int y, int w, int h, char * label) {
    My_Terminal *t = new My_Terminal(x, y, w, h, label);
    return t;
}

TERMINAL new_fl_terminal2(int x, int y, int w, int h, char * label,
    int rows, int cols, int hist) {
    My_Terminal *t = new My_Terminal(x, y, w, h, label, rows, cols, hist);
    return t;
}

void free_fl_terminal(TERMINAL t) {
    if (fl_inside_callback) {
        fl_delete_widget(t);
    } else {
        delete static_cast<My_Terminal*>(t);
    }
}




void fl_terminal_append(TERMINAL t, const char * s, int len) {
    static_cast<Fl_Terminal*>(t)->append(s, len);
}

void fl_terminal_append_utf8(TERMINAL t, const char * s, int len) {
    static_cast<Fl_Terminal*>(t)->append_utf8(s, len);
}

void fl_terminal_append_ascii(TERMINAL t, const char * s) {
    static_cast<Fl_Terminal*>(t)->append_ascii(s);
}

void fl_terminal_print_char(TERMINAL t, const char * s, int len) {
    static_cast<Fl_Terminal*>(t)->print_char(s, len);
}

void fl_terminal_print_char2(TERMINAL t, char c) {
    static_cast<Fl_Terminal*>(t)->print_char(c);
}

void fl_terminal_plot_char(TERMINAL t, const char * s, int len, int r, int c) {
    static_cast<Fl_Terminal*>(t)->plot_char(s, len, r, c);
}

void fl_terminal_plot_char2(TERMINAL t, char ch, int r, int c) {
    static_cast<Fl_Terminal*>(t)->plot_char(ch, r, c);
}




void fl_terminal_clear(TERMINAL t) {
    static_cast<Fl_Terminal*>(t)->clear();
}

void fl_terminal_clear2(TERMINAL t, unsigned int c) {
    static_cast<Fl_Terminal*>(t)->clear(static_cast<Fl_Color>(c));
}

void fl_terminal_clear_screen(TERMINAL t, int s) {
    static_cast<Fl_Terminal*>(t)->clear_screen(s != 0);
}

void fl_terminal_clear_screen_home(TERMINAL t, int s) {
    static_cast<Fl_Terminal*>(t)->clear_screen_home(s != 0);
}

void fl_terminal_clear_history(TERMINAL t) {
    static_cast<Fl_Terminal*>(t)->clear_history();
}

void fl_terminal_reset_terminal(TERMINAL t) {
    static_cast<Fl_Terminal*>(t)->reset_terminal();
}




void fl_terminal_cursor_home(TERMINAL t) {
    static_cast<Fl_Terminal*>(t)->cursor_home();
}

int fl_terminal_get_cursor_row(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->cursor_row();
}

void fl_terminal_set_cursor_row(TERMINAL t, int r) {
    static_cast<My_Terminal*>(t)->cursor_row(r);
}

int fl_terminal_get_cursor_col(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->cursor_col();
}

void fl_terminal_set_cursor_col(TERMINAL t, int c) {
    static_cast<My_Terminal*>(t)->cursor_col(c);
}

unsigned int fl_terminal_get_cursorfgcolor(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->cursorfgcolor();
}

void fl_terminal_set_cursorfgcolor(TERMINAL t, unsigned int c) {
    static_cast<Fl_Terminal*>(t)->cursorfgcolor(static_cast<Fl_Color>(c));
}

unsigned int fl_terminal_get_cursorbgcolor(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->cursorbgcolor();
}

void fl_terminal_set_cursorbgcolor(TERMINAL t, unsigned int c) {
    static_cast<Fl_Terminal*>(t)->cursorbgcolor(static_cast<Fl_Color>(c));
}




int fl_terminal_get_display_rows(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->display_rows();
}

void fl_terminal_set_display_rows(TERMINAL t, int r) {
    static_cast<Fl_Terminal*>(t)->display_rows(r);
}

int fl_terminal_get_display_columns(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->display_columns();
}

void fl_terminal_set_display_columns(TERMINAL t, int c) {
    static_cast<Fl_Terminal*>(t)->display_columns(c);
}

int fl_terminal_get_history_rows(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->history_rows();
}

void fl_terminal_set_history_rows(TERMINAL t, int r) {
    static_cast<Fl_Terminal*>(t)->history_rows(r);
}

int fl_terminal_get_history_lines(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->history_lines();
}

void fl_terminal_set_history_lines(TERMINAL t, int l) {
    static_cast<Fl_Terminal*>(t)->history_lines(l);
}

int fl_terminal_get_history_use(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->history_use();
}

float fl_terminal_get_redraw_rate(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->redraw_rate();
}

void fl_terminal_set_redraw_rate(TERMINAL t, float r) {
    static_cast<Fl_Terminal*>(t)->redraw_rate(r);
}

int fl_terminal_get_redraw_style(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->redraw_style();
}

void fl_terminal_set_redraw_style(TERMINAL t, int s) {
    static_cast<Fl_Terminal*>(t)->redraw_style(static_cast<Fl_Terminal::RedrawStyle>(s));
}




int fl_terminal_get_ansi(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->ansi();
}

void fl_terminal_set_ansi(TERMINAL t, int a) {
    static_cast<Fl_Terminal*>(t)->ansi(a != 0);
}

int fl_terminal_get_show_unknown(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->show_unknown();
}

void fl_terminal_set_show_unknown(TERMINAL t, int s) {
    static_cast<Fl_Terminal*>(t)->show_unknown(s != 0);
}

const char * fl_terminal_get_error_char(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->error_char();
}

void fl_terminal_set_error_char(TERMINAL t, const char * s) {
    My_Terminal *m = static_cast<My_Terminal*>(t);
    m->error_store = s;
    m->error_char(m->error_store.c_str());
}

int fl_terminal_get_output_translate(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->output_translate();
}

void fl_terminal_set_output_translate(TERMINAL t, int o) {
    static_cast<Fl_Terminal*>(t)->output_translate(static_cast<Fl_Terminal::OutFlags>(o));
}




int fl_terminal_get_textfont(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->textfont();
}

void fl_terminal_set_textfont(TERMINAL t, int f) {
    static_cast<Fl_Terminal*>(t)->textfont(static_cast<Fl_Font>(f));
}

int fl_terminal_get_textsize(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->textsize();
}

void fl_terminal_set_textsize(TERMINAL t, int s) {
    static_cast<Fl_Terminal*>(t)->textsize(static_cast<Fl_Fontsize>(s));
}

unsigned int fl_terminal_get_textcolor(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->textcolor();
}

void fl_terminal_set_textcolor(TERMINAL t, unsigned int c) {
    static_cast<Fl_Terminal*>(t)->textcolor(static_cast<Fl_Color>(c));
}

unsigned int fl_terminal_get_textfgcolor(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->textfgcolor();
}

void fl_terminal_set_textfgcolor(TERMINAL t, unsigned int c) {
    static_cast<Fl_Terminal*>(t)->textfgcolor(static_cast<Fl_Color>(c));
}

unsigned int fl_terminal_get_textbgcolor(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->textbgcolor();
}

void fl_terminal_set_textbgcolor(TERMINAL t, unsigned int c) {
    static_cast<Fl_Terminal*>(t)->textbgcolor(static_cast<Fl_Color>(c));
}

unsigned int fl_terminal_get_textfgcolor_default(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->textfgcolor_default();
}

void fl_terminal_set_textfgcolor_default(TERMINAL t, unsigned int c) {
    static_cast<Fl_Terminal*>(t)->textfgcolor_default(static_cast<Fl_Color>(c));
}

unsigned int fl_terminal_get_textbgcolor_default(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->textbgcolor_default();
}

void fl_terminal_set_textbgcolor_default(TERMINAL t, unsigned int c) {
    static_cast<Fl_Terminal*>(t)->textbgcolor_default(static_cast<Fl_Color>(c));
}

void fl_terminal_set_textfgcolor_xterm(TERMINAL t, unsigned char c) {
    static_cast<Fl_Terminal*>(t)->textfgcolor_xterm(c);
}

void fl_terminal_set_textbgcolor_xterm(TERMINAL t, unsigned char c) {
    static_cast<Fl_Terminal*>(t)->textbgcolor_xterm(c);
}

unsigned char fl_terminal_get_textattrib(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->textattrib();
}

void fl_terminal_set_textattrib(TERMINAL t, unsigned char a) {
    static_cast<Fl_Terminal*>(t)->textattrib(a);
}

unsigned int fl_terminal_get_selectionfgcolor(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->selectionfgcolor();
}

void fl_terminal_set_selectionfgcolor(TERMINAL t, unsigned int c) {
    static_cast<Fl_Terminal*>(t)->selectionfgcolor(static_cast<Fl_Color>(c));
}

unsigned int fl_terminal_get_selectionbgcolor(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->selectionbgcolor();
}

void fl_terminal_set_selectionbgcolor(TERMINAL t, unsigned int c) {
    static_cast<Fl_Terminal*>(t)->selectionbgcolor(static_cast<Fl_Color>(c));
}




void fl_terminal_set_box(TERMINAL t, int b) {
    static_cast<Fl_Terminal*>(t)->box(static_cast<Fl_Boxtype>(b));
}




int fl_terminal_get_margin_left(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->margin_left();
}

void fl_terminal_set_margin_left(TERMINAL t, int m) {
    static_cast<Fl_Terminal*>(t)->margin_left(m);
}

int fl_terminal_get_margin_right(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->margin_right();
}

void fl_terminal_set_margin_right(TERMINAL t, int m) {
    static_cast<Fl_Terminal*>(t)->margin_right(m);
}

int fl_terminal_get_margin_top(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->margin_top();
}

void fl_terminal_set_margin_top(TERMINAL t, int m) {
    static_cast<Fl_Terminal*>(t)->margin_top(m);
}

int fl_terminal_get_margin_bottom(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->margin_bottom();
}

void fl_terminal_set_margin_bottom(TERMINAL t, int m) {
    static_cast<Fl_Terminal*>(t)->margin_bottom(m);
}




int fl_terminal_get_scrollbar_size(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->scrollbar_size();
}

void fl_terminal_set_scrollbar_size(TERMINAL t, int s) {
    static_cast<Fl_Terminal*>(t)->scrollbar_size(s);
}

int fl_terminal_get_scrollbar_actual_size(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->scrollbar_actual_size();
}

int fl_terminal_get_hscrollbar_style(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->hscrollbar_style();
}

void fl_terminal_set_hscrollbar_style(TERMINAL t, int s) {
    static_cast<Fl_Terminal*>(t)->hscrollbar_style(
        static_cast<Fl_Terminal::ScrollbarStyle>(s));
}




int fl_terminal_get_selection(TERMINAL t, int * srow, int * scol, int * erow, int * ecol) {
    return static_cast<My_Terminal*>(t)->get_selection(*srow, *scol, *erow, *ecol);
}

int fl_terminal_selection_text_len(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->selection_text_len();
}

char * fl_terminal_selection_text(TERMINAL t) {
    //  The returned string is malloc'd and must be released with fl_terminal_free_text
    return const_cast<char*>(static_cast<Fl_Terminal*>(t)->selection_text());
}

char * fl_terminal_text(TERMINAL t, int b) {
    //  The returned string is malloc'd and must be released with fl_terminal_free_text
    return const_cast<char*>(static_cast<Fl_Terminal*>(t)->text(b != 0));
}

void fl_terminal_free_text(char * s) {
    free(s);
}




void fl_terminal_draw(TERMINAL n) {
    static_cast<My_Terminal*>(n)->Fl_Terminal::draw();
}

int fl_terminal_handle(TERMINAL n, int e) {
    return static_cast<My_Terminal*>(n)->Fl_Terminal::handle(e);
}

