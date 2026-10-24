

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#ifndef FL_NATIVE_FILE_CHOOSER_GUARD
#define FL_NATIVE_FILE_CHOOSER_GUARD


typedef void* NATIVEFILECHOOSER;


extern "C" NATIVEFILECHOOSER new_fl_native_file_chooser(int t);
extern "C" void free_fl_native_file_chooser(NATIVEFILECHOOSER f);


extern "C" const char * fl_native_file_chooser_get_file_exists_message();
extern "C" void fl_native_file_chooser_set_file_exists_message(const char * s);


extern "C" int fl_native_file_chooser_get_type(NATIVEFILECHOOSER f);
extern "C" void fl_native_file_chooser_set_type(NATIVEFILECHOOSER f, int t);
extern "C" int fl_native_file_chooser_get_options(NATIVEFILECHOOSER f);
extern "C" void fl_native_file_chooser_set_options(NATIVEFILECHOOSER f, int o);
extern "C" const char * fl_native_file_chooser_get_title(NATIVEFILECHOOSER f);
extern "C" void fl_native_file_chooser_set_title(NATIVEFILECHOOSER f, const char * t);


extern "C" const char * fl_native_file_chooser_get_directory(NATIVEFILECHOOSER f);
extern "C" void fl_native_file_chooser_set_directory(NATIVEFILECHOOSER f, const char * v);
extern "C" const char * fl_native_file_chooser_get_filter(NATIVEFILECHOOSER f);
extern "C" void fl_native_file_chooser_set_filter(NATIVEFILECHOOSER f, const char * v);
extern "C" int fl_native_file_chooser_filters(NATIVEFILECHOOSER f);
extern "C" int fl_native_file_chooser_get_filter_value(NATIVEFILECHOOSER f);
extern "C" void fl_native_file_chooser_set_filter_value(NATIVEFILECHOOSER f, int v);
extern "C" const char * fl_native_file_chooser_get_preset_file(NATIVEFILECHOOSER f);
extern "C" void fl_native_file_chooser_set_preset_file(NATIVEFILECHOOSER f, const char * v);


extern "C" int fl_native_file_chooser_count(NATIVEFILECHOOSER f);
extern "C" const char * fl_native_file_chooser_filename(NATIVEFILECHOOSER f);
extern "C" const char * fl_native_file_chooser_filename2(NATIVEFILECHOOSER f, int i);
extern "C" const char * fl_native_file_chooser_errmsg(NATIVEFILECHOOSER f);


extern "C" int fl_native_file_chooser_show(NATIVEFILECHOOSER f);


#endif


