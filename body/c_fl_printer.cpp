

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Printer.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Window.H>
#include "c_fl_printer.h"




//  Flattened C API

PRINTER new_fl_printer(void) {
    Fl_Printer *p = new Fl_Printer();
    return p;
}

void free_fl_printer(PRINTER p) {
    delete static_cast<Fl_Printer*>(p);
}




const char * fl_printer_get_dialog_title() {
    return Fl_Printer::dialog_title;
}

void fl_printer_set_dialog_title(const char * v) {
    Fl_Printer::dialog_title = v;
}

const char * fl_printer_get_dialog_printer() {
    return Fl_Printer::dialog_printer;
}

void fl_printer_set_dialog_printer(const char * v) {
    Fl_Printer::dialog_printer = v;
}

const char * fl_printer_get_dialog_range() {
    return Fl_Printer::dialog_range;
}

void fl_printer_set_dialog_range(const char * v) {
    Fl_Printer::dialog_range = v;
}

const char * fl_printer_get_dialog_copies() {
    return Fl_Printer::dialog_copies;
}

void fl_printer_set_dialog_copies(const char * v) {
    Fl_Printer::dialog_copies = v;
}

const char * fl_printer_get_dialog_all() {
    return Fl_Printer::dialog_all;
}

void fl_printer_set_dialog_all(const char * v) {
    Fl_Printer::dialog_all = v;
}

const char * fl_printer_get_dialog_pages() {
    return Fl_Printer::dialog_pages;
}

void fl_printer_set_dialog_pages(const char * v) {
    Fl_Printer::dialog_pages = v;
}

const char * fl_printer_get_dialog_from() {
    return Fl_Printer::dialog_from;
}

void fl_printer_set_dialog_from(const char * v) {
    Fl_Printer::dialog_from = v;
}

const char * fl_printer_get_dialog_to() {
    return Fl_Printer::dialog_to;
}

void fl_printer_set_dialog_to(const char * v) {
    Fl_Printer::dialog_to = v;
}

const char * fl_printer_get_dialog_properties() {
    return Fl_Printer::dialog_properties;
}

void fl_printer_set_dialog_properties(const char * v) {
    Fl_Printer::dialog_properties = v;
}

const char * fl_printer_get_dialog_copyno() {
    return Fl_Printer::dialog_copyNo;
}

void fl_printer_set_dialog_copyno(const char * v) {
    Fl_Printer::dialog_copyNo = v;
}

const char * fl_printer_get_dialog_print_button() {
    return Fl_Printer::dialog_print_button;
}

void fl_printer_set_dialog_print_button(const char * v) {
    Fl_Printer::dialog_print_button = v;
}

const char * fl_printer_get_dialog_cancel_button() {
    return Fl_Printer::dialog_cancel_button;
}

void fl_printer_set_dialog_cancel_button(const char * v) {
    Fl_Printer::dialog_cancel_button = v;
}

const char * fl_printer_get_dialog_print_to_file() {
    return Fl_Printer::dialog_print_to_file;
}

void fl_printer_set_dialog_print_to_file(const char * v) {
    Fl_Printer::dialog_print_to_file = v;
}

const char * fl_printer_get_property_title() {
    return Fl_Printer::property_title;
}

void fl_printer_set_property_title(const char * v) {
    Fl_Printer::property_title = v;
}

const char * fl_printer_get_property_pagesize() {
    return Fl_Printer::property_pagesize;
}

void fl_printer_set_property_pagesize(const char * v) {
    Fl_Printer::property_pagesize = v;
}

const char * fl_printer_get_property_mode() {
    return Fl_Printer::property_mode;
}

void fl_printer_set_property_mode(const char * v) {
    Fl_Printer::property_mode = v;
}

const char * fl_printer_get_property_use() {
    return Fl_Printer::property_use;
}

void fl_printer_set_property_use(const char * v) {
    Fl_Printer::property_use = v;
}

const char * fl_printer_get_property_save() {
    return Fl_Printer::property_save;
}

void fl_printer_set_property_save(const char * v) {
    Fl_Printer::property_save = v;
}

const char * fl_printer_get_property_cancel() {
    return Fl_Printer::property_cancel;
}

void fl_printer_set_property_cancel(const char * v) {
    Fl_Printer::property_cancel = v;
}




int fl_printer_start_job(PRINTER p, int c) {
    return static_cast<Fl_Printer*>(p)->start_job(c, 0, 0);
}

int fl_printer_start_job2(PRINTER p, int c, int * f, int * t) {
    return static_cast<Fl_Printer*>(p)->start_job(c, f, t);
}

void fl_printer_end_job(PRINTER p) {
    static_cast<Fl_Printer*>(p)->end_job();
}

int fl_printer_start_page(PRINTER p) {
    return static_cast<Fl_Printer*>(p)->start_page();
}

int fl_printer_end_page(PRINTER p) {
    return static_cast<Fl_Printer*>(p)->end_page();
}




void fl_printer_margins(PRINTER p, int * l, int * t, int * r, int * b) {
    static_cast<Fl_Printer*>(p)->margins(l,t,r,b);
}

int fl_printer_printable_rect(PRINTER p, int * w, int * h) {
    return static_cast<Fl_Printer*>(p)->printable_rect(w,h);
}

void fl_printer_get_origin(PRINTER p, int * x, int * y) {
    static_cast<Fl_Printer*>(p)->origin(x,y);
}

void fl_printer_set_origin(PRINTER p, int x, int y) {
    static_cast<Fl_Printer*>(p)->origin(x,y);
}

void fl_printer_rotate(PRINTER p, float r) {
    static_cast<Fl_Printer*>(p)->rotate(r);
}

void fl_printer_scale(PRINTER p, float x, float y) {
    static_cast<Fl_Printer*>(p)->scale(x,y);
}

void fl_printer_translate(PRINTER p, int x, int y) {
    static_cast<Fl_Printer*>(p)->translate(x,y);
}

void fl_printer_untranslate(PRINTER p) {
    static_cast<Fl_Printer*>(p)->untranslate();
}




void fl_printer_print_widget(PRINTER p, void * i, int dx, int dy) {
    static_cast<Fl_Printer*>(p)->print_widget(static_cast<Fl_Widget*>(i),dx,dy);
}

void fl_printer_print_window_part(PRINTER p, void * i, int x, int y,
    int w, int h, int dx, int dy)
{
    static_cast<Fl_Printer*>(p)->print_window_part(static_cast<Fl_Window*>(i),x,y,w,h,dx,dy);
}




void fl_printer_set_current(PRINTER p) {
    static_cast<Fl_Printer*>(p)->set_current();
}


