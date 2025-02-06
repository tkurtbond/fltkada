

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Menu_Bar.H>
#include "c_fl_menu_bar.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Menu_Bar : public Fl_Menu_Bar {
public:
    using Fl_Menu_Bar::Fl_Menu_Bar;

    friend void fl_menu_bar_draw(MENUBAR m);
    friend int fl_menu_bar_handle(MENUBAR m, int e);

    void draw();
    int handle(int e);
};

void My_Menu_Bar::draw() {
    widget_draw_hook(this->user_data());
}

int My_Menu_Bar::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

MENUBAR new_fl_menu_bar(int x, int y, int w, int h, char* label) {
    My_Menu_Bar *m = new My_Menu_Bar(x, y, w, h, label);
    return m;
}

void free_fl_menu_bar(MENUBAR m) {
    if (fl_inside_callback) {
        fl_delete_widget(m);
    } else {
        delete static_cast<My_Menu_Bar*>(m);
    }
}




void fl_menu_bar_draw(MENUBAR m) {
    static_cast<My_Menu_Bar*>(m)->Fl_Menu_Bar::draw();
}

int fl_menu_bar_handle(MENUBAR m, int e) {
    return static_cast<My_Menu_Bar*>(m)->Fl_Menu_Bar::handle(e);
}


