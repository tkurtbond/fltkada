

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Group.H>
#include <FL/Fl_Help_Dialog.H>
#include "c_fl_help_dialog.h"




//  The dialog's window is top-level, so making it sets the current group to
//  none (Fl_Window.cxx:82), and its end () leaves it none
//  (Fl_Help_Dialog.cxx:198).  So the current group is put back, as
//  Fl_File_Chooser's constructor does itself (pofltk 93).

HELPDIALOG new_fl_help_dialog() {
    Fl_Group *current = Fl_Group::current();
    Fl_Help_Dialog *d = new Fl_Help_Dialog();
    Fl_Group::current(current);
    return d;
}

void free_fl_help_dialog(HELPDIALOG d) {
    delete static_cast<Fl_Help_Dialog*>(d);
}




void fl_help_dialog_show(HELPDIALOG d) {
    static_cast<Fl_Help_Dialog*>(d)->show();
}

void fl_help_dialog_show2(HELPDIALOG d, int c, void * v) {
    static_cast<Fl_Help_Dialog*>(d)->show(c, static_cast<char**>(v));
}

void fl_help_dialog_hide(HELPDIALOG d) {
    static_cast<Fl_Help_Dialog*>(d)->hide();
}

int fl_help_dialog_visible(HELPDIALOG d) {
    return static_cast<Fl_Help_Dialog*>(d)->visible();
}




void fl_help_dialog_set_topline_number(HELPDIALOG d, int n) {
    static_cast<Fl_Help_Dialog*>(d)->topline(n);
}

void fl_help_dialog_set_topline_target(HELPDIALOG d, const char * t) {
    static_cast<Fl_Help_Dialog*>(d)->topline(t);
}




void fl_help_dialog_load(HELPDIALOG d, const char * n) {
    static_cast<Fl_Help_Dialog*>(d)->load(n);
}

const char * fl_help_dialog_get_value(HELPDIALOG d) {
    return static_cast<Fl_Help_Dialog*>(d)->value();
}

void fl_help_dialog_set_value(HELPDIALOG d, const char * v) {
    static_cast<Fl_Help_Dialog*>(d)->value(v);
}




int fl_help_dialog_get_textsize(HELPDIALOG d) {
    return static_cast<Fl_Help_Dialog*>(d)->textsize();
}

void fl_help_dialog_set_textsize(HELPDIALOG d, int s) {
    static_cast<Fl_Help_Dialog*>(d)->textsize(s);
}




int fl_help_dialog_get_x(HELPDIALOG d) {
    return static_cast<Fl_Help_Dialog*>(d)->x();
}

int fl_help_dialog_get_y(HELPDIALOG d) {
    return static_cast<Fl_Help_Dialog*>(d)->y();
}

int fl_help_dialog_get_w(HELPDIALOG d) {
    return static_cast<Fl_Help_Dialog*>(d)->w();
}

int fl_help_dialog_get_h(HELPDIALOG d) {
    return static_cast<Fl_Help_Dialog*>(d)->h();
}

void fl_help_dialog_resize(HELPDIALOG d, int xx, int yy, int ww, int hh) {
    static_cast<Fl_Help_Dialog*>(d)->resize(xx, yy, ww, hh);
}

void fl_help_dialog_position(HELPDIALOG d, int xx, int yy) {
    static_cast<Fl_Help_Dialog*>(d)->position(xx, yy);
}


