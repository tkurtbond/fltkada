

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl.H>
#include <FL/Fl_Menu_.H>
#include <FL/Fl_Window.H>
#include <FL/Fl_Menu_Item.H>
#include <cstdlib>
#include <cstring>
#include "c_fl_menu.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

extern "C" void menu_item_callback_hook(void * cobj, void * ud);




//  Attaching all relevant hooks and friends

class My_Menu : public Fl_Menu_ {
public:
    using Fl_Menu_::Fl_Menu_;

    friend void fl_menu_draw(MENU m);
    friend int fl_menu_handle(MENU m, int e);

    void draw();
    int handle(int e);
};

void My_Menu::draw() {
    widget_draw_hook(this->user_data());
}

int My_Menu::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

MENU new_fl_menu(int x, int y, int w, int h, char* label) {
    My_Menu *m = new My_Menu(x, y, w, h, label);
    return m;
}

void free_fl_menu(MENU m) {
    if (fl_inside_callback) {
        fl_delete_widget(m);
    } else {
        delete static_cast<My_Menu*>(m);
    }
}




int fl_menu_add(MENU m, const char * t) {
    return static_cast<Fl_Menu_*>(m)->add(t);
}

int fl_menu_add2(MENU m, const char * t, unsigned long s, void * u, unsigned long f) {
    return static_cast<Fl_Menu_*>(m)->add(t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_menu_add3(MENU m, const char * t, const char * s, void * u, unsigned long f) {
    return static_cast<Fl_Menu_*>(m)->add(t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_menu_insert(MENU m, int p, const char * t, unsigned long s, void * u, unsigned long f) {
    return static_cast<Fl_Menu_*>(m)->insert(p, t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

int fl_menu_insert2(MENU m, int p, const char * t, const char * s, void * u, unsigned long f) {
    return static_cast<Fl_Menu_*>(m)->insert(p, t, s,
        u==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), u, f);
}

//  Fl_Menu_::alloc is protected, and FLTK has no setter for it.  A pointer to
//  the member, formed in a class derived from Fl_Menu_, reaches it on any
//  Fl_Menu_.  The class is never instantiated.
class Menu_Alloc : public Fl_Menu_ {
public:
    static uchar Fl_Menu_::* member() {
        return &Menu_Alloc::alloc;
    }
};

//  Does an item own its text the way Fl_Menu_::clear frees it?  Image and
//  multi labels point to objects that are not freed (Fl_Menu_.cxx:576-587).
static bool owns_text(const Fl_Menu_Item & item) {
    return item.text != 0 &&
        item.labeltype_ != _FL_IMAGE_LABEL &&
        item.labeltype_ != _FL_MULTI_LABEL;
}

//  Returns a copy of the n items that i points to, with copies of their
//  texts, or 0 when out of memory.  The copy ends where Fl_Menu_Item::size
//  would end it (Fl_Menu.cxx:58-70), and terminators are added for any
//  submenu left open.
static Fl_Menu_Item * copy_items(const Fl_Menu_Item * const * i, int n) {
    int count = 0;
    int nest = 0;
    bool ended = false;
    for (int k = 0; k < n && !ended; k++) {
        count++;
        if (i[k]->text == 0) {
            if (nest == 0) {
                ended = true;
            } else {
                nest--;
            }
        } else if (i[k]->flags & FL_SUBMENU) {
            nest++;
        }
    }
    int copied = count;
    if (!ended) {
        count += nest + 1;
    }
    Fl_Menu_Item * items = 0;
    try {
        items = new Fl_Menu_Item[count];
    } catch (...) {
        return 0;
    }
    std::memset(static_cast<void*>(items), 0, count * sizeof(Fl_Menu_Item));
    for (int k = 0; k < copied; k++) {
        items[k] = *i[k];
        if (owns_text(items[k])) {
            items[k].text = strdup(items[k].text);
            if (items[k].text == 0) {
                for (int j = 0; j < k; j++) {
                    if (owns_text(items[j])) {
                        std::free(const_cast<char*>(items[j].text));
                    }
                }
                delete[] items;
                return 0;
            }
        }
    }
    return items;
}

//  Sets the menu to a copy of the n items that i points to, and makes the
//  menu own the copy and its texts, as if they had been added (alloc 2,
//  Fl_Menu_add.cxx:406), so clear() frees them.  Fl_Menu_::copy would share
//  the texts (alloc 1, Fl_Menu_.cxx:540), which the items' owners free.
//  Returns 0, or 1 when out of memory.
int fl_menu_set_items(MENU m, void * const * i, int n) {
    Fl_Menu_Item * items = copy_items(reinterpret_cast<const Fl_Menu_Item * const *>(i), n);
    if (items == 0) {
        return 1;
    }
    Fl_Menu_ * menu = static_cast<Fl_Menu_*>(m);
    menu->menu(items);
    menu->*Menu_Alloc::member() = 2;
    return 0;
}

//  Sets the menu to its own copy of the donor's items, as fl_menu_set_items
//  does.  Fl_Menu_::menu would share the donor's array (alloc 0,
//  Fl_Menu_.cxx:522-526), which the donor frees when it is deleted or when
//  add() outgrows it (Fl_Menu_add.cxx:55-60), and the donor's texts, which
//  it frees when it is cleared or an item is relabelled (FLTKAda-BUGS.md 38).
//  Returns 0, or 1 when out of memory.
int fl_menu_set_menu(MENU m, MENU d) {
    const Fl_Menu_Item * donor = static_cast<Fl_Menu_*>(d)->menu();
    Fl_Menu_ * menu = static_cast<Fl_Menu_*>(m);
    if (donor == 0) {
        menu->menu(0);
        return 0;
    }
    int n = donor->size();
    const Fl_Menu_Item ** pointers = 0;
    try {
        pointers = new const Fl_Menu_Item * [n];
    } catch (...) {
        return 1;
    }
    for (int k = 0; k < n; k++) {
        pointers[k] = donor + k;
    }
    Fl_Menu_Item * items = copy_items(pointers, n);
    delete[] pointers;
    if (items == 0) {
        return 1;
    }
    menu->menu(items);
    menu->*Menu_Alloc::member() = 2;
    return 0;
}


void fl_menu_remove(MENU m, int p) {
    static_cast<Fl_Menu_*>(m)->remove(p);
}

void fl_menu_clear(MENU m) {
    static_cast<Fl_Menu_*>(m)->clear();
}

int fl_menu_clear_submenu(MENU m, int i) {
    return static_cast<Fl_Menu_*>(m)->clear_submenu(i);
}




const void * fl_menu_get_item(MENU m, int i) {
    return &(static_cast<Fl_Menu_*>(m)->menu()[i]);
}

//  find_item and find_item2 are subsumed by find_index and find_index3
//  since we need to get the index for the Ada side anyway.

int fl_menu_find_index(MENU m, const char * t) {
    return static_cast<Fl_Menu_*>(m)->find_index(t);
}

int fl_menu_find_index2(MENU m, void * i) {
    return static_cast<Fl_Menu_*>(m)->find_index(static_cast<Fl_Menu_Item*>(i));
}

int fl_menu_find_index3(MENU m, void * cb) {
    //  have to loop through the array manually since callbacks are stored in userdata
    for (int i=0; i<fl_menu_size(m); i++) {
        if (static_cast<Fl_Menu_*>(m)->menu()[i].user_data() == cb) {
            return i;
        }
    }
    return -1;
}

int fl_menu_item_pathname(MENU m, char * buf, int len, void * mi) {
    return static_cast<Fl_Menu_*>(m)->item_pathname(buf, len, static_cast<Fl_Menu_Item*>(mi));
}

int fl_menu_size(MENU m) {
    return static_cast<Fl_Menu_*>(m)->size();
}




//  mvalue is subsumed by value since we need to get the index for
//  the Ada side anyway.

const char * fl_menu_text(MENU m) {
    return static_cast<Fl_Menu_*>(m)->text();
}

int fl_menu_value(MENU m) {
    return static_cast<Fl_Menu_*>(m)->value();
}

int fl_menu_set_value(MENU m, void * i) {
    return static_cast<Fl_Menu_*>(m)->value(static_cast<Fl_Menu_Item*>(i));
}

int fl_menu_set_value2(MENU m, int p) {
    return static_cast<Fl_Menu_*>(m)->value(p);
}




void fl_menu_setonly(MENU m, void * mi) {
    static_cast<Fl_Menu_*>(m)->setonly(static_cast<Fl_Menu_Item*>(mi));
}

const char * fl_menu_text2(MENU m, int i) {
    return static_cast<Fl_Menu_*>(m)->text(i);
}

//  Fl_Menu_::replace copies t only when the menu owns its strings (alloc > 1,
//  Fl_Menu_add.cxx:472-480), and otherwise keeps the pointer.  Returns 1 when
//  FLTK keeps t, so the caller must keep it alive, and sets *o to the text it
//  replaced.
int fl_menu_replace(MENU m, int i, const char * t, const char ** o) {
    Fl_Menu_ * menu = static_cast<Fl_Menu_*>(m);
    *o = 0;
    if (i < 0 || i >= menu->size()) {
        return 0;
    }
    *o = menu->menu()[i].text;
    menu->replace(i, t);
    return menu->menu()[i].text == t;
}

//  Points every item labelled t at a static empty string, before t is freed.
void fl_menu_forget_text(MENU m, const char * t) {
    Fl_Menu_ * menu = static_cast<Fl_Menu_*>(m);
    Fl_Menu_Item * items = const_cast<Fl_Menu_Item*>(menu->menu());
    if (items == 0) {
        return;
    }
    for (int i = 0; i < menu->size(); i++) {
        if (items[i].text == t) {
            items[i].text = "";
        }
    }
}

void fl_menu_shortcut(MENU m, int i, unsigned long s) {
    static_cast<Fl_Menu_*>(m)->shortcut(i, s);
}

unsigned long fl_menu_get_mode(MENU m, int i) {
    return static_cast<Fl_Menu_*>(m)->mode(i);
}

void fl_menu_set_mode(MENU m, int i, unsigned long f) {
    static_cast<Fl_Menu_*>(m)->mode(i, f);
}




unsigned int fl_menu_get_textcolor(MENU m) {
    return static_cast<Fl_Menu_*>(m)->textcolor();
}

void fl_menu_set_textcolor(MENU m, unsigned int c) {
    static_cast<Fl_Menu_*>(m)->textcolor(c);
}

int fl_menu_get_textfont(MENU m) {
    return static_cast<Fl_Menu_*>(m)->textfont();
}

void fl_menu_set_textfont(MENU m, int f) {
    static_cast<Fl_Menu_*>(m)->textfont(f);
}

int fl_menu_get_textsize(MENU m) {
    return static_cast<Fl_Menu_*>(m)->textsize();
}

void fl_menu_set_textsize(MENU m, int s) {
    static_cast<Fl_Menu_*>(m)->textsize(s);
}




int fl_menu_get_down_box(MENU m) {
    return static_cast<Fl_Menu_*>(m)->down_box();
}

void fl_menu_set_down_box(MENU m, int t) {
    static_cast<Fl_Menu_*>(m)->down_box(static_cast<Fl_Boxtype>(t));
}

void fl_menu_global(MENU m) {
    static_cast<Fl_Menu_*>(m)->global();
}

int fl_menu_measure(MENU m, int i, int *h) {
    //  method actually belongs to Fl_Menu_Item
    const Fl_Menu_Item * item = static_cast<const Fl_Menu_Item*>(fl_menu_get_item(m,i));
    return item==0?0:item->measure(h, static_cast<Fl_Menu_*>(m));
}




//  A menu popped up over a window not yet on the screen ends the program
//  under Wayland: "Fatal error no 1 in Wayland protocol: xdg_surface"
//  (pofltk 28).  FLTK makes the pop-up against the menu widget's top window,
//  or the first window if the widget is in none (Fl_Menu.cxx:987-996), and
//  waits for the pop-up's own expose but not that one's.  This waits for it
//  first, which returns at once once it is there, and on X11.
static void wait_for_parent(Fl_Widget * w) {
    Fl_Window * parent = (w != 0 && w->window() != 0) ? w->top_window() : Fl::first_window();
    if (parent != 0 && parent->shown()) {
        parent->wait_for_expose();
    }
}

const void * fl_menu_popup(MENU m, int x, int y, const char * t, int n) {
    //  method actually belongs to Fl_Menu_Item
    const Fl_Menu_Item * menuhead = static_cast<const Fl_Menu_Item*>(fl_menu_get_item(m, 0));
    const Fl_Menu_Item * initial  = n<0?0:static_cast<const Fl_Menu_Item*>(fl_menu_get_item(m, n));
    wait_for_parent(static_cast<Fl_Menu_*>(m));
    return menuhead->popup(x, y, t, initial, static_cast<Fl_Menu_*>(m));
}

const void * fl_menu_pulldown(MENU m, int x, int y, int w, int h, int n) {
    //  method actually belongs to Fl_Menu_Item
    const Fl_Menu_Item * menuhead = static_cast<const Fl_Menu_Item*>(fl_menu_get_item(m, 0));
    const Fl_Menu_Item * initial  = n<0?0:static_cast<const Fl_Menu_Item*>(fl_menu_get_item(m, n));
    wait_for_parent(static_cast<Fl_Menu_*>(m));
    return menuhead->pulldown(x, y, w, h, initial, static_cast<Fl_Menu_*>(m));
}

const void * fl_menu_picked(MENU m, const void * mi) {
    return static_cast<Fl_Menu_*>(m)->picked(static_cast<const Fl_Menu_Item*>(mi));
}

const void * fl_menu_find_shortcut(MENU m, void * ip, int a) {
    //  method actually belongs to Fl_Menu_Item
    const Fl_Menu_Item * dummy = static_cast<const Fl_Menu_Item*>(fl_menu_get_item(m, 0));
    return dummy==0?0:dummy->find_shortcut(static_cast<int*>(ip), static_cast<bool>(a));
}

const void * fl_menu_test_shortcut(MENU m) {
    return static_cast<Fl_Menu_*>(m)->test_shortcut();
}




void fl_menu_size2(MENU m, int w, int h) {
    static_cast<Fl_Menu_*>(m)->size(w, h);
}




void fl_menu_draw_item(MENU m, int i, int x, int y, int w, int h, int s) {
    //  method actually belongs to Fl_Menu_Item
    const Fl_Menu_Item * item = static_cast<const Fl_Menu_Item*>(fl_menu_get_item(m,i));
    if (item != 0) {
        item->draw(x, y, w, h, static_cast<Fl_Menu_*>(m), s);
    }
}

void fl_menu_draw(MENU m) {
    //  The Fl_Menu_ draw method doesn't technically exist, so...
    (void)(m);
    //  It is more convenient for this function to exist, however,
    //  even though it will likely never be called, because it simplifies
    //  and makes uniform the implementation of the Ada Menu Draw subprogram.
}

int fl_menu_handle(MENU m, int e) {
    return static_cast<My_Menu*>(m)->Fl_Menu_::handle(e);
}


