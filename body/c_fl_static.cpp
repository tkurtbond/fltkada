

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl.H>
#include <FL/Fl_Scheme.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Window.H>
#include <FL/platform.H>
#include <cstring>
#include "c_fl_static.h"
#include "c_fl_widget.h"




void fl_static_box_draw_marshal(void * f, int x, int y, int w, int h, unsigned int t) {
    reinterpret_cast<Fl_Box_Draw_F*>(f)(x, y, w, h, static_cast<Fl_Color>(t));
}




const char * const fl_help_usage_string_ptr = Fl::help;




void fl_static_open_display() {
    fl_open_display();
}




int fl_static_get_program_should_quit() {
    return Fl::program_should_quit();
}

void fl_static_set_program_should_quit(int q) {
    Fl::program_should_quit(q);
}

void fl_static_hide_all_windows() {
    Fl::hide_all_windows();
}

void fl_static_run_checks() {
    Fl::run_checks();
}

void fl_static_run_idle() {
    Fl::run_idle();
}

//  The handler for a window with FLTK's default callback, or FLTK's own if
//  h is null.
void fl_static_set_atclose(void * h) {
    Fl::set_atclose(h == 0 ? Fl::default_atclose : reinterpret_cast<Fl_Atclose_Handler>(h));
}




//  Fl_Timestamp's sec is a time_t, carried as a long long, so it fits on
//  every host.
void fl_static_now(double o, long long &s, int &u) {
    Fl_Timestamp t = Fl::now(o);
    s = static_cast<long long>(t.sec);
    u = t.usec;
}

static Fl_Timestamp stamp(long long s, int u) {
    Fl_Timestamp t;
    t.sec = static_cast<time_t>(s);
    t.usec = u;
    return t;
}

double fl_static_seconds_between(long long s1, int u1, long long s2, int u2) {
    Fl_Timestamp t1 = stamp(s1, u1), t2 = stamp(s2, u2);
    return Fl::seconds_between(t1, t2);
}

long fl_static_ticks_between(long long s1, int u1, long long s2, int u2) {
    Fl_Timestamp t1 = stamp(s1, u1), t2 = stamp(s2, u2);
    return Fl::ticks_between(t1, t2);
}

//  True if the display, which this opens, is Wayland's.  An FLTK built
//  without Wayland has no fl_wl_display.  From pofltk.
static bool wayland() {
    fl_open_display();
#if defined(FLTK_USE_WAYLAND)
    return fl_wl_display() != 0;
#else
    return false;
#endif
}




int fl_static_arg(int c, void * v, int &i) {
    return Fl::arg(c, static_cast<char**>(v), i);
}

void fl_static_args(int c, void * v) {
    Fl::args(c, static_cast<char**>(v));
}

//  Fl::args returns 0 when it stops at an option nobody knows, or one
//  missing its value, but only until a call has stopped at a word that
//  isn't an option: Fl::arg then sets the file-static return_i
//  (Fl_arg.cxx:141), nothing clears it, and Fl::args returns i instead
//  (Fl_arg.cxx:281) (pofltk 57).  So, as pofltk's ofl_args does, this
//  decides from the word it stopped at, with Fl::arg's test of a word.
int fl_static_args2(int c, void * v, int &i, void * h) {
    char ** argv = static_cast<char**>(v);
    int result = Fl::args(c, argv, i, reinterpret_cast<Fl_Args_Handler>(h));
    const char * s = i < c ? argv[i] : 0;
    if (s != 0 && s[0] == '-' && s[1] != '\0' && s[1] != '-') {
        return 0;
    }
    return result;
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

//  The calls below that open the display first crash FLTK 1.4.5 when they
//  come before it is open (pofltk 4, 49, 131), on X11, on Wayland, or both.
//  fl_open_display does nothing once it is open.

void fl_static_set_box_color(unsigned int t) {
    fl_open_display();
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




//  FLTK's font table holds its 16 built-in fonts until Fl::set_font or
//  Fl::set_fonts grows it (fl_set_font.cxx:45-68), so FL_FREE_FONT is past
//  its end, and Fl::get_font reads garbage (pofltk 130).  The first time a
//  font from FL_FREE_FONT on is used, this grows the table, with
//  FL_FREE_FONT empty, as a slot the table grows by is.  A font is set to
//  NULL safely only while its slot is empty
//  (Fl_Cairo_Graphics_Driver.cxx:1157-1158), so Fl::set_fonts, which fills
//  it, calls this first.  FLTK itself calls neither.  Growing the table
//  opens the display (Fl_Cairo_Graphics_Driver.cxx:1269).
void fl_static_grow_fonts(int f) {
    static bool grown = false;
    if (!grown && f >= FL_FREE_FONT) {
        grown = true;
        Fl::set_font(FL_FREE_FONT, static_cast<const char *>(0));
    }
}

//  An empty slot's name is NULL, and Fl_Cairo_Graphics_Driver::get_font_name
//  copies it before it tests it (Fl_Cairo_Graphics_Driver.cxx:1176).

const char * fl_static_get_font(int f) {
    fl_static_grow_fonts(f);
    const char * n = Fl::get_font(f);
    return n ? n : "";
}

const char * fl_static_get_font_name(int f) {
    fl_static_grow_fonts(f);
    const char * n = Fl::get_font(f);
    if (n == 0 || *n == 0) {
        return "";
    }
    return Fl::get_font_name(f);
}

void fl_static_set_font(int t, int f) {
    fl_static_grow_fonts(t);
    fl_static_grow_fonts(f);
    Fl::set_font(static_cast<Fl_Font>(t), static_cast<Fl_Font>(f));
}

void fl_static_set_font2(int t, char * s) {
    fl_static_grow_fonts(t);
    Fl::set_font(static_cast<Fl_Font>(t), s);
}

int fl_static_get_font_sizes(int f, int * &a) {
    fl_static_grow_fonts(f);
    return Fl::get_font_sizes(static_cast<Fl_Font>(f),a);
}

int fl_static_font_size_array_get(int * a, int i) {
    return a[i-1];
}

int fl_static_set_fonts() {
    fl_static_grow_fonts(FL_FREE_FONT);
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
    fl_open_display();
    Fl::copy(t, l, k);
}

#if defined(FLTK_USE_X11)
extern char fl_i_own_selection[2];
#endif

//  Under X11, another program's data is asked for through Fl::first_window
//  (Fl_x.cxx).  With no window shown FLTK asks with window 0 anyway, and the
//  X server's BadWindow error is printed, so the paste does nothing, as it
//  would have, unless this program owns what is pasted (pofltk 49).
void fl_static_paste(void * r, int s) {
#if defined(FLTK_USE_X11)
    if (!wayland() && Fl::first_window() == 0 && !fl_i_own_selection[s ? 1 : 0]) {
        return;
    }
#else
    fl_open_display();
#endif
    Fl_Widget &ref = *static_cast<Fl_Widget*>(r);
    Fl::paste(ref, s);
}

void fl_static_paste_image(void * r) {
#if defined(FLTK_USE_X11)
    if (!wayland() && Fl::first_window() == 0 && !fl_i_own_selection[1]) {
        return;
    }
#else
    fl_open_display();
#endif
    Fl_Widget &ref = *static_cast<Fl_Widget*>(r);
    Fl::paste(ref, 1, Fl::clipboard_image);
}

void fl_static_selection(void * o, char * t, int l) {
    fl_open_display();
    Fl_Widget &ref = *static_cast<Fl_Widget*>(o);
    Fl::selection(ref, t, l);
}

//  FLTK's drivers tell the kinds apart by pointer, not by text: on Wayland
//  always (fl_wayland_clipboard_dnd.cxx:51) and on X11 while this program owns
//  the clipboard (Fl_x.cxx:724-725).  So a kind given as text is replaced by
//  FLTK's own constant for it (FLTKAda-BUGS.md 38).
int fl_static_clipboard_contains(const char * k) {
    fl_open_display();
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
    fl_open_display();
    Fl::enable_im();
}

void fl_static_disable_im() {
    fl_open_display();
    Fl::disable_im();
}




void fl_static_default_atclose(void * w, void * u) {
    Fl::default_atclose(static_cast<Fl_Window*>(w), u);
}

//  The first window shown from w on with an Ada object, or 0.  A window
//  FLTK made, such as a file chooser's, is skipped, as in pofltk.
static void * ada_window(Fl_Window * w) {
    while (w != 0 && fl_widget_get_user_data(w) == 0) {
        w = Fl::next_window(w);
    }
    return w;
}

void * fl_static_get_first_window() {
    return ada_window(Fl::first_window());
}

void fl_static_set_first_window(void * w) {
    Fl::first_window(static_cast<Fl_Window*>(w));
}

//  Fl::next_window of a window not shown is an Fl::error.
void * fl_static_next_window(void * w) {
    Fl_Window * win = static_cast<Fl_Window*>(w);
    return win->shown() ? ada_window(Fl::next_window(win)) : 0;
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

int fl_static_scheme_count() {
    return Fl_Scheme::num_schemes();
}

//  FLTK keeps the names; the list moves when a name is added.
const char * fl_static_scheme_name(int i) {
    return Fl_Scheme::names()[i];
}

//  FLTK copies the name (Fl_Scheme.cxx:155).
int fl_static_add_scheme_name(const char * n) {
    return Fl_Scheme::add_scheme_name(n);
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




int fl_static_get_contrast_mode() {
    return fl_contrast_mode();
}

void fl_static_set_contrast_mode(int m) {
    fl_contrast_mode(m);
}

int fl_static_get_contrast_level() {
    return fl_contrast_level();
}

void fl_static_set_contrast_level(int l) {
    fl_contrast_level(l);
}

void fl_static_set_contrast_function(void * f) {
    fl_contrast_function(reinterpret_cast<Fl_Contrast_Function*>(f));
}

//  The X11 driver opens the display itself to look up a name
//  (Fl_X11_Screen_Driver.cxx:511-513); Wayland's reads hexadecimal alone
//  (pofltk 47).
int fl_static_parse_color(const char * n, unsigned char &r,
    unsigned char &g, unsigned char &b)
{
    return fl_parse_color(n, r, g, b);
}




int fl_static_get_box_border_radius_max() {
    return Fl::box_border_radius_max();
}

void fl_static_set_box_border_radius_max(int r) {
    Fl::box_border_radius_max(r);
}

int fl_static_get_box_shadow_width() {
    return Fl::box_shadow_width();
}

void fl_static_set_box_shadow_width(int w) {
    Fl::box_shadow_width(w);
}

int fl_static_get_menu_linespacing() {
    return Fl::menu_linespacing();
}

void fl_static_set_menu_linespacing(int h) {
    Fl::menu_linespacing(h);
}




int fl_static_callback_reason() {
    return Fl::callback_reason();
}




void * fl_static_get_selection_owner() {
    return Fl::selection_owner();
}

void fl_static_set_selection_owner(void * w) {
    Fl::selection_owner(static_cast<Fl_Widget*>(w));
}

int fl_static_get_selection_to_clipboard() {
    return Fl::selection_to_clipboard();
}

void fl_static_set_selection_to_clipboard(int m) {
    Fl::selection_to_clipboard(m);
}


