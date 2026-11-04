

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#ifndef FL_SHORTCUT_BUTTON_GUARD
#define FL_SHORTCUT_BUTTON_GUARD


typedef void* SHORTCUTBUTTON;


extern "C" SHORTCUTBUTTON new_fl_shortcut_button(int x, int y, int w, int h, char* label);
extern "C" void free_fl_shortcut_button(SHORTCUTBUTTON b);


extern "C" unsigned int fl_shortcut_button_get_value(SHORTCUTBUTTON b);
extern "C" void fl_shortcut_button_set_value(SHORTCUTBUTTON b, unsigned int s);


extern "C" void fl_shortcut_button_draw(SHORTCUTBUTTON b);
extern "C" int fl_shortcut_button_handle(SHORTCUTBUTTON b, int e);


#endif


