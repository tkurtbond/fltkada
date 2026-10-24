

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Fl_Native_File_Chooser.H>
#include "c_fl_native_file_chooser.h"




//  Flattened C API begins here

NATIVEFILECHOOSER new_fl_native_file_chooser(int t) {
    Fl_Native_File_Chooser *f = new Fl_Native_File_Chooser(t);
    return f;
}

void free_fl_native_file_chooser(NATIVEFILECHOOSER f) {
    delete static_cast<Fl_Native_File_Chooser*>(f);
}




const char * fl_native_file_chooser_get_file_exists_message() {
    return Fl_Native_File_Chooser::file_exists_message;
}

void fl_native_file_chooser_set_file_exists_message(const char * s) {
    Fl_Native_File_Chooser::file_exists_message = s;
}




int fl_native_file_chooser_get_type(NATIVEFILECHOOSER f) {
    return static_cast<Fl_Native_File_Chooser*>(f)->type();
}

void fl_native_file_chooser_set_type(NATIVEFILECHOOSER f, int t) {
    static_cast<Fl_Native_File_Chooser*>(f)->type(t);
}

int fl_native_file_chooser_get_options(NATIVEFILECHOOSER f) {
    return static_cast<Fl_Native_File_Chooser*>(f)->options();
}

void fl_native_file_chooser_set_options(NATIVEFILECHOOSER f, int o) {
    static_cast<Fl_Native_File_Chooser*>(f)->options(o);
}

const char * fl_native_file_chooser_get_title(NATIVEFILECHOOSER f) {
    return static_cast<Fl_Native_File_Chooser*>(f)->title();
}

void fl_native_file_chooser_set_title(NATIVEFILECHOOSER f, const char * t) {
    static_cast<Fl_Native_File_Chooser*>(f)->title(t);
}




const char * fl_native_file_chooser_get_directory(NATIVEFILECHOOSER f) {
    return static_cast<Fl_Native_File_Chooser*>(f)->directory();
}

void fl_native_file_chooser_set_directory(NATIVEFILECHOOSER f, const char * v) {
    static_cast<Fl_Native_File_Chooser*>(f)->directory(v);
}

const char * fl_native_file_chooser_get_filter(NATIVEFILECHOOSER f) {
    return static_cast<Fl_Native_File_Chooser*>(f)->filter();
}

void fl_native_file_chooser_set_filter(NATIVEFILECHOOSER f, const char * v) {
    static_cast<Fl_Native_File_Chooser*>(f)->filter(v);
}

int fl_native_file_chooser_filters(NATIVEFILECHOOSER f) {
    return static_cast<Fl_Native_File_Chooser*>(f)->filters();
}

int fl_native_file_chooser_get_filter_value(NATIVEFILECHOOSER f) {
    return static_cast<Fl_Native_File_Chooser*>(f)->filter_value();
}

void fl_native_file_chooser_set_filter_value(NATIVEFILECHOOSER f, int v) {
    static_cast<Fl_Native_File_Chooser*>(f)->filter_value(v);
}

const char * fl_native_file_chooser_get_preset_file(NATIVEFILECHOOSER f) {
    return static_cast<Fl_Native_File_Chooser*>(f)->preset_file();
}

void fl_native_file_chooser_set_preset_file(NATIVEFILECHOOSER f, const char * v) {
    static_cast<Fl_Native_File_Chooser*>(f)->preset_file(v);
}




int fl_native_file_chooser_count(NATIVEFILECHOOSER f) {
    return static_cast<Fl_Native_File_Chooser*>(f)->count();
}

const char * fl_native_file_chooser_filename(NATIVEFILECHOOSER f) {
    return static_cast<Fl_Native_File_Chooser*>(f)->filename();
}

const char * fl_native_file_chooser_filename2(NATIVEFILECHOOSER f, int i) {
    return static_cast<Fl_Native_File_Chooser*>(f)->filename(i);
}

const char * fl_native_file_chooser_errmsg(NATIVEFILECHOOSER f) {
    return static_cast<Fl_Native_File_Chooser*>(f)->errmsg();
}




int fl_native_file_chooser_show(NATIVEFILECHOOSER f) {
    return static_cast<Fl_Native_File_Chooser*>(f)->show();
}


