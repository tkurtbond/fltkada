

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Group.H>
#include <FL/Fl_Help_View.H>
#include <FL/Enumerations.H>
#include "c_fl_help_view.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Help_View : public Fl_Help_View {
public:
    using Fl_Help_View::Fl_Help_View;

    friend void fl_help_view_draw(HELPVIEW v);
    friend int fl_help_view_handle(HELPVIEW v, int e);

    void draw();
    int handle(int e);
};

void My_Help_View::draw() {
    widget_draw_hook(this->user_data());
}

int My_Help_View::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

HELPVIEW new_fl_help_view(int x, int y, int w, int h, char * label) {
    My_Help_View *v = new My_Help_View(x, y, w, h, label);
    return v;
}

void free_fl_help_view(HELPVIEW v) {
    if (fl_inside_callback) {
        fl_delete_widget(v);
    } else {
        delete static_cast<My_Help_View*>(v);
    }
}




void fl_help_view_clear_selection(HELPVIEW v) {
    static_cast<Fl_Help_View*>(v)->clear_selection();
}

void fl_help_view_select_all(HELPVIEW v) {
    static_cast<Fl_Help_View*>(v)->select_all();
}




int fl_help_view_find(HELPVIEW v, const char * s, int p) {
    return static_cast<Fl_Help_View*>(v)->find(s, p);
}

int fl_help_view_get_leftline(HELPVIEW v) {
    return static_cast<Fl_Help_View*>(v)->leftline();
}

void fl_help_view_set_leftline(HELPVIEW v, int t) {
    static_cast<Fl_Help_View*>(v)->leftline(t);
}

int fl_help_view_get_topline(HELPVIEW v) {
    return static_cast<Fl_Help_View*>(v)->topline();
}

void fl_help_view_set_topline(HELPVIEW v, int t) {
    static_cast<Fl_Help_View*>(v)->topline(t);
}

void fl_help_view_set_topline_target(HELPVIEW v, const char * t) {
    static_cast<Fl_Help_View*>(v)->topline(t);
}




const char * fl_help_view_directory(HELPVIEW v) {
    return static_cast<Fl_Help_View*>(v)->directory();
}

const char * fl_help_view_filename(HELPVIEW v) {
    return static_cast<Fl_Help_View*>(v)->filename();
}

int fl_help_view_load(HELPVIEW v, const char * f) {
    return static_cast<Fl_Help_View*>(v)->load(f);
}

const char * fl_help_view_title(HELPVIEW v) {
    return static_cast<Fl_Help_View*>(v)->title();
}

const char * fl_help_view_get_value(HELPVIEW v) {
    return static_cast<Fl_Help_View*>(v)->value();
}

void fl_help_view_set_value(HELPVIEW v, const char * t) {
    static_cast<Fl_Help_View*>(v)->value(t);
}

void fl_help_view_link(HELPVIEW v, void * f) {
    static_cast<Fl_Help_View*>(v)->link(reinterpret_cast<Fl_Help_Func*>(f));
}




int fl_help_view_get_scrollbar_size(HELPVIEW v) {
    return static_cast<Fl_Help_View*>(v)->scrollbar_size();
}

void fl_help_view_set_scrollbar_size(HELPVIEW v, int s) {
    static_cast<Fl_Help_View*>(v)->scrollbar_size(s);
}

int fl_help_view_get_size(HELPVIEW v) {
    return static_cast<Fl_Help_View*>(v)->size();
}

void fl_help_view_set_size(HELPVIEW v, int w, int h) {
    static_cast<Fl_Help_View*>(v)->size(w, h);
}

void fl_help_view_resize(HELPVIEW v, int x, int y, int w, int h) {
    static_cast<Fl_Help_View*>(v)->resize(x, y, w, h);
}

unsigned int fl_help_view_get_textcolor(HELPVIEW v) {
    return static_cast<Fl_Help_View*>(v)->textcolor();
}

void fl_help_view_set_textcolor(HELPVIEW v, unsigned int c) {
    static_cast<Fl_Help_View*>(v)->textcolor(c);
}

int fl_help_view_get_textfont(HELPVIEW v) {
    return static_cast<Fl_Help_View*>(v)->textfont();
}

void fl_help_view_set_textfont(HELPVIEW v, int f) {
    static_cast<Fl_Help_View*>(v)->textfont(f);
}

int fl_help_view_get_textsize(HELPVIEW v) {
    return static_cast<Fl_Help_View*>(v)->textsize();
}

void fl_help_view_set_textsize(HELPVIEW v, int s) {
    static_cast<Fl_Help_View*>(v)->textsize(s);
}




void fl_help_view_draw(HELPVIEW v) {
#if FL_ABI_VERSION >= 10303
    static_cast<My_Help_View*>(v)->Fl_Help_View::draw();
#else
    static_cast<My_Help_View*>(v)->Fl_Group::draw();
#endif
}

int fl_help_view_handle(HELPVIEW v, int e) {
#if FL_ABI_VERSION >= 10303
    return static_cast<My_Help_View*>(v)->Fl_Help_View::handle(e);
#else
    return static_cast<My_Help_View*>(v)->Fl_Group::handle(e);
#endif
}


