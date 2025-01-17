

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_SYS_MENU_BAR_GUARD
#define FL_SYS_MENU_BAR_GUARD


typedef void* SYSMENUBAR;


extern "C" SYSMENUBAR new_fl_sys_menu_bar(int x, int y, int w, int h, char* label);
extern "C" void free_fl_sys_menu_bar(SYSMENUBAR m);


extern "C" int fl_sys_menu_bar_add(SYSMENUBAR m, const char * t);
extern "C" int fl_sys_menu_bar_add2(SYSMENUBAR m, const char * t,
    unsigned long s, void * u, unsigned long f);
extern "C" int fl_sys_menu_bar_add3(SYSMENUBAR m, const char * t,
    const char * s, void * u, unsigned long f);
extern "C" int fl_sys_menu_bar_insert(SYSMENUBAR m, int p, const char * t,
    unsigned long s, void * u, unsigned long f);
extern "C" int fl_sys_menu_bar_insert2(SYSMENUBAR m, int p, const char * t,
    const char * s, void * u, unsigned long f);
extern "C" void fl_sys_menu_bar_set_menu(SYSMENUBAR m, void * d);
extern "C" void fl_sys_menu_bar_remove(SYSMENUBAR m, int p);
extern "C" void fl_sys_menu_bar_clear(SYSMENUBAR m);
extern "C" int fl_sys_menu_bar_clear_submenu(SYSMENUBAR m, int p);


extern "C" const void * fl_sys_menu_bar_get_item(SYSMENUBAR m, int i);


extern "C" void fl_sys_menu_bar_setonly(SYSMENUBAR m, void * mi);
extern "C" void fl_sys_menu_bar_replace(SYSMENUBAR m, int i, const char * t);
extern "C" void fl_sys_menu_bar_shortcut(SYSMENUBAR m, int p, unsigned long s);
extern "C" unsigned long fl_sys_menu_bar_get_mode(SYSMENUBAR m, int p);
extern "C" void fl_sys_menu_bar_set_mode(SYSMENUBAR m, int p, unsigned long f);


extern "C" void fl_sys_menu_bar_global(SYSMENUBAR m);
extern "C" void fl_sys_menu_bar_update(SYSMENUBAR m);


extern "C" void fl_sys_menu_bar_draw(SYSMENUBAR m);
extern "C" int fl_sys_menu_bar_handle(SYSMENUBAR m, int e);


#endif


