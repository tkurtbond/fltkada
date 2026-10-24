

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_MENU_ITEM_GUARD
#define FL_MENU_ITEM_GUARD


typedef void* MENUITEM;


extern "C" void * null_fl_menu_item();
extern "C" void * new_fl_menu_item(char * t, void * c, int s, int f);
extern "C" void free_fl_menu_item(MENUITEM mi);


extern "C" void * fl_menu_item_get_user_data(MENUITEM mi);
extern "C" void fl_menu_item_set_callback(MENUITEM mi, void * c);
extern "C" void fl_menu_item_do_callback(MENUITEM mi, void * w);


extern "C" int fl_menu_item_checkbox(MENUITEM mi);
extern "C" int fl_menu_item_radio(MENUITEM mi);
extern "C" int fl_menu_item_submenu(MENUITEM mi);
extern "C" int fl_menu_item_value(MENUITEM mi);
extern "C" void fl_menu_item_set(MENUITEM mi);
extern "C" void fl_menu_item_clear(MENUITEM mi);
extern "C" void fl_menu_item_setonly(MENUITEM mi);


extern "C" const char * fl_menu_item_get_label(MENUITEM mi);
extern "C" void fl_menu_item_set_label(MENUITEM mi, const char *t);
extern "C" void fl_menu_item_set_label2(MENUITEM mi, int k, const char * t);
extern "C" unsigned int fl_menu_item_get_labelcolor(MENUITEM mi);
extern "C" void fl_menu_item_set_labelcolor(MENUITEM mi, unsigned int c);
extern "C" int fl_menu_item_get_labelfont(MENUITEM mi);
extern "C" void fl_menu_item_set_labelfont(MENUITEM mi, int f);
extern "C" int fl_menu_item_get_labelsize(MENUITEM mi);
extern "C" void fl_menu_item_set_labelsize(MENUITEM mi, int s);
extern "C" int fl_menu_item_get_labeltype(MENUITEM mi);
extern "C" void fl_menu_item_set_labeltype(MENUITEM mi, int t);


extern "C" int fl_menu_item_get_shortcut(MENUITEM mi);
extern "C" void fl_menu_item_set_shortcut(MENUITEM mi, int s);
extern "C" int fl_menu_item_get_flags(MENUITEM mi);
extern "C" void fl_menu_item_set_flags(MENUITEM mi, int f);


extern "C" void fl_menu_item_image(MENUITEM mi, void * i);
extern "C" void fl_menu_item_multi_label(MENUITEM mi, void * ml);


extern "C" void fl_menu_item_activate(MENUITEM mi);
extern "C" void fl_menu_item_deactivate(MENUITEM mi);
extern "C" void fl_menu_item_show(MENUITEM mi);
extern "C" void fl_menu_item_hide(MENUITEM mi);
extern "C" int fl_menu_item_active(MENUITEM mi);
extern "C" int fl_menu_item_visible(MENUITEM mi);
extern "C" int fl_menu_item_activevisible(MENUITEM mi);


#endif


