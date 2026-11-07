

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Browser_.H>
#include "c_fl_browser_.h"
#include "c_fl_widget.h"
#include "c_fl.h"




const int fl_sort_ascending = FL_SORT_ASCENDING;
const int fl_sort_descending = FL_SORT_DESCENDING;
const int fl_sort_caseinsensitive = FL_SORT_CASEINSENSITIVE;




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




//  Non-friend protected access

class Friend_Browser_ : Fl_Browser_ {
public:
    using Fl_Browser_::selection;
    using Fl_Browser_::displayed;
    using Fl_Browser_::find_item;
    using Fl_Browser_::top;

    using Fl_Browser_::bbox;
    using Fl_Browser_::leftedge;
    using Fl_Browser_::redraw_line;
    using Fl_Browser_::redraw_lines;

    using Fl_Browser_::new_list;
    using Fl_Browser_::inserting;
    using Fl_Browser_::deleting;
    using Fl_Browser_::replacing;
    using Fl_Browser_::swapping;
};




//  Attaching all relevant hooks and friends

class My_Browser_ : public Ada_Resizing<Fl_Browser_> {
public:
    using Ada_Resizing<Fl_Browser_>::Ada_Resizing;
    friend ABSTRACTBROWSER new_fl_abstract_browser(int x, int y, int w, int h, char * label);

    friend int fl_abstract_browser_full_width(ABSTRACTBROWSER b);
    friend int fl_abstract_browser_full_height(ABSTRACTBROWSER b);
    friend int fl_abstract_browser_incr_height(ABSTRACTBROWSER b);
    friend int fl_abstract_browser_item_quick_height(ABSTRACTBROWSER b, void * i);

    friend void fl_abstract_browser_draw(ABSTRACTBROWSER b);
    friend int fl_abstract_browser_handle(ABSTRACTBROWSER b, int e);

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
    int handle(int e);
};


int My_Browser_::full_width() const {
    return browser_full_width_hook(this->user_data());
}

int My_Browser_::full_height() const {
    return browser_full_height_hook(this->user_data());
}

int My_Browser_::incr_height() const {
    return browser_incr_height_hook(this->user_data());
}

int My_Browser_::item_quick_height(void * item) const {
    return browser_item_quick_height_hook(this->user_data(), item);
}


int My_Browser_::item_width(void * item) const {
    return browser_item_width_hook(this->user_data(), item);
}

int My_Browser_::item_height(void * item) const {
    return browser_item_height_hook(this->user_data(), item);
}

void * My_Browser_::item_first() const {
    return browser_item_first_hook(this->user_data());
}

void * My_Browser_::item_last() const {
    return browser_item_last_hook(this->user_data());
}

void * My_Browser_::item_next(void * item) const {
    return browser_item_next_hook(this->user_data(), item);
}

void * My_Browser_::item_prev(void * item) const {
    return browser_item_prev_hook(this->user_data(), item);
}

void * My_Browser_::item_at(int index) const {
    return browser_item_at_hook(this->user_data(), index);
}

void My_Browser_::item_select(void * item, int val) {
    browser_item_select_hook(this->user_data(), item, val);
}

int My_Browser_::item_selected(void * item) const {
    return browser_item_selected_hook(this->user_data(), item);
}

void My_Browser_::item_swap(void * a, void * b) {
    browser_item_swap_hook(this->user_data(), a, b);
}

const char * My_Browser_::item_text(void * item) const {
    return browser_item_text_hook(this->user_data(), item);
}

void My_Browser_::item_draw(void * item, int x, int y, int w, int h) const {
    browser_item_draw_hook(this->user_data(), item, x, y, w, h);
}


void My_Browser_::draw() {
    widget_draw_hook(this->user_data());
}

int My_Browser_::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API begins here

ABSTRACTBROWSER new_fl_abstract_browser(int x, int y, int w, int h, char * label) {
    My_Browser_ *b = new My_Browser_(x, y, w, h, label);
    return b;
}

void free_fl_abstract_browser(ABSTRACTBROWSER b) {
    if (fl_inside_callback) {
        fl_delete_widget(b);
    } else {
        delete static_cast<My_Browser_*>(b);
    }
}




void * fl_abstract_browser_hscrollbar(ABSTRACTBROWSER b) {
    return &static_cast<Fl_Browser_*>(b)->hscrollbar;
}

void * fl_abstract_browser_scrollbar(ABSTRACTBROWSER b) {
    return &static_cast<Fl_Browser_*>(b)->scrollbar;
}




int fl_abstract_browser_select(ABSTRACTBROWSER b, void * i, int v, int c) {
    return static_cast<Fl_Browser_*>(b)->select(i, v, c);
}

int fl_abstract_browser_select_only(ABSTRACTBROWSER b, void * i, int c) {
    return static_cast<Fl_Browser_*>(b)->select_only(i, c);
}

void * fl_abstract_browser_selection(ABSTRACTBROWSER b) {
    return (static_cast<Fl_Browser_*>(b)->*(&Friend_Browser_::selection))();
}

int fl_abstract_browser_deselect(ABSTRACTBROWSER b, int c) {
    return static_cast<Fl_Browser_*>(b)->deselect(c);
}

void fl_abstract_browser_display(ABSTRACTBROWSER b, void * i) {
    static_cast<Fl_Browser_*>(b)->display(i);
}

int fl_abstract_browser_displayed(ABSTRACTBROWSER b, void * i) {
    browser_update_top(static_cast<Fl_Browser_*>(b));
    return (static_cast<Fl_Browser_*>(b)->*(&Friend_Browser_::displayed))(i);
}

//  Fl_Browser_ finds its top line from its scroll position only in the
//  private update_top, which draw and find_item call
//  (Fl_Browser_.cxx:132-184, 330, 583).  Until then top (), displayed () and
//  Fl_Browser::topline () read the old top line, or none in a browser never
//  drawn (pofltk 38).  find_item, which is protected, updates it first.
void browser_update_top(Fl_Browser_ * b) {
    (b->*(&Friend_Browser_::find_item))(0);
}

void * fl_abstract_browser_find_item(ABSTRACTBROWSER b, int y) {
    return (static_cast<Fl_Browser_*>(b)->*(&Friend_Browser_::find_item))(y);
}

void * fl_abstract_browser_top(ABSTRACTBROWSER b) {
    browser_update_top(static_cast<Fl_Browser_*>(b));
    return (static_cast<Fl_Browser_*>(b)->*(&Friend_Browser_::top))();
}

void fl_abstract_browser_sort(ABSTRACTBROWSER b, int f) {
    static_cast<Fl_Browser_*>(b)->sort(f);
}




unsigned char fl_abstract_browser_get_has_scrollbar(ABSTRACTBROWSER b) {
    return static_cast<Fl_Browser_*>(b)->has_scrollbar();
}

void fl_abstract_browser_set_has_scrollbar(ABSTRACTBROWSER b, unsigned char m) {
    static_cast<Fl_Browser_*>(b)->has_scrollbar(m);
}

int fl_abstract_browser_get_hposition(ABSTRACTBROWSER b) {
    return static_cast<Fl_Browser_*>(b)->hposition();
}

void fl_abstract_browser_set_hposition(ABSTRACTBROWSER b, int p) {
    static_cast<Fl_Browser_*>(b)->hposition(p);
}

int fl_abstract_browser_get_position(ABSTRACTBROWSER b) {
    return static_cast<Fl_Browser_*>(b)->vposition();
}

void fl_abstract_browser_set_position(ABSTRACTBROWSER b, int p) {
    static_cast<Fl_Browser_*>(b)->vposition(p);
}

void fl_abstract_browser_scrollbar_left(ABSTRACTBROWSER b) {
    static_cast<Fl_Browser_*>(b)->scrollbar_left();
}

void fl_abstract_browser_scrollbar_right(ABSTRACTBROWSER b) {
    static_cast<Fl_Browser_*>(b)->scrollbar_right();
}

int fl_abstract_browser_get_scrollbar_size(ABSTRACTBROWSER b) {
    return static_cast<Fl_Browser_*>(b)->scrollbar_size();
}

void fl_abstract_browser_set_scrollbar_size(ABSTRACTBROWSER b, int s) {
    static_cast<Fl_Browser_*>(b)->scrollbar_size(s);
}




unsigned int fl_abstract_browser_get_textcolor(ABSTRACTBROWSER b) {
    return static_cast<Fl_Browser_*>(b)->textcolor();
}

void fl_abstract_browser_set_textcolor(ABSTRACTBROWSER b, unsigned int c) {
    static_cast<Fl_Browser_*>(b)->textcolor(c);
}

int fl_abstract_browser_get_textfont(ABSTRACTBROWSER b) {
    return static_cast<Fl_Browser_*>(b)->textfont();
}

void fl_abstract_browser_set_textfont(ABSTRACTBROWSER b, int f) {
    static_cast<Fl_Browser_*>(b)->textfont(f);
}

int fl_abstract_browser_get_textsize(ABSTRACTBROWSER b) {
    return static_cast<Fl_Browser_*>(b)->textsize();
}

void fl_abstract_browser_set_textsize(ABSTRACTBROWSER b, int s) {
    static_cast<Fl_Browser_*>(b)->textsize(s);
}




void fl_abstract_browser_resize(ABSTRACTBROWSER b, int x, int y, int w, int h) {
    ada_default_resize(static_cast<Fl_Widget*>(b), x, y, w, h);
}

void fl_abstract_browser_bbox(ABSTRACTBROWSER b, int &x, int &y, int &w, int &h) {
    (static_cast<Fl_Browser_*>(b)->*(&Friend_Browser_::bbox))(x, y, w, h);
}

int fl_abstract_browser_leftedge(ABSTRACTBROWSER b) {
    return (static_cast<Fl_Browser_*>(b)->*(&Friend_Browser_::leftedge))();
}

void fl_abstract_browser_redraw_line(ABSTRACTBROWSER b, void * i) {
    (static_cast<Fl_Browser_*>(b)->*(&Friend_Browser_::redraw_line))(i);
}

void fl_abstract_browser_redraw_lines(ABSTRACTBROWSER b) {
    (static_cast<Fl_Browser_*>(b)->*(&Friend_Browser_::redraw_lines))();
}




int fl_abstract_browser_full_width(ABSTRACTBROWSER b) {
    return static_cast<My_Browser_*>(b)->Fl_Browser_::full_width();
}

int fl_abstract_browser_full_height(ABSTRACTBROWSER b) {
    return static_cast<My_Browser_*>(b)->Fl_Browser_::full_height();
}

int fl_abstract_browser_incr_height(ABSTRACTBROWSER b) {
    return static_cast<My_Browser_*>(b)->Fl_Browser_::incr_height();
}

int fl_abstract_browser_item_quick_height(ABSTRACTBROWSER b, void * i) {
    return static_cast<My_Browser_*>(b)->Fl_Browser_::item_quick_height(i);
}




void fl_abstract_browser_new_list(ABSTRACTBROWSER b) {
    (static_cast<Fl_Browser_*>(b)->*(&Friend_Browser_::new_list))();
}

void fl_abstract_browser_inserting(ABSTRACTBROWSER b, void * a1, void * a2) {
    (static_cast<Fl_Browser_*>(b)->*(&Friend_Browser_::inserting))(a1, a2);
}

void fl_abstract_browser_deleting(ABSTRACTBROWSER b, void * item) {
    (static_cast<Fl_Browser_*>(b)->*(&Friend_Browser_::deleting))(item);
}

void fl_abstract_browser_replacing(ABSTRACTBROWSER b, void * a1, void * a2) {
    (static_cast<Fl_Browser_*>(b)->*(&Friend_Browser_::replacing))(a1, a2);
}

void fl_abstract_browser_swapping(ABSTRACTBROWSER b, void * a1, void * a2) {
    (static_cast<Fl_Browser_*>(b)->*(&Friend_Browser_::swapping))(a1, a2);
}




void fl_abstract_browser_draw(ABSTRACTBROWSER b) {
    static_cast<My_Browser_*>(b)->Fl_Browser_::draw();
}

int fl_abstract_browser_handle(ABSTRACTBROWSER b, int e) {
    return static_cast<My_Browser_*>(b)->Fl_Browser_::handle(e);
}


