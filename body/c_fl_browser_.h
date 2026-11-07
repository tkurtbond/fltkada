

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_ABSTRACT_BROWSER_GUARD
#define FL_ABSTRACT_BROWSER_GUARD


extern "C" const int fl_sort_ascending;
extern "C" const int fl_sort_descending;
extern "C" const int fl_sort_caseinsensitive;


typedef void* ABSTRACTBROWSER;


class Fl_Browser_;

//  Brings the browser's top line up to date with its scroll position.
void browser_update_top(Fl_Browser_ * b);


extern "C" ABSTRACTBROWSER new_fl_abstract_browser(int x, int y, int w, int h, char * label);
extern "C" void free_fl_abstract_browser(ABSTRACTBROWSER b);


extern "C" void * fl_abstract_browser_hscrollbar(ABSTRACTBROWSER b);
extern "C" void * fl_abstract_browser_scrollbar(ABSTRACTBROWSER b);


extern "C" int fl_abstract_browser_select(ABSTRACTBROWSER b, void * i, int v, int c);
extern "C" int fl_abstract_browser_select_only(ABSTRACTBROWSER b, void * i, int c);
extern "C" void * fl_abstract_browser_selection(ABSTRACTBROWSER b);
extern "C" int fl_abstract_browser_deselect(ABSTRACTBROWSER b, int c);
extern "C" void fl_abstract_browser_display(ABSTRACTBROWSER b, void * i);
extern "C" int fl_abstract_browser_displayed(ABSTRACTBROWSER b, void * i);
extern "C" void * fl_abstract_browser_find_item(ABSTRACTBROWSER b, int y);
extern "C" void * fl_abstract_browser_top(ABSTRACTBROWSER b);
extern "C" void fl_abstract_browser_sort(ABSTRACTBROWSER b, int f);


extern "C" unsigned char fl_abstract_browser_get_has_scrollbar(ABSTRACTBROWSER b);
extern "C" void fl_abstract_browser_set_has_scrollbar(ABSTRACTBROWSER b, unsigned char m);
extern "C" int fl_abstract_browser_get_hposition(ABSTRACTBROWSER b);
extern "C" void fl_abstract_browser_set_hposition(ABSTRACTBROWSER b, int p);
extern "C" int fl_abstract_browser_get_position(ABSTRACTBROWSER b);
extern "C" void fl_abstract_browser_set_position(ABSTRACTBROWSER b, int p);
extern "C" void fl_abstract_browser_scrollbar_left(ABSTRACTBROWSER b);
extern "C" void fl_abstract_browser_scrollbar_right(ABSTRACTBROWSER b);
extern "C" int fl_abstract_browser_get_scrollbar_size(ABSTRACTBROWSER b);
extern "C" void fl_abstract_browser_set_scrollbar_size(ABSTRACTBROWSER b, int s);


extern "C" unsigned int fl_abstract_browser_get_textcolor(ABSTRACTBROWSER b);
extern "C" void fl_abstract_browser_set_textcolor(ABSTRACTBROWSER b, unsigned int c);
extern "C" int fl_abstract_browser_get_textfont(ABSTRACTBROWSER b);
extern "C" void fl_abstract_browser_set_textfont(ABSTRACTBROWSER b, int f);
extern "C" int fl_abstract_browser_get_textsize(ABSTRACTBROWSER b);
extern "C" void fl_abstract_browser_set_textsize(ABSTRACTBROWSER b, int s);


extern "C" void fl_abstract_browser_resize(ABSTRACTBROWSER b, int x, int y, int w, int h);
extern "C" void fl_abstract_browser_bbox(ABSTRACTBROWSER b, int &x, int &y, int &w, int &h);
extern "C" int fl_abstract_browser_leftedge(ABSTRACTBROWSER b);
extern "C" void fl_abstract_browser_redraw_line(ABSTRACTBROWSER b, void * i);
extern "C" void fl_abstract_browser_redraw_lines(ABSTRACTBROWSER b);


extern "C" int fl_abstract_browser_full_width(ABSTRACTBROWSER b);
extern "C" int fl_abstract_browser_full_height(ABSTRACTBROWSER b);
extern "C" int fl_abstract_browser_incr_height(ABSTRACTBROWSER b);
extern "C" int fl_abstract_browser_item_quick_height(ABSTRACTBROWSER b, void * i);


extern "C" void fl_abstract_browser_new_list(ABSTRACTBROWSER b);
extern "C" void fl_abstract_browser_inserting(ABSTRACTBROWSER b, void * a1, void * a2);
extern "C" void fl_abstract_browser_deleting(ABSTRACTBROWSER b, void * item);
extern "C" void fl_abstract_browser_replacing(ABSTRACTBROWSER b, void * a1, void * a2);
extern "C" void fl_abstract_browser_swapping(ABSTRACTBROWSER b, void * a1, void * a2);


extern "C" void fl_abstract_browser_draw(ABSTRACTBROWSER b);
extern "C" int fl_abstract_browser_handle(ABSTRACTBROWSER b, int e);


#endif


