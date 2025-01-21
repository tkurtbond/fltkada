

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_MULTI_BROWSER_GUARD
#define FL_MULTI_BROWSER_GUARD


typedef void* MULTIBROWSER;


extern "C" MULTIBROWSER new_fl_multi_browser(int x, int y, int w, int h, char * label);
extern "C" void free_fl_multi_browser(MULTIBROWSER b);


//  reimp below here

extern "C" int fl_multi_browser_full_height(MULTIBROWSER c);
extern "C" int fl_multi_browser_incr_height(MULTIBROWSER c);


extern "C" int fl_multi_browser_item_width(MULTIBROWSER b, void * item);
extern "C" int fl_multi_browser_item_height(MULTIBROWSER b, void * item);
extern "C" void * fl_multi_browser_item_first(MULTIBROWSER b);
extern "C" void * fl_multi_browser_item_last(MULTIBROWSER b);
extern "C" void * fl_multi_browser_item_next(MULTIBROWSER b, void * item);
extern "C" void * fl_multi_browser_item_prev(MULTIBROWSER b, void * item);
extern "C" void * fl_multi_browser_item_at(MULTIBROWSER b, int index);
extern "C" void fl_multi_browser_item_select(MULTIBROWSER b, void * item, int val=1);
extern "C" int fl_multi_browser_item_selected(MULTIBROWSER b, void * item);
extern "C" void fl_multi_browser_item_swap(MULTIBROWSER b, void * x, void * y);
extern "C" const char * fl_multi_browser_item_text(MULTIBROWSER b, void * item);
extern "C" void fl_multi_browser_item_draw(MULTIBROWSER b, void * item, int x, int y, int w, int h);


extern "C" int fl_multi_browser_full_width(MULTIBROWSER c);
extern "C" int fl_multi_browser_item_quick_height(MULTIBROWSER c, void * i);


extern "C" void fl_multi_browser_draw(MULTIBROWSER b);
extern "C" int fl_multi_browser_handle(MULTIBROWSER b, int e);


#endif


