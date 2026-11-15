

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Group.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Window.H>
#include <FL/Fl_Image.H>
#include <FL/platform.H>
#include <unordered_map>
#include "c_fl_widget.h"
#include "c_fl_anim_gif_image.h"
#include "c_fl_file_chooser.h"
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




//  The widgets with Ada objects

//  Each widget Ada made or wrapped, with the Ada object its user data was
//  set to.  A widget FLTK made has user data of its own, or none: a file
//  chooser's window has the Fl_File_Chooser (Fl_File_Chooser.cxx:114), a
//  menu's window 0.  So fl_widget_get_user_data gives the Ada object only
//  for a widget here whose user data is still that object, and otherwise
//  0 (FLTKAda-BUGS.md 44, 51).  fl_widget_forget takes a widget out, with
//  the parts FLTK made in it, which go with it.

static std::unordered_map<const Fl_Widget*, void*> ada_widgets;

static void forget_ada_object(Fl_Widget * w) {
    ada_widgets.erase(w);
    Fl_Group * g = w->as_group();
    if (g != 0) {
        for (int i = 0; i < g->children(); i++) {
            forget_ada_object(g->child(i));
        }
    }
}




//  Attaching all relevant hooks and friends

class My_Widget : public Ada_Resizing<Fl_Widget> {
public:
    using Ada_Resizing<Fl_Widget>::Ada_Resizing;
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
//  Extra_Final, before it frees the widget.  An animation showing in the
//  widget forgets it too (pofltk 62), and a file chooser whose extra widget
//  it is lets it go (pofltk 92).
void fl_widget_forget(WIDGET w) {
    Fl_Widget *wi = static_cast<Fl_Widget*>(w);
    anim_gif_canvas_gone(wi);
    file_chooser_extra_gone(wi);
    if (Fl::grab() != 0 && Fl::grab() == wi) {
        Fl::grab(0);
    }
    if (Fl::selection_owner() == wi) {
        Fl::selection_owner(0);
    }
    //  Fl::delete_widget hides a widget it queues, and hiding redraws its
    //  group (Fl.cxx:1827, Fl_Widget.cxx:263-267).  Extra_Final takes the
    //  widget out of its group before free_fl_widget queues it, so it is
    //  hidden here, while it still has a group to redraw (FLTKAda-BUGS.md
    //  104).  Outside a callback FLTK's plain delete hides nothing.
    if (fl_inside_callback && wi->visible_r()) {
        wi->hide();
    }
    //  A widget freed in a callback is deleted later (Fl::delete_widget),
    //  but its Ada object is gone now, so its trackers say so now.
    Fl::clear_widget_pointer(wi);
    forget_ada_object(wi);
}




void widget_forget_ada_objects(Fl_Widget * w) {
    forget_ada_object(w);
}

void * fl_widget_get_user_data(WIDGET w) {
    if (w == 0) {
        return 0;
    }
    Fl_Widget * wi = static_cast<Fl_Widget*>(w);
    std::unordered_map<const Fl_Widget*, void*>::const_iterator i = ada_widgets.find(wi);
    if (i == ada_widgets.end() || i->second != wi->user_data()) {
        return 0;
    }
    return i->second;
}

void fl_widget_set_user_data(WIDGET w, void * d) {
    Fl_Widget * wi = static_cast<Fl_Widget*>(w);
    wi->user_data(d);
    if (d == 0) {
        ada_widgets.erase(wi);
    } else {
        ada_widgets[wi] = d;
    }
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




//  The label of a multi-label, a file icon or an image label is a pointer
//  to it, not text (Fl_Multi_Label.cxx:28, Fl_File_Icon.cxx:425,
//  Fl_Image.cxx:224).
int fl_widget_label_is_pointer(WIDGET w) {
    const Fl_Labeltype t = static_cast<Fl_Widget*>(w)->labeltype();
    return t == _FL_MULTI_LABEL || t == _FL_ICON_LABEL || t == _FL_IMAGE_LABEL;
}

//  Text set on a widget showing such a label replaces it, as text of
//  FL_NORMAL_LABEL: copy_label keeps the type, and FLTK would read the text
//  as the pointer (pofltk 55).  The pointer isn't the widget's to free,
//  since FLTKAda clears the copied label before setting one.
void fl_widget_plain_label(WIDGET w) {
    if (fl_widget_label_is_pointer(w)) {
        static_cast<Fl_Widget*>(w)->label(FL_NORMAL_LABEL, 0);
    }
}

const char* fl_widget_get_label(WIDGET w) {
    if (fl_widget_label_is_pointer(w)) {
        return 0;
    }
    return static_cast<Fl_Widget*>(w)->label();
}

void fl_widget_set_label(WIDGET w, const char* t) {
    fl_widget_plain_label(w);
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

//  Which is 0 for the horizontal margin, 1 for the vertical and 2 for
//  the image spacing.  FLTK casts each to a byte (Fl_Widget.H:700-725),
//  so the Ada side checks the range.
int fl_widget_get_label_margin(WIDGET w, int which) {
    Fl_Widget * o = static_cast<Fl_Widget*>(w);
    switch (which) {
    case 0: return o->horizontal_label_margin();
    case 1: return o->vertical_label_margin();
    default: return o->label_image_spacing();
    }
}

void fl_widget_set_label_margin(WIDGET w, int which, int px) {
    Fl_Widget * o = static_cast<Fl_Widget*>(w);
    switch (which) {
    case 0: o->horizontal_label_margin(px); break;
    case 1: o->vertical_label_margin(px); break;
    default: o->label_image_spacing(px); break;
    }
}

int fl_widget_get_labeltype(WIDGET w) {
    return static_cast<Fl_Widget*>(w)->labeltype();
}

//  A widget showing a multi-label or a file icon keeps it, since a
//  multi-label's parts have kinds of their own, and none of those kinds is
//  given to text, which FLTK would read as the pointer.
void fl_widget_set_labeltype(WIDGET w, int l) {
    if (fl_widget_label_is_pointer(w)
        || l == _FL_MULTI_LABEL || l == _FL_ICON_LABEL || l == _FL_IMAGE_LABEL)
    {
        return;
    }
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

void ada_default_resize(Fl_Widget * w, int x, int y, int ww, int hh) {
    Ada_Resizer * r = dynamic_cast<Ada_Resizer*>(w);
    if (r != 0) {
        r->base_resize(x, y, ww, hh);
    } else {
        w->resize(x, y, ww, hh);
    }
}

void fl_widget_resize(WIDGET o, int x, int y, int w, int h) {
    ada_default_resize(static_cast<Fl_Widget*>(o), x, y, w, h);
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

//  For one draw of w, scales its image and inactive image to the inside of
//  its box, in proportion, growing them only if expand (PLAN.md, Phase 30;
//  pofltk's FitImages).  Each image scaled goes in imgs, and its size
//  before in sizes, for fl_widget_unfit_images; an image not scaled is a
//  null.  Fl_Image::scale changes no pixels, and a shared image is known
//  in FLTK's pool by its data size, which scaling leaves alone.
void fl_widget_fit_images(WIDGET w, int expand, void ** imgs, int * sizes) {
    Fl_Widget * o = static_cast<Fl_Widget*>(w);
    int bw = o->w() - Fl::box_dw(o->box());
    int bh = o->h() - Fl::box_dh(o->box());
    Fl_Image * m[2] = {o->image(), o->deimage()};
    for (int i = 0; i < 2; i++) {
        imgs[i] = nullptr;
        if (m[i] == nullptr || bw <= 0 || bh <= 0) {
            continue;
        }
        sizes[2 * i] = m[i]->w();
        sizes[2 * i + 1] = m[i]->h();
        imgs[i] = m[i];
        try {
            m[i]->scale(bw, bh, 1, expand);
        } catch (...) {
        }
    }
}

//  Puts back the sizes fl_widget_fit_images changed, the inactive image's
//  first, so that an image that is both ends at its own size.
void fl_widget_unfit_images(void * const * imgs, const int * sizes) {
    for (int i = 1; i >= 0; i--) {
        if (imgs[i] != nullptr) {
            try {
                static_cast<Fl_Image*>(imgs[i])->scale(sizes[2 * i], sizes[2 * i + 1], 0, 1);
            } catch (...) {
            }
        }
    }
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


