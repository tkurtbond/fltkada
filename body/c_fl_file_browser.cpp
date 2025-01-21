

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_File_Browser.H>
#include <FL/Fl_Browser.H>
#include <FL/filename.H>
#include "c_fl_file_browser.h"




//  Exports from Ada

extern "C" int browser_full_width_hook(void * b);
//  extern "C" int browser_full_height_hook(void * b);
//  extern "C" int browser_incr_height_hook(void * b);
extern "C" int browser_item_quick_height_hook(void * b, void * i);

//  extern "C" int browser_item_width_hook(void * b, void * i);
//  extern "C" int browser_item_height_hook(void * b, void * i);
extern "C" void * browser_item_first_hook(void * b);
extern "C" void * browser_item_last_hook(void * b);
extern "C" void * browser_item_next_hook(void * b, void * i);
extern "C" void * browser_item_prev_hook(void * b, void * i);
extern "C" void * browser_item_at_hook(void * b, int n);
extern "C" void browser_item_select_hook(void * b, void * i, int s);
extern "C" int browser_item_selected_hook(void * b, void * i);
extern "C" void browser_item_swap_hook(void * b, void * one, void * two);
extern "C" const char * browser_item_text_hook(void * b, void * i);
//  extern "C" void browser_item_draw_hook(void * b, void * i, int x, int y, int w, int h);

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Non-friend protected / private access

//  Should check these in future versions of FLTK to see whether
//  it is possible to change them back to being overridden properly.

class Friend_Browser : Fl_Browser {
public:
    using Fl_Browser::full_height;
    using Fl_Browser::incr_height;
    using Fl_Browser::item_width;
    using Fl_Browser::item_height;
    using Fl_Browser::item_draw;
};




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

    friend int fl_file_browser_full_width(FILEBROWSER c);
    friend int fl_file_browser_full_height(FILEBROWSER c);
    friend int fl_file_browser_incr_height(FILEBROWSER c);
    friend int fl_file_browser_item_quick_height(FILEBROWSER c, void * i);

    friend void fl_file_browser_draw(FILEBROWSER b);

    int handle(int e);

protected:
    int full_width() const;
    //  int full_height() const;
    //  int incr_height() const;
    int item_quick_height(void * item) const;

    //  int item_width(void * item) const;
    //  int item_height(void * item) const;
    void * item_first() const;
    void * item_last() const;
    void * item_next(void * item) const;
    void * item_prev(void * item) const;
    void * item_at(int index) const;
    void item_select(void * item, int val=1);
    int item_selected(void * item) const;
    void item_swap(void * a, void * b);
    const char * item_text(void * item) const;
    //  void item_draw(void * item, int x, int y, int w, int h) const;

    void draw();
};


int My_File_Browser::full_width() const {
    return browser_full_width_hook(this->user_data());
}

//  int My_File_Browser::full_height() const {
//      return browser_full_height_hook(this->user_data());
//  }

//  int My_File_Browser::incr_height() const {
//      return browser_incr_height_hook(this->user_data());
//  }

int My_File_Browser::item_quick_height(void * item) const {
    return browser_item_quick_height_hook(this->user_data(), item);
}


//  int My_File_Browser::item_width(void * item) const {
//      return browser_item_width_hook(this->user_data(), item);
//  }

//  int My_File_Browser::item_height(void * item) const {
//      return browser_item_height_hook(this->user_data(), item);
//  }

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

//  void My_File_Browser::item_draw(void * item, int x, int y, int w, int h) const {
//      browser_item_draw_hook(this->user_data(), item, x, y, w, h);
//  }


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
    delete static_cast<My_File_Browser*>(b);
}




int fl_file_browser_load(FILEBROWSER b, const char * d, void * s) {
    return static_cast<Fl_File_Browser*>(b)->load(d, reinterpret_cast<Fl_File_Sort_F*>(s));
}




int fl_file_browser_get_filetype(FILEBROWSER b) {
    return static_cast<Fl_File_Browser*>(b)->filetype();
}

void fl_file_browser_set_filetype(FILEBROWSER b, int f) {
    static_cast<Fl_File_Browser*>(b)->filetype(f);
}

const char * fl_file_browser_get_filter(FILEBROWSER b) {
    return static_cast<Fl_File_Browser*>(b)->filter();
}

void fl_file_browser_set_filter(FILEBROWSER b, const char * f) {
    static_cast<Fl_File_Browser*>(b)->filter(f);
}

unsigned char fl_file_browser_get_iconsize(FILEBROWSER b) {
    return static_cast<Fl_File_Browser*>(b)->iconsize();
}

void fl_file_browser_set_iconsize(FILEBROWSER b, unsigned int i) {
    static_cast<Fl_File_Browser*>(b)->iconsize(i);
}

int fl_file_browser_get_textsize(FILEBROWSER b) {
    return static_cast<Fl_File_Browser*>(b)->textsize();
}

void fl_file_browser_set_textsize(FILEBROWSER b, int s) {
    static_cast<Fl_File_Browser*>(b)->textsize(s);
}




//  These have to be reimplemented due to relying on custom class extensions


int fl_file_browser_full_height(FILEBROWSER c) {
    //  return static_cast<My_File_Browser*>(c)->Fl_File_Browser::full_height();
    return (static_cast<Fl_File_Browser*>(c)->*(&Friend_Browser::full_height))();
}

int fl_file_browser_incr_height(FILEBROWSER c) {
    //  return static_cast<My_File_Browser*>(c)->Fl_File_Browser::incr_height();
    return (static_cast<Fl_File_Browser*>(c)->*(&Friend_Browser::incr_height))();
}




int fl_file_browser_item_width(FILEBROWSER b, void * item) {
    //  return static_cast<My_File_Browser*>(b)->Fl_File_Browser::item_width(item);
    return (static_cast<Fl_File_Browser*>(b)->*(&Friend_Browser::item_width))(item);
}

int fl_file_browser_item_height(FILEBROWSER b, void * item) {
    //  return static_cast<My_File_Browser*>(b)->Fl_File_Browser::item_height(item);
    return (static_cast<Fl_File_Browser*>(b)->*(&Friend_Browser::item_height))(item);
}

void * fl_file_browser_item_first(FILEBROWSER b) {
    return static_cast<My_File_Browser*>(b)->Fl_File_Browser::item_first();
}

void * fl_file_browser_item_last(FILEBROWSER b) {
    return static_cast<My_File_Browser*>(b)->Fl_File_Browser::item_last();
}

void * fl_file_browser_item_next(FILEBROWSER b, void * item) {
    return static_cast<My_File_Browser*>(b)->Fl_File_Browser::item_next(item);
}

void * fl_file_browser_item_prev(FILEBROWSER b, void * item) {
    return static_cast<My_File_Browser*>(b)->Fl_File_Browser::item_prev(item);
}

void * fl_file_browser_item_at(FILEBROWSER b, int index) {
    return static_cast<My_File_Browser*>(b)->Fl_File_Browser::item_at(index);
}

void fl_file_browser_item_select(FILEBROWSER b, void * item, int val) {
    static_cast<My_File_Browser*>(b)->Fl_File_Browser::item_select(item, val);
}

int fl_file_browser_item_selected(FILEBROWSER b, void * item) {
    return static_cast<My_File_Browser*>(b)->Fl_File_Browser::item_selected(item);
}

void fl_file_browser_item_swap(FILEBROWSER b, void * x, void * y) {
    static_cast<My_File_Browser*>(b)->Fl_File_Browser::item_swap(x, y);
}

const char * fl_file_browser_item_text(FILEBROWSER b, void * item) {
    return static_cast<My_File_Browser*>(b)->Fl_File_Browser::item_text(item);
}

void fl_file_browser_item_draw(FILEBROWSER b, void * item, int x, int y, int w, int h) {
    //  static_cast<My_File_Browser*>(b)->Fl_File_Browser::item_draw(item, x, y, w, h);
    (static_cast<Fl_File_Browser*>(b)->*(&Friend_Browser::item_draw))(item, x, y, w, h);
}




int fl_file_browser_full_width(FILEBROWSER c) {
    return static_cast<My_File_Browser*>(c)->Fl_File_Browser::full_width();
}

int fl_file_browser_item_quick_height(FILEBROWSER c, void * i) {
    return static_cast<My_File_Browser*>(c)->Fl_File_Browser::item_quick_height(i);
}




void fl_file_browser_draw(FILEBROWSER b) {
    static_cast<My_File_Browser*>(b)->Fl_File_Browser::draw();
}

int fl_file_browser_handle(FILEBROWSER b, int e) {
    return static_cast<My_File_Browser*>(b)->Fl_File_Browser::handle(e);
}


