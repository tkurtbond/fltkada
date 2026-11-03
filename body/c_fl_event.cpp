

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Window.H>
#include <FL/platform.H>
#include <string>
#include "c_fl_event.h"




void fl_event_add_handler(void * f) {
    Fl::add_handler(reinterpret_cast<Fl_Event_Handler>(f));
}

void fl_event_remove_handler(void * f) {
    Fl::remove_handler(reinterpret_cast<Fl_Event_Handler>(f));
}

void fl_event_add_system_handler(void * h, void * f) {
    Fl::add_system_handler(reinterpret_cast<Fl_System_Handler>(h), f);
}

void fl_event_remove_system_handler(void * h) {
    Fl::remove_system_handler(reinterpret_cast<Fl_System_Handler>(h));
}




void fl_event_set_dispatch(void * f) {
    Fl::event_dispatch(reinterpret_cast<Fl_Event_Dispatch>(f));
}

//  With no window shown, two events crash FLTK 1.4.5, since it calls through
//  Fl::first_window(), which is then 0.  A key no widget uses is tried as a
//  shortcut, and FL_SHORTCUT sends it to first_window() when the below-mouse
//  widget is in another window (Fl.cxx:1556-1557, pofltk 3).  FL_DND_LEAVE
//  reaches an Fl_Input below the mouse, which sets first_window()'s cursor
//  (Fl_Input.cxx, pofltk 53).  Neither can come from the system then, so
//  only a program that sends them itself gets here: a key goes to the focus
//  widget and its parents and no further, as Fl::handle_ tries it first, and
//  FL_DND_LEAVE is taken and does nothing.  Sets *r and returns true if it
//  dealt with the event.
static bool unshown_event(int e, int &r) {
    if (Fl::first_window() != 0) {
        return false;
    }
    switch (e) {
    case FL_KEYBOARD:
    case FL_SHORTCUT:
        Fl::e_number = e;
        r = 0;
        for (Fl_Widget *wi = Fl::grab() ? Fl::grab() : Fl::focus(); wi != 0; wi = wi->parent()) {
            if (wi->handle(e)) {
                r = 1;
                break;
            }
        }
        return true;
    case FL_DND_LEAVE:
        r = 1;
        return true;
    default:
        return false;
    }
}

//  A dispatch function the program set sees the event, and passes it on
//  through fl_event_handle.
int fl_event_handle_dispatch(int e, void * w) {
    int r;
    if (Fl::event_dispatch() == 0 && unshown_event(e, r)) {
        return r;
    }
    return Fl::handle(e, static_cast<Fl_Window*>(w));
}

int fl_event_handle(int e, void * w) {
    int r;
    if (unshown_event(e, r)) {
        return r;
    }
    return Fl::handle_(e, static_cast<Fl_Window*>(w));
}




void * fl_event_get_grab() {
    return Fl::grab();
}

//  Returns 0 for a window not shown.  On X11 Fl::grab then grabs the pointer
//  for Fl::first_window(), and crashes in XGrabPointer if there is none
//  (Fl_X11_Screen_Driver.cxx:460, pofltk 129).  A null w releases the grab.
int fl_event_set_grab(void * w) {
    if (w != 0 && !static_cast<Fl_Window*>(w)->shown()) {
        return 0;
    }
    Fl::grab(static_cast<Fl_Window*>(w));
    return 1;
}

void * fl_event_get_pushed() {
    return Fl::pushed();
}

void fl_event_set_pushed(void * w) {
    Fl::pushed(static_cast<Fl_Widget*>(w));
}

void * fl_event_get_belowmouse() {
    return Fl::belowmouse();
}

void fl_event_set_belowmouse(void * w) {
    Fl::belowmouse(static_cast<Fl_Widget*>(w));
}

void * fl_event_get_focus() {
    return Fl::focus();
}

//  As fl_widget_take_focus (pofltk 4).
void fl_event_set_focus(void * w) {
    fl_open_display();
    Fl::focus(static_cast<Fl_Widget*>(w));
}

int fl_event_get_visible_focus() {
    return Fl::visible_focus();
}

void fl_event_set_visible_focus(int f) {
    Fl::visible_focus(f);
}




const char * fl_event_clipboard_text() {
    return static_cast<const char*>(Fl::event_clipboard());
}

const char * fl_event_clipboard_type() {
    return Fl::event_clipboard_type();
}




int fl_event_compose(int &d) {
    return Fl::compose(d);
}

void fl_event_compose_reset() {
    Fl::compose_reset();
}

const char * fl_event_text() {
    return Fl::event_text();
}

int fl_event_length() {
    return Fl::event_length();
}

void fl_event_set_text(const char * t, int len) {
    static std::string buffer;
    buffer.assign(t, len);
    Fl::e_text = const_cast<char*>(buffer.c_str());
    Fl::e_length = len;
}

int fl_event_test_shortcut(unsigned int s) {
    return Fl::test_shortcut(static_cast<Fl_Shortcut>(s));
}




int fl_event_get() {
    return Fl::event();
}

int fl_event_state() {
    return Fl::event_state();
}

int fl_event_check_state(int s) {
    return Fl::event_state(s);
}




int fl_event_x() {
    return Fl::event_x();
}

int fl_event_x_root() {
    return Fl::event_x_root();
}

int fl_event_y() {
    return Fl::event_y();
}

int fl_event_y_root() {
    return Fl::event_y_root();
}

int fl_event_dx() {
    return Fl::event_dx();
}

int fl_event_dy() {
    return Fl::event_dy();
}

void fl_event_get_mouse(int &x, int &y) {
    Fl::get_mouse(x, y);
}

int fl_event_is_click() {
    return Fl::event_is_click();
}

void fl_event_set_click(int c) {
    Fl::event_is_click(c);
}

int fl_event_get_clicks() {
    return Fl::event_clicks();
}

void fl_event_set_clicks(int c) {
    Fl::event_clicks(c);
}

int fl_event_button() {
    return Fl::event_button();
}

int fl_event_button1() {
    return Fl::event_button1();
}

int fl_event_button2() {
    return Fl::event_button2();
}

int fl_event_button3() {
    return Fl::event_button3();
}

int fl_event_button4() {
#if FL_API_VERSION >= 10310
    return Fl::event_button4();
#else
    return 0;
#endif
}

int fl_event_button5() {
#if FL_API_VERSION >= 10310
    return Fl::event_button5();
#else
    return 0;
#endif
}

int fl_event_buttons() {
    return Fl::event_buttons();
}

int fl_event_inside2(void * c) {
    return Fl::event_inside(static_cast<Fl_Widget*>(c));
}

int fl_event_inside(int x, int y, int w, int h) {
    return Fl::event_inside(x, y, w, h);
}




int fl_event_key() {
    return Fl::event_key();
}

int fl_event_original_key() {
    return Fl::event_original_key();
}

void fl_event_set_key(int k) {
    Fl::e_keysym = k;
}

int fl_event_key_during(int k) {
    return Fl::event_key(k);
}

int fl_event_get_key(int k) {
    return Fl::get_key(k);
}

int fl_event_ctrl() {
    return Fl::event_ctrl();
}

int fl_event_alt() {
    return Fl::event_alt();
}

int fl_event_command() {
    return Fl::event_command();
}

int fl_event_shift() {
    return Fl::event_shift();
}


