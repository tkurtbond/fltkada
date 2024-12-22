

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_File_Browser.H>
#include <FL/filename.H>
#include "c_fl_file_browser.h"




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

class My_File_Browser : public Fl_File_Browser {
public:
    using Fl_File_Browser::Fl_File_Browser;

    friend int fl_file_browser_item_width(FILEBROWSER b, void * item);
    friend int fl_file_browser_item_height(FILEBROWSER b, void * item);
    friend void * fl_file_browser_item_first(FILEBROWSER b);
    friend void * fl_file_browser_item_last(FILEBROWSER b);
    friend void * fl_file_browser_item_next(FILEBROWSER b, void * item);
    friend void * fl_file_browser_item_prev(FILEBROWSER b, void * item);
    friend void * fl_file_browser_item_at(FILEBROWSER b, int index);
    friend void fl_file_browser_item_select(FILEBROWSER b, void * item, int val);
    friend int fl_file_browser_item_selected(FILEBROWSER b, void * item);
    friend void fl_file_browser_item_swap(FILEBROWSER b, void * x, void * y);
    friend const char * fl_file_browser_item_text(FILEBROWSER b, void * item);
    friend void fl_file_browser_item_draw(FILEBROWSER b, void * item, int x, int y, int w, int h);

    friend int fl_file_browser_lineno(FILEBROWSER b, void * item);

    friend void * fl_file_browser_selection(FILEBROWSER c);
    friend int fl_file_browser_displayed2(FILEBROWSER c, void * i);
    friend void * fl_file_browser_find_item(FILEBROWSER c, int y);
    friend void * fl_file_browser_top(FILEBROWSER c);

    friend void fl_file_browser_bbox(FILEBROWSER c, int &x, int &y, int &w, int &h);
    friend int fl_file_browser_leftedge(FILEBROWSER c);
    friend void fl_file_browser_redraw_line(FILEBROWSER c, void * i);
    friend void fl_file_browser_redraw_lines(FILEBROWSER c);

    friend int fl_file_browser_full_width(FILEBROWSER c);
    friend int fl_file_browser_full_height(FILEBROWSER c);
    friend int fl_file_browser_incr_height(FILEBROWSER c);
    friend int fl_file_browser_item_quick_height(FILEBROWSER c, void * i);

    friend void fl_file_browser_new_list(FILEBROWSER b);
    friend void fl_file_browser_inserting(FILEBROWSER b, void * a1, void * a2);
    friend void fl_file_browser_deleting(FILEBROWSER b, void * item);
    friend void fl_file_browser_replacing(FILEBROWSER b, void * a1, void * a2);
    friend void fl_file_browser_swapping(FILEBROWSER b, void * a1, void * a2);

    friend void fl_file_browser_draw(FILEBROWSER b);

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


int My_File_Browser::full_width() const {
    return browser_full_width_hook(this->user_data());
}

int My_File_Browser::full_height() const {
    return browser_full_height_hook(this->user_data());
}

int My_File_Browser::incr_height() const {
    return browser_incr_height_hook(this->user_data());
}

int My_File_Browser::item_quick_height(void * item) const {
    return browser_item_quick_height_hook(this->user_data(), item);
}


int My_File_Browser::item_width(void * item) const {
    return browser_item_width_hook(this->user_data(), item);
}

int My_File_Browser::item_height(void * item) const {
    return browser_item_height_hook(this->user_data(), item);
}

void * My_File_Browser::item_first() const {
    return browser_item_first_hook(this->user_data());
}

void * My_File_Browser::item_last() const {
    return browser_item_last_hook(this->user_data());
}

void * My_File_Browser::item_next(void * item) const {
    return browser_item_next_hook(this->user_data(), item);
}

void * My_File_Browser::item_prev(void * item) const {
    return browser_item_prev_hook(this->user_data(), item);
}

void * My_File_Browser::item_at(int index) const {
    return browser_item_at_hook(this->user_data(), index);
}

void My_File_Browser::item_select(void * item, int val) {
    browser_item_select_hook(this->user_data(), item, val);
}

int My_File_Browser::item_selected(void * item) const {
    return browser_item_selected_hook(this->user_data(), item);
}

void My_File_Browser::item_swap(void * a, void * b) {
    browser_item_swap_hook(this->user_data(), a, b);
}

const char * My_File_Browser::item_text(void * item) const {
    return browser_item_text_hook(this->user_data(), item);
}

void My_File_Browser::item_draw(void * item, int x, int y, int w, int h) const {
    browser_item_draw_hook(this->user_data(), item, x, y, w, h);
}


void My_File_Browser::draw() {
    widget_draw_hook(this->user_data());
}

int My_File_Browser::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API begins here

FILEBROWSER new_fl_file_browser(int x, int y, int w, int h, char * label) {
    My_File_Browser *b = new My_File_Browser(x, y, w, h, label);
    return b;
}

void free_fl_file_browser(FILEBROWSER b) {
    delete reinterpret_cast<My_File_Browser*>(b);
}




int fl_file_browser_load(FILEBROWSER b, const char * d, void * s) {
    return reinterpret_cast<Fl_File_Browser*>(b)->load(d, reinterpret_cast<Fl_File_Sort_F*>(s));
}




int fl_file_browser_get_filetype(FILEBROWSER b) {
    return reinterpret_cast<Fl_File_Browser*>(b)->filetype();
}

void fl_file_browser_set_filetype(FILEBROWSER b, int f) {
    reinterpret_cast<Fl_File_Browser*>(b)->filetype(f);
}

const char * fl_file_browser_get_filter(FILEBROWSER b) {
    return reinterpret_cast<Fl_File_Browser*>(b)->filter();
}

void fl_file_browser_set_filter(FILEBROWSER b, const char * f) {
    reinterpret_cast<Fl_File_Browser*>(b)->filter(f);
}

unsigned char fl_file_browser_get_iconsize(FILEBROWSER b) {
    return reinterpret_cast<Fl_File_Browser*>(b)->iconsize();
}

void fl_file_browser_set_iconsize(FILEBROWSER b, unsigned int i) {
    reinterpret_cast<Fl_File_Browser*>(b)->iconsize(i);
}

int fl_file_browser_get_textsize(FILEBROWSER b) {
    return reinterpret_cast<Fl_File_Browser*>(b)->textsize();
}

void fl_file_browser_set_textsize(FILEBROWSER b, int s) {
    reinterpret_cast<Fl_File_Browser*>(b)->textsize(s);
}




//  These have to be reimplemented due to relying on custom class extensions

int fl_file_browser_full_height(FILEBROWSER c) {
    return reinterpret_cast<My_File_Browser*>(c)->Fl_Browser::full_height();
}

int fl_file_browser_incr_height(FILEBROWSER c) {
    return reinterpret_cast<My_File_Browser*>(c)->Fl_Browser::incr_height();
}




int fl_file_browser_item_width(FILEBROWSER b, void * item) {
    return reinterpret_cast<My_File_Browser*>(b)->item_width(item);
}

int fl_file_browser_item_height(FILEBROWSER b, void * item) {
    return reinterpret_cast<My_File_Browser*>(b)->item_height(item);
}

void * fl_file_browser_item_first(FILEBROWSER b) {
    return reinterpret_cast<My_File_Browser*>(b)->item_first();
}

void * fl_file_browser_item_last(FILEBROWSER b) {
    return reinterpret_cast<My_File_Browser*>(b)->item_last();
}

void * fl_file_browser_item_next(FILEBROWSER b, void * item) {
    return reinterpret_cast<My_File_Browser*>(b)->item_next(item);
}

void * fl_file_browser_item_prev(FILEBROWSER b, void * item) {
    return reinterpret_cast<My_File_Browser*>(b)->item_prev(item);
}

void * fl_file_browser_item_at(FILEBROWSER b, int index) {
    return reinterpret_cast<My_File_Browser*>(b)->item_at(index);
}

void fl_file_browser_item_select(FILEBROWSER b, void * item, int val) {
    reinterpret_cast<My_File_Browser*>(b)->item_select(item, val);
}

int fl_file_browser_item_selected(FILEBROWSER b, void * item) {
    return reinterpret_cast<My_File_Browser*>(b)->item_selected(item);
}

void fl_file_browser_item_swap(FILEBROWSER b, void * x, void * y) {
    reinterpret_cast<My_File_Browser*>(b)->item_swap(x, y);
}

const char * fl_file_browser_item_text(FILEBROWSER b, void * item) {
    return reinterpret_cast<My_File_Browser*>(b)->item_text(item);
}

void fl_file_browser_item_draw(FILEBROWSER b, void * item, int x, int y, int w, int h) {
    reinterpret_cast<My_File_Browser*>(b)->item_draw(item, x, y, w, h);
}




int fl_file_browser_lineno(FILEBROWSER b, void * item) {
    return reinterpret_cast<My_File_Browser*>(b)->lineno(item);
}




void * fl_file_browser_selection(FILEBROWSER c) {
    return reinterpret_cast<My_File_Browser*>(c)->selection();
}

int fl_file_browser_displayed2(FILEBROWSER c, void * i) {
    return reinterpret_cast<My_File_Browser*>(c)->Fl_Browser_::displayed(i);
}

void * fl_file_browser_find_item(FILEBROWSER c, int y) {
    return reinterpret_cast<My_File_Browser*>(c)->find_item(y);
}

void * fl_file_browser_top(FILEBROWSER c) {
    return reinterpret_cast<My_File_Browser*>(c)->top();
}




void fl_file_browser_bbox(FILEBROWSER c, int &x, int &y, int &w, int &h) {
    reinterpret_cast<My_File_Browser*>(c)->bbox(x, y, w, h);
}

int fl_file_browser_leftedge(FILEBROWSER c) {
    return reinterpret_cast<My_File_Browser*>(c)->leftedge();
}

void fl_file_browser_redraw_line(FILEBROWSER c, void * i) {
    reinterpret_cast<My_File_Browser*>(c)->redraw_line(i);
}

void fl_file_browser_redraw_lines(FILEBROWSER c) {
    reinterpret_cast<My_File_Browser*>(c)->redraw_lines();
}




int fl_file_browser_full_width(FILEBROWSER c) {
    return reinterpret_cast<My_File_Browser*>(c)->Fl_Browser::full_width();
}

int fl_file_browser_item_quick_height(FILEBROWSER c, void * i) {
    return reinterpret_cast<My_File_Browser*>(c)->Fl_Browser::item_quick_height(i);
}




void fl_file_browser_new_list(FILEBROWSER b) {
    reinterpret_cast<My_File_Browser*>(b)->new_list();
}

void fl_file_browser_inserting(FILEBROWSER b, void * a1, void * a2) {
    reinterpret_cast<My_File_Browser*>(b)->inserting(a1, a2);
}

void fl_file_browser_deleting(FILEBROWSER b, void * item) {
    reinterpret_cast<My_File_Browser*>(b)->deleting(item);
}

void fl_file_browser_replacing(FILEBROWSER b, void * a1, void * a2) {
    reinterpret_cast<My_File_Browser*>(b)->replacing(a1, a2);
}

void fl_file_browser_swapping(FILEBROWSER b, void * a1, void * a2) {
    reinterpret_cast<My_File_Browser*>(b)->swapping(a1, a2);
}




void fl_file_browser_draw(FILEBROWSER b) {
    reinterpret_cast<My_File_Browser*>(b)->Fl_Browser::draw();
}

int fl_file_browser_handle(FILEBROWSER b, int e) {
    return reinterpret_cast<My_File_Browser*>(b)->Fl_Browser::handle(e);
}


