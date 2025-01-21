

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_MENU_BAR_GUARD
#define FL_MENU_BAR_GUARD


typedef void* MENUBAR;


extern "C" MENUBAR new_fl_menu_bar(int x, int y, int w, int h, char* label);
extern "C" void free_fl_menu_bar(MENUBAR m);


extern "C" void fl_menu_bar_draw(MENUBAR m);
extern "C" int fl_menu_bar_handle(MENUBAR m, int e);


#endif


