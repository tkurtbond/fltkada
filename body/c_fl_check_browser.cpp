

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Check_Browser.H>
#include <FL/Fl_Browser_.H>
#include "c_fl_check_browser.h"
#include "c_fl_widget.h"
#include "c_fl.h"




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




//  Non-friend protected / private access

class Friend_Browser : Fl_Browser_ {
public:
    using Fl_Browser_::item_width;
    using Fl_Browser_::item_height;
    using Fl_Browser_::item_first;
    using Fl_Browser_::item_next;
    using Fl_Browser_::item_prev;
    using Fl_Browser_::item_select;
    using Fl_Browser_::item_selected;
    using Fl_Browser_::item_draw;
};




//  Attaching all relevant hooks and friends

class My_Check_Browser : public Ada_Resizing<Fl_Check_Browser> {
public:
    using Ada_Resizing<Fl_Check_Browser>::Ada_Resizing;

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
    if (fl_inside_callback) {
        fl_delete_widget(c);
    } else {
        delete static_cast<My_Check_Browser*>(c);
    }
}




int fl_check_browser_add(CHECKBROWSER c, const char * s, int b) {
    return static_cast<Fl_Check_Browser*>(c)->add(s, b);
}

int fl_check_browser_remove(CHECKBROWSER c, int i) {
    return static_cast<Fl_Check_Browser*>(c)->remove(i);
}

void fl_check_browser_clear(CHECKBROWSER c) {
    static_cast<Fl_Check_Browser*>(c)->clear();
}

int fl_check_browser_nitems(CHECKBROWSER c) {
    return static_cast<Fl_Check_Browser*>(c)->nitems();
}




void fl_check_browser_check_all(CHECKBROWSER c) {
    static_cast<Fl_Check_Browser*>(c)->check_all();
}

void fl_check_browser_check_none(CHECKBROWSER c) {
    static_cast<Fl_Check_Browser*>(c)->check_none();
}

int fl_check_browser_get_checked(CHECKBROWSER c, int i) {
    return static_cast<Fl_Check_Browser*>(c)->checked(i);
}

void fl_check_browser_set_checked(CHECKBROWSER c, int i, int b) {
    static_cast<Fl_Check_Browser*>(c)->checked(i, b);
}

int fl_check_browser_nchecked(CHECKBROWSER c) {
    return static_cast<Fl_Check_Browser*>(c)->nchecked();
}




const char * fl_check_browser_text(CHECKBROWSER c, int i) {
    return static_cast<Fl_Check_Browser*>(c)->text(i);
}

int fl_check_browser_value(CHECKBROWSER c) {
    return static_cast<Fl_Check_Browser*>(c)->value();
}




int fl_check_browser_full_width(CHECKBROWSER c) {
    return static_cast<My_Check_Browser*>(c)->Fl_Check_Browser::full_width();
}

int fl_check_browser_full_height(CHECKBROWSER c) {
    return static_cast<My_Check_Browser*>(c)->Fl_Check_Browser::full_height();
}

int fl_check_browser_incr_height(CHECKBROWSER c) {
    return static_cast<My_Check_Browser*>(c)->Fl_Check_Browser::incr_height();
}

int fl_check_browser_item_quick_height(CHECKBROWSER c, void * i) {
    return static_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_quick_height(i);
}




int fl_check_browser_item_width(CHECKBROWSER c, void * i) {
    return (static_cast<Fl_Check_Browser*>(c)->*(&Friend_Browser::item_width))(i);
    //  return static_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_width(i);
}

int fl_check_browser_item_height(CHECKBROWSER c, void * i) {
    return (static_cast<Fl_Check_Browser*>(c)->*(&Friend_Browser::item_height))(i);
    //  return static_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_height(i);
}

void * fl_check_browser_item_first(CHECKBROWSER c) {
    return (static_cast<Fl_Check_Browser*>(c)->*(&Friend_Browser::item_first))();
    //  return static_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_first();
}

//  missing item_last

void * fl_check_browser_item_next(CHECKBROWSER c, void * i) {
    return (static_cast<Fl_Check_Browser*>(c)->*(&Friend_Browser::item_next))(i);
    //  return static_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_next(i);
}

void * fl_check_browser_item_prev(CHECKBROWSER c, void * i) {
    return (static_cast<Fl_Check_Browser*>(c)->*(&Friend_Browser::item_prev))(i);
    //  return static_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_prev(i);
}

//  missing item_at

void fl_check_browser_item_select(CHECKBROWSER c, void * i, int v) {
    (static_cast<Fl_Check_Browser*>(c)->*(&Friend_Browser::item_select))(i, v);
    //  static_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_select(i, v);
}

int fl_check_browser_item_selected(CHECKBROWSER c, void * i) {
    return (static_cast<Fl_Check_Browser*>(c)->*(&Friend_Browser::item_selected))(i);
    //  return static_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_selected(i);
}

//  missing item_swap
//  missing item_text

void fl_check_browser_item_draw(CHECKBROWSER c, void * item, int x, int y, int w, int h) {
    (static_cast<Fl_Check_Browser*>(c)->*(&Friend_Browser::item_draw))(item, x, y, w, h);
    //  static_cast<My_Check_Browser*>(c)->Fl_Check_Browser::item_draw(item, x, y, w, h);
}




void fl_check_browser_draw(CHECKBROWSER c) {
    static_cast<My_Check_Browser*>(c)->Fl_Check_Browser::draw();
}

int fl_check_browser_handle(CHECKBROWSER c, int e) {
    return static_cast<My_Check_Browser*>(c)->Fl_Check_Browser::handle(e);
}


