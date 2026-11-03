

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Widget.H>
#include <FL/Fl_Window.H>
#include <FL/Fl_Image.H>
#include <FL/platform.H>
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Non-friend protected access

class Friend_Widget : Fl_Widget {
public:
    using Fl_Widget::draw_backdrop;
    using Fl_Widget::draw_box;
    using Fl_Widget::draw_focus;
    using Fl_Widget::draw_label;
};




//  Attaching all relevant hooks and friends

class My_Widget : public Fl_Widget {
public:
    using Fl_Widget::Fl_Widget;
    friend WIDGET new_fl_widget(int x, int y, int w, int h, char* label);

    friend void fl_widget_draw(WIDGET w);
    friend int fl_widget_handle(WIDGET w, int e);

    void draw();
    int handle(int e);
};

void My_Widget::draw() {
    widget_draw_hook(this->user_data());
}

int My_Widget::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

WIDGET new_fl_widget(int x, int y, int w, int h, char* label) {
    My_Widget *wd = new My_Widget(x, y, w, h, label);
    return wd;
}

void free_fl_widget(WIDGET w) {
    if (fl_inside_callback) {
        fl_delete_widget(w);
    } else {
        delete static_cast<My_Widget*>(w);
    }
}

//  ~Fl_Widget clears Fl::pushed, belowmouse and focus, but not Fl::grab or
//  the selection owner, and the next event then reads the freed widget
//  (Fl_Widget.cxx:166-185, Fl.cxx:1205-1219, pofltk 129).  Every widget's Finalize calls this, through
//  Extra_Final, before it frees the widget.
void fl_widget_forget(WIDGET w) {
    Fl_Widget *wi = static_cast<Fl_Widget*>(w);
    if (Fl::grab() != 0 && Fl::grab() == wi) {
        Fl::grab(0);
    }
    if (Fl::selection_owner() == wi) {
        Fl::selection_owner(0);
    }
}




void * fl_widget_get_user_data(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->user_data();
}

void fl_widget_set_user_data(WIDGET w, void * d) {
    static_cast<Fl_Widget*>(w)->user_data(d);
}




void fl_widget_activate(WIDGET w) {
    static_cast<Fl_Widget*>(w)->activate();
}

void fl_widget_deactivate(WIDGET w) {
    static_cast<Fl_Widget*>(w)->deactivate();
}

int fl_widget_active(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->active();
}

int fl_widget_active_r(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->active_r();
}

void fl_widget_set_active(WIDGET w) {
    static_cast<Fl_Widget*>(w)->set_active();
}

void fl_widget_clear_active(WIDGET w) {
    static_cast<Fl_Widget*>(w)->clear_active();
}




unsigned int fl_widget_changed(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->changed();
}

void fl_widget_set_changed(WIDGET w) {
    static_cast<Fl_Widget*>(w)->set_changed();
}

void fl_widget_clear_changed(WIDGET w) {
    static_cast<Fl_Widget*>(w)->clear_changed();
}

int fl_widget_output(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->output();
}

void fl_widget_set_output(WIDGET w) {
    static_cast<Fl_Widget*>(w)->set_output();
}

void fl_widget_clear_output(WIDGET w) {
    static_cast<Fl_Widget*>(w)->clear_output();
}




int fl_widget_visible(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->visible();
}

int fl_widget_visible_r(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->visible_r();
}

void fl_widget_set_visible(WIDGET w) {
    static_cast<Fl_Widget*>(w)->set_visible();
}

void fl_widget_clear_visible(WIDGET w) {
    static_cast<Fl_Widget*>(w)->clear_visible();
}

void fl_widget_show(WIDGET w) {
    static_cast<Fl_Widget*>(w)->show();
}

void fl_widget_hide(WIDGET w) {
    static_cast<Fl_Widget*>(w)->hide();
}




int fl_widget_get_visible_focus(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->visible_focus();
}

void fl_widget_set_visible_focus2(WIDGET w) {
    static_cast<Fl_Widget*>(w)->set_visible_focus();
}

void fl_widget_set_visible_focus(WIDGET w, int f) {
    static_cast<Fl_Widget*>(w)->visible_focus(f);
}

void fl_widget_clear_visible_focus(WIDGET w) {
    static_cast<Fl_Widget*>(w)->clear_visible_focus();
}

//  An input taking the focus before the display is open crashes FLTK 1.4.5
//  on Wayland (pofltk 4).
int fl_widget_take_focus(WIDGET w) {
    fl_open_display();
    return static_cast<Fl_Widget*>(w)->take_focus();
}

int fl_widget_takesevents(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->takesevents();
}




unsigned int fl_widget_get_color(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->color();
}

void fl_widget_set_color(WIDGET w, unsigned int b) {
    static_cast<Fl_Widget*>(w)->color(b);
}

unsigned int fl_widget_get_selection_color(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->selection_color();
}

void fl_widget_set_selection_color(WIDGET w, unsigned int c) {
    static_cast<Fl_Widget*>(w)->selection_color(c);
}

void fl_widget_set_colors(WIDGET w, unsigned int b, unsigned int s) {
    static_cast<Fl_Widget*>(w)->color(b, s);
}




void * fl_widget_get_parent(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->parent();
}

int fl_widget_contains(WIDGET w, WIDGET i) {
    return static_cast<Fl_Widget*>(w)->contains(static_cast<Fl_Widget*>(i));
}

int fl_widget_inside(WIDGET w, WIDGET p) {
    return static_cast<Fl_Widget*>(w)->inside(static_cast<Fl_Widget*>(p));
}

void * fl_widget_window(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->window();
}

void * fl_widget_top_window(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->top_window();
}

void * fl_widget_top_window_offset(WIDGET w, int &x, int &y) {
    return static_cast<Fl_Widget*>(w)->top_window_offset(x,y);
}




unsigned int fl_widget_get_align(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->align();
}

void fl_widget_set_align(WIDGET w, unsigned int a) {
    static_cast<Fl_Widget*>(w)->align(a);
}

int fl_widget_get_box(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->box();
}

void fl_widget_set_box(WIDGET w, int b) {
    static_cast<Fl_Widget*>(w)->box(static_cast<Fl_Boxtype>(b));
}

const char * fl_widget_tooltip(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->tooltip();
}

void fl_widget_copy_tooltip(WIDGET w, const char * t) {
    static_cast<Fl_Widget*>(w)->copy_tooltip(t);
}




const char* fl_widget_get_label(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->label();
}

void fl_widget_set_label(WIDGET w, const char* t) {
    static_cast<Fl_Widget*>(w)->copy_label(t);
}

unsigned int fl_widget_get_labelcolor(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->labelcolor();
}

void fl_widget_set_labelcolor(WIDGET w, unsigned int v) {
    static_cast<Fl_Widget*>(w)->labelcolor(v);
}

int fl_widget_get_labelfont(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->labelfont();
}

void fl_widget_set_labelfont(WIDGET w, int f) {
    static_cast<Fl_Widget*>(w)->labelfont(static_cast<Fl_Font>(f));
}

int fl_widget_get_labelsize(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->labelsize();
}

void fl_widget_set_labelsize(WIDGET w, int s) {
    static_cast<Fl_Widget*>(w)->labelsize(static_cast<Fl_Fontsize>(s));
}

int fl_widget_get_labeltype(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->labeltype();
}

void fl_widget_set_labeltype(WIDGET w, int l) {
    static_cast<Fl_Widget*>(w)->labeltype(static_cast<Fl_Labeltype>(l));
}

void fl_widget_measure_label(WIDGET w, int &d, int &h) {
    static_cast<Fl_Widget*>(w)->measure_label(d,h);
}




void fl_widget_set_callback(WIDGET w, void * cb) {
    static_cast<Fl_Widget*>(w)->callback(reinterpret_cast<Fl_Callback_p>(cb));
}

void fl_widget_default_callback(WIDGET w, void * ud) {
    Fl_Widget::default_callback(static_cast<Fl_Widget*>(w), ud);
}

unsigned char fl_widget_get_when(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->when();
}

void fl_widget_set_when(WIDGET w, unsigned char c) {
    static_cast<Fl_Widget*>(w)->when(c);
}




int fl_widget_get_x(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->x();
}

int fl_widget_get_y(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->y();
}

int fl_widget_get_w(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->w();
}

int fl_widget_get_h(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->h();
}

void fl_widget_size(WIDGET w, int d, int h) {
    static_cast<Fl_Widget*>(w)->size(d, h);
}

void fl_widget_resize(WIDGET o, int x, int y, int w, int h) {
    static_cast<Fl_Widget*>(o)->resize(x, y, w, h);
}

void fl_widget_position(WIDGET w, int x, int y) {
    static_cast<Fl_Widget*>(w)->position(x, y);
}




void fl_widget_set_image(WIDGET w, void * img) {
    static_cast<Fl_Widget*>(w)->image(static_cast<Fl_Image*>(img));
}

void fl_widget_set_deimage(WIDGET w, void * img) {
    static_cast<Fl_Widget*>(w)->deimage(static_cast<Fl_Image*>(img));
}




unsigned char fl_widget_get_type(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->type();
}

void fl_widget_set_type(WIDGET w, unsigned char t) {
    static_cast<Fl_Widget*>(w)->type(t);
}




unsigned char fl_widget_damage(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->damage();
}

void fl_widget_set_damage(WIDGET w, unsigned char m) {
    static_cast<Fl_Widget*>(w)->damage(m);
}

void fl_widget_set_damage2(WIDGET w, unsigned char m, int x, int y, int d, int h) {
    static_cast<Fl_Widget*>(w)->damage(m, x, y, d, h);
}

void fl_widget_clear_damage(WIDGET w, unsigned char m) {
    static_cast<Fl_Widget*>(w)->clear_damage(m);
}

void fl_widget_draw(WIDGET w) {
    //  The Fl_Widget draw method doesn't technically exist, so...
    (void)(w);
    //  It is more convenient for this function to exist, however,
    //  even though it will likely never be called, because it simplifies
    //  and makes uniform the implementation of the Ada Widget Draw subprogram.
}

void fl_widget_draw_label(WIDGET w) {
    void (Fl_Widget::*mydraw)(void) const = &Friend_Widget::draw_label;
    (static_cast<Fl_Widget*>(w)->*mydraw)();
}

void fl_widget_draw_label2(WIDGET o, int x, int y, int w, int h) {
    void (Fl_Widget::*mydraw)(int,int,int,int) const = &Friend_Widget::draw_label;
    (static_cast<Fl_Widget*>(o)->*mydraw)(x, y, w, h);
}

void fl_widget_draw_label3(WIDGET w, int x, int y, int d, int h, unsigned int a) {
    static_cast<Fl_Widget*>(w)->draw_label(x, y, d, h, a);
}

void fl_widget_draw_backdrop(WIDGET w) {
    (static_cast<Fl_Widget*>(w)->*(&Friend_Widget::draw_backdrop))();
}

void fl_widget_draw_box(WIDGET w) {
    void (Fl_Widget::*mydraw)(void) const = &Friend_Widget::draw_box;
    (static_cast<Fl_Widget*>(w)->*mydraw)();
}

void fl_widget_draw_box2(WIDGET w, int k, unsigned int h) {
    void (Fl_Widget::*mydraw)(Fl_Boxtype,Fl_Color) const = &Friend_Widget::draw_box;
    (static_cast<Fl_Widget*>(w)->*mydraw)(static_cast<Fl_Boxtype>(k), static_cast<Fl_Color>(h));
}

void fl_widget_draw_box3(WIDGET o, int k, int x, int y, int w, int h, unsigned int c) {
    void (Fl_Widget::*mydraw)(Fl_Boxtype,int,int,int,int,Fl_Color) const = &Friend_Widget::draw_box;
    (static_cast<Fl_Widget*>(o)->*mydraw)
        (static_cast<Fl_Boxtype>(k), x, y, w, h, static_cast<Fl_Color>(c));
}

void fl_widget_draw_focus(WIDGET w) {
    void (Fl_Widget::*mydraw)(void) const = &Friend_Widget::draw_focus;
    (static_cast<Fl_Widget*>(w)->*mydraw)();
}

void fl_widget_draw_focus2(WIDGET o, int k, int x, int y, int w, int h) {
    void (Fl_Widget::*mydraw)(Fl_Boxtype,int,int,int,int) const = &Friend_Widget::draw_focus;
    (static_cast<Fl_Widget*>(o)->*mydraw)(static_cast<Fl_Boxtype>(k), x, y, w, h);
}

void fl_widget_redraw(WIDGET w) {
    static_cast<Fl_Widget*>(w)->redraw();
}

void fl_widget_redraw_label(WIDGET w) {
    static_cast<Fl_Widget*>(w)->redraw_label();
}

int fl_widget_handle(WIDGET w, int e) {
    return static_cast<My_Widget*>(w)->Fl_Widget::handle(e);
}




int fl_widget_use_accents_menu(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->use_accents_menu();
}


