

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


//  The C++ part of FLTK.Probe, for the unit tests only: capturing a widget's
//  drawing as pixels, and sending events as if from the user.  Ported from
//  pofltk's test/Probe.cpp.  tests_unit.gpr compiles it; the library doesn't.


#include <FL/Fl.H>
#include <FL/fl_config.h>
#include <FL/platform.H>
#include <FL/Fl_Browser.H>
#include <FL/Fl_Button.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Menu_.H>
#include <FL/Fl_Image_Surface.H>
#include <FL/Fl_RGB_Image.H>
#include <FL/Fl_Shared_Image.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Window.H>
#include <FL/fl_draw.H>
#if FLTK_USE_WAYLAND
#include <FL/wayland.H>
#endif
#if FLTK_USE_X11
#include <FL/x11.H>
#include <dlfcn.h>
#endif
#include <stdlib.h>
#include <string.h>
#include <sys/resource.h>
#include <unistd.h>




//  Internals

namespace {

Fl_RGB_Image *shot = 0;     //  the last capture, or 0
char key_text[64];          //  the text of the last key event sent

Fl_Widget * widget(void * w) {
    return static_cast<Fl_Widget*>(w);
}

void set_key(int key, int state, const char * s) {
    strncpy(key_text, s, sizeof key_text - 1);
    key_text[sizeof key_text - 1] = 0;
    Fl::e_keysym = Fl::e_original_keysym = key;
    Fl::e_state = state;
    Fl::e_text = key_text;
    Fl::e_length = static_cast<int>(strlen(key_text));
}

}




//  Not in a header: what the window system's code calls.

extern void fl_trigger_clipboard_notify(int source);




//  Pixels

extern "C" int fl_probe_capture(void * w) {
    Fl_Widget *wd = widget(w);
    delete shot;
    shot = 0;
    Fl_Image_Surface surface(wd->w(), wd->h());
    Fl_Surface_Device::push_current(&surface);
    fl_color(FL_WHITE);
    fl_rectf(0, 0, wd->w(), wd->h());
    surface.draw(wd, 0, 0);
    shot = surface.image();
    Fl_Surface_Device::pop_current();
    return shot != 0 && shot->w() == wd->w() && shot->h() == wd->h();
}

extern "C" int fl_probe_pixel(int x, int y) {
    if (shot == 0 || x < 0 || y < 0 || x >= shot->w() || y >= shot->h()) {
        return -1;
    }
    int ld = shot->ld() ? shot->ld() : shot->w() * shot->d();
    const uchar *p = reinterpret_cast<const uchar*>(shot->data()[0]) + y * ld + x * shot->d();
    if (shot->d() < 3) {
        return p[0] << 16 | p[0] << 8 | p[0];
    }
    return p[0] << 16 | p[1] << 8 | p[2];
}

extern "C" void fl_probe_release() {
    delete shot;
    shot = 0;
}

extern "C" int fl_probe_shown_pixel(void * w, int x, int y) {
    Fl_Window *win = widget(w)->as_window();
    uchar p[3] = {0, 0, 0};
    win->make_current();
    fl_read_image(p, x, y, 1, 1);
    return p[0] << 16 | p[1] << 8 | p[2];
}




//  Events

extern "C" int fl_probe_mouse(void * win, int event, int x, int y,
        int button, int state, int clicks) {
    Fl_Widget *w = widget(win);
    Fl::e_x = x;
    Fl::e_y = y;
    Fl::e_x_root = w->x() + x;
    Fl::e_y_root = w->y() + y;
    Fl::e_keysym = FL_Button + button;
    Fl::e_state = state;
    Fl::e_clicks = clicks;
    Fl::e_is_click = 1;
    return Fl::handle(event, w->as_window());
}

extern "C" int fl_probe_wheel(void * win, int x, int y, int dx, int dy) {
    Fl_Widget *w = widget(win);
    Fl::e_x = x;
    Fl::e_y = y;
    Fl::e_x_root = w->x() + x;
    Fl::e_y_root = w->y() + y;
    Fl::e_dx = dx;
    Fl::e_dy = dy;
    return Fl::handle(FL_MOUSEWHEEL, w->as_window());
}

//  Sent to the focus widget directly, not by Fl::handle: FLTK 1.4.5 then
//  offers a key the focus doesn't use as a shortcut, which crashes in a
//  window never shown (pofltk 3).
extern "C" int fl_probe_key(int event, int key, int state, const char * s) {
    Fl_Widget *focus = Fl::focus();
    if (focus == 0) {
        return 0;
    }
    char *old_text = Fl::e_text;
    int old_length = Fl::e_length;
    set_key(key, state, s);
    Fl::e_number = event;
    int r = focus->handle(event);
    Fl::e_text = old_text;
    Fl::e_length = old_length;
    return r;
}

extern "C" int fl_probe_shortcut(void * win, int key, int state, const char * s) {
    char *old_text = Fl::e_text;
    int old_length = Fl::e_length;
    set_key(key, state, s);
    Fl::e_number = FL_SHORTCUT;
    int r = widget(win)->handle(FL_SHORTCUT);
    Fl::e_text = old_text;
    Fl::e_length = old_length;
    return r;
}

extern "C" int fl_probe_handle_key(void * win, int event, int key, int state, const char * s) {
    char *old_text = Fl::e_text;
    int old_length = Fl::e_length;
    set_key(key, state, s);
    int r = Fl::handle(event, widget(win)->as_window());
    Fl::e_text = old_text;
    Fl::e_length = old_length;
    return r;
}

extern "C" void fl_probe_set_key(int key, const char * s) {
    set_key(key, Fl::e_state, s);
}




//  Dialogs

extern "C" int fl_probe_modal() {
    Fl_Window *modal = Fl::modal();
    return modal != 0 && modal->shown();
}

extern "C" int fl_probe_grabbed() {
    return Fl::grab() != 0;
}

//  How many windows FLTK has shown, its own (a tooltip's, a menu's) too.
extern "C" int fl_probe_shown_windows() {
    int n = 0;
    for (Fl_Window *w = Fl::first_window(); w != 0; w = Fl::next_window(w)) {
        n++;
    }
    return n;
}

//  The screen rectangle of the window FLTK grabs events to (an open menu)
//  in r; 0 if there is none.  From pofltk's Probe.
extern "C" int fl_probe_grab(int * r) {
    Fl_Window *g = Fl::grab();
    if (g == 0) {
        return 0;
    }
    r[0] = g->x();
    r[1] = g->y();
    r[2] = g->w();
    r[3] = g->h();
    return 1;
}

extern "C" const char * fl_probe_modal_title() {
    Fl_Window *modal = Fl::modal();
    if (modal == 0 || modal->label() == 0) {
        return "";
    }
    return modal->label();
}

extern "C" int fl_probe_modal_h() {
    Fl_Window *modal = Fl::modal();
    return modal == 0 ? 0 : modal->h();
}

extern "C" int fl_probe_modal_x() {
    Fl_Window *modal = Fl::modal();
    return modal == 0 ? 0 : modal->x();
}

extern "C" int fl_probe_modal_y() {
    Fl_Window *modal = Fl::modal();
    return modal == 0 ? 0 : modal->y();
}

extern "C" const char * fl_probe_modal_icon() {
    Fl_Window *modal = Fl::modal();
    if (modal == 0) {
        return "";
    }
    //  Fl_Message's icon is the window's third child, after the message
    //  box and the input (Fl_Message.cxx:150-162).
    if (modal->children() < 3 || modal->child(2)->label() == 0) {
        return "";
    }
    return modal->child(2)->label();
}

extern "C" int fl_probe_modal_key(int key, int state, const char * s) {
    Fl_Window *modal = Fl::modal();
    if (modal == 0) {
        return 0;
    }
    return fl_probe_handle_key(modal, FL_KEYDOWN, key, state, s);
}

//  The window FLTK made for a pop-up menu, which has the grab, given the
//  key as the window system gives it.
extern "C" int fl_probe_grab_key(int key, int state, const char * s) {
    Fl_Window *grab = Fl::grab();
    if (grab == 0) {
        return 0;
    }
    return fl_probe_handle_key(grab, FL_KEYDOWN, key, state, s);
}

//  What Fl::handle does with an Escape no widget takes (Fl.cxx:1567-1570).
extern "C" int fl_probe_close_modal() {
    Fl_Window *modal = Fl::modal();
    if (modal == 0) {
        return 0;
    }
    modal->do_callback(FL_REASON_CANCELLED);
    return 1;
}

//  What the window system's close button does: Fl::handle (FL_CLOSE),
//  which sets Fl::event (Fl.cxx:1393-1396).
extern "C" int fl_probe_close_modal_window() {
    Fl_Window *modal = Fl::modal();
    if (modal == 0) {
        return 0;
    }
    return Fl::handle(FL_CLOSE, modal);
}

static int has_text(Fl_Widget * w, const char * t) {
    if ((w->label() != 0 && strcmp(w->label(), t) == 0)
        || (w->tooltip() != 0 && strcmp(w->tooltip(), t) == 0)) {
        return 1;
    }
    Fl_Group * g = w->as_group();
    if (g != 0) {
        for (int i = 0; i < g->children(); i++) {
            if (has_text(g->child(i), t)) {
                return 1;
            }
        }
    }
    return 0;
}

//  Whether a widget in a shown window has t as its label or tooltip.
extern "C" int fl_probe_has_label(const char * t) {
    for (Fl_Window * w = Fl::first_window(); w != 0; w = Fl::next_window(w)) {
        if (has_text(w, t)) {
            return 1;
        }
    }
    return 0;
}

//  A shown window's title as the X server has it (WM_NAME, which
//  Fl_x.cxx:3208-3220 sets), copied to buf; 0 if not on X11 or not shown.
//  XFetchName and XFree are found with dlsym, since libX11 is loaded by FLTK
//  but not on the tests' link line.
extern "C" int fl_probe_x11_title(void * w, char * buf, int n) {
    buf[0] = 0;
#if FLTK_USE_X11
    Display *d = fl_x11_display();
    Window x = d == 0 ? 0 : fl_x11_xid(static_cast<Fl_Window*>(w));
    if (x == 0) {
        return 0;
    }
    typedef int (*Fetch)(Display *, Window, char **);
    typedef int (*Free)(void *);
    Fetch fetch = reinterpret_cast<Fetch>(dlsym(RTLD_DEFAULT, "XFetchName"));
    Free xfree = reinterpret_cast<Free>(dlsym(RTLD_DEFAULT, "XFree"));
    char *name = 0;
    if (fetch == 0 || xfree == 0 || fetch(d, x, &name) == 0 || name == 0) {
        return 0;
    }
    strncpy(buf, name, n - 1);
    buf[n - 1] = 0;
    xfree(name);
    return 1;
#else
    (void) w;
    (void) n;
    return 0;
#endif
}

//  The number of 32-bit words in shown window w's _NET_WM_ICON property, the
//  icons FLTK gave the window manager:  for each, its width, its height and
//  its pixels.  -1 if not on X11 or not shown.  From pofltk's Probe.
extern "C" int fl_probe_icon_words(void * w) {
#if FLTK_USE_X11
    Display *d = fl_x11_display();
    Window x = d == 0 ? 0 : fl_x11_xid(static_cast<Fl_Window*>(w));
    if (x == 0) {
        return -1;
    }
    typedef Atom (*Intern)(Display *, const char *, Bool);
    typedef int (*Get)(Display *, Window, Atom, long, long, Bool, Atom, Atom *,
        int *, unsigned long *, unsigned long *, unsigned char **);
    typedef int (*Free)(void *);
    Intern intern = reinterpret_cast<Intern>(dlsym(RTLD_DEFAULT, "XInternAtom"));
    Get get = reinterpret_cast<Get>(dlsym(RTLD_DEFAULT, "XGetWindowProperty"));
    Free xfree = reinterpret_cast<Free>(dlsym(RTLD_DEFAULT, "XFree"));
    if (intern == 0 || get == 0 || xfree == 0) {
        return -1;
    }
    Atom type;
    int format;
    unsigned long n, after;
    unsigned char *data = 0;
    if (get(d, x, intern(d, "_NET_WM_ICON", False), 0, 1 << 20, False,
            AnyPropertyType, &type, &format, &n, &after, &data) != Success) {
        return -1;
    }
    if (data) {
        xfree(data);
    }
    return static_cast<int>(n);
#else
    (void) w;
    return -1;
#endif
}

static Fl_Widget * labelled(Fl_Widget * w, const char * t) {
    if (w->label() != 0 && strcmp(w->label(), t) == 0) {
        return w;
    }
    Fl_Group * g = w->as_group();
    if (g != 0) {
        for (int i = 0; i < g->children(); i++) {
            Fl_Widget * found = labelled(g->child(i), t);
            if (found != 0) {
                return found;
            }
        }
    }
    return 0;
}

//  The widget labelled t in the modal window, not the window itself, whose
//  title may be the same (FLTK's print panel and its Print button).
static Fl_Widget * in_modal(const char * t) {
    Fl_Window *modal = Fl::modal();
    if (modal == 0) {
        return 0;
    }
    for (int i = 0; i < modal->children(); i++) {
        Fl_Widget * found = labelled(modal->child(i), t);
        if (found != 0) {
            return found;
        }
    }
    return 0;
}

//  The widget labelled t in the modal window has its callback done, as a
//  click on a button does; 0 if there is none.
extern "C" int fl_probe_press_in_modal(const char * t) {
    Fl_Widget *w = in_modal(t);
    if (w == 0) {
        return 0;
    }
    w->do_callback();
    return 1;
}

//  The menu (a choice) labelled t in the modal window has item n, counted
//  from 0, chosen and its callback done; 0 if there is no such menu or item.
extern "C" int fl_probe_choose_in_modal(const char * t, int n) {
    Fl_Menu_ *m = dynamic_cast<Fl_Menu_*>(in_modal(t));
    if (m == 0 || n < 0 || n >= m->size() - 1) {
        return 0;
    }
    m->value(n);
    if (m->value() != n) {
        return 0;
    }
    m->do_callback();
    return 1;
}

//  The text of the item chosen in the menu labelled t in the modal window,
//  or "" if there is none.
extern "C" const char * fl_probe_chosen_in_modal(const char * t) {
    Fl_Menu_ *m = dynamic_cast<Fl_Menu_*>(in_modal(t));
    const char * text = m == 0 ? 0 : m->text();
    return text == 0 ? "" : text;
}

//  With on, this process can start no other (RLIMIT_NPROC, which counts the
//  user's processes), so fork and popen fail with EAGAIN; with on 0, it can
//  again.  0 if the limit couldn't be set.
//  A window, and a button in it, that FLTK made with no Ada object, for
//  FLTK.Events' Get_ and Has_ functions to meet (FLTKAda-BUGS.md 44).
//  What: 0 grab the window, 1 push the button, 2 put it below the mouse,
//  3 focus it.
static Fl_Window * foreign_window = 0;
static Fl_Button * foreign_button = 0;

extern "C" void fl_probe_foreign_show() {
    if (foreign_window == 0) {
        foreign_window = new Fl_Window(120, 60, "foreign");
        foreign_button = new Fl_Button(10, 10, 100, 40, "foreign");
        foreign_window->end();
    }
    foreign_window->show();
    foreign_window->wait_for_expose();
}

extern "C" void fl_probe_foreign_take(int what) {
    switch (what) {
    case 0: Fl::grab(foreign_window); break;
    case 1: Fl::pushed(foreign_button); break;
    case 2: Fl::belowmouse(foreign_button); break;
    case 3: Fl::focus(foreign_button); break;
    }
}

extern "C" void fl_probe_foreign_release() {
    Fl::grab(0);
    Fl::pushed(0);
    Fl::belowmouse(0);
    Fl::focus(0);
}

extern "C" void fl_probe_foreign_delete() {
    delete foreign_window;
    foreign_window = 0;
    foreign_button = 0;
}

extern "C" int fl_probe_limit_processes(int on) {
    static struct rlimit saved;
    static int limited = 0;
    if (on != 0 && limited == 0) {
        struct rlimit none;
        if (getrlimit(RLIMIT_NPROC, &saved) != 0) {
            return 0;
        }
        none.rlim_cur = 1;
        none.rlim_max = saved.rlim_max;
        if (setrlimit(RLIMIT_NPROC, &none) != 0) {
            return 0;
        }
        limited = 1;
    } else if (on == 0 && limited != 0) {
        if (setrlimit(RLIMIT_NPROC, &saved) != 0) {
            return 0;
        }
        limited = 0;
    }
    return 1;
}

//  Whether Fl_Printer uses GTK's dialog or FLTK's own print panel.  FLTKAda's
//  Option type has no Printer_Uses_GTK.  FLTK reads the option once, when the
//  first Fl_Printer is made (Fl_Posix_Printer_Driver.cxx:270).
extern "C" void fl_probe_printer_uses_gtk(int on) {
    Fl::option(Fl::OPTION_PRINTER_USES_GTK, on != 0);
}




//  This FLTK

extern "C" int fl_probe_configured(int feature) {
    switch (feature) {
#ifdef FLTK_USE_SVG
    case 0: return 1;
#endif
#if FLTK_USE_WAYLAND
    case 1: return 1;
#endif
#if FLTK_USE_X11
    case 2: return 1;
#endif
#if FLTK_HAVE_CAIRO
    case 3: return 1;
#endif
#if FLTK_HAVE_FORMS
    case 4: return 1;
#endif
#if FLTK_USE_CAIRO
    case 5: return 1;
#endif
    default: return 0;
    }
}

extern "C" int fl_probe_on_wayland() {
    fl_open_display();
#if FLTK_USE_WAYLAND
    return fl_wl_display() != 0;
#else
    return 0;
#endif
}

extern "C" int fl_probe_shared_width(const char * name) {
    Fl_Shared_Image *s = Fl_Shared_Image::get(name);
    if (s == 0) {
        return 0;
    }
    int w = s->w();
    s->release();
    return w;
}

//  The column widths FLTK has, up to the 0 that ends them, at most n of
//  them written; how many there are.
extern "C" int fl_probe_column_widths(void * b, int * out, int n) {
    const int *w = static_cast<Fl_Browser*>(widget(b))->column_widths();
    int count = 0;
    while (w[count] != 0) {
        if (count < n) {
            out[count] = w[count];
        }
        count++;
    }
    return count;
}

extern "C" void fl_probe_clipboard_notice(int source) {
    fl_trigger_clipboard_notify(source);
}




//  The process

extern "C" int fl_probe_pipe(int * fds) {
    return pipe(fds) == 0;
}

extern "C" int fl_probe_write(int fd, const char * s, int n) {
    return static_cast<int>(write(fd, s, n));
}

extern "C" int fl_probe_read(int fd, char * buf, int n) {
    return static_cast<int>(read(fd, buf, n));
}

extern "C" void fl_probe_close(int fd) {
    close(fd);
}

extern "C" void fl_probe_setenv(const char * name, const char * value) {
    setenv(name, value, 1);
}

