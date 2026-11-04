

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FL_FILE_ICON_GUARD
#define FL_FILE_ICON_GUARD


typedef void* FILEICON;


extern "C" FILEICON new_fl_file_icon(const char * p, int t);
extern "C" void free_fl_file_icon(FILEICON i);


extern "C" void fl_file_icon_add(FILEICON i, int d);
extern "C" void fl_file_icon_add_color(FILEICON i, unsigned int c);
extern "C" void fl_file_icon_add_vertex(FILEICON i, int x, int y);
extern "C" void fl_file_icon_clear(FILEICON i);
extern "C" int fl_file_icon_size(FILEICON i);


extern "C" int fl_file_icon_load(FILEICON i, const char * f);
extern "C" void fl_file_icon_load_system_icons();


extern "C" FILEICON fl_file_icon_find(const char * n, int t);
extern "C" FILEICON fl_file_icon_first();
extern "C" FILEICON fl_file_icon_next(FILEICON i);
extern "C" const char * fl_file_icon_pattern(FILEICON i);
extern "C" int fl_file_icon_type(FILEICON i);


extern "C" void fl_file_icon_draw(FILEICON i, int x, int y, int w, int h, unsigned int c, int a);
extern "C" void fl_file_icon_label(FILEICON i, void * w);


extern "C" void fl_file_icon_browser_add(void * b, const char * t, FILEICON i);
extern "C" void fl_file_icon_browser_set(void * b, int l, FILEICON i);
extern "C" FILEICON fl_file_icon_browser_get(void * b, int l);


#endif


