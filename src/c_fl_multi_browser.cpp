

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Multi_Browser.H>
#include "c_fl_multi_browser.h"




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

class My_Multi_Browser : public Fl_Multi_Browser {
public:
    using Fl_Multi_Browser::Fl_Multi_Browser;

    friend int fl_multi_browser_item_width(MULTIBROWSER b, void * item);
    friend int fl_multi_browser_item_height(MULTIBROWSER b, void * item);
    friend void * fl_multi_browser_item_first(MULTIBROWSER b);
    friend void * fl_multi_browser_item_last(MULTIBROWSER b);
    friend void * fl_multi_browser_item_next(MULTIBROWSER b, void * item);
    friend void * fl_multi_browser_item_prev(MULTIBROWSER b, void * item);
    friend void * fl_multi_browser_item_at(MULTIBROWSER b, int index);
    friend void fl_multi_browser_item_select(MULTIBROWSER b, void * item, int val);
    friend int fl_multi_browser_item_selected(MULTIBROWSER b, void * item);
    friend void fl_multi_browser_item_swap(MULTIBROWSER b, void * x, void * y);
    friend const char * fl_multi_browser_item_text(MULTIBROWSER b, void * item);
    friend void fl_multi_browser_item_draw(MULTIBROWSER b, void * item, int x, int y, int w, int h);

    friend int fl_multi_browser_full_width(MULTIBROWSER c);
    friend int fl_multi_browser_full_height(MULTIBROWSER c);
    friend int fl_multi_browser_incr_height(MULTIBROWSER c);
    friend int fl_multi_browser_item_quick_height(MULTIBROWSER c, void * i);

    friend void fl_multi_browser_draw(MULTIBROWSER b);

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


int My_Multi_Browser::full_width() const {
    return browser_full_width_hook(this->user_data());
}

int My_Multi_Browser::full_height() const {
    return browser_full_height_hook(this->user_data());
}

int My_Multi_Browser::incr_height() const {
    return browser_incr_height_hook(this->user_data());
}

int My_Multi_Browser::item_quick_height(void * item) const {
    return browser_item_quick_height_hook(this->user_data(), item);
}


int My_Multi_Browser::item_width(void * item) const {
    return browser_item_width_hook(this->user_data(), item);
}

int My_Multi_Browser::item_height(void * item) const {
    return browser_item_height_hook(this->user_data(), item);
}

void * My_Multi_Browser::item_first() const {
    return browser_item_first_hook(this->user_data());
}

void * My_Multi_Browser::item_last() const {
    return browser_item_last_hook(this->user_data());
}

void * My_Multi_Browser::item_next(void * item) const {
    return browser_item_next_hook(this->user_data(), item);
}

void * My_Multi_Browser::item_prev(void * item) const {
    return browser_item_prev_hook(this->user_data(), item);
}

void * My_Multi_Browser::item_at(int index) const {
    return browser_item_at_hook(this->user_data(), index);
}

void My_Multi_Browser::item_select(void * item, int val) {
    browser_item_select_hook(this->user_data(), item, val);
}

int My_Multi_Browser::item_selected(void * item) const {
    return browser_item_selected_hook(this->user_data(), item);
}

void My_Multi_Browser::item_swap(void * a, void * b) {
    browser_item_swap_hook(this->user_data(), a, b);
}

const char * My_Multi_Browser::item_text(void * item) const {
    return browser_item_text_hook(this->user_data(), item);
}

void My_Multi_Browser::item_draw(void * item, int x, int y, int w, int h) const {
    browser_item_draw_hook(this->user_data(), item, x, y, w, h);
}


void My_Multi_Browser::draw() {
    widget_draw_hook(this->user_data());
}

int My_Multi_Browser::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API begins here

MULTIBROWSER new_fl_multi_browser(int x, int y, int w, int h, char * label) {
    My_Multi_Browser *b = new My_Multi_Browser(x, y, w, h, label);
    return b;
}

void free_fl_multi_browser(MULTIBROWSER b) {
    delete reinterpret_cast<My_Multi_Browser*>(b);
}




//  These have to be reimplemented due to relying on custom class extensions


int fl_multi_browser_full_height(MULTIBROWSER c) {
    return reinterpret_cast<My_Multi_Browser*>(c)->Fl_Multi_Browser::full_height();
}

int fl_multi_browser_incr_height(MULTIBROWSER c) {
    return reinterpret_cast<My_Multi_Browser*>(c)->Fl_Multi_Browser::incr_height();
}




int fl_multi_browser_item_width(MULTIBROWSER b, void * item) {
    return reinterpret_cast<My_Multi_Browser*>(b)->Fl_Multi_Browser::item_width(item);
}

int fl_multi_browser_item_height(MULTIBROWSER b, void * item) {
    return reinterpret_cast<My_Multi_Browser*>(b)->Fl_Multi_Browser::item_height(item);
}

void * fl_multi_browser_item_first(MULTIBROWSER b) {
    return reinterpret_cast<My_Multi_Browser*>(b)->Fl_Multi_Browser::item_first();
}

void * fl_multi_browser_item_last(MULTIBROWSER b) {
    return reinterpret_cast<My_Multi_Browser*>(b)->Fl_Multi_Browser::item_last();
}

void * fl_multi_browser_item_next(MULTIBROWSER b, void * item) {
    return reinterpret_cast<My_Multi_Browser*>(b)->Fl_Multi_Browser::item_next(item);
}

void * fl_multi_browser_item_prev(MULTIBROWSER b, void * item) {
    return reinterpret_cast<My_Multi_Browser*>(b)->Fl_Multi_Browser::item_prev(item);
}

void * fl_multi_browser_item_at(MULTIBROWSER b, int index) {
    return reinterpret_cast<My_Multi_Browser*>(b)->Fl_Multi_Browser::item_at(index);
}

void fl_multi_browser_item_select(MULTIBROWSER b, void * item, int val) {
    reinterpret_cast<My_Multi_Browser*>(b)->Fl_Multi_Browser::item_select(item, val);
}

int fl_multi_browser_item_selected(MULTIBROWSER b, void * item) {
    return reinterpret_cast<My_Multi_Browser*>(b)->Fl_Multi_Browser::item_selected(item);
}

void fl_multi_browser_item_swap(MULTIBROWSER b, void * x, void * y) {
    reinterpret_cast<My_Multi_Browser*>(b)->Fl_Multi_Browser::item_swap(x, y);
}

const char * fl_multi_browser_item_text(MULTIBROWSER b, void * item) {
    return reinterpret_cast<My_Multi_Browser*>(b)->Fl_Multi_Browser::item_text(item);
}

void fl_multi_browser_item_draw(MULTIBROWSER b, void * item, int x, int y, int w, int h) {
    reinterpret_cast<My_Multi_Browser*>(b)->Fl_Multi_Browser::item_draw(item, x, y, w, h);
}




int fl_multi_browser_full_width(MULTIBROWSER c) {
    return reinterpret_cast<My_Multi_Browser*>(c)->Fl_Multi_Browser::full_width();
}

int fl_multi_browser_item_quick_height(MULTIBROWSER c, void * i) {
    return reinterpret_cast<My_Multi_Browser*>(c)->Fl_Multi_Browser::item_quick_height(i);
}




void fl_multi_browser_draw(MULTIBROWSER b) {
    reinterpret_cast<My_Multi_Browser*>(b)->Fl_Multi_Browser::draw();
}

int fl_multi_browser_handle(MULTIBROWSER b, int e) {
    return reinterpret_cast<My_Multi_Browser*>(b)->Fl_Multi_Browser::handle(e);
}


