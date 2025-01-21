

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_SELECT_BROWSER_GUARD
#define FL_SELECT_BROWSER_GUARD


typedef void* SELECTBROWSER;


extern "C" SELECTBROWSER new_fl_select_browser(int x, int y, int w, int h, char * label);
extern "C" void free_fl_select_browser(SELECTBROWSER b);


//  reimp below here

extern "C" int fl_select_browser_full_height(SELECTBROWSER c);
extern "C" int fl_select_browser_incr_height(SELECTBROWSER c);


extern "C" int fl_select_browser_item_width(SELECTBROWSER b, void * item);
extern "C" int fl_select_browser_item_height(SELECTBROWSER b, void * item);
extern "C" void * fl_select_browser_item_first(SELECTBROWSER b);
extern "C" void * fl_select_browser_item_last(SELECTBROWSER b);
extern "C" void * fl_select_browser_item_next(SELECTBROWSER b, void * item);
extern "C" void * fl_select_browser_item_prev(SELECTBROWSER b, void * item);
extern "C" void * fl_select_browser_item_at(SELECTBROWSER b, int index);
extern "C" void fl_select_browser_item_select(SELECTBROWSER b, void * item, int val=1);
extern "C" int fl_select_browser_item_selected(SELECTBROWSER b, void * item);
extern "C" void fl_select_browser_item_swap(SELECTBROWSER b, void * x, void * y);
extern "C" const char * fl_select_browser_item_text(SELECTBROWSER b, void * item);
extern "C" void fl_select_browser_item_draw(SELECTBROWSER b, void * item, int x, int y, int w, int h);


extern "C" int fl_select_browser_full_width(SELECTBROWSER c);
extern "C" int fl_select_browser_item_quick_height(SELECTBROWSER c, void * i);


extern "C" void fl_select_browser_draw(SELECTBROWSER b);
extern "C" int fl_select_browser_handle(SELECTBROWSER b, int e);


#endif


