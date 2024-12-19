

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_HOLD_BROWSER_GUARD
#define FL_HOLD_BROWSER_GUARD


typedef void* HOLDBROWSER;


extern "C" HOLDBROWSER new_fl_hold_browser(int x, int y, int w, int h, char * label);
extern "C" void free_fl_hold_browser(HOLDBROWSER b);


//  reimp below here

extern "C" int fl_hold_browser_full_height(HOLDBROWSER c);
extern "C" int fl_hold_browser_incr_height(HOLDBROWSER c);


extern "C" int fl_hold_browser_item_width(HOLDBROWSER b, void * item);
extern "C" int fl_hold_browser_item_height(HOLDBROWSER b, void * item);
extern "C" void * fl_hold_browser_item_first(HOLDBROWSER b);
extern "C" void * fl_hold_browser_item_last(HOLDBROWSER b);
extern "C" void * fl_hold_browser_item_next(HOLDBROWSER b, void * item);
extern "C" void * fl_hold_browser_item_prev(HOLDBROWSER b, void * item);
extern "C" void * fl_hold_browser_item_at(HOLDBROWSER b, int index);
extern "C" void fl_hold_browser_item_select(HOLDBROWSER b, void * item, int val=1);
extern "C" int fl_hold_browser_item_selected(HOLDBROWSER b, void * item);
extern "C" void fl_hold_browser_item_swap(HOLDBROWSER b, void * x, void * y);
extern "C" const char * fl_hold_browser_item_text(HOLDBROWSER b, void * item);
extern "C" void fl_hold_browser_item_draw(HOLDBROWSER b, void * item, int x, int y, int w, int h);


extern "C" int fl_hold_browser_lineno(HOLDBROWSER b, void * item);


extern "C" void * fl_hold_browser_selection(HOLDBROWSER c);
extern "C" int fl_hold_browser_displayed2(HOLDBROWSER c, void * i);
extern "C" void * fl_hold_browser_find_item(HOLDBROWSER c, int y);
extern "C" void * fl_hold_browser_top(HOLDBROWSER c);


extern "C" void fl_hold_browser_bbox(HOLDBROWSER c, int &x, int &y, int &w, int &h);
extern "C" int fl_hold_browser_leftedge(HOLDBROWSER c);
extern "C" void fl_hold_browser_redraw_line(HOLDBROWSER c, void * i);
extern "C" void fl_hold_browser_redraw_lines(HOLDBROWSER c);


extern "C" int fl_hold_browser_full_width(HOLDBROWSER c);
extern "C" int fl_hold_browser_item_quick_height(HOLDBROWSER c, void * i);


extern "C" void fl_hold_browser_new_list(HOLDBROWSER b);
extern "C" void fl_hold_browser_inserting(HOLDBROWSER b, void * a1, void * a2);
extern "C" void fl_hold_browser_deleting(HOLDBROWSER b, void * item);
extern "C" void fl_hold_browser_replacing(HOLDBROWSER b, void * a1, void * a2);
extern "C" void fl_hold_browser_swapping(HOLDBROWSER b, void * a1, void * a2);


extern "C" void fl_hold_browser_draw(HOLDBROWSER b);
extern "C" int fl_hold_browser_handle(HOLDBROWSER b, int e);


#endif


