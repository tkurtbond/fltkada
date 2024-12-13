

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Check_Browser.H>
#include "c_fl_check_browser.h"




//  Exports from Ada

extern "C" int browser_full_width_hook(void * b);
extern "C" int browser_full_height_hook(void * b);
extern "C" int browser_incr_height_hook(void * b);
extern "C" int browser_item_quick_height_hook(void * b, void * i);

//  These browser_item_* hooks are disabled since if they are used to hook
//  into Ada using virtual dispatch then there will be no way to access the
//  real Fl_Check_Browser versions once coming back into C++ via C since the
//  versions we want to actually use here are private in FLTK because reasons.

//  Should be possible to re-enable in 1.4.

//  extern "C" int browser_item_width_hook(void * b, void * i);
//  extern "C" int browser_item_height_hook(void * b, void * i);
//  extern "C" void * browser_item_first_hook(void * b);
//  extern "C" void * browser_item_last_hook(void * b);
//  extern "C" void * browser_item_next_hook(void * b, void * i);
//  extern "C" void * browser_item_prev_hook(void * b, void * i);
//  extern "C" void * browser_item_at_hook(void * b, int n);
//  extern "C" void browser_item_select_hook(void * b, void * i, int s);
//  extern "C" int browser_item_selected_hook(void * b, void * i);
//  extern "C" void browser_item_swap_hook(void * b, void * one, void * two);
//  extern "C" const char * browser_item_text_hook(void * b, void * i);
//  extern "C" void browser_item_draw_hook(void * b, void * i, int x, int y, int w, int h);

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Check_Browser : public Fl_Check_Browser {
public:
    using Fl_Check_Browser::Fl_Check_Browser;

    friend void * fl_check_browser_selection(CHECKBROWSER c);
    friend int fl_check_browser_displayed(CHECKBROWSER c, void * i);
    friend void * fl_check_browser_find_item(CHECKBROWSER c, int y);
    friend void * fl_check_browser_top(CHECKBROWSER c);

    friend void fl_check_browser_bbox(CHECKBROWSER c, int &x, int &y, int &w, int &h);
    friend int fl_check_browser_leftedge(CHECKBROWSER c);
    friend void fl_check_browser_redraw_line(CHECKBROWSER c, void * i);
    friend void fl_check_browser_redraw_lines(CHECKBROWSER c);

    friend int fl_check_browser_full_width(CHECKBROWSER c);
    friend int fl_check_browser_full_height(CHECKBROWSER c);
    friend int fl_check_browser_incr_height(CHECKBROWSER c);
    friend int fl_check_browser_item_quick_height(CHECKBROWSER c, void * i);

    friend int fl_check_browser_item_width(CHECKBROWSER c, void * i);
    friend int fl_check_browser_item_height(CHECKBROWSER c, void * i);
    friend void * fl_check_browser_item_first(CHECKBROWSER c);
    //  item_last goes here
    friend void * fl_check_browser_item_next(CHECKBROWSER c, void * i);
    friend void * fl_check_browser_item_prev(CHECKBROWSER c, void * i);
    //  item_at goes here
    friend void fl_check_browser_item_select(CHECKBROWSER c, void * i, int v);
    friend int fl_check_browser_item_selected(CHECKBROWSER c, void * i);
    //  item_swap goes here
    //  item_text goes here
    friend void fl_check_browser_item_draw(CHECKBROWSER c, void * item, int x, int y, int w, int h);

    friend void fl_check_browser_new_list(CHECKBROWSER c);
    friend void fl_check_browser_inserting(CHECKBROWSER c, void * a1, void * a2);
    friend void fl_check_browser_deleting(CHECKBROWSER c, void * item);
    friend void fl_check_browser_replacing(CHECKBROWSER c, void * a1, void * a2);
    friend void fl_check_browser_swapping(CHECKBROWSER c, void * a1, void * a2);

    friend void fl_check_browser_draw(CHECKBROWSER c);
    friend int fl_check_browser_handle(CHECKBROWSER c, int e);

protected:
    int full_width() const;
    int full_height() const;
    int incr_height() const;
    int item_quick_height(void * item) const;

    //  int item_width(void * item) const;
    //  int item_height(void * item) const;
    //  void * item_first() const;
    //  void * item_last() const;
    //  void * item_next(void * item) const;
    //  void * item_prev(void * item) const;
    //  void * item_at(int index) const;
    //  void item_select(void * item, int val=1);
    //  int item_selected(void * item) const;
    //  void item_swap(void * a, void * b);
    //  const char * item_text(void * item) const;
    //  void item_draw(void * item, int x, int y, int w, int h) const;

    void draw();
    int handle(int e);
};


int My_Check_Browser::full_width() const {
    return browser_full_width_hook(this->user_data());
}

int My_Check_Browser::full_height() const {
    return browser_full_height_hook(this->user_data());
}

int My_Check_Browser::incr_height() const {
    return browser_incr_height_hook(this->user_data());
}

int My_Check_Browser::item_quick_height(void * item) const {
    return browser_item_quick_height_hook(this->user_data(), item);
}


//  int My_Check_Browser::item_width(void * item) const {
//      return browser_item_width_hook(this->user_data(), item);
//  }

//  int My_Check_Browser::item_height(void * item) const {
//      return browser_item_height_hook(this->user_data(), item);
//  }

//  void * My_Check_Browser::item_first() const {
//      return browser_item_first_hook(this->user_data());
//  }

//  void * My_Check_Browser::item_last() const {
//      return browser_item_last_hook(this->user_data());
//  }

//  void * My_Check_Browser::item_next(void * item) const {
//      return browser_item_next_hook(this->user_data(), item);
//  }

//  void * My_Check_Browser::item_prev(void * item) const {
//      return browser_item_prev_hook(this->user_data(), item);
//  }

//  void * My_Check_Browser::item_at(int index) const {
//      return browser_item_at_hook(this->user_data(), index);
//  }

//  void My_Check_Browser::item_select(void * item, int val) {
//      browser_item_select_hook(this->user_data(), item, val);
//  }

//  int My_Check_Browser::item_selected(void * item) const {
//      return browser_item_selected_hook(this->user_data(), item);
//  }

//  void My_Check_Browser::item_swap(void * a, void * b) {
//      browser_item_swap_hook(this->user_data(), a, b);
//  }

//  const char * My_Check_Browser::item_text(void * item) const {
//      return browser_item_text_hook(this->user_data(), item);
//  }

//  void My_Check_Browser::item_draw(void * item, int x, int y, int w, int h) const {
//      browser_item_draw_hook(this->user_data(), item, x, y, w, h);
//  }


void My_Check_Browser::draw() {
    widget_draw_hook(this->user_data());
}

int My_Check_Browser::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API begins here

CHECKBROWSER new_fl_check_browser(int x, int y, int w, int h, char * label) {
    My_Check_Browser *c = new My_Check_Browser(x, y, w, h, label);
    return c;
}

void free_fl_check_browser(CHECKBROWSER c) {
    delete reinterpret_cast<My_Check_Browser*>(c);
}




int fl_check_browser_add(CHECKBROWSER c, const char * s, int b) {
    return reinterpret_cast<Fl_Check_Browser*>(c)->add(s, b);
}

int fl_check_browser_remove(CHECKBROWSER c, int i) {
    return reinterpret_cast<Fl_Check_Browser*>(c)->remove(i);
}

void fl_check_browser_clear(CHECKBROWSER c) {
    reinterpret_cast<Fl_Check_Browser*>(c)->clear();
}

int fl_check_browser_nitems(CHECKBROWSER c) {
    return reinterpret_cast<Fl_Check_Browser*>(c)->nitems();
}




void fl_check_browser_check_all(CHECKBROWSER c) {
    reinterpret_cast<Fl_Check_Browser*>(c)->check_all();
}

void fl_check_browser_check_none(CHECKBROWSER c) {
    reinterpret_cast<Fl_Check_Browser*>(c)->check_none();
}

int fl_check_browser_get_checked(CHECKBROWSER c, int i) {
    return reinterpret_cast<Fl_Check_Browser*>(c)->checked(i);
}

void fl_check_browser_set_checked(CHECKBROWSER c, int i, int b) {
    reinterpret_cast<Fl_Check_Browser*>(c)->checked(i, b);
}

int fl_check_browser_nchecked(CHECKBROWSER c) {
    return reinterpret_cast<Fl_Check_Browser*>(c)->nchecked();
}




const char * fl_check_browser_text(CHECKBROWSER c, int i) {
    return reinterpret_cast<Fl_Check_Browser*>(c)->text(i);
}

int fl_check_browser_value(CHECKBROWSER c) {
    return reinterpret_cast<Fl_Check_Browser*>(c)->value();
}




//  These have to be reimplemented due to relying on custom class extensions

void * fl_check_browser_selection(CHECKBROWSER c) {
    return reinterpret_cast<My_Check_Browser*>(c)->selection();
}

int fl_check_browser_displayed(CHECKBROWSER c, void * i) {
    return reinterpret_cast<My_Check_Browser*>(c)->displayed(i);
}

void * fl_check_browser_find_item(CHECKBROWSER c, int y) {
    //  For whatever reason the Fl_Check_Browser version of find_item is private
    return reinterpret_cast<My_Check_Browser*>(c)->Fl_Browser_::find_item(y);
}

void * fl_check_browser_top(CHECKBROWSER c) {
    return reinterpret_cast<My_Check_Browser*>(c)->top();
}




void fl_check_browser_bbox(CHECKBROWSER c, int &x, int &y, int &w, int &h) {
    reinterpret_cast<My_Check_Browser*>(c)->bbox(x, y, w, h);
}

int fl_check_browser_leftedge(CHECKBROWSER c) {
    return reinterpret_cast<My_Check_Browser*>(c)->leftedge();
}

void fl_check_browser_redraw_line(CHECKBROWSER c, void * i) {
    reinterpret_cast<My_Check_Browser*>(c)->redraw_line(i);
}

void fl_check_browser_redraw_lines(CHECKBROWSER c) {
    reinterpret_cast<My_Check_Browser*>(c)->redraw_lines();
}




int fl_check_browser_full_width(CHECKBROWSER c) {
    return reinterpret_cast<My_Check_Browser*>(c)->Fl_Check_Browser::full_width();
}

int fl_check_browser_full_height(CHECKBROWSER c) {
    return reinterpret_cast<My_Check_Browser*>(c)->Fl_Check_Browser::full_height();
}

int fl_check_browser_incr_height(CHECKBROWSER c) {
    return reinterpret_cast<My_Check_Browser*>(c)->Fl_Check_Browser::incr_height();
}

int fl_check_browser_item_quick_height(CHECKBROWSER c, void * i) {
    return reinterpret_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_quick_height(i);
}




int fl_check_browser_item_width(CHECKBROWSER c, void * i) {
    (void)c; (void)i;
    return 0;
    //  return reinterpret_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_width(i);
}

int fl_check_browser_item_height(CHECKBROWSER c, void * i) {
    (void)c; (void)i;
    return 0;
    //  return reinterpret_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_height(i);
}

void * fl_check_browser_item_first(CHECKBROWSER c) {
    (void)c;
    return 0;
    //  return reinterpret_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_first();
}

//  missing item_last

void * fl_check_browser_item_next(CHECKBROWSER c, void * i) {
    (void)c; (void)i;
    return 0;
    //  return reinterpret_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_next(i);
}

void * fl_check_browser_item_prev(CHECKBROWSER c, void * i) {
    (void)c; (void)i;
    return 0;
    //  return reinterpret_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_prev(i);
}

//  missing item_at

void fl_check_browser_item_select(CHECKBROWSER c, void * i, int v) {
    (void)c; (void)i; (void)v;
    //  reinterpret_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_select(i, v);
}

int fl_check_browser_item_selected(CHECKBROWSER c, void * i) {
    (void)c; (void)i;
    return 0;
    //  return reinterpret_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_selected(i);
}

//  missing item_swap
//  missing item_text

void fl_check_browser_item_draw(CHECKBROWSER c, void * item, int x, int y, int w, int h) {
    (void)c; (void)item; (void)x; (void)y; (void)w; (void)h;
    //  reinterpret_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_draw(item, x, y, w, h);
}




void fl_check_browser_new_list(CHECKBROWSER c) {
    reinterpret_cast<My_Check_Browser*>(c)->new_list();
}

void fl_check_browser_inserting(CHECKBROWSER c, void * a1, void * a2) {
    reinterpret_cast<My_Check_Browser*>(c)->inserting(a1, a2);
}

void fl_check_browser_deleting(CHECKBROWSER c, void * item) {
    reinterpret_cast<My_Check_Browser*>(c)->deleting(item);
}

void fl_check_browser_replacing(CHECKBROWSER c, void * a1, void * a2) {
    reinterpret_cast<My_Check_Browser*>(c)->replacing(a1, a2);
}

void fl_check_browser_swapping(CHECKBROWSER c, void * a1, void * a2) {
    reinterpret_cast<My_Check_Browser*>(c)->swapping(a1, a2);
}




void fl_check_browser_draw(CHECKBROWSER c) {
    reinterpret_cast<My_Check_Browser*>(c)->Fl_Check_Browser::draw();
}

int fl_check_browser_handle(CHECKBROWSER c, int e) {
    return reinterpret_cast<My_Check_Browser*>(c)->Fl_Check_Browser::handle(e);
}


