

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_WIDGET_GUARD
#define FL_WIDGET_GUARD


typedef void* WIDGET;


extern "C" WIDGET new_fl_widget(int x, int y, int w, int h, char* label);
extern "C" void free_fl_widget(WIDGET w);
extern "C" void fl_widget_forget(WIDGET w);

//  For a widget FLTK deletes: takes it and the widgets in it out of the
//  widgets with Ada objects, as fl_widget_forget does.
class Fl_Widget;
void widget_forget_ada_objects(Fl_Widget * w);


extern "C" void * fl_widget_get_user_data(WIDGET w);
extern "C" void fl_widget_set_user_data(WIDGET w, void * d);


extern "C" void fl_widget_activate(WIDGET w);
extern "C" void fl_widget_deactivate(WIDGET w);
extern "C" int fl_widget_active(WIDGET w);
extern "C" int fl_widget_active_r(WIDGET w);
extern "C" void fl_widget_set_active(WIDGET w);
extern "C" void fl_widget_clear_active(WIDGET w);


extern "C" unsigned int fl_widget_changed(WIDGET w);
extern "C" void fl_widget_set_changed(WIDGET w);
extern "C" void fl_widget_clear_changed(WIDGET w);
extern "C" int fl_widget_output(WIDGET w);
extern "C" void fl_widget_set_output(WIDGET w);
extern "C" void fl_widget_clear_output(WIDGET w);


extern "C" int fl_widget_visible(WIDGET w);
extern "C" int fl_widget_visible_r(WIDGET w);
extern "C" void fl_widget_set_visible(WIDGET w);
extern "C" void fl_widget_clear_visible(WIDGET w);
extern "C" void fl_widget_show(WIDGET w);
extern "C" void fl_widget_hide(WIDGET w);


extern "C" int fl_widget_get_visible_focus(WIDGET w);
extern "C" void fl_widget_set_visible_focus2(WIDGET w);
extern "C" void fl_widget_set_visible_focus(WIDGET w, int f);
extern "C" void fl_widget_clear_visible_focus(WIDGET w);
extern "C" int fl_widget_take_focus(WIDGET w);
extern "C" int fl_widget_takesevents(WIDGET w);


extern "C" unsigned int fl_widget_get_color(WIDGET w);
extern "C" void fl_widget_set_color(WIDGET w, unsigned int b);
extern "C" unsigned int fl_widget_get_selection_color(WIDGET w);
extern "C" void fl_widget_set_selection_color(WIDGET w, unsigned int c);
extern "C" void fl_widget_set_colors(WIDGET w, unsigned int b, unsigned int s);


extern "C" void * fl_widget_get_parent(WIDGET w);
extern "C" int fl_widget_contains(WIDGET w, WIDGET i);
extern "C" int fl_widget_inside(WIDGET w, WIDGET p);
extern "C" void * fl_widget_window(WIDGET w);
extern "C" void * fl_widget_top_window(WIDGET w);
extern "C" void * fl_widget_top_window_offset(WIDGET w, int &x, int &y);


extern "C" unsigned int fl_widget_get_align(WIDGET w);
extern "C" void fl_widget_set_align(WIDGET w, unsigned int a);
extern "C" int fl_widget_get_box(WIDGET w);
extern "C" void fl_widget_set_box(WIDGET w, int b);
extern "C" const char * fl_widget_tooltip(WIDGET w);
extern "C" void fl_widget_copy_tooltip(WIDGET w, const char * t);


extern "C" const char* fl_widget_get_label(WIDGET w);
extern "C" void fl_widget_set_label(WIDGET w, const char* t);
extern "C" int fl_widget_label_is_pointer(WIDGET w);
extern "C" void fl_widget_plain_label(WIDGET w);
extern "C" unsigned int fl_widget_get_labelcolor(WIDGET w);
extern "C" void fl_widget_set_labelcolor(WIDGET w, unsigned int v);
extern "C" int fl_widget_get_labelfont(WIDGET w);
extern "C" void fl_widget_set_labelfont(WIDGET w, int f);
extern "C" int fl_widget_get_labelsize(WIDGET w);
extern "C" void fl_widget_set_labelsize(WIDGET w, int s);
extern "C" int fl_widget_get_label_margin(WIDGET w, int which);
extern "C" void fl_widget_set_label_margin(WIDGET w, int which, int px);
extern "C" int fl_widget_get_labeltype(WIDGET w);
extern "C" void fl_widget_set_labeltype(WIDGET w, int l);
extern "C" void fl_widget_measure_label(WIDGET w, int &d, int &h);


extern "C" void fl_widget_set_callback(WIDGET w, void * cb);
extern "C" void fl_widget_default_callback(WIDGET w, void * ud);
extern "C" unsigned char fl_widget_get_when(WIDGET w);
extern "C" void fl_widget_set_when(WIDGET w, unsigned char c);


extern "C" int fl_widget_get_x(WIDGET w);
extern "C" int fl_widget_get_y(WIDGET w);
extern "C" int fl_widget_get_w(WIDGET w);
extern "C" int fl_widget_get_h(WIDGET w);
extern "C" void fl_widget_size(WIDGET w, int d, int h);
extern "C" void fl_widget_resize(WIDGET o, int x, int y, int w, int h);
extern "C" void fl_widget_position(WIDGET w, int x, int y);


extern "C" void fl_widget_set_image(WIDGET w, void * img);
extern "C" void fl_widget_set_deimage(WIDGET w, void * img);
extern "C" void fl_widget_fit_images(WIDGET w, int expand, void ** imgs, int * sizes);
extern "C" void fl_widget_unfit_images(void * const * imgs, const int * sizes);


extern "C" unsigned char fl_widget_get_type(WIDGET w);
extern "C" void fl_widget_set_type(WIDGET w, unsigned char t);


extern "C" unsigned char fl_widget_damage(WIDGET w);
extern "C" void fl_widget_set_damage(WIDGET w, unsigned char m);
extern "C" void fl_widget_set_damage2(WIDGET w, unsigned char m, int x, int y, int d, int h);
extern "C" void fl_widget_clear_damage(WIDGET w, unsigned char m);
extern "C" void fl_widget_draw(WIDGET w);
extern "C" void fl_widget_draw_label(WIDGET w);
extern "C" void fl_widget_draw_label2(WIDGET o, int x, int y, int w, int h);
extern "C" void fl_widget_draw_label3(WIDGET w, int x, int y, int d, int h, unsigned int a);
extern "C" void fl_widget_draw_backdrop(WIDGET w);
extern "C" void fl_widget_draw_box(WIDGET w);
extern "C" void fl_widget_draw_box2(WIDGET w, int k, unsigned int h);
extern "C" void fl_widget_draw_box3(WIDGET o, int k, int x, int y, int w, int h, unsigned int c);
extern "C" void fl_widget_draw_focus(WIDGET w);
extern "C" void fl_widget_draw_focus2(WIDGET o, int k, int x, int y, int w, int h);
extern "C" void fl_widget_redraw(WIDGET w);
extern "C" void fl_widget_redraw_label(WIDGET w);
extern "C" int fl_widget_handle(WIDGET w, int e);


extern "C" int fl_widget_use_accents_menu(WIDGET w);


//  An Ada widget's FLTK class B, with resize() sent to the Ada Resize,
//  which FLTK calls as a group or a window lays out its children.  Until
//  the Ada side has set the user data there is no Ada object, and B's own
//  runs.  The Ada default Resize is base_resize, through
//  ada_default_resize, so an override that calls the default runs once.
//  Ported from pofltk's W and Hooks (pofltk.h).

extern "C" void widget_resize_hook(void * ud, int x, int y, int w, int h);

class Ada_Resizer {
public:
    virtual ~Ada_Resizer() {}
    virtual void base_resize(int x, int y, int w, int h) = 0;
};

template <class B> class Ada_Resizing : public B, public Ada_Resizer {
public:
    using B::B;

    void resize(int x, int y, int w, int h) override {
        if (this->user_data() == nullptr) {
            this->base_resize(x, y, w, h);
        } else {
            widget_resize_hook(this->user_data(), x, y, w, h);
        }
    }

    void base_resize(int x, int y, int w, int h) override {
        B::resize(x, y, w, h);
    }
};

class Fl_Widget;

//  FLTK's own resize for an Ada widget, not the virtual one, which would
//  come back to the Ada Resize; the virtual one for a widget FLTK made.
void ada_default_resize(Fl_Widget * w, int x, int y, int ww, int hh);


#endif


