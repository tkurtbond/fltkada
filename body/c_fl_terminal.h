

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#ifndef FL_TERMINAL_GUARD
#define FL_TERMINAL_GUARD


typedef void* TERMINAL;


extern "C" TERMINAL new_fl_terminal(int x, int y, int w, int h, char * label);
extern "C" int fl_terminal_fits(int rows, int hist, int cols);
extern "C" TERMINAL new_fl_terminal2(int x, int y, int w, int h, char * label,
    int rows, int cols, int hist);
extern "C" void free_fl_terminal(TERMINAL t);


extern "C" void fl_terminal_append(TERMINAL t, const char * s, int len);
extern "C" void fl_terminal_append_utf8(TERMINAL t, const char * s, int len);
extern "C" void fl_terminal_append_ascii(TERMINAL t, const char * s);
extern "C" void fl_terminal_print_char(TERMINAL t, const char * s, int len);
extern "C" void fl_terminal_print_char2(TERMINAL t, char c);
extern "C" void fl_terminal_plot_char(TERMINAL t, const char * s, int len, int r, int c);
extern "C" void fl_terminal_plot_char2(TERMINAL t, char ch, int r, int c);


extern "C" void fl_terminal_clear(TERMINAL t);
extern "C" void fl_terminal_clear2(TERMINAL t, unsigned int c);
extern "C" void fl_terminal_clear_screen(TERMINAL t, int s);
extern "C" void fl_terminal_clear_screen_home(TERMINAL t, int s);
extern "C" void fl_terminal_clear_history(TERMINAL t);
extern "C" void fl_terminal_reset_terminal(TERMINAL t);


extern "C" void fl_terminal_cursor_home(TERMINAL t);
extern "C" void fl_terminal_cursor_move(TERMINAL t, int what, int count, int scroll);
extern "C" int fl_terminal_get_cursor_row(TERMINAL t);
extern "C" void fl_terminal_set_cursor_row(TERMINAL t, int r);
extern "C" int fl_terminal_get_cursor_col(TERMINAL t);
extern "C" void fl_terminal_set_cursor_col(TERMINAL t, int c);
extern "C" unsigned int fl_terminal_get_cursorfgcolor(TERMINAL t);
extern "C" void fl_terminal_set_cursorfgcolor(TERMINAL t, unsigned int c);
extern "C" unsigned int fl_terminal_get_cursorbgcolor(TERMINAL t);
extern "C" void fl_terminal_set_cursorbgcolor(TERMINAL t, unsigned int c);


extern "C" int fl_terminal_get_display_rows(TERMINAL t);
extern "C" int fl_terminal_set_display_rows(TERMINAL t, int r);
extern "C" int fl_terminal_get_display_columns(TERMINAL t);
extern "C" int fl_terminal_set_display_columns(TERMINAL t, int c);
extern "C" int fl_terminal_get_history_rows(TERMINAL t);
extern "C" int fl_terminal_set_history_rows(TERMINAL t, int r);
extern "C" int fl_terminal_get_history_lines(TERMINAL t);
extern "C" int fl_terminal_set_history_lines(TERMINAL t, int l);
extern "C" int fl_terminal_get_history_use(TERMINAL t);
extern "C" float fl_terminal_get_redraw_rate(TERMINAL t);
extern "C" void fl_terminal_set_redraw_rate(TERMINAL t, float r);
extern "C" int fl_terminal_get_redraw_style(TERMINAL t);
extern "C" void fl_terminal_set_redraw_style(TERMINAL t, int s);


extern "C" int fl_terminal_get_ansi(TERMINAL t);
extern "C" void fl_terminal_set_ansi(TERMINAL t, int a);
extern "C" int fl_terminal_get_show_unknown(TERMINAL t);
extern "C" void fl_terminal_set_show_unknown(TERMINAL t, int s);
extern "C" const char * fl_terminal_get_error_char(TERMINAL t);
extern "C" int fl_terminal_set_error_char(TERMINAL t, const char * s);
extern "C" int fl_terminal_get_output_translate(TERMINAL t);
extern "C" void fl_terminal_set_output_translate(TERMINAL t, int o);


extern "C" int fl_terminal_get_textfont(TERMINAL t);
extern "C" void fl_terminal_set_textfont(TERMINAL t, int f);
extern "C" int fl_terminal_get_textsize(TERMINAL t);
extern "C" int fl_terminal_set_textsize(TERMINAL t, int s);
extern "C" unsigned int fl_terminal_get_textcolor(TERMINAL t);
extern "C" void fl_terminal_set_textcolor(TERMINAL t, unsigned int c);
extern "C" unsigned int fl_terminal_get_textfgcolor(TERMINAL t);
extern "C" void fl_terminal_set_textfgcolor(TERMINAL t, unsigned int c);
extern "C" unsigned int fl_terminal_get_textbgcolor(TERMINAL t);
extern "C" void fl_terminal_set_textbgcolor(TERMINAL t, unsigned int c);
extern "C" unsigned int fl_terminal_get_textfgcolor_default(TERMINAL t);
extern "C" void fl_terminal_set_textfgcolor_default(TERMINAL t, unsigned int c);
extern "C" unsigned int fl_terminal_get_textbgcolor_default(TERMINAL t);
extern "C" void fl_terminal_set_textbgcolor_default(TERMINAL t, unsigned int c);
extern "C" void fl_terminal_set_textfgcolor_xterm(TERMINAL t, unsigned char c);
extern "C" void fl_terminal_set_textbgcolor_xterm(TERMINAL t, unsigned char c);
extern "C" unsigned char fl_terminal_get_textattrib(TERMINAL t);
extern "C" void fl_terminal_set_textattrib(TERMINAL t, unsigned char a);
extern "C" unsigned int fl_terminal_get_selectionfgcolor(TERMINAL t);
extern "C" void fl_terminal_set_selectionfgcolor(TERMINAL t, unsigned int c);
extern "C" unsigned int fl_terminal_get_selectionbgcolor(TERMINAL t);
extern "C" void fl_terminal_set_selectionbgcolor(TERMINAL t, unsigned int c);


extern "C" void fl_terminal_set_box(TERMINAL t, int b);


extern "C" int fl_terminal_get_margin_left(TERMINAL t);
extern "C" void fl_terminal_set_margin_left(TERMINAL t, int m);
extern "C" int fl_terminal_get_margin_right(TERMINAL t);
extern "C" void fl_terminal_set_margin_right(TERMINAL t, int m);
extern "C" int fl_terminal_get_margin_top(TERMINAL t);
extern "C" void fl_terminal_set_margin_top(TERMINAL t, int m);
extern "C" int fl_terminal_get_margin_bottom(TERMINAL t);
extern "C" void fl_terminal_set_margin_bottom(TERMINAL t, int m);


extern "C" int fl_terminal_get_scrollbar_size(TERMINAL t);
extern "C" void fl_terminal_set_scrollbar_size(TERMINAL t, int s);
extern "C" int fl_terminal_get_scrollbar_actual_size(TERMINAL t);
extern "C" int fl_terminal_get_hscrollbar_style(TERMINAL t);
extern "C" void fl_terminal_set_hscrollbar_style(TERMINAL t, int s);


extern "C" int fl_terminal_get_selection(TERMINAL t, int * srow, int * scol,
    int * erow, int * ecol);
extern "C" int fl_terminal_selection_text_len(TERMINAL t);
extern "C" int fl_terminal_ring(TERMINAL t, int what);
extern "C" int fl_terminal_cell(TERMINAL t, int row, int col, char * buf, int * len,
    int * attrib, unsigned int * fg, unsigned int * bg);
extern "C" char * fl_terminal_selection_text(TERMINAL t);
extern "C" char * fl_terminal_text(TERMINAL t, int b);
extern "C" void fl_terminal_free_text(char * s);


extern "C" void fl_terminal_draw(TERMINAL n);
extern "C" int fl_terminal_handle(TERMINAL n, int e);


#endif

