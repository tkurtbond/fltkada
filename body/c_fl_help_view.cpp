

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Help_View.H>
#include <FL/Enumerations.H>
#include "c_fl_help_view.h"
#include "c_fl.h"
#include <map>
#include <string>




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" int help_view_link_hook(void * ud, const char * uri);




//  Attaching all relevant hooks and friends

//  FLTK asks a view's link function two questions it doesn't tell apart:
//  what to load, as a page loads, and where an image is, as a page is laid
//  out, drawn or freed (Fl_Help_View.cxx:2788-2799, 3368, 3407).  It asks
//  about each image again for each of those, and releases the image the
//  answer names, so each image's answer is kept and given again without
//  asking Ada.  The answer to what to load is kept till the next one, since
//  load() reads it after free_data() has asked about the old page's images
//  (FLTKAda-BUGS.md, N4 in PLAN.md).  A refused image is answered "", which
//  names nothing, so FLTK draws its broken image, where NULL would crash it
//  (pofltk 90).  Ported from pofltk's FlHelp.cpp.

class My_Help_View : public Fl_Help_View {
public:
    using Fl_Help_View::Fl_Help_View;

    //  The destructor of Fl_Help_View would ask about its images once this
    //  class is gone.
    ~My_Help_View() { value(0); }

    friend void fl_help_view_draw(HELPVIEW v);
    friend int fl_help_view_handle(HELPVIEW v, int e);

    void draw();
    int handle(int e);
    void resize(int x, int y, int w, int h);

    std::map<std::string, std::string> images;
    std::string answer;
    bool asks = false;
    bool loading = false;
    bool in_image = false;

    //  A link pushed is kept till the release, which follows it
    //  (Fl_Help_View.cxx:3150, 3190, 3218-3220), but setting the page frees
    //  the links (:2554-2560) and a resize lays them out again.  So the
    //  layout's changes are counted, and a link pushed before one isn't
    //  followed (pofltk 89).
    unsigned changes = 0;
    unsigned at_push = 0;
};

void My_Help_View::draw() {
    widget_draw_hook(this->user_data());
}

int My_Help_View::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}

void My_Help_View::resize(int x, int y, int w, int h) {
    ++changes;
    Fl_Help_View::resize(x, y, w, h);
}




static const char * help_view_link(Fl_Widget * w, const char * uri) {
    My_Help_View * v = static_cast<My_Help_View*>(w);
    if (v->loading) {
        v->loading = false;
        if (!v->asks) {
            return uri;
        }
        return help_view_link_hook(v->user_data(), uri) ? v->answer.c_str() : 0;
    }
    std::map<std::string, std::string>::iterator i = v->images.find(uri);
    if (i != v->images.end()) {
        return i->second.c_str();
    }
    std::string r = uri;
    if (v->asks) {
        v->in_image = true;
        r = help_view_link_hook(v->user_data(), uri) ? v->answer : "";
        v->in_image = false;
    }
    return (v->images[uri] = r).c_str();
}




//  Flattened C API

HELPVIEW new_fl_help_view(int x, int y, int w, int h, char * label) {
    My_Help_View *v = new My_Help_View(x, y, w, h, label);
    v->link(help_view_link);
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
    My_Help_View * h = static_cast<My_Help_View*>(v);
    ++h->changes;
    h->loading = true;
    int r = h->load(f);
    h->loading = false;
    return r;
}

const char * fl_help_view_title(HELPVIEW v) {
    return static_cast<Fl_Help_View*>(v)->title();
}

const char * fl_help_view_get_value(HELPVIEW v) {
    return static_cast<Fl_Help_View*>(v)->value();
}

void fl_help_view_set_value(HELPVIEW v, const char * t) {
    My_Help_View * h = static_cast<My_Help_View*>(v);
    ++h->changes;
    h->value(t);
}

void fl_help_view_set_asks(HELPVIEW v, int a) {
    static_cast<My_Help_View*>(v)->asks = a != 0;
}

void fl_help_view_set_answer(HELPVIEW v, const char * s) {
    static_cast<My_Help_View*>(v)->answer = s;
}

int fl_help_view_in_image(HELPVIEW v) {
    return static_cast<My_Help_View*>(v)->in_image;
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
    //  A release on a link loads it (Fl_Help_View.cxx:3216-3220).
    My_Help_View * h = static_cast<My_Help_View*>(v);
    if (e == FL_PUSH) {
        h->at_push = h->changes;
    } else if (e == FL_RELEASE && h->changes != h->at_push) {
        Fl::event_is_click(0);
    }
    h->loading = e == FL_RELEASE;
    int r = h->Fl_Help_View::handle(e);
    h->loading = false;
    return r;
#else
    return static_cast<My_Help_View*>(v)->Fl_Group::handle(e);
#endif
}


