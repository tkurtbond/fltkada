

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_CHECK_BROWSER_GUARD
#define FL_CHECK_BROWSER_GUARD


typedef void* CHECKBROWSER;


extern "C" CHECKBROWSER new_fl_check_browser(int x, int y, int w, int h, char * label);
extern "C" void free_fl_check_browser(CHECKBROWSER c);


extern "C" int fl_check_browser_add(CHECKBROWSER c, const char * s, int b);
extern "C" int fl_check_browser_remove(CHECKBROWSER c, int i);
extern "C" void fl_check_browser_clear(CHECKBROWSER c);
extern "C" int fl_check_browser_nitems(CHECKBROWSER c);


extern "C" void fl_check_browser_check_all(CHECKBROWSER c);
extern "C" void fl_check_browser_check_none(CHECKBROWSER c);
extern "C" int fl_check_browser_get_checked(CHECKBROWSER c, int i);
extern "C" void fl_check_browser_set_checked(CHECKBROWSER c, int i, int b);
extern "C" int fl_check_browser_nchecked(CHECKBROWSER c);


extern "C" const char * fl_check_browser_text(CHECKBROWSER c, int i);
extern "C" int fl_check_browser_value(CHECKBROWSER c);


extern "C" int fl_check_browser_full_width(CHECKBROWSER c);
extern "C" int fl_check_browser_full_height(CHECKBROWSER c);
extern "C" int fl_check_browser_incr_height(CHECKBROWSER c);
extern "C" int fl_check_browser_item_quick_height(CHECKBROWSER c, void * i);


extern "C" int fl_check_browser_item_width(CHECKBROWSER c, void * i);
extern "C" int fl_check_browser_item_height(CHECKBROWSER c, void * i);
extern "C" void * fl_check_browser_item_first(CHECKBROWSER c);
//  missing item_last
extern "C" void * fl_check_browser_item_next(CHECKBROWSER c, void * i);
extern "C" void * fl_check_browser_item_prev(CHECKBROWSER c, void * i);
//  missing item_at
extern "C" void fl_check_browser_item_select(CHECKBROWSER c, void * i, int v);
extern "C" int fl_check_browser_item_selected(CHECKBROWSER c, void * i);
//  missing item_swap
//  missing item_text
extern "C" void fl_check_browser_item_draw(CHECKBROWSER c, void * item, int x, int y, int w, int h);


extern "C" void fl_check_browser_draw(CHECKBROWSER c);
extern "C" int fl_check_browser_handle(CHECKBROWSER c, int e);


#endif


