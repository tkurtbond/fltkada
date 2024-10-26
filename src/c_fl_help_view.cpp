

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Group.H>
#include <FL/Fl_Help_View.H>
#include <FL/Enumerations.H>
#include "c_fl_help_view.h"
#include "c_fl_type.h"




class My_Help_View : public Fl_Help_View {
    public:
        using Fl_Help_View::Fl_Help_View;
        friend void help_view_set_draw_hook(HELPVIEW v, void * d);
        friend void fl_help_view_draw(HELPVIEW v);
        friend void help_view_set_handle_hook(HELPVIEW v, void * h);
        friend int fl_help_view_handle(HELPVIEW v, int e);
    protected:
        void draw();
        void real_draw();
        int handle(int e);
        int real_handle(int e);
        d_hook_p draw_hook;
        h_hook_p handle_hook;
};

void My_Help_View::draw() {
    (*draw_hook)(this->user_data());
}

void My_Help_View::real_draw() {
    #if FL_ABI_VERSION >= 10303
    Fl_Help_View::draw();
    #else
    Fl_Group::draw();
    #endif
}

int My_Help_View::handle(int e) {
    return (*handle_hook)(this->user_data(), e);
}

int My_Help_View::real_handle(int e) {
    #if FL_ABI_VERSION >= 10303
    return Fl_Help_View::handle(e);
    #else
    return Fl_Group::handle(e);
    #endif
}

void help_view_set_draw_hook(HELPVIEW v, void * d) {
    reinterpret_cast<My_Help_View*>(v)->draw_hook = reinterpret_cast<d_hook_p>(d);
}

void fl_help_view_draw(HELPVIEW v) {
    reinterpret_cast<My_Help_View*>(v)->real_draw();
}

void help_view_set_handle_hook(HELPVIEW v, void * h) {
    reinterpret_cast<My_Help_View*>(v)->handle_hook = reinterpret_cast<h_hook_p>(h);
}

int fl_help_view_handle(HELPVIEW v, int e) {
    return reinterpret_cast<My_Help_View*>(v)->real_handle(e);
}




HELPVIEW new_fl_help_view(int x, int y, int w, int h, char * label) {
    My_Help_View *v = new My_Help_View(x, y, w, h, label);
    return v;
}

void free_fl_help_view(HELPVIEW v) {
    delete reinterpret_cast<My_Help_View*>(v);
}




void fl_help_view_clear_selection(HELPVIEW v) {
    reinterpret_cast<Fl_Help_View*>(v)->clear_selection();
}

void fl_help_view_select_all(HELPVIEW v) {
    reinterpret_cast<Fl_Help_View*>(v)->select_all();
}




int fl_help_view_find(HELPVIEW v, const char * s, int p) {
    return reinterpret_cast<Fl_Help_View*>(v)->find(s, p);
}

int fl_help_view_get_leftline(HELPVIEW v) {
    return reinterpret_cast<Fl_Help_View*>(v)->leftline();
}

void fl_help_view_set_leftline(HELPVIEW v, int t) {
    reinterpret_cast<Fl_Help_View*>(v)->leftline(t);
}

int fl_help_view_get_topline(HELPVIEW v) {
    return reinterpret_cast<Fl_Help_View*>(v)->topline();
}

void fl_help_view_set_topline(HELPVIEW v, int t) {
    reinterpret_cast<Fl_Help_View*>(v)->topline(t);
}

void fl_help_view_set_topline_target(HELPVIEW v, const char * t) {
    reinterpret_cast<Fl_Help_View*>(v)->topline(t);
}




const char * fl_help_view_directory(HELPVIEW v) {
    return reinterpret_cast<Fl_Help_View*>(v)->directory();
}

const char * fl_help_view_filename(HELPVIEW v) {
    return reinterpret_cast<Fl_Help_View*>(v)->filename();
}

int fl_help_view_load(HELPVIEW v, const char * f) {
    return reinterpret_cast<Fl_Help_View*>(v)->load(f);
}

const char * fl_help_view_title(HELPVIEW v) {
    return reinterpret_cast<Fl_Help_View*>(v)->title();
}

const char * fl_help_view_get_value(HELPVIEW v) {
    return reinterpret_cast<Fl_Help_View*>(v)->value();
}

void fl_help_view_set_value(HELPVIEW v, const char * t) {
    reinterpret_cast<Fl_Help_View*>(v)->value(t);
}

void fl_help_view_link(HELPVIEW v, void * f) {
    reinterpret_cast<Fl_Help_View*>(v)->link(reinterpret_cast<Fl_Help_Func*>(f));
}




int fl_help_view_get_scrollbar_size(HELPVIEW v) {
    return reinterpret_cast<Fl_Help_View*>(v)->scrollbar_size();
}

void fl_help_view_set_scrollbar_size(HELPVIEW v, int s) {
    reinterpret_cast<Fl_Help_View*>(v)->scrollbar_size(s);
}

int fl_help_view_get_size(HELPVIEW v) {
    return reinterpret_cast<Fl_Help_View*>(v)->size();
}

void fl_help_view_set_size(HELPVIEW v, int w, int h) {
    reinterpret_cast<Fl_Help_View*>(v)->size(w, h);
}

unsigned int fl_help_view_get_textcolor(HELPVIEW v) {
    return reinterpret_cast<Fl_Help_View*>(v)->textcolor();
}

void fl_help_view_set_textcolor(HELPVIEW v, unsigned int c) {
    reinterpret_cast<Fl_Help_View*>(v)->textcolor(c);
}

int fl_help_view_get_textfont(HELPVIEW v) {
    return reinterpret_cast<Fl_Help_View*>(v)->textfont();
}

void fl_help_view_set_textfont(HELPVIEW v, int f) {
    reinterpret_cast<Fl_Help_View*>(v)->textfont(f);
}

int fl_help_view_get_textsize(HELPVIEW v) {
    return reinterpret_cast<Fl_Help_View*>(v)->textsize();
}

void fl_help_view_set_textsize(HELPVIEW v, int s) {
    reinterpret_cast<Fl_Help_View*>(v)->textsize(s);
}


