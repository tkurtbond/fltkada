

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_BROWSER_GUARD
#define FL_BROWSER_GUARD


typedef void* BROWSER;


extern "C" BROWSER new_fl_browser(int x, int y, int w, int h, char * label);
extern "C" void free_fl_browser(BROWSER b);


extern "C" void fl_browser_add(BROWSER b, const char * text, void * d=0);
extern "C" void fl_browser_insert(BROWSER b, int line, const char * text, void * d=0);
extern "C" void fl_browser_move(BROWSER b, int to, int from);
extern "C" void fl_browser_swap(BROWSER b, int x, int y);
extern "C" void fl_browser_remove(BROWSER b, int line);
extern "C" void fl_browser_clear(BROWSER b);
extern "C" int fl_browser_size(BROWSER b);


extern "C" int fl_browser_load(BROWSER b, const char * f);
extern "C" const char * fl_browser_get_text(BROWSER b, int line);
extern "C" void fl_browser_set_text(BROWSER b, int line, const char * text);
extern "C" int fl_browser_get_textsize(BROWSER b);
extern "C" void fl_browser_set_textsize(BROWSER b, int size);


extern "C" char fl_browser_get_column_char(BROWSER b);
extern "C" void fl_browser_set_column_char(BROWSER b, char c);
extern "C" void fl_browser_set_column_widths(BROWSER b, void * w);
extern "C" char fl_browser_get_format_char(BROWSER b);
extern "C" void fl_browser_set_format_char(BROWSER b, char c);


extern "C" int fl_browser_get_topline(BROWSER b);
extern "C" void fl_browser_set_topline(BROWSER b, int line);
extern "C" void fl_browser_middleline(BROWSER b, int line);
extern "C" void fl_browser_bottomline(BROWSER b, int line);
extern "C" void fl_browser_lineposition(BROWSER b, int line, int p);


extern "C" int fl_browser_select(BROWSER b, int l, int v);
extern "C" int fl_browser_selected(BROWSER b, int l);
extern "C" int fl_browser_value(BROWSER b);


extern "C" int fl_browser_visible(BROWSER b, int l);
extern "C" void fl_browser_make_visible(BROWSER b, int l);
extern "C" int fl_browser_displayed(BROWSER b, int l);
extern "C" void fl_browser_show_line(BROWSER b, int l);
extern "C" void fl_browser_hide_line(BROWSER b, int l);
extern "C" void fl_browser_show(BROWSER b);
extern "C" void fl_browser_hide(BROWSER b);


extern "C" void fl_browser_set_size(BROWSER b, int w, int h);


extern "C" void fl_browser_set_icon(BROWSER b, int l, void * c);
extern "C" void fl_browser_remove_icon(BROWSER b, int l);
extern "C" void * fl_browser_get_icon(BROWSER b, int l);


extern "C" int fl_browser_full_height(BROWSER c);
extern "C" int fl_browser_incr_height(BROWSER c);


extern "C" int fl_browser_item_width(BROWSER b, void * item);
extern "C" int fl_browser_item_height(BROWSER b, void * item);
extern "C" void * fl_browser_item_first(BROWSER b);
extern "C" void * fl_browser_item_last(BROWSER b);
extern "C" void * fl_browser_item_next(BROWSER b, void * item);
extern "C" void * fl_browser_item_prev(BROWSER b, void * item);
extern "C" void * fl_browser_item_at(BROWSER b, int index);
extern "C" void fl_browser_item_select(BROWSER b, void * item, int val=1);
extern "C" int fl_browser_item_selected(BROWSER b, void * item);
extern "C" void fl_browser_item_swap(BROWSER b, void * x, void * y);
extern "C" const char * fl_browser_item_text(BROWSER b, void * item);
extern "C" void fl_browser_item_draw(BROWSER b, void * item, int x, int y, int w, int h);


extern "C" int fl_browser_lineno(BROWSER b, void * item);


//  reimp below here

extern "C" int fl_browser_full_width(BROWSER c);
extern "C" int fl_browser_item_quick_height(BROWSER c, void * i);


extern "C" void fl_browser_draw(BROWSER b);
extern "C" int fl_browser_handle(BROWSER b, int e);


#endif


