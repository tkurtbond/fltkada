

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_SCROLL_GUARD
#define FL_SCROLL_GUARD


extern "C" void fl_scroll_extra_init(void * adaobj, int x, int y, int w, int h, const char * label);


typedef void* SCROLL;


extern "C" SCROLL new_fl_scroll(int x, int y, int w, int h, char* label);
extern "C" void free_fl_scroll(SCROLL s);


extern "C" void * fl_scroll_hscrollbar(SCROLL s);
extern "C" void * fl_scroll_scrollbar(SCROLL s);


extern "C" void fl_scroll_to(SCROLL s, int x, int y);
extern "C" int fl_scroll_xposition(SCROLL s);
extern "C" int fl_scroll_yposition(SCROLL s);


extern "C" int fl_scroll_get_size(SCROLL s);
extern "C" void fl_scroll_set_size(SCROLL s, int t);
extern "C" unsigned int fl_scroll_get_scrollbar_align(SCROLL s);
extern "C" void fl_scroll_set_scrollbar_align(SCROLL s, unsigned int a);
extern "C" int fl_scroll_set_fit_width(SCROLL s, int on);
extern "C" int fl_scroll_get_fit_width(SCROLL s);


extern "C" void fl_scroll_resize(SCROLL s, int x, int y, int w, int h);
extern "C" void fl_scroll_recalc_scrollbars(SCROLL s,
    int &cb_x, int &cb_y, int &cb_w, int &cb_h,
    int &ib_x, int &ib_y, int &ib_w, int &ib_h,
    int &ic_x, int &ic_y, int &ic_w, int &ic_h,
    int &chneed, int &cvneed,
    int &hs_x,    int &hs_y,     int &hs_w,     int &hs_h,
    int &hs_size, int &hs_total, int &hs_first, int &hs_pos,
    int &vs_x,    int &vs_y,     int &vs_w,     int &vs_h,
    int &vs_size, int &vs_total, int &vs_first, int &vs_pos,
    int &ssize);


extern "C" void fl_scroll_bbox(SCROLL s, int &x, int &y, int &w, int &h);
extern "C" void fl_scroll_draw(SCROLL s);
extern "C" int fl_scroll_handle(SCROLL s, int e);


#endif


