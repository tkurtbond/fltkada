

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Fl_Terminal.H>
#include <FL/fl_utf8.h>
#include <cstdlib>
#include <cstring>
#include <string>
#include "c_fl_terminal.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Reaching a private member: an explicit instantiation may name it
//  (pofltk's FlTerminal.cpp does the same)

template <class Tag, typename Tag::type M> struct Reach {
    friend typename Tag::type member(Tag) { return M; }
};

//  More cells than this are refused: a failed allocation would throw
//  through the shim (pofltk 99)
static const long long max_cells = 1LL << 24;




//  Attaching all relevant hooks and friends

class My_Terminal : public Ada_Resizing<Fl_Terminal> {
public:
    using Ada_Resizing<Fl_Terminal>::Ada_Resizing;

    struct Seq {
        typedef EscapeSeq Fl_Terminal::*type;
        friend type member(Seq);
    };

    //  Under PER_WRITE, display_modified redraws only while
    //  redraw_modified_ is false, and only the RATE_LIMITED timer sets it
    //  false again: after one write the terminal never redraws, under
    //  either style (F23).  draw, under PER_WRITE, and the style setter
    //  clear it here.
    struct Modified {
        typedef bool Fl_Terminal::*type;
        friend type member(Modified);
    };

    //  The size setters and resize leave the cursor, and the place ESC[s
    //  saved, where they were, on a screen that may now be smaller, and
    //  the next character is written outside its row (pofltk 96).  This
    //  puts both back on the screen; cursor_row and cursor_col clamp.
    void fit();

    void base_resize(int x, int y, int w, int h);

    //  Fl_Terminal::restore_cursor tests col != 1, a slip for -1, so a
    //  place saved at column 1 isn't restored (pofltk 97).  This reads
    //  the saved place and sets the cursor itself.
    void restore();

    //  display_modified is private, and the cursor's moves don't call
    //  it; this is the public way there, so redraw_style is obeyed
    //  (pofltk 99).
    void modified() { append_ascii(""); }

    friend void fl_terminal_cursor_move(TERMINAL t, int what, int count, int scroll);

    //  Fl_Terminal::error_char only stores the pointer it is given,
    //  so the string it points to is kept alive here.
    std::string error_store;

    friend void fl_terminal_cursor_home(TERMINAL t);
    friend void fl_terminal_set_cursor_row(TERMINAL t, int r);
    friend void fl_terminal_set_cursor_col(TERMINAL t, int c);
    friend int fl_terminal_get_selection(TERMINAL t, int * srow, int * scol,
        int * erow, int * ecol);
    friend int fl_terminal_ring(TERMINAL t, int what);
    friend int fl_terminal_cell(TERMINAL t, int row, int col, char * buf, int * len,
        int * attrib, unsigned int * fg, unsigned int * bg);

    friend void fl_terminal_draw(TERMINAL n);
    friend int fl_terminal_handle(TERMINAL n, int e);

    void draw();
    int handle(int e);
};

template struct Reach<My_Terminal::Seq, &Fl_Terminal::escseq>;
template struct Reach<My_Terminal::Modified, &Fl_Terminal::redraw_modified_>;

void My_Terminal::fit() {
    cursor_row(cursor_row());
    cursor_col(cursor_col());
    EscapeSeq &seq = this->*member(Seq());
    int row, col;
    seq.restore_cursor(row, col);
    if (row >= 0 || col >= 0) {
        if (row >= display_rows()) {
            row = display_rows() - 1;
        }
        if (col >= display_columns()) {
            col = display_columns() - 1;
        }
        seq.save_cursor(row, col);
    }
}

void My_Terminal::restore() {
    EscapeSeq &seq = this->*member(Seq());
    int row, col;
    seq.restore_cursor(row, col);
    if (row >= 0 && col >= 0) {
        cursor_row(row);
        cursor_col(col);
    }
}

void My_Terminal::base_resize(int x, int y, int w, int h) {
    Fl_Terminal::resize(x, y, w, h);
    fit();
}

void My_Terminal::draw() {
    widget_draw_hook(this->user_data());
}

int My_Terminal::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

int fl_terminal_fits(int rows, int hist, int cols) {
    return rows >= 1 && hist >= 0 && cols >= 1 &&
        (static_cast<long long>(rows) + hist) * cols <= max_cells;
}

//  One printable UTF-8 character of at most 4 bytes, since FLTK copies
//  the error character into a cell of 4 bytes unchecked, and prints it
//  with print_char, which sends a control character back to
//  handle_unknown_char without end (pofltk 98)
static bool one_character(const char * s) {
    size_t len = strlen(s);
    if (len < 1 || len > 4) {
        return false;
    }
    if (static_cast<unsigned char>(s[0]) < 0x20 || s[0] == 0x7f) {
        return false;
    }
    if (fl_utf8len(s[0]) != static_cast<int>(len)) {
        return false;
    }
    for (size_t i = 1; i < len; i++) {
        if ((s[i] & 0xC0) != 0x80) {
            return false;
        }
    }
    return true;
}

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




//  These redraw as the other moves do (pofltk 99).
void fl_terminal_cursor_home(TERMINAL t) {
    My_Terminal *m = static_cast<My_Terminal*>(t);
    m->cursor_home();
    m->modified();
}

//  FLTK clamps every count but cursor_right's, which with scrolling
//  would loop through a huge one a line at a time; no move needs more
//  than a screen's worth of cells.
void fl_terminal_cursor_move(TERMINAL t, int what, int count, int scroll) {
    My_Terminal *m = static_cast<My_Terminal*>(t);
    bool s = scroll != 0;
    if (count < 1) {
        return;
    }
    switch (what) {
    case 0: m->cursor_up(count, s); break;
    case 1: m->cursor_down(count, s); break;
    case 2: m->cursor_left(count); break;
    case 3: {
        long long most = static_cast<long long>(m->display_columns()) *
            (m->display_rows() + m->history_rows() + 1);
        m->cursor_right(count > most ? static_cast<int>(most) : count, s);
        break;
    }
    case 4: m->cursor_eol(); break;
    case 5: m->cursor_sol(); break;
    case 6: m->cursor_cr(); break;
    case 7: m->cursor_crlf(count); break;
    //  FLTK's tabs stop at the first tab stop whatever the count (F24)
    case 8:
    case 9:
        if (count > m->display_columns()) {
            count = m->display_columns();
        }
        for (int i = 0; i < count; i++) {
            if (what == 8) {
                m->cursor_tab_right(1);
            } else {
                m->cursor_tab_left(1);
            }
        }
        break;
    case 10: m->save_cursor(); break;
    case 11: m->restore(); break;
    default: return;
    }
    m->modified();
}

int fl_terminal_get_cursor_row(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->cursor_row();
}

void fl_terminal_set_cursor_row(TERMINAL t, int r) {
    My_Terminal *m = static_cast<My_Terminal*>(t);
    m->cursor_row(r);
    m->modified();
}

int fl_terminal_get_cursor_col(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->cursor_col();
}

void fl_terminal_set_cursor_col(TERMINAL t, int c) {
    My_Terminal *m = static_cast<My_Terminal*>(t);
    m->cursor_col(c);
    m->modified();
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

//  display_rows of 0 or less snaps back to what the height allows
int fl_terminal_set_display_rows(TERMINAL t, int r) {
    My_Terminal *m = static_cast<My_Terminal*>(t);
    if (r >= 1 && !fl_terminal_fits(r, m->history_rows(), m->display_columns())) {
        return 0;
    }
    m->display_rows(r);
    m->fit();
    return 1;
}

int fl_terminal_get_display_columns(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->display_columns();
}

//  FLTK takes display_columns of 0 (pofltk 99)
int fl_terminal_set_display_columns(TERMINAL t, int c) {
    My_Terminal *m = static_cast<My_Terminal*>(t);
    if (!fl_terminal_fits(m->display_rows(), m->history_rows(), c)) {
        return 0;
    }
    m->display_columns(c);
    m->fit();
    return 1;
}

int fl_terminal_get_history_rows(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->history_rows();
}

int fl_terminal_set_history_rows(TERMINAL t, int r) {
    My_Terminal *m = static_cast<My_Terminal*>(t);
    if (!fl_terminal_fits(m->display_rows(), r, m->display_columns())) {
        return 0;
    }
    m->history_rows(r);
    m->fit();
    return 1;
}

int fl_terminal_get_history_lines(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->history_lines();
}

//  history_lines is history_rows (Fl_Terminal.cxx:4141)
int fl_terminal_set_history_lines(TERMINAL t, int l) {
    return fl_terminal_set_history_rows(t, l);
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

//  A change made under the old style, and not yet drawn, is drawn now,
//  unless the new style is NO_REDRAW (F23)
void fl_terminal_set_redraw_style(TERMINAL t, int s) {
    My_Terminal *m = static_cast<My_Terminal*>(t);
    m->redraw_style(static_cast<Fl_Terminal::RedrawStyle>(s));
    bool &modified = m->*member(My_Terminal::Modified());
    if (modified) {
        modified = false;
        if (s != Fl_Terminal::NO_REDRAW) {
            m->redraw();
        }
    }
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

int fl_terminal_set_error_char(TERMINAL t, const char * s) {
    if (!one_character(s)) {
        return 0;
    }
    My_Terminal *m = static_cast<My_Terminal*>(t);
    m->error_store = s;
    m->error_char(m->error_store.c_str());
    return 1;
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
    My_Terminal *m = static_cast<My_Terminal*>(t);
    m->textfont(static_cast<Fl_Font>(f));
    m->fit();
}

int fl_terminal_get_textsize(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->textsize();
}

//  A text size of 0 divides by zero (pofltk 99)
int fl_terminal_set_textsize(TERMINAL t, int s) {
    if (s < 1) {
        return 0;
    }
    My_Terminal *m = static_cast<My_Terminal*>(t);
    m->textsize(static_cast<Fl_Fontsize>(s));
    m->fit();
    return 1;
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
    My_Terminal *m = static_cast<My_Terminal*>(t);
    m->box(static_cast<Fl_Boxtype>(b));
    m->fit();
}




int fl_terminal_get_margin_left(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->margin_left();
}

void fl_terminal_set_margin_left(TERMINAL t, int m) {
    My_Terminal *n = static_cast<My_Terminal*>(t);
    n->margin_left(m);
    n->fit();
}

int fl_terminal_get_margin_right(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->margin_right();
}

void fl_terminal_set_margin_right(TERMINAL t, int m) {
    My_Terminal *n = static_cast<My_Terminal*>(t);
    n->margin_right(m);
    n->fit();
}

int fl_terminal_get_margin_top(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->margin_top();
}

void fl_terminal_set_margin_top(TERMINAL t, int m) {
    My_Terminal *n = static_cast<My_Terminal*>(t);
    n->margin_top(m);
    n->fit();
}

int fl_terminal_get_margin_bottom(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->margin_bottom();
}

void fl_terminal_set_margin_bottom(TERMINAL t, int m) {
    My_Terminal *n = static_cast<My_Terminal*>(t);
    n->margin_bottom(m);
    n->fit();
}




int fl_terminal_get_scrollbar_size(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->scrollbar_size();
}

void fl_terminal_set_scrollbar_size(TERMINAL t, int s) {
    My_Terminal *m = static_cast<My_Terminal*>(t);
    m->scrollbar_size(s);
    m->fit();
}

int fl_terminal_get_scrollbar_actual_size(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->scrollbar_actual_size();
}

int fl_terminal_get_hscrollbar_style(TERMINAL t) {
    return static_cast<Fl_Terminal*>(t)->hscrollbar_style();
}

void fl_terminal_set_hscrollbar_style(TERMINAL t, int s) {
    My_Terminal *m = static_cast<My_Terminal*>(t);
    m->hscrollbar_style(static_cast<Fl_Terminal::ScrollbarStyle>(s));
    m->fit();
}




int fl_terminal_get_selection(TERMINAL t, int * srow, int * scol, int * erow, int * ecol) {
    return static_cast<My_Terminal*>(t)->get_selection(*srow, *scol, *erow, *ecol);
}


//  FLTK's ring, which only a subclass sees (from pofltk's FlTerminal.cpp).
//  what:  0 rows, 1 columns, 2 offset, 3 and 4 the history's first and
//  last rows, 5 and 6 the screen's, 7 the current style's flags.
int fl_terminal_ring(TERMINAL t, int what) {
    My_Terminal * m = static_cast<My_Terminal*>(t);
    switch (what) {
    case 0: return m->ring_rows();
    case 1: return m->ring_cols();
    case 2: return m->offset();
    case 3: return m->hist_srow();
    case 4: return m->hist_erow();
    case 5: return m->disp_srow();
    case 6: return m->disp_erow();
    case 7: return m->current_style().charflags();
    default: return 0;
    }
}

//  A cell of the ring:  its character into buf, of 4 bytes, not ended by
//  a 0, its length, attributes and colours.  0, doing nothing, for a row
//  or column outside the ring, which FLTK doesn't check.
int fl_terminal_cell(TERMINAL t, int row, int col, char * buf, int * len,
    int * attrib, unsigned int * fg, unsigned int * bg)
{
    My_Terminal * m = static_cast<My_Terminal*>(t);
    if (row < 0 || row >= m->ring_rows() || col < 0 || col >= m->ring_cols()) {
        return 0;
    }
    const auto * u = m->u8c_ring_row(row) + col;
    int n = u->length();
    if (n > 4) {
        n = 4;
    }
    for (int i = 0; i < n; i++) {
        buf[i] = u->text_utf8()[i];
    }
    *len = n;
    *attrib = u->attrib();
    *fg = u->fgcolor();
    *bg = u->bgcolor();
    return 1;
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




//  Drawn, the terminal is no longer modified, so the next change under
//  PER_WRITE redraws again (F23).  Not under RATE_LIMITED, whose timer
//  clears it: this draw may be clipped to a scrollbar the write changed,
//  and the timer's redraw is then the only one (FLTKAda-BUGS.md 87).
void fl_terminal_draw(TERMINAL n) {
    My_Terminal *m = static_cast<My_Terminal*>(n);
    m->Fl_Terminal::draw();
    if (m->redraw_style() == Fl_Terminal::PER_WRITE) {
        m->*member(My_Terminal::Modified()) = false;
    }
}

int fl_terminal_handle(TERMINAL n, int e) {
    return static_cast<My_Terminal*>(n)->Fl_Terminal::handle(e);
}

