

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_FILE_BROWSER_GUARD
#define FL_FILE_BROWSER_GUARD


typedef void* FILEBROWSER;


extern "C" FILEBROWSER new_fl_file_browser(int x, int y, int w, int h, char * label);
extern "C" void free_fl_file_browser(FILEBROWSER b);


extern "C" int fl_file_browser_load(FILEBROWSER b, const char * d, void * s);


extern "C" int fl_file_browser_get_filetype(FILEBROWSER b);
extern "C" void fl_file_browser_set_filetype(FILEBROWSER b, int f);
extern "C" const char * fl_file_browser_get_filter(FILEBROWSER b);
extern "C" void fl_file_browser_set_filter(FILEBROWSER b, const char * f);
extern "C" unsigned char fl_file_browser_get_iconsize(FILEBROWSER b);
extern "C" void fl_file_browser_set_iconsize(FILEBROWSER b, unsigned int i);
extern "C" int fl_file_browser_get_textsize(FILEBROWSER b);
extern "C" void fl_file_browser_set_textsize(FILEBROWSER b, int s);


//  reimp below here

extern "C" int fl_file_browser_full_height(FILEBROWSER c);
extern "C" int fl_file_browser_incr_height(FILEBROWSER c);


extern "C" int fl_file_browser_item_width(FILEBROWSER b, void * item);
extern "C" int fl_file_browser_item_height(FILEBROWSER b, void * item);
extern "C" void * fl_file_browser_item_first(FILEBROWSER b);
extern "C" void * fl_file_browser_item_last(FILEBROWSER b);
extern "C" void * fl_file_browser_item_next(FILEBROWSER b, void * item);
extern "C" void * fl_file_browser_item_prev(FILEBROWSER b, void * item);
extern "C" void * fl_file_browser_item_at(FILEBROWSER b, int index);
extern "C" void fl_file_browser_item_select(FILEBROWSER b, void * item, int val=1);
extern "C" int fl_file_browser_item_selected(FILEBROWSER b, void * item);
extern "C" void fl_file_browser_item_swap(FILEBROWSER b, void * x, void * y);
extern "C" const char * fl_file_browser_item_text(FILEBROWSER b, void * item);
extern "C" void fl_file_browser_item_draw(FILEBROWSER b, void * item, int x, int y, int w, int h);


extern "C" int fl_file_browser_full_width(FILEBROWSER c);
extern "C" int fl_file_browser_item_quick_height(FILEBROWSER c, void * i);


extern "C" void fl_file_browser_draw(FILEBROWSER b);
extern "C" int fl_file_browser_handle(FILEBROWSER b, int e);


#endif


