

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_File_Chooser.H>
#include <FL/Fl_Widget.H>
#include "c_fl_file_chooser.h"




//  Exports from Ada

extern "C" int file_chooser_sort_hook(const char * a, const char * b);




//  Some extra setup

int file_chooser_sort_prehook(struct dirent ** a, struct dirent ** b) {
    return file_chooser_sort_hook((*a)->d_name, (*b)->d_name);
}

void file_chooser_setup_sort_hook() {
    Fl_File_Chooser::sort = &file_chooser_sort_prehook;
}




//  Flattened C API begins here

FILECHOOSER new_fl_file_chooser(const char * n, const char * p, int k, const char * t) {
    Fl_File_Chooser *f = new Fl_File_Chooser(n, p, k, t);
    return f;
}

void free_fl_file_chooser(FILECHOOSER f) {
    delete reinterpret_cast<Fl_File_Chooser*>(f);
}




void * fl_file_chooser_get_user_data(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->user_data();
}

void fl_file_chooser_set_user_data(FILECHOOSER f, void * ud) {
    reinterpret_cast<Fl_File_Chooser*>(f)->user_data(ud);
}




void * fl_file_chooser_newbutton(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->newButton;
}

void * fl_file_chooser_previewbutton(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->previewButton;
}

void * fl_file_chooser_showhiddenbutton(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->showHiddenButton;
}




const char * fl_file_chooser_get_add_favorites_label() {
    return Fl_File_Chooser::add_favorites_label;
}

void fl_file_chooser_set_add_favorites_label(const char * s) {
    Fl_File_Chooser::add_favorites_label = s;
}

const char * fl_file_chooser_get_all_files_label() {
    return Fl_File_Chooser::all_files_label;
}

void fl_file_chooser_set_all_files_label(const char * s) {
    Fl_File_Chooser::all_files_label = s;
}

const char * fl_file_chooser_get_custom_filter_label() {
    return Fl_File_Chooser::custom_filter_label;
}

void fl_file_chooser_set_custom_filter_label(const char * s) {
    Fl_File_Chooser::custom_filter_label = s;
}

const char * fl_file_chooser_get_existing_file_label() {
    return Fl_File_Chooser::existing_file_label;
}

void fl_file_chooser_set_existing_file_label(const char * s) {
    Fl_File_Chooser::existing_file_label = s;
}

const char * fl_file_chooser_get_favorites_label() {
    return Fl_File_Chooser::favorites_label;
}

void fl_file_chooser_set_favorites_label(const char * s) {
    Fl_File_Chooser::favorites_label = s;
}

const char * fl_file_chooser_get_filename_label() {
    return Fl_File_Chooser::filename_label;
}

void fl_file_chooser_set_filename_label(const char * s) {
    Fl_File_Chooser::filename_label = s;
}

const char * fl_file_chooser_get_filesystems_label() {
    return Fl_File_Chooser::filesystems_label;
}

void fl_file_chooser_set_filesystems_label(const char * s) {
    Fl_File_Chooser::filesystems_label = s;
}

const char * fl_file_chooser_get_hidden_label() {
    return Fl_File_Chooser::hidden_label;
}

void fl_file_chooser_set_hidden_label(const char * s) {
    Fl_File_Chooser::hidden_label = s;
}

const char * fl_file_chooser_get_manage_favorites_label() {
    return Fl_File_Chooser::manage_favorites_label;
}

void fl_file_chooser_set_manage_favorites_label(const char * s) {
    Fl_File_Chooser::manage_favorites_label = s;
}

const char * fl_file_chooser_get_new_directory_label() {
    return Fl_File_Chooser::new_directory_label;
}

void fl_file_chooser_set_new_directory_label(const char * s) {
    Fl_File_Chooser::new_directory_label = s;
}

const char * fl_file_chooser_get_new_directory_tooltip() {
    return Fl_File_Chooser::new_directory_tooltip;
}

void fl_file_chooser_set_new_directory_tooltip(const char * s) {
    Fl_File_Chooser::new_directory_tooltip = s;
}

const char * fl_file_chooser_get_preview_label() {
    return Fl_File_Chooser::preview_label;
}

void fl_file_chooser_set_preview_label(const char * s) {
    Fl_File_Chooser::preview_label = s;
}

const char * fl_file_chooser_get_save_label() {
    return Fl_File_Chooser::save_label;
}

void fl_file_chooser_set_save_label(const char * s) {
    Fl_File_Chooser::save_label = s;
}

const char * fl_file_chooser_get_show_label() {
    return Fl_File_Chooser::show_label;
}

void fl_file_chooser_set_show_label(const char * s) {
    Fl_File_Chooser::show_label = s;
}




void * fl_file_chooser_add_extra(FILECHOOSER f, void * w) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->add_extra(reinterpret_cast<Fl_Widget*>(w));
}

typedef void (*Chooser_Callback)(Fl_File_Chooser *, void *);

void fl_file_chooser_callback(FILECHOOSER f, void * c, void * u) {
    reinterpret_cast<Fl_File_Chooser*>(f)->callback(reinterpret_cast<Chooser_Callback>(c), u);
}




unsigned int fl_file_chooser_get_color(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->color();
}

void fl_file_chooser_set_color(FILECHOOSER f, unsigned int c) {
    reinterpret_cast<Fl_File_Chooser*>(f)->color(c);
}

unsigned char fl_file_chooser_get_iconsize(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->iconsize();
}

void fl_file_chooser_set_iconsize(FILECHOOSER f, unsigned char i) {
    reinterpret_cast<Fl_File_Chooser*>(f)->iconsize(i);
}

const char * fl_file_chooser_get_label(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->label();
}

void fl_file_chooser_set_label(FILECHOOSER f, const char * t) {
    reinterpret_cast<Fl_File_Chooser*>(f)->label(t);
}

const char * fl_file_chooser_get_ok_label(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->ok_label();
}

void fl_file_chooser_set_ok_label(FILECHOOSER f, const char * t) {
    reinterpret_cast<Fl_File_Chooser*>(f)->ok_label(t);
}

int fl_file_chooser_get_preview(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->preview();
}

void fl_file_chooser_set_preview(FILECHOOSER f, int p) {
    reinterpret_cast<Fl_File_Chooser*>(f)->preview(p);
}

unsigned int fl_file_chooser_get_textcolor(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->textcolor();
}

void fl_file_chooser_set_textcolor(FILECHOOSER f, unsigned int c) {
    reinterpret_cast<Fl_File_Chooser*>(f)->textcolor(c);
}

int fl_file_chooser_get_textfont(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->textfont();
}

void fl_file_chooser_set_textfont(FILECHOOSER f, int n) {
    reinterpret_cast<Fl_File_Chooser*>(f)->textfont(n);
}

int fl_file_chooser_get_textsize(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->textsize();
}

void fl_file_chooser_set_textsize(FILECHOOSER f, int s) {
    reinterpret_cast<Fl_File_Chooser*>(f)->textsize(s);
}

int fl_file_chooser_get_type(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->type();
}

void fl_file_chooser_set_type(FILECHOOSER f, int t) {
    reinterpret_cast<Fl_File_Chooser*>(f)->type(t);
}




int fl_file_chooser_count(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->count();
}

const char * fl_file_chooser_get_directory(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->directory();
}

void fl_file_chooser_set_directory(FILECHOOSER f, const char * v) {
    reinterpret_cast<Fl_File_Chooser*>(f)->directory(v);
}

const char * fl_file_chooser_get_filter(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->filter();
}

void fl_file_chooser_set_filter(FILECHOOSER f, const char * v) {
    reinterpret_cast<Fl_File_Chooser*>(f)->filter(v);
}

int fl_file_chooser_get_filter_value(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->filter_value();
}

void fl_file_chooser_set_filter_value(FILECHOOSER f, int v) {
    reinterpret_cast<Fl_File_Chooser*>(f)->filter_value(v);
}

void fl_file_chooser_rescan(FILECHOOSER f) {
    reinterpret_cast<Fl_File_Chooser*>(f)->rescan();
}

void fl_file_chooser_rescan_keep_filename(FILECHOOSER f) {
    reinterpret_cast<Fl_File_Chooser*>(f)->rescan_keep_filename();
}

const char * fl_file_chooser_get_value(FILECHOOSER f, int n) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->value(n);
}

void fl_file_chooser_set_value(FILECHOOSER f, const char * v) {
    reinterpret_cast<Fl_File_Chooser*>(f)->value(v);
}




void fl_file_chooser_show(FILECHOOSER f) {
    reinterpret_cast<Fl_File_Chooser*>(f)->show();
}

void fl_file_chooser_hide(FILECHOOSER f) {
    reinterpret_cast<Fl_File_Chooser*>(f)->hide();
}

int fl_file_chooser_shown(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->shown();
}

int fl_file_chooser_visible(FILECHOOSER f) {
    return reinterpret_cast<Fl_File_Chooser*>(f)->visible();
}


