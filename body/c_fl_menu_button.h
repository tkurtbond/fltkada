

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_MENU_BUTTON_GUARD
#define FL_MENU_BUTTON_GUARD


extern "C" void fl_menu_button_extra_init
    (void * adaobj, int x, int y, int w, int h, const char * label);
extern "C" void fl_menu_button_extra_final(void * adaobj);


typedef void* MENUBUTTON;


extern "C" MENUBUTTON new_fl_menu_button(int x, int y, int w, int h, char* label);
extern "C" void free_fl_menu_button(MENUBUTTON m);


extern "C" const void * fl_menu_button_popup(MENUBUTTON m);


extern "C" void fl_menu_button_draw(MENUBUTTON m);
extern "C" int fl_menu_button_handle(MENUBUTTON m, int e);


#endif


