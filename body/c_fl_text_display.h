

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_TEXT_DISPLAY_GUARD
#define FL_TEXT_DISPLAY_GUARD

#include "c_fl_text_buffer.h"


typedef void* TEXTDISPLAY;


extern "C" TEXTDISPLAY new_fl_text_display(int x, int y, int w, int h, char* label);
extern "C" void free_fl_text_display(TEXTDISPLAY td);


extern "C" TEXTBUFFER fl_text_display_get_buffer(TEXTDISPLAY td);
extern "C" void fl_text_display_set_buffer(TEXTDISPLAY td, TEXTBUFFER tb);
extern "C" void fl_text_display_buffer_modified_cb(int p, int i, int d, int r,
    const char * t, TEXTDISPLAY td);
extern "C" void fl_text_display_buffer_predelete_cb(int p, int d, TEXTDISPLAY td);


extern "C" void fl_text_display_highlight_data(TEXTDISPLAY td, TEXTBUFFER tb, void * st, int len);
extern "C" void fl_text_display_highlight_data2(TEXTDISPLAY td, TEXTBUFFER tb, void * st, int len,
    char us, void * cb, void * a);
extern "C" int fl_text_display_position_style(TEXTDISPLAY td, int s, int l, int i);


extern "C" double fl_text_display_col_to_x(TEXTDISPLAY td, double c);
extern "C" double fl_text_display_x_to_col(TEXTDISPLAY td, double x);
extern "C" int fl_text_display_in_selection(TEXTDISPLAY td, int x, int y);
extern "C" int fl_text_display_position_to_xy(TEXTDISPLAY td, int p, int * x, int * y);
extern "C" void fl_text_display_find_line_end(TEXTDISPLAY td, int sp, int spils, int &le, int &nls);
extern "C" int fl_text_display_find_x(TEXTDISPLAY td, const char * str, int l, int s, int x);
extern "C" int fl_text_display_position_to_line(TEXTDISPLAY td, int p, int &ln);
extern "C" int fl_text_display_position_to_linecol(TEXTDISPLAY td, int p, int &ln, int &c);
extern "C" int fl_text_display_xy_to_position(TEXTDISPLAY td, int x, int y, int k);
extern "C" void fl_text_display_xy_to_rowcol(TEXTDISPLAY td, int x, int y, int &r, int &c, int k);


extern "C" unsigned int fl_text_display_get_cursor_color(TEXTDISPLAY td);
extern "C" void fl_text_display_set_cursor_color(TEXTDISPLAY td, unsigned int c);
extern "C" void fl_text_display_set_cursor_style(TEXTDISPLAY td, int s);
extern "C" void fl_text_display_hide_cursor(TEXTDISPLAY td);
extern "C" void fl_text_display_show_cursor(TEXTDISPLAY td);


extern "C" unsigned int fl_text_display_get_text_color(TEXTDISPLAY td);
extern "C" void fl_text_display_set_text_color(TEXTDISPLAY td, unsigned int c);
extern "C" int fl_text_display_get_text_font(TEXTDISPLAY td);
extern "C" void fl_text_display_set_text_font(TEXTDISPLAY td, int f);
extern "C" int fl_text_display_get_text_size(TEXTDISPLAY td);
extern "C" void fl_text_display_set_text_size(TEXTDISPLAY td, int s);


extern "C" void fl_text_display_insert(TEXTDISPLAY td, char * i);
extern "C" void fl_text_display_overstrike(TEXTDISPLAY td, char * t);
extern "C" int fl_text_display_get_insert_pos(TEXTDISPLAY td);
extern "C" void fl_text_display_set_insert_pos(TEXTDISPLAY td, int p);
extern "C" void fl_text_display_show_insert_pos(TEXTDISPLAY td);


extern "C" int fl_text_display_word_start(TEXTDISPLAY td, int p);
extern "C" int fl_text_display_word_end(TEXTDISPLAY td, int p);
extern "C" void fl_text_display_next_word(TEXTDISPLAY td);
extern "C" void fl_text_display_previous_word(TEXTDISPLAY td);


extern "C" void fl_text_display_wrap_mode(TEXTDISPLAY td, int w, int m);
extern "C" int fl_text_display_wrapped_row(TEXTDISPLAY td, int r);
extern "C" int fl_text_display_wrapped_column(TEXTDISPLAY td, int r, int c);
extern "C" int fl_text_display_wrap_uses_character(TEXTDISPLAY td, int lep);
extern "C" void fl_text_display_wrapped_line_counter(TEXTDISPLAY td, void * buf, int startPos,
    int maxPos, int maxLines, int spils, int sbo, int &retPos, int &retLines, int &retLineStart,
    int &retLineEnd, int cllmnl);


extern "C" int fl_text_display_line_start(TEXTDISPLAY td, int s);
extern "C" int fl_text_display_line_end(TEXTDISPLAY td, int s, int p);
extern "C" int fl_text_display_count_lines(TEXTDISPLAY td, int s, int f, int p);
extern "C" int fl_text_display_skip_lines(TEXTDISPLAY td, int s, int l, int p);
extern "C" int fl_text_display_rewind_lines(TEXTDISPLAY td, int s, int l);
extern "C" void fl_text_display_calc_last_char(TEXTDISPLAY td);
extern "C" void fl_text_display_calc_line_starts(TEXTDISPLAY td, int s, int f);
extern "C" void fl_text_display_offset_line_starts(TEXTDISPLAY td, int t);


extern "C" void fl_text_display_absolute_top_line_number(TEXTDISPLAY td, int c);
extern "C" int fl_text_display_get_absolute_top_line_number(TEXTDISPLAY td);
extern "C" void fl_text_display_maintain_absolute_top_line_number(TEXTDISPLAY td, int s);
extern "C" int fl_text_display_maintaining_absolute_top_line_number(TEXTDISPLAY td);
extern "C" void fl_text_display_reset_absolute_top_line_number(TEXTDISPLAY td);


extern "C" int fl_text_display_empty_vlines(TEXTDISPLAY td);
extern "C" int fl_text_display_longest_vline(TEXTDISPLAY td);
extern "C" int fl_text_display_vline_length(TEXTDISPLAY td, int l);


extern "C" unsigned int fl_text_display_get_linenumber_align(TEXTDISPLAY td);
extern "C" void fl_text_display_set_linenumber_align(TEXTDISPLAY td, unsigned int a);
extern "C" unsigned int fl_text_display_get_linenumber_bgcolor(TEXTDISPLAY td);
extern "C" void fl_text_display_set_linenumber_bgcolor(TEXTDISPLAY td, unsigned int c);
extern "C" unsigned int fl_text_display_get_linenumber_fgcolor(TEXTDISPLAY td);
extern "C" void fl_text_display_set_linenumber_fgcolor(TEXTDISPLAY td, unsigned int c);
extern "C" int fl_text_display_get_linenumber_font(TEXTDISPLAY td);
extern "C" void fl_text_display_set_linenumber_font(TEXTDISPLAY td, int f);
extern "C" int fl_text_display_get_linenumber_size(TEXTDISPLAY td);
extern "C" void fl_text_display_set_linenumber_size(TEXTDISPLAY td, int s);
extern "C" int fl_text_display_get_linenumber_width(TEXTDISPLAY td);
extern "C" void fl_text_display_set_linenumber_width(TEXTDISPLAY td, int w);
extern "C" const char * fl_text_display_get_linenumber_format(TEXTDISPLAY td);
extern "C" void fl_text_display_set_linenumber_format(TEXTDISPLAY td, const char * v);


extern "C" double fl_text_display_measure_proportional_character(TEXTDISPLAY td, const char * str,
    int xpix, int pos);
extern "C" int fl_text_display_measure_vline(TEXTDISPLAY td, int line);
extern "C" double fl_text_display_string_width(TEXTDISPLAY td, const char * str, int len, int s);


extern "C" int fl_text_display_move_down(TEXTDISPLAY td);
extern "C" int fl_text_display_move_left(TEXTDISPLAY td);
extern "C" int fl_text_display_move_right(TEXTDISPLAY td);
extern "C" int fl_text_display_move_up(TEXTDISPLAY td);


extern "C" void fl_text_display_scroll(TEXTDISPLAY td, int l, int c);
extern "C" int fl_text_display_scroll2(TEXTDISPLAY td, int l, int p);
extern "C" unsigned int fl_text_display_get_scrollbar_align(TEXTDISPLAY td);
extern "C" void fl_text_display_set_scrollbar_align(TEXTDISPLAY td, unsigned int a);
extern "C" int fl_text_display_get_scrollbar_width(TEXTDISPLAY td);
extern "C" void fl_text_display_set_scrollbar_width(TEXTDISPLAY td, int w);
extern "C" int fl_text_display_get_scrollbar_size(TEXTDISPLAY td);
extern "C" void fl_text_display_set_scrollbar_size(TEXTDISPLAY td, int s);
extern "C" void fl_text_display_update_h_scrollbar(TEXTDISPLAY td);
extern "C" void fl_text_display_update_v_scrollbar(TEXTDISPLAY td);


extern "C" int fl_text_display_get_shortcut(TEXTDISPLAY td);
extern "C" void fl_text_display_set_shortcut(TEXTDISPLAY td, int s);


extern "C" void fl_text_display_resize(TEXTDISPLAY td, int x, int y, int w, int h);


extern "C" void fl_text_display_clear_rect(TEXTDISPLAY td, int s, int x, int y, int w, int h);
extern "C" void fl_text_display_display_insert(TEXTDISPLAY td);
extern "C" void fl_text_display_redisplay_range(TEXTDISPLAY td, int s, int f);
extern "C" void fl_text_display_draw(TEXTDISPLAY td);
extern "C" void fl_text_display_draw_cursor(TEXTDISPLAY td, int x, int y);
extern "C" void fl_text_display_draw_line_numbers(TEXTDISPLAY td, int c);
extern "C" void fl_text_display_draw_range(TEXTDISPLAY td, int s, int f);
extern "C" void fl_text_display_draw_string(TEXTDISPLAY td, int s, int x, int y, int r,
    const char * str, int n);
extern "C" void fl_text_display_draw_text(TEXTDISPLAY td, int x, int y, int w, int h);
extern "C" void fl_text_display_draw_vline(TEXTDISPLAY td, int line, int left, int right,
    int lchar, int rchar);
extern "C" int fl_text_display_handle(TEXTDISPLAY td, int e);


#endif


