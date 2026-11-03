

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_MENU_GUARD
#define FL_MENU_GUARD


typedef void* MENU;


extern "C" MENU new_fl_menu(int x, int y, int w, int h, char* label);
extern "C" void free_fl_menu(MENU m);


extern "C" int fl_menu_add(MENU m, const char * t);
extern "C" int fl_menu_add2(MENU m, const char * t, unsigned long s, void * u, unsigned long f);
extern "C" int fl_menu_add3(MENU m, const char * t, const char * s, void * u, unsigned long f);
extern "C" int fl_menu_insert(MENU m, int p, const char * t,
    unsigned long s, void * u, unsigned long f);
extern "C" int fl_menu_insert2(MENU m, int p, const char * t,
    const char * s, void * u, unsigned long f);
extern "C" int fl_menu_set_items(MENU m, void * const * i, int n);
extern "C" int fl_menu_set_menu(MENU m, MENU d);
extern "C" void fl_menu_remove(MENU m, int p);
extern "C" void fl_menu_clear(MENU m);
extern "C" int fl_menu_clear_submenu(MENU m, int i);


extern "C" const void * fl_menu_get_item(MENU m, int i);
//  find_item and find_item2 are subsumed by find_index and find_index3
extern "C" int fl_menu_find_index(MENU m, const char * t);
extern "C" int fl_menu_find_index2(MENU m, void * i);
extern "C" int fl_menu_find_index3(MENU m, void * cb);
extern "C" int fl_menu_item_pathname(MENU m, char * buf, int len, void * mi);
extern "C" int fl_menu_size(MENU m);


//  mvalue is subsumed by value
extern "C" const char * fl_menu_text(MENU m);
extern "C" int fl_menu_value(MENU m);
extern "C" int fl_menu_set_value(MENU m, void * i);
extern "C" int fl_menu_set_value2(MENU m, int p);


extern "C" void fl_menu_setonly(MENU m, void * mi);
extern "C" const char * fl_menu_text2(MENU m, int i);
extern "C" int fl_menu_replace(MENU m, int i, const char * t, const char ** o);
extern "C" void fl_menu_forget_text(MENU m, const char * t);
extern "C" void fl_menu_shortcut(MENU m, int i, unsigned long s);
extern "C" unsigned long fl_menu_get_mode(MENU m, int i);
extern "C" void fl_menu_set_mode(MENU m, int i, unsigned long f);


extern "C" unsigned int fl_menu_get_textcolor(MENU m);
extern "C" void fl_menu_set_textcolor(MENU m, unsigned int c);
extern "C" int fl_menu_get_textfont(MENU m);
extern "C" void fl_menu_set_textfont(MENU m, int f);
extern "C" int fl_menu_get_textsize(MENU m);
extern "C" void fl_menu_set_textsize(MENU m, int s);


extern "C" int fl_menu_get_down_box(MENU m);
extern "C" void fl_menu_set_down_box(MENU m, int t);
extern "C" void fl_menu_global(MENU m);
extern "C" int fl_menu_measure(MENU m, int i, int *h);


extern "C" const void * fl_menu_popup(MENU m, int x, int y, const char * t, int n);
extern "C" const void * fl_menu_pulldown(MENU m, int x, int y, int w, int h, int n);
extern "C" const void * fl_menu_picked(MENU m, const void * mi);
extern "C" const void * fl_menu_find_shortcut(MENU m, void * ip, int a);
extern "C" const void * fl_menu_test_shortcut(MENU m);


extern "C" void fl_menu_size2(MENU m, int w, int h);


extern "C" void fl_menu_draw_item(MENU m, int i, int x, int y, int w, int h, int s);
extern "C" void fl_menu_draw(MENU m);
extern "C" int fl_menu_handle(MENU m, int e);


#endif


