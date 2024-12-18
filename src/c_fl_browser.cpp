

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Browser.H>
#include <FL/Fl_Image.H>
#include "c_fl_browser.h"




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

class My_Browser : public Fl_Browser {
public:
    using Fl_Browser::Fl_Browser;

    friend int fl_browser_item_width(BROWSER b, void * item);
    friend int fl_browser_item_height(BROWSER b, void * item);
    friend void * fl_browser_item_first(BROWSER b);
    friend void * fl_browser_item_last(BROWSER b);
    friend void * fl_browser_item_next(BROWSER b, void * item);
    friend void * fl_browser_item_prev(BROWSER b, void * item);
    friend void * fl_browser_item_at(BROWSER b, int index);
    friend void fl_browser_item_select(BROWSER b, void * item, int val);
    friend int fl_browser_item_selected(BROWSER b, void * item);
    friend void fl_browser_item_swap(BROWSER b, void * x, void * y);
    friend const char * fl_browser_item_text(BROWSER b, void * item);
    friend void fl_browser_item_draw(BROWSER b, void * item, int x, int y, int w, int h);

    friend int fl_browser_lineno(BROWSER b, void * item);

    friend void * fl_browser_selection(BROWSER c);
    friend int fl_browser_displayed2(BROWSER c, void * i);
    friend void * fl_browser_find_item(BROWSER c, int y);
    friend void * fl_browser_top(BROWSER c);

    friend void fl_browser_bbox(BROWSER c, int &x, int &y, int &w, int &h);
    friend int fl_browser_leftedge(BROWSER c);
    friend void fl_browser_redraw_line(BROWSER c, void * i);
    friend void fl_browser_redraw_lines(BROWSER c);

    friend int fl_browser_full_width(BROWSER c);
    friend int fl_browser_full_height(BROWSER c);
    friend int fl_browser_incr_height(BROWSER c);
    friend int fl_browser_item_quick_height(BROWSER c, void * i);

    friend void fl_browser_new_list(BROWSER b);
    friend void fl_browser_inserting(BROWSER b, void * a1, void * a2);
    friend void fl_browser_deleting(BROWSER b, void * item);
    friend void fl_browser_replacing(BROWSER b, void * a1, void * a2);
    friend void fl_browser_swapping(BROWSER b, void * a1, void * a2);

    friend void fl_browser_draw(BROWSER b);

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


int My_Browser::full_width() const {
    return browser_full_width_hook(this->user_data());
}

int My_Browser::full_height() const {
    return browser_full_height_hook(this->user_data());
}

int My_Browser::incr_height() const {
    return browser_incr_height_hook(this->user_data());
}

int My_Browser::item_quick_height(void * item) const {
    return browser_item_quick_height_hook(this->user_data(), item);
}


int My_Browser::item_width(void * item) const {
    return browser_item_width_hook(this->user_data(), item);
}

int My_Browser::item_height(void * item) const {
    return browser_item_height_hook(this->user_data(), item);
}

void * My_Browser::item_first() const {
    return browser_item_first_hook(this->user_data());
}

void * My_Browser::item_last() const {
    return browser_item_last_hook(this->user_data());
}

void * My_Browser::item_next(void * item) const {
    return browser_item_next_hook(this->user_data(), item);
}

void * My_Browser::item_prev(void * item) const {
    return browser_item_prev_hook(this->user_data(), item);
}

void * My_Browser::item_at(int index) const {
    return browser_item_at_hook(this->user_data(), index);
}

void My_Browser::item_select(void * item, int val) {
    browser_item_select_hook(this->user_data(), item, val);
}

int My_Browser::item_selected(void * item) const {
    return browser_item_selected_hook(this->user_data(), item);
}

void My_Browser::item_swap(void * a, void * b) {
    browser_item_swap_hook(this->user_data(), a, b);
}

const char * My_Browser::item_text(void * item) const {
    return browser_item_text_hook(this->user_data(), item);
}

void My_Browser::item_draw(void * item, int x, int y, int w, int h) const {
    browser_item_draw_hook(this->user_data(), item, x, y, w, h);
}


void My_Browser::draw() {
    widget_draw_hook(this->user_data());
}

int My_Browser::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API begins here

BROWSER new_fl_browser(int x, int y, int w, int h, char * label) {
    My_Browser *b = new My_Browser(x, y, w, h, label);
    return b;
}

void free_fl_browser(BROWSER b) {
    delete reinterpret_cast<My_Browser*>(b);
}




void fl_browser_add(BROWSER b, const char * text, void * d) {
    reinterpret_cast<Fl_Browser*>(b)->add(text, d);
}

void fl_browser_insert(BROWSER b, int line, const char * text, void * d) {
    reinterpret_cast<Fl_Browser*>(b)->insert(line, text, d);
}

void fl_browser_move(BROWSER b, int to, int from) {
    reinterpret_cast<Fl_Browser*>(b)->move(to, from);
}

void fl_browser_swap(BROWSER b, int x, int y) {
    reinterpret_cast<Fl_Browser*>(b)->swap(x, y);
}

void fl_browser_remove(BROWSER b, int line) {
    reinterpret_cast<Fl_Browser*>(b)->remove(line);
}

void fl_browser_clear(BROWSER b) {
    reinterpret_cast<Fl_Browser*>(b)->clear();
}

int fl_browser_size(BROWSER b) {
    return reinterpret_cast<Fl_Browser*>(b)->size();
}




int fl_browser_load(BROWSER b, const char * f) {
    return reinterpret_cast<Fl_Browser*>(b)->load(f);
}

const char * fl_browser_get_text(BROWSER b, int line) {
    return reinterpret_cast<Fl_Browser*>(b)->text(line);
}

void fl_browser_set_text(BROWSER b, int line, const char * text) {
    reinterpret_cast<Fl_Browser*>(b)->text(line, text);
}

int fl_browser_get_textsize(BROWSER b) {
    return reinterpret_cast<Fl_Browser*>(b)->textsize();
}

void fl_browser_set_textsize(BROWSER b, int size) {
    reinterpret_cast<Fl_Browser*>(b)->textsize(size);
}




char fl_browser_get_column_char(BROWSER b) {
    return reinterpret_cast<Fl_Browser*>(b)->column_char();
}

void fl_browser_set_column_char(BROWSER b, char c) {
    reinterpret_cast<Fl_Browser*>(b)->column_char(c);
}

void fl_browser_set_column_widths(BROWSER b, void * w) {
    reinterpret_cast<Fl_Browser*>(b)->column_widths(reinterpret_cast<const int *>(w));
}

char fl_browser_get_format_char(BROWSER b) {
    return reinterpret_cast<Fl_Browser*>(b)->format_char();
}

void fl_browser_set_format_char(BROWSER b, char c) {
    reinterpret_cast<Fl_Browser*>(b)->format_char(c);
}




int fl_browser_get_topline(BROWSER b) {
    return reinterpret_cast<Fl_Browser*>(b)->topline();
}

void fl_browser_set_topline(BROWSER b, int line) {
    reinterpret_cast<Fl_Browser*>(b)->topline(line);
}

void fl_browser_middleline(BROWSER b, int line) {
    reinterpret_cast<Fl_Browser*>(b)->middleline(line);
}

void fl_browser_bottomline(BROWSER b, int line) {
    reinterpret_cast<Fl_Browser*>(b)->bottomline(line);
}

void fl_browser_lineposition(BROWSER b, int line, int p) {
    reinterpret_cast<Fl_Browser*>(b)->lineposition
        (line, static_cast<Fl_Browser::Fl_Line_Position>(p));
}




int fl_browser_select(BROWSER b, int l, int v) {
    return reinterpret_cast<Fl_Browser*>(b)->select(l, v);
}

int fl_browser_selected(BROWSER b, int l) {
    return reinterpret_cast<Fl_Browser*>(b)->selected(l);
}

int fl_browser_value(BROWSER b) {
    return reinterpret_cast<Fl_Browser*>(b)->value();
}




int fl_browser_visible(BROWSER b, int l) {
    return reinterpret_cast<Fl_Browser*>(b)->visible(l);
}

void fl_browser_make_visible(BROWSER b, int l) {
    reinterpret_cast<Fl_Browser*>(b)->make_visible(l);
}

int fl_browser_displayed(BROWSER b, int l) {
    return reinterpret_cast<Fl_Browser*>(b)->displayed(l);
}

void fl_browser_show_line(BROWSER b, int l) {
    reinterpret_cast<Fl_Browser*>(b)->show(l);
}

void fl_browser_hide_line(BROWSER b, int l) {
    reinterpret_cast<Fl_Browser*>(b)->hide(l);
}

void fl_browser_show(BROWSER b) {
    reinterpret_cast<Fl_Browser*>(b)->show();
}

void fl_browser_hide(BROWSER b) {
    reinterpret_cast<Fl_Browser*>(b)->hide();
}




void fl_browser_set_icon(BROWSER b, int l, void * c) {
    reinterpret_cast<Fl_Browser*>(b)->icon(l, reinterpret_cast<Fl_Image*>(c));
}

void fl_browser_remove_icon(BROWSER b, int l) {
    reinterpret_cast<Fl_Browser*>(b)->remove_icon(l);
}




int fl_browser_full_height(BROWSER c) {
    return reinterpret_cast<My_Browser*>(c)->Fl_Browser::full_height();
}

int fl_browser_incr_height(BROWSER c) {
    return reinterpret_cast<My_Browser*>(c)->Fl_Browser::incr_height();
}




int fl_browser_item_width(BROWSER b, void * item) {
    return reinterpret_cast<My_Browser*>(b)->item_width(item);
}

int fl_browser_item_height(BROWSER b, void * item) {
    return reinterpret_cast<My_Browser*>(b)->item_height(item);
}

void * fl_browser_item_first(BROWSER b) {
    return reinterpret_cast<My_Browser*>(b)->item_first();
}

void * fl_browser_item_last(BROWSER b) {
    return reinterpret_cast<My_Browser*>(b)->item_last();
}

void * fl_browser_item_next(BROWSER b, void * item) {
    return reinterpret_cast<My_Browser*>(b)->item_next(item);
}

void * fl_browser_item_prev(BROWSER b, void * item) {
    return reinterpret_cast<My_Browser*>(b)->item_prev(item);
}

void * fl_browser_item_at(BROWSER b, int index) {
    return reinterpret_cast<My_Browser*>(b)->item_at(index);
}

void fl_browser_item_select(BROWSER b, void * item, int val) {
    reinterpret_cast<My_Browser*>(b)->item_select(item, val);
}

int fl_browser_item_selected(BROWSER b, void * item) {
    return reinterpret_cast<My_Browser*>(b)->item_selected(item);
}

void fl_browser_item_swap(BROWSER b, void * x, void * y) {
    reinterpret_cast<My_Browser*>(b)->item_swap(x, y);
}

const char * fl_browser_item_text(BROWSER b, void * item) {
    return reinterpret_cast<My_Browser*>(b)->item_text(item);
}

void fl_browser_item_draw(BROWSER b, void * item, int x, int y, int w, int h) {
    reinterpret_cast<My_Browser*>(b)->item_draw(item, x, y, w, h);
}




int fl_browser_lineno(BROWSER b, void * item) {
    return reinterpret_cast<My_Browser*>(b)->lineno(item);
}




//  These have to be reimplemented due to relying on custom class extensions

void * fl_browser_selection(BROWSER c) {
    return reinterpret_cast<My_Browser*>(c)->selection();
}

int fl_browser_displayed2(BROWSER c, void * i) {
    return reinterpret_cast<My_Browser*>(c)->Fl_Browser_::displayed(i);
}

void * fl_browser_find_item(BROWSER c, int y) {
    return reinterpret_cast<My_Browser*>(c)->find_item(y);
}

void * fl_browser_top(BROWSER c) {
    return reinterpret_cast<My_Browser*>(c)->top();
}




void fl_browser_bbox(BROWSER c, int &x, int &y, int &w, int &h) {
    reinterpret_cast<My_Browser*>(c)->bbox(x, y, w, h);
}

int fl_browser_leftedge(BROWSER c) {
    return reinterpret_cast<My_Browser*>(c)->leftedge();
}

void fl_browser_redraw_line(BROWSER c, void * i) {
    reinterpret_cast<My_Browser*>(c)->redraw_line(i);
}

void fl_browser_redraw_lines(BROWSER c) {
    reinterpret_cast<My_Browser*>(c)->redraw_lines();
}




int fl_browser_full_width(BROWSER c) {
    return reinterpret_cast<My_Browser*>(c)->Fl_Browser::full_width();
}

int fl_browser_item_quick_height(BROWSER c, void * i) {
    return reinterpret_cast<My_Browser*>(c)->Fl_Browser::item_quick_height(i);
}




void fl_browser_new_list(BROWSER b) {
    reinterpret_cast<My_Browser*>(b)->new_list();
}

void fl_browser_inserting(BROWSER b, void * a1, void * a2) {
    reinterpret_cast<My_Browser*>(b)->inserting(a1, a2);
}

void fl_browser_deleting(BROWSER b, void * item) {
    reinterpret_cast<My_Browser*>(b)->deleting(item);
}

void fl_browser_replacing(BROWSER b, void * a1, void * a2) {
    reinterpret_cast<My_Browser*>(b)->replacing(a1, a2);
}

void fl_browser_swapping(BROWSER b, void * a1, void * a2) {
    reinterpret_cast<My_Browser*>(b)->swapping(a1, a2);
}




void fl_browser_draw(BROWSER b) {
    reinterpret_cast<My_Browser*>(b)->Fl_Browser::draw();
}

int fl_browser_handle(BROWSER b, int e) {
    return reinterpret_cast<My_Browser*>(b)->Fl_Browser::handle(e);
}


