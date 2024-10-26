

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_HELP_VIEW_GUARD
#define FL_HELP_VIEW_GUARD




typedef void* HELPVIEW;




extern "C" void help_view_set_draw_hook(HELPVIEW v, void * d);
extern "C" void fl_help_view_draw(HELPVIEW v);
extern "C" void help_view_set_handle_hook(HELPVIEW v, void * h);
extern "C" int fl_help_view_handle(HELPVIEW v, int e);




extern "C" HELPVIEW new_fl_help_view(int x, int y, int w, int h, char * label);
extern "C" void free_fl_help_view(HELPVIEW v);




extern "C" void fl_help_view_clear_selection(HELPVIEW v);
extern "C" void fl_help_view_select_all(HELPVIEW v);


extern "C" int fl_help_view_find(HELPVIEW v, const char * s, int p);
extern "C" int fl_help_view_get_leftline(HELPVIEW v);
extern "C" void fl_help_view_set_leftline(HELPVIEW v, int t);
extern "C" int fl_help_view_get_topline(HELPVIEW v);
extern "C" void fl_help_view_set_topline(HELPVIEW v, int t);
extern "C" void fl_help_view_set_topline_target(HELPVIEW v, const char * t);


extern "C" const char * fl_help_view_directory(HELPVIEW v);
extern "C" const char * fl_help_view_filename(HELPVIEW v);
extern "C" int fl_help_view_load(HELPVIEW v, const char * f);
extern "C" const char * fl_help_view_title(HELPVIEW v);
extern "C" const char * fl_help_view_get_value(HELPVIEW v);
extern "C" void fl_help_view_set_value(HELPVIEW v, const char * t);
extern "C" void fl_help_view_link(HELPVIEW v, void * f);


extern "C" int fl_help_view_get_scrollbar_size(HELPVIEW v);
extern "C" void fl_help_view_set_scrollbar_size(HELPVIEW v, int s);
extern "C" int fl_help_view_get_size(HELPVIEW v);
extern "C" void fl_help_view_set_size(HELPVIEW v, int w, int h);
extern "C" unsigned int fl_help_view_get_textcolor(HELPVIEW v);
extern "C" void fl_help_view_set_textcolor(HELPVIEW v, unsigned int c);
extern "C" int fl_help_view_get_textfont(HELPVIEW v);
extern "C" void fl_help_view_set_textfont(HELPVIEW v, int f);
extern "C" int fl_help_view_get_textsize(HELPVIEW v);
extern "C" void fl_help_view_set_textsize(HELPVIEW v, int s);


#endif


