

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Text_Display.H>
#include <FL/Fl_Text_Buffer.H>
#include "c_fl_text_display.h"
#include "c_fl_text_buffer.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Non-friend protected access

class Friend_Text_Display : Fl_Text_Display {
public:
    using Fl_Text_Display::buffer_modified_cb;
    using Fl_Text_Display::buffer_predelete_cb;

    using Fl_Text_Display::find_line_end;
    using Fl_Text_Display::find_x;
    using Fl_Text_Display::position_to_line;
    using Fl_Text_Display::position_to_linecol;
    using Fl_Text_Display::xy_to_position;
    using Fl_Text_Display::xy_to_rowcol;

    using Fl_Text_Display::wrap_uses_character;
    using Fl_Text_Display::wrapped_line_counter;

    using Fl_Text_Display::calc_last_char;
    using Fl_Text_Display::calc_line_starts;
    using Fl_Text_Display::offset_line_starts;

    using Fl_Text_Display::absolute_top_line_number;
    using Fl_Text_Display::get_absolute_top_line_number;
    using Fl_Text_Display::maintain_absolute_top_line_number;
    using Fl_Text_Display::maintaining_absolute_top_line_number;
    using Fl_Text_Display::reset_absolute_top_line_number;

    using Fl_Text_Display::empty_vlines;
    using Fl_Text_Display::longest_vline;
    using Fl_Text_Display::vline_length;

    using Fl_Text_Display::measure_proportional_character;
    using Fl_Text_Display::measure_vline;
    using Fl_Text_Display::string_width;

    using Fl_Text_Display::scroll_;
    using Fl_Text_Display::update_h_scrollbar;
    using Fl_Text_Display::update_v_scrollbar;

    using Fl_Text_Display::clear_rect;
    using Fl_Text_Display::display_insert;
    using Fl_Text_Display::draw_cursor;
    using Fl_Text_Display::draw_line_numbers;
    using Fl_Text_Display::draw_range;
    using Fl_Text_Display::draw_string;
    using Fl_Text_Display::draw_text;
    using Fl_Text_Display::draw_vline;
};




//  Attaching all relevant hooks and friends

class My_Text_Display : public Fl_Text_Display {
public:
    using Fl_Text_Display::Fl_Text_Display;

    friend void fl_text_display_draw(TEXTDISPLAY td);
    friend int fl_text_display_handle(TEXTDISPLAY td, int e);

    void draw();
    int handle(int e);
};

void My_Text_Display::draw() {
    widget_draw_hook(this->user_data());
}

int My_Text_Display::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

TEXTDISPLAY new_fl_text_display(int x, int y, int w, int h, char*  label) {
    My_Text_Display *td = new My_Text_Display(x, y, w, h, label);
    return td;
}

void free_fl_text_display(TEXTDISPLAY td) {
    delete static_cast<My_Text_Display*>(td);
}




// this actually never gets called, since an access to the text_buffer
// object is stored on the Ada side of things
TEXTBUFFER fl_text_display_get_buffer(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->buffer();
}

void fl_text_display_set_buffer(TEXTDISPLAY td, TEXTBUFFER tb) {
    static_cast<Fl_Text_Display*>(td)->buffer(static_cast<Fl_Text_Buffer*>(tb));
}

void fl_text_display_buffer_modified_cb(int p, int i, int d, int r,
    const char * t, TEXTDISPLAY td)
{
    Friend_Text_Display::buffer_modified_cb(p, i, d, r, t, static_cast<Fl_Text_Display*>(td));
}

void fl_text_display_buffer_predelete_cb(int p, int d, TEXTDISPLAY td) {
    Friend_Text_Display::buffer_predelete_cb(p, d, static_cast<Fl_Text_Display*>(td));
}




void fl_text_display_highlight_data(TEXTDISPLAY td, TEXTBUFFER tb, void * st, int len) {
    static_cast<Fl_Text_Display*>(td)->highlight_data
       (static_cast<Fl_Text_Buffer*>(tb),
        static_cast<Fl_Text_Display::Style_Table_Entry*>(st),
        len, 0, 0, 0);
}

void fl_text_display_highlight_data2(TEXTDISPLAY td, TEXTBUFFER tb, void * st, int len,
    char us, void * cb, void * a)
{
    static_cast<Fl_Text_Display*>(td)->highlight_data
       (static_cast<Fl_Text_Buffer*>(tb),
        static_cast<Fl_Text_Display::Style_Table_Entry*>(st),
        len, us, reinterpret_cast<Fl_Text_Display::Unfinished_Style_Cb>(cb), a);
}

int fl_text_display_position_style(TEXTDISPLAY td, int s, int l, int i) {
    return static_cast<Fl_Text_Display*>(td)->position_style(s, l, i);
}




double fl_text_display_col_to_x(TEXTDISPLAY td, double c) {
    return static_cast<Fl_Text_Display*>(td)->col_to_x(c);
}

double fl_text_display_x_to_col(TEXTDISPLAY td, double x) {
    return static_cast<Fl_Text_Display*>(td)->x_to_col(x);
}

int fl_text_display_in_selection(TEXTDISPLAY td, int x, int y) {
    return static_cast<Fl_Text_Display*>(td)->in_selection(x, y);
}

int fl_text_display_position_to_xy(TEXTDISPLAY td, int p, int * x, int * y) {
    return static_cast<Fl_Text_Display*>(td)->position_to_xy(p, x, y);
}

void fl_text_display_find_line_end(TEXTDISPLAY td, int sp, int spils, int &le, int &nls) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::find_line_end))
        (sp, spils!=0, &le, &nls);
}

int fl_text_display_find_x(TEXTDISPLAY td, const char * str, int l, int s, int x) {
    return (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::find_x))(str, l, s, x);
}

int fl_text_display_position_to_line(TEXTDISPLAY td, int p, int &ln) {
    return (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::position_to_line))(p, &ln);
}

int fl_text_display_position_to_linecol(TEXTDISPLAY td, int p, int &ln, int &c) {
    return (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::position_to_linecol))
        (p, &ln, &c);
}

int fl_text_display_xy_to_position(TEXTDISPLAY td, int x, int y, int k) {
    return (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::xy_to_position))(x, y, k);
}

void fl_text_display_xy_to_rowcol(TEXTDISPLAY td, int x, int y, int &r, int &c, int k) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::xy_to_rowcol))(x, y, &r, &c, k);
}




unsigned int fl_text_display_get_cursor_color(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->cursor_color();
}

void fl_text_display_set_cursor_color(TEXTDISPLAY td, unsigned int c) {
    static_cast<Fl_Text_Display*>(td)->cursor_color(c);
}

void fl_text_display_set_cursor_style(TEXTDISPLAY td, int s) {
    static_cast<Fl_Text_Display*>(td)->cursor_style(s);
}

void fl_text_display_hide_cursor(TEXTDISPLAY td) {
    static_cast<Fl_Text_Display*>(td)->hide_cursor();
}

void fl_text_display_show_cursor(TEXTDISPLAY td) {
    static_cast<Fl_Text_Display*>(td)->show_cursor();
}




unsigned int fl_text_display_get_text_color(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->textcolor();
}

void fl_text_display_set_text_color(TEXTDISPLAY td, unsigned int c) {
    static_cast<Fl_Text_Display*>(td)->textcolor(static_cast<Fl_Color>(c));
}

int fl_text_display_get_text_font(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->textfont();
}

void fl_text_display_set_text_font(TEXTDISPLAY td, int f) {
    static_cast<Fl_Text_Display*>(td)->textfont(static_cast<Fl_Font>(f));
}

int fl_text_display_get_text_size(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->textsize();
}

void fl_text_display_set_text_size(TEXTDISPLAY td, int s) {
    static_cast<Fl_Text_Display*>(td)->textsize(static_cast<Fl_Fontsize>(s));
}




void fl_text_display_insert(TEXTDISPLAY td, char * i) {
    static_cast<Fl_Text_Display*>(td)->insert(i);
}

void fl_text_display_overstrike(TEXTDISPLAY td, char * t) {
    static_cast<Fl_Text_Display*>(td)->overstrike(t);
}

int fl_text_display_get_insert_pos(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->insert_position();
}

void fl_text_display_set_insert_pos(TEXTDISPLAY td, int p) {
    static_cast<Fl_Text_Display*>(td)->insert_position(p);
}

void fl_text_display_show_insert_pos(TEXTDISPLAY td) {
    static_cast<Fl_Text_Display*>(td)->show_insert_position();
}




int fl_text_display_word_start(TEXTDISPLAY td, int p) {
    return static_cast<Fl_Text_Display*>(td)->word_start(p);
}

int fl_text_display_word_end(TEXTDISPLAY td, int p) {
    return static_cast<Fl_Text_Display*>(td)->word_end(p);
}

void fl_text_display_next_word(TEXTDISPLAY td) {
    static_cast<Fl_Text_Display*>(td)->next_word();
}

void fl_text_display_previous_word(TEXTDISPLAY td) {
    static_cast<Fl_Text_Display*>(td)->previous_word();
}




void fl_text_display_wrap_mode(TEXTDISPLAY td, int w, int m) {
    static_cast<Fl_Text_Display*>(td)->wrap_mode(w, m);
}

int fl_text_display_wrapped_row(TEXTDISPLAY td, int r) {
    return static_cast<Fl_Text_Display*>(td)->wrapped_row(r);
}

int fl_text_display_wrapped_column(TEXTDISPLAY td, int r, int c) {
    return static_cast<Fl_Text_Display*>(td)->wrapped_column(r, c);
}

int fl_text_display_wrap_uses_character(TEXTDISPLAY td, int lep) {
    return (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::wrap_uses_character))(lep);
}

void fl_text_display_wrapped_line_counter(TEXTDISPLAY td, void * buf, int startPos,
    int maxPos, int maxLines, int spils, int sbo, int &retPos, int &retLines, int &retLineStart,
    int &retLineEnd, int cllmnl)
{
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::wrapped_line_counter))
       (static_cast<Fl_Text_Buffer*>(buf), startPos, maxPos, maxLines, spils!=0, sbo,
        &retPos, &retLines, &retLineStart, &retLineEnd, cllmnl!=0);
}




int fl_text_display_line_start(TEXTDISPLAY td, int s) {
    return static_cast<Fl_Text_Display*>(td)->line_start(s);
}

int fl_text_display_line_end(TEXTDISPLAY td, int s, int p) {
    return static_cast<Fl_Text_Display*>(td)->line_end(s, p);
}

int fl_text_display_count_lines(TEXTDISPLAY td, int s, int f, int p) {
    return static_cast<Fl_Text_Display*>(td)->count_lines(s, f, p);
}

int fl_text_display_skip_lines(TEXTDISPLAY td, int s, int l, int p) {
    return static_cast<Fl_Text_Display*>(td)->skip_lines(s, l, p);
}

int fl_text_display_rewind_lines(TEXTDISPLAY td, int s, int l) {
    return static_cast<Fl_Text_Display*>(td)->rewind_lines(s, l);
}

void fl_text_display_calc_last_char(TEXTDISPLAY td) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::calc_last_char))();
}

void fl_text_display_calc_line_starts(TEXTDISPLAY td, int s, int f) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::calc_line_starts))(s, f);
}

void fl_text_display_offset_line_starts(TEXTDISPLAY td, int t) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::offset_line_starts))(t);
}




void fl_text_display_absolute_top_line_number(TEXTDISPLAY td, int c) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::absolute_top_line_number))(c);
}

int fl_text_display_get_absolute_top_line_number(TEXTDISPLAY td) {
    return (static_cast<Fl_Text_Display*>(td)->*
        (&Friend_Text_Display::get_absolute_top_line_number))();
}

void fl_text_display_maintain_absolute_top_line_number(TEXTDISPLAY td, int s) {
    (static_cast<Fl_Text_Display*>(td)->*
        (&Friend_Text_Display::maintain_absolute_top_line_number))(s);
}

int fl_text_display_maintaining_absolute_top_line_number(TEXTDISPLAY td) {
    return (static_cast<Fl_Text_Display*>(td)->*
        (&Friend_Text_Display::maintaining_absolute_top_line_number))();
}

void fl_text_display_reset_absolute_top_line_number(TEXTDISPLAY td) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::reset_absolute_top_line_number))();
}




int fl_text_display_empty_vlines(TEXTDISPLAY td) {
    return (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::empty_vlines))();
}

int fl_text_display_longest_vline(TEXTDISPLAY td) {
    return (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::longest_vline))();
}

int fl_text_display_vline_length(TEXTDISPLAY td, int l) {
    return (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::vline_length))(l);
}




unsigned int fl_text_display_get_linenumber_align(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->linenumber_align();
}

void fl_text_display_set_linenumber_align(TEXTDISPLAY td, unsigned int a) {
    static_cast<Fl_Text_Display*>(td)->linenumber_align(a);
}

unsigned int fl_text_display_get_linenumber_bgcolor(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->linenumber_bgcolor();
}

void fl_text_display_set_linenumber_bgcolor(TEXTDISPLAY td, unsigned int c) {
    static_cast<Fl_Text_Display*>(td)->linenumber_bgcolor(c);
}

unsigned int fl_text_display_get_linenumber_fgcolor(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->linenumber_fgcolor();
}

void fl_text_display_set_linenumber_fgcolor(TEXTDISPLAY td, unsigned int c) {
    static_cast<Fl_Text_Display*>(td)->linenumber_fgcolor(c);
}

int fl_text_display_get_linenumber_font(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->linenumber_font();
}

void fl_text_display_set_linenumber_font(TEXTDISPLAY td, int f) {
    static_cast<Fl_Text_Display*>(td)->linenumber_font(f);
}

int fl_text_display_get_linenumber_size(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->linenumber_size();
}

void fl_text_display_set_linenumber_size(TEXTDISPLAY td, int s) {
    static_cast<Fl_Text_Display*>(td)->linenumber_size(s);
}

int fl_text_display_get_linenumber_width(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->linenumber_width();
}

void fl_text_display_set_linenumber_width(TEXTDISPLAY td, int w) {
    static_cast<Fl_Text_Display*>(td)->linenumber_width(w);
}

const char * fl_text_display_get_linenumber_format(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->linenumber_format();
}

void fl_text_display_set_linenumber_format(TEXTDISPLAY td, const char * v) {
    static_cast<Fl_Text_Display*>(td)->linenumber_format(v);
}




double fl_text_display_measure_proportional_character(TEXTDISPLAY td, const char * str,
    int xpix, int pos)
{
    return (static_cast<Fl_Text_Display*>(td)->*
        (&Friend_Text_Display::measure_proportional_character))(str, xpix, pos);
}

int fl_text_display_measure_vline(TEXTDISPLAY td, int line) {
    return (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::measure_vline))(line);
}

double fl_text_display_string_width(TEXTDISPLAY td, const char * str, int len, int s) {
    return (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::string_width))(str, len, s);
}




int fl_text_display_move_down(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->move_down();
}

int fl_text_display_move_left(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->move_left();
}

int fl_text_display_move_right(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->move_right();
}

int fl_text_display_move_up(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->move_up();
}




void fl_text_display_scroll(TEXTDISPLAY td, int l, int c) {
    static_cast<Fl_Text_Display*>(td)->scroll(l, c);
}

int fl_text_display_scroll2(TEXTDISPLAY td, int l, int p) {
    return (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::scroll_))(l, p);
}

unsigned int fl_text_display_get_scrollbar_align(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->scrollbar_align();
}

void fl_text_display_set_scrollbar_align(TEXTDISPLAY td, unsigned int a) {
    static_cast<Fl_Text_Display*>(td)->scrollbar_align(a);
}

int fl_text_display_get_scrollbar_width(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->scrollbar_width();
}

void fl_text_display_set_scrollbar_width(TEXTDISPLAY td, int w) {
    static_cast<Fl_Text_Display*>(td)->scrollbar_width(w);
}

void fl_text_display_update_h_scrollbar(TEXTDISPLAY td) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::update_h_scrollbar))();
}

void fl_text_display_update_v_scrollbar(TEXTDISPLAY td) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::update_v_scrollbar))();
}




int fl_text_display_get_shortcut(TEXTDISPLAY td) {
    return static_cast<Fl_Text_Display*>(td)->shortcut();
}

void fl_text_display_set_shortcut(TEXTDISPLAY td, int s) {
    static_cast<Fl_Text_Display*>(td)->shortcut(s);
}




void fl_text_display_resize(TEXTDISPLAY td, int x, int y, int w, int h) {
    static_cast<Fl_Text_Display*>(td)->resize(x, y, w, h);
}




void fl_text_display_clear_rect(TEXTDISPLAY td, int s, int x, int y, int w, int h) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::clear_rect))(s, x, y, w, h);
}

void fl_text_display_display_insert(TEXTDISPLAY td) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::display_insert))();
}

void fl_text_display_redisplay_range(TEXTDISPLAY td, int s, int f) {
    static_cast<Fl_Text_Display*>(td)->redisplay_range(s,f);
}

void fl_text_display_draw(TEXTDISPLAY td) {
    static_cast<My_Text_Display*>(td)->Fl_Text_Display::draw();
}

void fl_text_display_draw_cursor(TEXTDISPLAY td, int x, int y) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::draw_cursor))(x, y);
}

void fl_text_display_draw_line_numbers(TEXTDISPLAY td, int c) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::draw_line_numbers))(c!=0);
}

void fl_text_display_draw_range(TEXTDISPLAY td, int s, int f) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::draw_range))(s, f);
}

void fl_text_display_draw_string(TEXTDISPLAY td, int s, int x, int y, int r,
    const char * str, int n)
{
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::draw_string))(s, x, y, r, str, n);
}

void fl_text_display_draw_text(TEXTDISPLAY td, int x, int y, int w, int h) {
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::draw_text))(x, y, w, h);
}

void fl_text_display_draw_vline(TEXTDISPLAY td, int line, int left, int right,
    int lchar, int rchar)
{
    (static_cast<Fl_Text_Display*>(td)->*(&Friend_Text_Display::draw_vline))
        (line, left, right, lchar, rchar);
}

int fl_text_display_handle(TEXTDISPLAY td, int e) {
    return static_cast<My_Text_Display*>(td)->Fl_Text_Display::handle(e);
}


