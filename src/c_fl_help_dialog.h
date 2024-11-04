

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_HELP_DIALOG_GUARD
#define FL_HELP_DIALOG_GUARD




typedef void* HELPDIALOG;




extern "C" HELPDIALOG new_fl_help_dialog();
extern "C" void free_fl_help_dialog(HELPDIALOG d);




extern "C" void fl_help_dialog_show(HELPDIALOG d);
extern "C" void fl_help_dialog_hide(HELPDIALOG d);
extern "C" int fl_help_dialog_visible(HELPDIALOG d);


extern "C" void fl_help_dialog_set_topline_number(HELPDIALOG d, int n);
extern "C" void fl_help_dialog_set_topline_target(HELPDIALOG d, const char * t);


extern "C" void fl_help_dialog_load(HELPDIALOG d, const char * n);
extern "C" const char * fl_help_dialog_get_value(HELPDIALOG d);
extern "C" void fl_help_dialog_set_value(HELPDIALOG d, const char * v);


extern "C" int fl_help_dialog_get_textsize(HELPDIALOG d);
extern "C" void fl_help_dialog_set_textsize(HELPDIALOG d, int s);


extern "C" int fl_help_dialog_get_x(HELPDIALOG d);
extern "C" int fl_help_dialog_get_y(HELPDIALOG d);
extern "C" int fl_help_dialog_get_w(HELPDIALOG d);
extern "C" int fl_help_dialog_get_h(HELPDIALOG d);
extern "C" void fl_help_dialog_resize(HELPDIALOG d, int xx, int yy, int ww, int hh);
extern "C" void fl_help_dialog_position(HELPDIALOG d, int xx, int yy);


#endif


