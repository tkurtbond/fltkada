

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl.H>
#include <FL/Fl_Menu_Button.H>
#include <FL/Fl_Window.H>
#include "c_fl_menu_button.h"
#include "c_fl_menuitem.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Telprot stopover

extern "C" void menu_button_extra_init_hook
    (void * aobj, int x, int y, int w, int h, const char * l);
void fl_menu_button_extra_init(void * adaobj, int x, int y, int w, int h, const char * label) {
    menu_button_extra_init_hook(adaobj, x, y, w, h, label);
}




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Menu_Button : public Ada_Resizing<Fl_Menu_Button> {
public:
    using Ada_Resizing<Fl_Menu_Button>::Ada_Resizing;

    friend void fl_menu_button_draw(MENUBUTTON m);
    friend int fl_menu_button_handle(MENUBUTTON m, int e);

    void draw();
    int handle(int e);
};

void My_Menu_Button::draw() {
    widget_draw_hook(this->user_data());
}

int My_Menu_Button::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

MENUBUTTON new_fl_menu_button(int x, int y, int w, int h, char* label) {
    My_Menu_Button *m = new My_Menu_Button(x, y, w, h, label);
    return m;
}

void free_fl_menu_button(MENUBUTTON m) {
    plain_menu(static_cast<Fl_Menu_*>(m));
    if (fl_inside_callback) {
        fl_delete_widget(m);
    } else {
        delete static_cast<My_Menu_Button*>(m);
    }
}




//  A menu popped up over a window not yet on the screen ends the program
//  under Wayland: "Fatal error no 1 in Wayland protocol: xdg_surface"
//  (pofltk 28).  FLTK makes the pop-up against the menu widget's top window,
//  or the first window if the widget is in none (Fl_Menu.cxx:987-996), and
//  waits for the pop-up's own expose but not that one's.  This waits for it
//  first, which returns at once once it is there, and on X11.
static void wait_for_parent(Fl_Widget * w) {
    Fl_Window * parent = (w != 0 && w->window() != 0) ? w->top_window() : Fl::first_window();
    if (parent != 0 && parent->shown()) {
        parent->wait_for_expose();
    }
}

const void * fl_menu_button_popup(MENUBUTTON m) {
    wait_for_parent(static_cast<Fl_Menu_Button*>(m));
    return static_cast<Fl_Menu_Button*>(m)->popup();
}




void fl_menu_button_draw(MENUBUTTON m) {
    static_cast<My_Menu_Button*>(m)->Fl_Menu_Button::draw();
}

int fl_menu_button_handle(MENUBUTTON m, int e) {
    return static_cast<My_Menu_Button*>(m)->Fl_Menu_Button::handle(e);
}


