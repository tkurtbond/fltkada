

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_FILE_CHOOSER_GUARD
#define FL_FILE_CHOOSER_GUARD


typedef void* FILECHOOSER;


extern "C" FILECHOOSER new_fl_file_chooser(const char * n, const char * p, int k, const char * t);
extern "C" void free_fl_file_chooser(FILECHOOSER f);


extern "C" void * fl_file_chooser_get_user_data(FILECHOOSER f);
extern "C" void fl_file_chooser_set_user_data(FILECHOOSER f, void * ud);


extern "C" void * fl_file_chooser_newbutton(FILECHOOSER f);
extern "C" void * fl_file_chooser_previewbutton(FILECHOOSER f);
extern "C" void * fl_file_chooser_showhiddenbutton(FILECHOOSER f);


extern "C" const char * fl_file_chooser_get_add_favorites_label();
extern "C" void fl_file_chooser_set_add_favorites_label(const char * s);
extern "C" const char * fl_file_chooser_get_all_files_label();
extern "C" void fl_file_chooser_set_all_file_label(const char * s);
extern "C" const char * fl_file_chooser_get_custom_filter_label();
extern "C" void fl_file_chooser_set_custom_filter_label(const char * s);
extern "C" const char * fl_file_chooser_get_existing_file_label();
extern "C" void fl_file_chooser_set_existing_file_label(const char * s);
extern "C" const char * fl_file_chooser_get_favorites_label();
extern "C" void fl_file_chooser_set_favorites_label(const char * s);
extern "C" const char * fl_file_chooser_get_filename_label();
extern "C" void fl_file_chooser_set_filename_label(const char * s);
extern "C" const char * fl_file_chooser_get_filesystems_label();
extern "C" void fl_file_chooser_set_filesystems_label(const char * s);
extern "C" const char * fl_file_chooser_get_hidden_label();
extern "C" void fl_file_chooser_set_hidden_label(const char * s);
extern "C" const char * fl_file_chooser_get_manage_favorites_label();
extern "C" void fl_file_chooser_set_manage_favorites_label(const char * s);
extern "C" const char * fl_file_chooser_get_new_directory_label();
extern "C" void fl_file_chooser_set_new_directory_label(const char * s);
extern "C" const char * fl_file_chooser_get_new_directory_tooltip();
extern "C" void fl_file_chooser_set_new_directory_tooltip(const char * s);
extern "C" const char * fl_file_chooser_get_preview_label();
extern "C" void fl_file_chooser_set_preview_label(const char * s);
extern "C" const char * fl_file_chooser_get_save_label();
extern "C" void fl_file_chooser_set_save_label(const char * s);
extern "C" const char * fl_file_chooser_get_show_label();
extern "C" void fl_file_chooser_set_show_label(const char * s);


extern "C" void * fl_file_chooser_add_extra(FILECHOOSER f, void * w);
extern "C" void fl_file_chooser_callback(FILECHOOSER f, void * c, void * u);


extern "C" unsigned int fl_file_chooser_get_color(FILECHOOSER f);
extern "C" void fl_file_chooser_set_color(FILECHOOSER f, unsigned int c);
extern "C" unsigned char fl_file_chooser_get_iconsize(FILECHOOSER f);
extern "C" void fl_file_chooser_set_iconsize(FILECHOOSER f, unsigned char i);
extern "C" const char * fl_file_chooser_get_label(FILECHOOSER f);
extern "C" void fl_file_chooser_set_label(FILECHOOSER f, const char * t);
extern "C" const char * fl_file_chooser_get_ok_label(FILECHOOSER f);
extern "C" void fl_file_chooser_set_ok_label(FILECHOOSER f, const char * t);
extern "C" int fl_file_chooser_get_preview(FILECHOOSER f);
extern "C" void fl_file_chooser_set_preview(FILECHOOSER f, int p);
extern "C" unsigned int fl_file_chooser_get_textcolor(FILECHOOSER f);
extern "C" void fl_file_chooser_set_textcolor(FILECHOOSER f, unsigned int c);
extern "C" int fl_file_chooser_get_textfont(FILECHOOSER f);
extern "C" void fl_file_chooser_set_textfont(FILECHOOSER f, int n);
extern "C" int fl_file_chooser_get_textsize(FILECHOOSER f);
extern "C" void fl_file_chooser_set_textsize(FILECHOOSER f, int s);
extern "C" int fl_file_chooser_get_type(FILECHOOSER f);
extern "C" void fl_file_chooser_set_type(FILECHOOSER f, int t);


extern "C" int fl_file_chooser_count(FILECHOOSER f);
extern "C" const char * fl_file_chooser_get_directory(FILECHOOSER f);
extern "C" void fl_file_chooser_set_directory(FILECHOOSER f, const char * v);
extern "C" const char * fl_file_chooser_get_filter(FILECHOOSER f);
extern "C" void fl_file_chooser_set_filter(FILECHOOSER f, const char * v);
extern "C" int fl_file_chooser_get_filter_value(FILECHOOSER f);
extern "C" void fl_file_chooser_set_filter_value(FILECHOOSER f, int v);
extern "C" void fl_file_chooser_rescan(FILECHOOSER f);
extern "C" void fl_file_chooser_rescan_keep_filename(FILECHOOSER f);
extern "C" const char * fl_file_chooser_get_value(FILECHOOSER f, int n);
extern "C" void fl_file_chooser_set_value(FILECHOOSER f, const char * v);


extern "C" void fl_file_chooser_show(FILECHOOSER f);
extern "C" void fl_file_chooser_hide(FILECHOOSER f);
extern "C" int fl_file_chooser_shown(FILECHOOSER f);
extern "C" int fl_file_chooser_visible(FILECHOOSER f);


#endif


