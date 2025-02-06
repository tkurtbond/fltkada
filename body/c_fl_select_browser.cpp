

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Select_Browser.H>
#include "c_fl_select_browser.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" int browser_full_width_hook(void * b);
extern "C" int browser_full_height_hook(void * b);
extern "C" int browser_incr_height_hook(void * b);
extern "C" int browser_item_quick_height_hook(void * b, void * i);

extern "C" int browser_item_width_hook(void * b, void * i);
extern "C" int browser_item_height_hook(void * b, void * i);
extern "C" void * browser_item_first_hook(void * b);
extern "C" void * browser_item_last_hook(void * b);
extern "C" void * browser_item_next_hook(void * b, void * i);
extern "C" void * browser_item_prev_hook(void * b, void * i);
extern "C" void * browser_item_at_hook(void * b, int n);
extern "C" void browser_item_select_hook(void * b, void * i, int s);
extern "C" int browser_item_selected_hook(void * b, void * i);
extern "C" void browser_item_swap_hook(void * b, void * one, void * two);
extern "C" const char * browser_item_text_hook(void * b, void * i);
extern "C" void browser_item_draw_hook(void * b, void * i, int x, int y, int w, int h);

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Select_Browser : public Fl_Select_Browser {
public:
    using Fl_Select_Browser::Fl_Select_Browser;

    friend int fl_select_browser_item_width(SELECTBROWSER b, void * item);
    friend int fl_select_browser_item_height(SELECTBROWSER b, void * item);
    friend void * fl_select_browser_item_first(SELECTBROWSER b);
    friend void * fl_select_browser_item_last(SELECTBROWSER b);
    friend void * fl_select_browser_item_next(SELECTBROWSER b, void * item);
    friend void * fl_select_browser_item_prev(SELECTBROWSER b, void * item);
    friend void * fl_select_browser_item_at(SELECTBROWSER b, int index);
    friend void fl_select_browser_item_select(SELECTBROWSER b, void * item, int val);
    friend int fl_select_browser_item_selected(SELECTBROWSER b, void * item);
    friend void fl_select_browser_item_swap(SELECTBROWSER b, void * x, void * y);
    friend const char * fl_select_browser_item_text(SELECTBROWSER b, void * item);
    friend void fl_select_browser_item_draw(SELECTBROWSER b, void * item, int x, int y, int w, int h);

    friend int fl_select_browser_full_width(SELECTBROWSER c);
    friend int fl_select_browser_full_height(SELECTBROWSER c);
    friend int fl_select_browser_incr_height(SELECTBROWSER c);
    friend int fl_select_browser_item_quick_height(SELECTBROWSER c, void * i);

    friend void fl_select_browser_draw(SELECTBROWSER b);

    int handle(int e);

protected:
    int full_width() const;
    int full_height() const;
    int incr_height() const;
    int item_quick_height(void * item) const;

    int item_width(void * item) const;
    int item_height(void * item) const;
    void * item_first() const;
    void * item_last() const;
    void * item_next(void * item) const;
    void * item_prev(void * item) const;
    void * item_at(int index) const;
    void item_select(void * item, int val=1);
    int item_selected(void * item) const;
    void item_swap(void * a, void * b);
    const char * item_text(void * item) const;
    void item_draw(void * item, int x, int y, int w, int h) const;

    void draw();
};


int My_Select_Browser::full_width() const {
    return browser_full_width_hook(this->user_data());
}

int My_Select_Browser::full_height() const {
    return browser_full_height_hook(this->user_data());
}

int My_Select_Browser::incr_height() const {
    return browser_incr_height_hook(this->user_data());
}

int My_Select_Browser::item_quick_height(void * item) const {
    return browser_item_quick_height_hook(this->user_data(), item);
}


int My_Select_Browser::item_width(void * item) const {
    return browser_item_width_hook(this->user_data(), item);
}

int My_Select_Browser::item_height(void * item) const {
    return browser_item_height_hook(this->user_data(), item);
}

void * My_Select_Browser::item_first() const {
    return browser_item_first_hook(this->user_data());
}

void * My_Select_Browser::item_last() const {
    return browser_item_last_hook(this->user_data());
}

void * My_Select_Browser::item_next(void * item) const {
    return browser_item_next_hook(this->user_data(), item);
}

void * My_Select_Browser::item_prev(void * item) const {
    return browser_item_prev_hook(this->user_data(), item);
}

void * My_Select_Browser::item_at(int index) const {
    return browser_item_at_hook(this->user_data(), index);
}

void My_Select_Browser::item_select(void * item, int val) {
    browser_item_select_hook(this->user_data(), item, val);
}

int My_Select_Browser::item_selected(void * item) const {
    return browser_item_selected_hook(this->user_data(), item);
}

void My_Select_Browser::item_swap(void * a, void * b) {
    browser_item_swap_hook(this->user_data(), a, b);
}

const char * My_Select_Browser::item_text(void * item) const {
    return browser_item_text_hook(this->user_data(), item);
}

void My_Select_Browser::item_draw(void * item, int x, int y, int w, int h) const {
    browser_item_draw_hook(this->user_data(), item, x, y, w, h);
}


void My_Select_Browser::draw() {
    widget_draw_hook(this->user_data());
}

int My_Select_Browser::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API begins here

SELECTBROWSER new_fl_select_browser(int x, int y, int w, int h, char * label) {
    My_Select_Browser *b = new My_Select_Browser(x, y, w, h, label);
    return b;
}

void free_fl_select_browser(SELECTBROWSER b) {
    if (fl_inside_callback) {
        fl_delete_widget(b);
    } else {
        delete static_cast<My_Select_Browser*>(b);
    }
}




//  These have to be reimplemented due to relying on custom class extensions

int fl_select_browser_full_height(SELECTBROWSER c) {
    return static_cast<My_Select_Browser*>(c)->Fl_Select_Browser::full_height();
}

int fl_select_browser_incr_height(SELECTBROWSER c) {
    return static_cast<My_Select_Browser*>(c)->Fl_Select_Browser::incr_height();
}




int fl_select_browser_item_width(SELECTBROWSER b, void * item) {
    return static_cast<My_Select_Browser*>(b)->Fl_Select_Browser::item_width(item);
}

int fl_select_browser_item_height(SELECTBROWSER b, void * item) {
    return static_cast<My_Select_Browser*>(b)->Fl_Select_Browser::item_height(item);
}

void * fl_select_browser_item_first(SELECTBROWSER b) {
    return static_cast<My_Select_Browser*>(b)->Fl_Select_Browser::item_first();
}

void * fl_select_browser_item_last(SELECTBROWSER b) {
    return static_cast<My_Select_Browser*>(b)->Fl_Select_Browser::item_last();
}

void * fl_select_browser_item_next(SELECTBROWSER b, void * item) {
    return static_cast<My_Select_Browser*>(b)->Fl_Select_Browser::item_next(item);
}

void * fl_select_browser_item_prev(SELECTBROWSER b, void * item) {
    return static_cast<My_Select_Browser*>(b)->Fl_Select_Browser::item_prev(item);
}

void * fl_select_browser_item_at(SELECTBROWSER b, int index) {
    return static_cast<My_Select_Browser*>(b)->Fl_Select_Browser::item_at(index);
}

void fl_select_browser_item_select(SELECTBROWSER b, void * item, int val) {
    static_cast<My_Select_Browser*>(b)->Fl_Select_Browser::item_select(item, val);
}

int fl_select_browser_item_selected(SELECTBROWSER b, void * item) {
    return static_cast<My_Select_Browser*>(b)->Fl_Select_Browser::item_selected(item);
}

void fl_select_browser_item_swap(SELECTBROWSER b, void * x, void * y) {
    static_cast<My_Select_Browser*>(b)->Fl_Select_Browser::item_swap(x, y);
}

const char * fl_select_browser_item_text(SELECTBROWSER b, void * item) {
    return static_cast<My_Select_Browser*>(b)->Fl_Select_Browser::item_text(item);
}

void fl_select_browser_item_draw(SELECTBROWSER b, void * item, int x, int y, int w, int h) {
    static_cast<My_Select_Browser*>(b)->Fl_Select_Browser::item_draw(item, x, y, w, h);
}




int fl_select_browser_full_width(SELECTBROWSER c) {
    return static_cast<My_Select_Browser*>(c)->Fl_Select_Browser::full_width();
}

int fl_select_browser_item_quick_height(SELECTBROWSER c, void * i) {
    return static_cast<My_Select_Browser*>(c)->Fl_Select_Browser::item_quick_height(i);
}




void fl_select_browser_draw(SELECTBROWSER b) {
    static_cast<My_Select_Browser*>(b)->Fl_Select_Browser::draw();
}

int fl_select_browser_handle(SELECTBROWSER b, int e) {
    return static_cast<My_Select_Browser*>(b)->Fl_Select_Browser::handle(e);
}


