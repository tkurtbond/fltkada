

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Window.H>
#include <cstring>
#include "c_fl_static.h"




void fl_static_box_draw_marshal(void * f, int x, int y, int w, int h, unsigned int t) {
    reinterpret_cast<Fl_Box_Draw_F*>(f)(x, y, w, h, static_cast<Fl_Color>(t));
}




const char * const fl_help_usage_string_ptr = Fl::help;




int fl_static_arg(int c, void * v, int &i) {
    return Fl::arg(c, static_cast<char**>(v), i);
}

void fl_static_args(int c, void * v) {
    Fl::args(c, static_cast<char**>(v));
}

int fl_static_args2(int c, void * v, int &i, void * h) {
    return Fl::args(c, static_cast<char**>(v), i, reinterpret_cast<Fl_Args_Handler>(h));
}




int fl_static_add_awake_handler(void * h, void * f) {
    return Fl::add_awake_handler_(reinterpret_cast<Fl_Awake_Handler>(h), f);
}

int fl_static_get_awake_handler(void * &h, void * &f) {
    return Fl::get_awake_handler_(reinterpret_cast<Fl_Awake_Handler&>(h), f);
}

int fl_static_awake2(void * h, void * f) {
    return Fl::awake(reinterpret_cast<Fl_Awake_Handler>(h), f);
}

void fl_static_awake(void * msg) {
    Fl::awake(msg);
}

void fl_static_lock() {
    Fl::lock();
}

void fl_static_unlock() {
    Fl::unlock();
}




void fl_static_add_check(void * h, void * f) {
    Fl::add_check(reinterpret_cast<Fl_Timeout_Handler>(h), f);
}

int fl_static_has_check(void * h, void * f) {
    return Fl::has_check(reinterpret_cast<Fl_Timeout_Handler>(h), f);
}

void fl_static_remove_check(void * h, void * f) {
    Fl::remove_check(reinterpret_cast<Fl_Timeout_Handler>(h), f);
}




void fl_static_add_timeout(double s, void * h, void * f) {
    Fl::add_timeout(s, reinterpret_cast<Fl_Timeout_Handler>(h), f);
}

int fl_static_has_timeout(void * h, void * f) {
    return Fl::has_timeout(reinterpret_cast<Fl_Timeout_Handler>(h), f);
}

void fl_static_remove_timeout(void * h, void * f) {
    Fl::remove_timeout(reinterpret_cast<Fl_Timeout_Handler>(h), f);
}

void fl_static_repeat_timeout(double s, void * h, void * f) {
    Fl::repeat_timeout(s, reinterpret_cast<Fl_Timeout_Handler>(h), f);
}




void fl_static_add_clipboard_notify(void * h, void * f) {
    Fl::add_clipboard_notify(reinterpret_cast<Fl_Clipboard_Notify_Handler>(h), f);
}

void fl_static_remove_clipboard_notify(void * h) {
    Fl::remove_clipboard_notify(reinterpret_cast<Fl_Clipboard_Notify_Handler>(h));
}




void fl_static_add_fd(int d, void * h, void * f) {
    Fl::add_fd(d,reinterpret_cast<Fl_FD_Handler>(h), f);
}

void fl_static_add_fd2(int d, int m, void * h, void * f) {
    Fl::add_fd(d,m,reinterpret_cast<Fl_FD_Handler>(h), f);
}

void fl_static_remove_fd(int d) {
    Fl::remove_fd(d);
}

void fl_static_remove_fd2(int d, int m) {
    Fl::remove_fd(d, m);
}




void fl_static_add_idle(void * h, void * f) {
    Fl::add_idle(reinterpret_cast<Fl_Idle_Handler>(h), f);
}

int fl_static_has_idle(void * h, void * f) {
    return Fl::has_idle(reinterpret_cast<Fl_Idle_Handler>(h), f);
}

void fl_static_remove_idle(void * h, void * f) {
    Fl::remove_idle(reinterpret_cast<Fl_Idle_Handler>(h), f);
}




unsigned int fl_static_get_color2(unsigned int c) {
    return Fl::get_color(c);
}

void fl_static_get_color(unsigned int c, unsigned char &r, unsigned char &g, unsigned char &b) {
    Fl::get_color(c, r, g, b);
}

void fl_static_set_color2(unsigned int t, unsigned int f) {
    Fl::set_color(t, f);
}

void fl_static_set_color(unsigned int c, unsigned char r, unsigned char g, unsigned char b) {
    Fl::set_color(c, r, g, b);
}

void fl_static_free_color(unsigned int c, int b) {
    Fl::free_color(c, b);
}

unsigned int fl_static_get_box_color(unsigned int t) {
    return Fl::box_color(static_cast<Fl_Color>(t));
}

void fl_static_set_box_color(unsigned int t) {
    Fl::set_box_color(static_cast<Fl_Color>(t));
}

void fl_static_own_colormap() {
    Fl::own_colormap();
}

void fl_static_foreground(unsigned int r, unsigned int g, unsigned int b) {
    Fl::foreground(r, g, b);
}

void fl_static_background(unsigned int r, unsigned int g, unsigned int b) {
    Fl::background(r, g, b);
}

void fl_static_background2(unsigned int r, unsigned int g, unsigned int b) {
    Fl::background2(r, g, b);
}

void fl_static_get_system_colors() {
    Fl::get_system_colors();
}

void fl_static_get_color3(unsigned int c, unsigned char &r, unsigned char &g, unsigned char &b, unsigned char &a) {
    Fl::get_color(c, r, g, b, a);
}

void fl_static_set_color3(unsigned int c, unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
    Fl::set_color(c, r, g, b, a);
}




const char * fl_static_get_font(int f) {
    return Fl::get_font(f);
}

const char * fl_static_get_font_name(int f) {
    return Fl::get_font_name(f);
}

void fl_static_set_font(int t, int f) {
    Fl::set_font(static_cast<Fl_Font>(t), static_cast<Fl_Font>(f));
}

void fl_static_set_font2(int t, char * s) {
    Fl::set_font(static_cast<Fl_Font>(t), s);
}

int fl_static_get_font_sizes(int f, int * &a) {
    return Fl::get_font_sizes(static_cast<Fl_Font>(f),a);
}

int fl_static_font_size_array_get(int * a, int i) {
    return a[i-1];
}

int fl_static_set_fonts() {
    return Fl::set_fonts();
}




int fl_static_box_dh(int b) {
    return Fl::box_dh(static_cast<Fl_Boxtype>(b));
}

int fl_static_box_dw(int b) {
    return Fl::box_dw(static_cast<Fl_Boxtype>(b));
}

int fl_static_box_dx(int b) {
    return Fl::box_dx(static_cast<Fl_Boxtype>(b));
}

int fl_static_box_dy(int b) {
    return Fl::box_dy(static_cast<Fl_Boxtype>(b));
}

void * fl_static_get_boxtype(int t) {
    return reinterpret_cast<void*>(Fl::get_boxtype(static_cast<Fl_Boxtype>(t)));
}

void fl_static_set_boxtype(int t, int f) {
    Fl::set_boxtype(static_cast<Fl_Boxtype>(t),static_cast<Fl_Boxtype>(f));
}

void fl_static_set_boxtype2(int t, void * f,
    unsigned char dx, unsigned char dy, unsigned char dw, unsigned char dh)
{
    Fl::set_boxtype(static_cast<Fl_Boxtype>(t), reinterpret_cast<Fl_Box_Draw_F*>(f), dx, dy, dw, dh);
}

int fl_static_draw_box_active() {
    return Fl::draw_box_active();
}




void fl_static_set_labeltype(int k, void * d, void * m) {
    Fl::set_labeltype(static_cast<Fl_Labeltype>(k),
        reinterpret_cast<Fl_Label_Draw_F*>(d), reinterpret_cast<Fl_Label_Measure_F*>(m));
}




void fl_static_copy(const char * t, int l, int k) {
    Fl::copy(t, l, k);
}

void fl_static_paste(void * r, int s) {
    Fl_Widget &ref = *static_cast<Fl_Widget*>(r);
    Fl::paste(ref, s);
}

void fl_static_selection(void * o, char * t, int l) {
    Fl_Widget &ref = *static_cast<Fl_Widget*>(o);
    Fl::selection(ref, t, l);
}

//  FLTK's drivers tell the kinds apart by pointer, not by text: on Wayland
//  always (fl_wayland_clipboard_dnd.cxx:51) and on X11 while this program owns
//  the clipboard (Fl_x.cxx:724-725).  So a kind given as text is replaced by
//  FLTK's own constant for it (FLTKAda-BUGS.md 38).
int fl_static_clipboard_contains(const char * k) {
    if (std::strcmp(k, Fl::clipboard_plain_text) == 0) {
        return Fl::clipboard_contains(Fl::clipboard_plain_text);
    } else if (std::strcmp(k, Fl::clipboard_image) == 0) {
        return Fl::clipboard_contains(Fl::clipboard_image);
    } else {
        return Fl::clipboard_contains(k);
    }
}




int fl_static_dnd() {
    return Fl::dnd();
}

int fl_static_get_dnd_text_ops() {
    return Fl::dnd_text_ops();
}

void fl_static_set_dnd_text_ops(int t) {
    Fl::dnd_text_ops(t);
}




void fl_static_enable_im() {
    Fl::enable_im();
}

void fl_static_disable_im() {
    Fl::disable_im();
}




void fl_static_default_atclose(void * w, void * u) {
    Fl::default_atclose(static_cast<Fl_Window*>(w), u);
}

void * fl_static_get_first_window() {
    return Fl::first_window();
}

void fl_static_set_first_window(void * w) {
    Fl::first_window(static_cast<Fl_Window*>(w));
}

void * fl_static_next_window(void * w) {
    return Fl::next_window(static_cast<Fl_Window*>(w));
}

void * fl_static_modal() {
    return Fl::modal();
}




void * fl_static_readqueue() {
    return Fl::readqueue();
}




const char * fl_static_get_scheme() {
    return Fl::scheme();
}

void fl_static_set_scheme(const char *n) {
    Fl::scheme(n);
}

int fl_static_is_scheme(const char *n) {
    return Fl::is_scheme(n);
}

void fl_static_reload_scheme() {
    //  this always returns 1 for some reason so we can ignore the return value
    Fl::reload_scheme();
}




int fl_static_get_option(int o) {
    return Fl::option(static_cast<Fl::Fl_Option>(o)) ? 1 : 0;
}

void fl_static_set_option(int o, int t) {
    Fl::option(static_cast<Fl::Fl_Option>(o), t!=0);
}

int fl_static_get_use_high_res_gl() {
    return Fl::use_high_res_GL();
}

void fl_static_set_use_high_res_gl(int v) {
    Fl::use_high_res_GL(v);
}




int fl_static_get_scrollbar_size() {
    return Fl::scrollbar_size();
}

void fl_static_set_scrollbar_size(int s) {
    Fl::scrollbar_size(s);
}


