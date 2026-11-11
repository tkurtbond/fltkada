

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Scroll.H>
#include "c_fl_scroll.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Telprot stopover

extern "C" void scroll_extra_init_hook(void * aobj, int x, int y, int w, int h, const char * l);
void fl_scroll_extra_init(void * adaobj, int x, int y, int w, int h, const char * label) {
    scroll_extra_init_hook(adaobj, x, y, w, h, label);
}




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Non-friend protected access

class Friend_Scroll : Fl_Scroll {
public:
    using Fl_Scroll::bbox;
    using Fl_Scroll::ScrollInfo;
    using Fl_Scroll::recalc_scrollbars;
};




//  Attaching all relevant hooks and friends

class My_Scroll : public Ada_Resizing<Fl_Scroll> {
public:
    using Ada_Resizing<Fl_Scroll>::Ada_Resizing;

    friend void fl_scroll_draw(SCROLL s);
    friend int fl_scroll_handle(SCROLL s, int e);

    void draw();
    int handle(int e);
};

void My_Scroll::draw() {
    widget_draw_hook(this->user_data());
}

int My_Scroll::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

SCROLL new_fl_scroll(int x, int y, int w, int h, char* label) {
    My_Scroll *s = new My_Scroll(x, y, w, h, label);
    return s;
}

void free_fl_scroll(SCROLL s) {
    if (fl_inside_callback) {
        fl_delete_widget(s);
    } else {
        delete static_cast<My_Scroll*>(s);
    }
}




void * fl_scroll_hscrollbar(SCROLL s) {
    return &static_cast<Fl_Scroll*>(s)->hscrollbar;
}

void * fl_scroll_scrollbar(SCROLL s) {
    return &static_cast<Fl_Scroll*>(s)->scrollbar;
}




void fl_scroll_to(SCROLL s, int x, int y) {
    static_cast<Fl_Scroll*>(s)->scroll_to(x, y);
}

int fl_scroll_xposition(SCROLL s) {
    return static_cast<Fl_Scroll*>(s)->xposition();
}

int fl_scroll_yposition(SCROLL s) {
    return static_cast<Fl_Scroll*>(s)->yposition();
}




int fl_scroll_get_size(SCROLL s) {
    return static_cast<Fl_Scroll*>(s)->scrollbar_size();
}

void fl_scroll_set_size(SCROLL s, int t) {
    static_cast<Fl_Scroll*>(s)->scrollbar_size(t);
}

unsigned int fl_scroll_get_scrollbar_align(SCROLL s) {
    return static_cast<Fl_Scroll*>(s)->scrollbar.align();
}

void fl_scroll_set_scrollbar_align(SCROLL s, unsigned int a) {
    static_cast<Fl_Scroll*>(s)->scrollbar.align(a);
    static_cast<Fl_Scroll*>(s)->redraw();
}




void fl_scroll_resize(SCROLL s, int x, int y, int w, int h) {
    ada_default_resize(static_cast<Fl_Widget*>(s), x, y, w, h);
}

void fl_scroll_recalc_scrollbars(SCROLL s,
    int &cb_x, int &cb_y, int &cb_w, int &cb_h,
    int &ib_x, int &ib_y, int &ib_w, int &ib_h,
    int &ic_x, int &ic_y, int &ic_w, int &ic_h,
    int &chneed, int &cvneed,
    int &hs_x,    int &hs_y,     int &hs_w,     int &hs_h,
    int &hs_size, int &hs_total, int &hs_first, int &hs_pos,
    int &vs_x,    int &vs_y,     int &vs_w,     int &vs_h,
    int &vs_size, int &vs_total, int &vs_first, int &vs_pos,
    int &ssize)
{
    Friend_Scroll::ScrollInfo my_info;
    (static_cast<Fl_Scroll*>(s)->*(&Friend_Scroll::recalc_scrollbars))(my_info);

    cb_x = my_info.child.l;
    cb_y = my_info.child.t;
    cb_w = my_info.child.r - my_info.child.l;
    cb_h = my_info.child.b - my_info.child.t;

    ib_x = my_info.innerbox.x;
    ib_y = my_info.innerbox.y;
    ib_w = my_info.innerbox.w;
    ib_h = my_info.innerbox.h;

    ic_x = my_info.innerchild.x;
    ic_y = my_info.innerchild.y;
    ic_w = my_info.innerchild.w;
    ic_h = my_info.innerchild.h;

    chneed = my_info.hneeded;
    cvneed = my_info.vneeded;

    hs_x = my_info.hscroll.x;
    hs_y = my_info.hscroll.y;
    hs_w = my_info.hscroll.w;
    hs_h = my_info.hscroll.h;
    hs_size  = my_info.hscroll.size;
    hs_total = my_info.hscroll.total;
    hs_first = my_info.hscroll.first;
    hs_pos   = my_info.hscroll.pos;

    vs_x = my_info.vscroll.x;
    vs_y = my_info.vscroll.y;
    vs_w = my_info.vscroll.w;
    vs_h = my_info.vscroll.h;
    vs_size  = my_info.vscroll.size;
    vs_total = my_info.vscroll.total;
    vs_first = my_info.vscroll.first;
    vs_pos   = my_info.vscroll.pos;

    ssize = my_info.scrollsize;
}




void fl_scroll_bbox(SCROLL s, int &x, int &y, int &w, int &h) {
    (static_cast<Fl_Scroll*>(s)->*(&Friend_Scroll::bbox))(x, y, w, h);
}

void fl_scroll_draw(SCROLL s) {
    static_cast<My_Scroll*>(s)->Fl_Scroll::draw();
}

int fl_scroll_handle(SCROLL s, int e) {
    return static_cast<My_Scroll*>(s)->Fl_Scroll::handle(e);
}


