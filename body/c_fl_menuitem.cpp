

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Menu_Item.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Image.H>
#include <FL/Fl_Menu_.H>
#include <FL/Fl_Multi_Label.H>
#include <FL/fl_draw.H>
#include <cstdlib>
#include <cstring>
#include <new>
#include <set>
#include "c_fl_menuitem.h"




//  Exports from Ada

extern "C" void menu_item_callback_hook(void * cobj, void * ud);




//  Label Ownership

//  Text labels are always strdup'd, so that they are owned by the item the
//  same way Fl_Menu_ owns the labels of the items it adds.  Images and
//  multi-labels are owned on the Ada side, and are never freed here.

//  An item showing an image or a multi-label holds a pointer to it in its
//  text, and FLTK still reads that text as the item's name: Fl_Menu_::insert
//  finds a path's submenus by it, find_index and item_pathname make paths of
//  it, and remove and replace free() it (Fl_Menu_add.cxx:472-506, pofltk 54).
//  So such an item shows an Item_Label instead: a multi-label of its own,
//  whose first part is the image or the user's multi-label, with the item's
//  name beside it.  The item's text points at the Item_Label, which its ml,
//  first, makes an Fl_Multi_Label.  Each Item_Label is one item's; a copy
//  of the item gets its own.  The menu shims give the items their names as
//  text before FLTK reads or frees them (plain_items, Item_Names).

struct Item_Label {
    Fl_Multi_Label ml;
    char * name;
};

static std::set<const void*> & live_labels() {
    static std::set<const void*> labels;
    return labels;
}

static Item_Label * item_label(const Fl_Menu_Item * mi) {
    if (mi->text == 0 || mi->labeltype_ != _FL_MULTI_LABEL ||
        live_labels().count(mi->text) == 0)
    {
        return 0;
    }
    return reinterpret_cast<Item_Label*>(const_cast<char*>(mi->text));
}

//  A new Item_Label showing labela, of type typea, or 0 when out of memory.
static Item_Label * new_item_label(Fl_Labeltype typea, const char * labela, char * name) {
    Item_Label * l = new (std::nothrow) Item_Label;
    if (l == 0) {
        return 0;
    }
    try {
        live_labels().insert(l);
    } catch (...) {
        delete l;
        return 0;
    }
    l->ml.typea = typea;
    l->ml.labela = labela;
    l->ml.typeb = FL_NO_LABEL;
    l->ml.labelb = 0;
    l->name = name;
    return l;
}

static void delete_item_label(Item_Label * l) {
    live_labels().erase(l);
    delete l;
}

const char * item_name(const Fl_Menu_Item * mi) {
    Item_Label * l = item_label(mi);
    return l == 0 ? mi->text : l->name;
}

static void plain_item(Fl_Menu_Item * mi) {
    Item_Label * l = item_label(mi);
    if (l != 0) {
        mi->text = l->name;
        mi->labeltype_ = FL_NORMAL_LABEL;
        delete_item_label(l);
    }
}

//  Gives items from to to - 1 their names as text again.
void plain_items(Fl_Menu_Item * items, int from, int to) {
    if (items == 0) {
        return;
    }
    for (int i = from; i < to; i++) {
        plain_item(items + i);
    }
}

void plain_menu(Fl_Menu_ * m) {
    plain_items(const_cast<Fl_Menu_Item*>(m->menu()), 0, m->size());
}

//  The index after item i and its submenu, if it has one.
int item_after(const Fl_Menu_ * m, int i) {
    const Fl_Menu_Item * items = m->menu();
    return static_cast<int>(items[i].next() - items);
}

//  Gives copy, a copy of an item, its own Item_Label if it shows one.
//  Returns false when out of memory, and copy is then text.
bool copy_item_label(Fl_Menu_Item & copy) {
    Item_Label * l = item_label(&copy);
    if (l == 0) {
        return true;
    }
    copy.labeltype_ = FL_NORMAL_LABEL;
    copy.text = 0;
    char * name = 0;
    if (l->name != 0) {
        name = strdup(l->name);
        if (name == 0) {
            return false;
        }
    }
    Item_Label * c = new_item_label(static_cast<Fl_Labeltype>(l->ml.typea), l->ml.labela, name);
    if (c == 0) {
        free(name);
        return false;
    }
    copy.label(FL_MULTI_LABEL, reinterpret_cast<const char*>(c));
    return true;
}

//  Frees a copy's text, and its Item_Label if it has one.
void free_item_label(Fl_Menu_Item & copy) {
    plain_item(&copy);
    if (copy.labeltype_ != _FL_IMAGE_LABEL && copy.labeltype_ != _FL_MULTI_LABEL) {
        free(const_cast<char*>(copy.text));
    }
    copy.text = 0;
}

//  A label for Fl_Menu_Item::insert, each of its parts between '/'s cut to
//  1023 bytes.  insert copies each part, its '\' escapes undone, into a
//  1024-byte buffer on the stack with no bound (Fl_Menu_add.cxx:147,163;
//  pofltk 172).  An escape counts as the one byte it becomes, and the cut
//  falls where a UTF-8 character starts.  A part starting with '/' is the
//  rest of the label, which insert takes whole without copying, so it is
//  kept whole.  From pofltk's ofl::menu_path.
std::string menu_path(const char * s) {
    const size_t most = 1023;
    std::string r;
    for (;;) {
        if (*s == '/') {
            r += s;
            break;
        }
        if (*s == '_') {
            r += *s++;  //  a divider before the item, not copied
        }
        size_t n = 0;             //  the part's bytes, escapes undone
        size_t start = r.size();  //  where the last character starts in r
        while (*s && *s != '/') {
            size_t w = s[0] == '\\' && s[1] ? 2 : 1;
            unsigned char c = static_cast<unsigned char>(s[w - 1]);
            bool lead = (c & 0xC0) != 0x80;
            if (n == most) {
                if (!lead) {
                    r.resize(start);
                }
                while (*s && *s != '/') {
                    s += s[0] == '\\' && s[1] ? 2 : 1;
                }
                break;
            }
            if (lead) {
                start = r.size();
            }
            r.append(s, w);
            s += w;
            n++;
        }
        if (*s != '/') {
            break;
        }
        r += *s++;
    }
    return r;
}

//  Fl_Menu_::add (const char *), split here.  FLTK's cuts a part between
//  '|'s after 1022 bytes into several items, dropping the byte at each cut
//  (FLTK-issues.md F11), and reads a shortcut from the tab before it, which
//  strtol skips, so "^a" gives none (Fl_Menu_add.cxx:445-460; pofltk 173).
//  Here each part is one item: its label ends at its first tab and is cut
//  by menu_path, and its shortcut is what follows the last tab, read by
//  fl_old_shortcut.  From pofltk's ofl_input_choice_add.
std::vector<Menu_Part> menu_parts(const char * s) {
    std::vector<Menu_Part> parts;
    while (*s) {
        size_t n = strcspn(s, "|");
        std::string part(s, n);
        Menu_Part p;
        p.shortcut = 0;
        size_t tab = part.find('\t');
        if (tab != std::string::npos) {
            p.shortcut = static_cast<int>(fl_old_shortcut(part.c_str() + part.rfind('\t') + 1));
            part.resize(tab);
        }
        p.label = menu_path(part.c_str());
        parts.push_back(p);
        s += n;
        if (*s) {
            s++;
        }
    }
    return parts;
}

Item_Names::Item_Names(Fl_Menu_ * m) : menu(m) {
    Fl_Menu_Item * items = const_cast<Fl_Menu_Item*>(m->menu());
    for (int i = 0; items != 0 && i < m->size(); i++) {
        Item_Label * l = item_label(items + i);
        if (l != 0) {
            try {
                labels.push_back(l);
            } catch (...) {
                continue;
            }
            items[i].text = l->name;
        }
    }
}

Item_Names::~Item_Names() {
    if (labels.empty()) {
        return;
    }
    Fl_Menu_Item * items = const_cast<Fl_Menu_Item*>(menu->menu());
    for (int i = 0; items != 0 && i < menu->size(); i++) {
        for (size_t k = 0; k < labels.size(); k++) {
            if (items[i].text == labels[k]->name && items[i].labeltype_ == _FL_MULTI_LABEL) {
                items[i].text = reinterpret_cast<const char*>(labels[k]);
            }
        }
    }
}

static void free_text_label(Fl_Menu_Item * mi) {
    Item_Label * l = item_label(mi);
    if (l != 0) {
        free(l->name);
        delete_item_label(l);
    } else if (mi->text != 0 &&
        mi->labeltype_ != _FL_IMAGE_LABEL &&
        mi->labeltype_ != _FL_MULTI_LABEL)
    {
        free(const_cast<char*>(mi->text));
    }
    mi->text = 0;
}

//  Makes the item show labela, of type typea, beside its name.
static void show_label(Fl_Menu_Item * mi, Fl_Labeltype typea, const char * labela) {
    Item_Label * l = new_item_label(typea, labela, 0);
    if (l == 0) {
        return;
    }
    Item_Label * old = item_label(mi);
    if (old != 0) {
        l->name = old->name;
        delete_item_label(old);
    } else if (mi->labeltype_ != _FL_IMAGE_LABEL && mi->labeltype_ != _FL_MULTI_LABEL) {
        l->name = const_cast<char*>(mi->text);
    }
    mi->label(FL_MULTI_LABEL, reinterpret_cast<const char*>(l));
}




//  Flattened C API

void * null_fl_menu_item() {
    //  Value-initialised (the ()), so every field FLTK reads is 0, as in a
    //  static Fl_Menu_Item array; plain new left them unset.
    Fl_Menu_Item *mi = new Fl_Menu_Item();
    mi->label(0);
    return mi;
}

void * new_fl_menu_item(char * t, void * c, int s, int f) {
    Fl_Menu_Item *mi = new Fl_Menu_Item();
    mi->callback(c==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), c);
    mi->flags = static_cast<int>(f);
    mi->shortcut(static_cast<int>(s));
    mi->label(t==0?0:strdup(t));
    return mi;
}

void free_fl_menu_item(MENUITEM mi) {
    free_text_label(static_cast<Fl_Menu_Item*>(mi));
    delete static_cast<Fl_Menu_Item*>(mi);
}




void * fl_menu_item_get_user_data(MENUITEM mi) {
    return static_cast<Fl_Menu_Item*>(mi)->user_data();
}

void fl_menu_item_set_callback(MENUITEM mi, void * c) {
    static_cast<Fl_Menu_Item*>(mi)->callback
        (c==0?0:reinterpret_cast<Fl_Callback_p>(&menu_item_callback_hook), c);
}

void fl_menu_item_do_callback(MENUITEM mi, void * w) {
    static_cast<Fl_Menu_Item*>(mi)->do_callback(static_cast<Fl_Widget*>(w));
}




int fl_menu_item_checkbox(MENUITEM mi) {
    return static_cast<Fl_Menu_Item*>(mi)->checkbox();
}

int fl_menu_item_radio(MENUITEM mi) {
    return static_cast<Fl_Menu_Item*>(mi)->radio();
}

int fl_menu_item_submenu(MENUITEM mi) {
    return static_cast<Fl_Menu_Item*>(mi)->submenu();
}

int fl_menu_item_value(MENUITEM mi) {
    return static_cast<Fl_Menu_Item*>(mi)->value();
}

void fl_menu_item_set(MENUITEM mi) {
    static_cast<Fl_Menu_Item*>(mi)->set();
}

void fl_menu_item_clear(MENUITEM mi) {
    static_cast<Fl_Menu_Item*>(mi)->clear();
}

void fl_menu_item_setonly(MENUITEM mi) {
    static_cast<Fl_Menu_Item*>(mi)->setonly();
}




const char * fl_menu_item_get_label(MENUITEM mi) {
    return item_name(static_cast<Fl_Menu_Item*>(mi));
}

//  The label of a multi-label, a file icon or an image label is a pointer
//  to it, not text (Fl_Multi_Label.cxx:28, Fl_File_Icon.cxx:425,
//  Fl_Image.cxx:224).
static bool pointer_type(int t) {
    return t == _FL_MULTI_LABEL || t == _FL_ICON_LABEL || t == _FL_IMAGE_LABEL;
}

//  Text given to an item showing an image or a multi-label is shown as
//  FL_NORMAL_LABEL, which FLTK doesn't read as a pointer (FLTKAda-BUGS.md 83).
void fl_menu_item_set_label(MENUITEM mi, const char *t) {
    Fl_Menu_Item * item = static_cast<Fl_Menu_Item*>(mi);
    free_text_label(item);
    if (pointer_type(item->labeltype_)) {
        item->labeltype_ = FL_NORMAL_LABEL;
    }
    item->label(t==0?0:strdup(t));
}

void fl_menu_item_set_label2(MENUITEM mi, int k, const char * t) {
    fl_menu_item_set_label(mi, t);
    fl_menu_item_set_labeltype(mi, k);
}

unsigned int fl_menu_item_get_labelcolor(MENUITEM mi) {
    return static_cast<Fl_Menu_Item*>(mi)->labelcolor();
}

void fl_menu_item_set_labelcolor(MENUITEM mi, unsigned int c) {
    static_cast<Fl_Menu_Item*>(mi)->labelcolor(c);
}

int fl_menu_item_get_labelfont(MENUITEM mi) {
    return static_cast<Fl_Menu_Item*>(mi)->labelfont();
}

void fl_menu_item_set_labelfont(MENUITEM mi, int f) {
    static_cast<Fl_Menu_Item*>(mi)->labelfont(f);
}

int fl_menu_item_get_labelsize(MENUITEM mi) {
    return static_cast<Fl_Menu_Item*>(mi)->labelsize();
}

void fl_menu_item_set_labelsize(MENUITEM mi, int s) {
    static_cast<Fl_Menu_Item*>(mi)->labelsize(s);
}

int fl_menu_item_get_labeltype(MENUITEM mi) {
    Item_Label * l = item_label(static_cast<Fl_Menu_Item*>(mi));
    return l == 0 ? static_cast<Fl_Menu_Item*>(mi)->labeltype() : l->ml.typea;
}

//  An item showing an image or a multi-label keeps it when given either
//  type again, and shows its name when given another.  None of the types
//  whose label is a pointer is given to text, which FLTK would read as the
//  pointer (FLTKAda-BUGS.md 83).
void fl_menu_item_set_labeltype(MENUITEM mi, int t) {
    Fl_Menu_Item * item = static_cast<Fl_Menu_Item*>(mi);
    if (pointer_type(t)) {
        return;
    }
    plain_item(item);
    item->labeltype(static_cast<Fl_Labeltype>(t));
}




int fl_menu_item_get_shortcut(MENUITEM mi) {
    return static_cast<Fl_Menu_Item*>(mi)->shortcut();
}

void fl_menu_item_set_shortcut(MENUITEM mi, int s) {
    static_cast<Fl_Menu_Item*>(mi)->shortcut(s);
}

int fl_menu_item_get_flags(MENUITEM mi) {
    return static_cast<Fl_Menu_Item*>(mi)->flags;
}

//  An item in a menu keeps FL_SUBMENU and FL_SUBMENU_POINTER, which give
//  the array its shape (FLTKAda-BUGS.md 106).  An item not yet in one may
//  set them.
void fl_menu_item_set_flags(MENUITEM mi, int f, int keep_shape) {
    Fl_Menu_Item * item = static_cast<Fl_Menu_Item*>(mi);
    const int shape = FL_SUBMENU | FL_SUBMENU_POINTER;
    item->flags = keep_shape ? (item->flags & shape) | (f & ~shape) : f;
}




void fl_menu_item_image(MENUITEM mi, void * i) {
    show_label(static_cast<Fl_Menu_Item*>(mi), FL_IMAGE_LABEL, static_cast<const char*>(i));
}

void fl_menu_item_multi_label(MENUITEM mi, void * ml) {
    show_label(static_cast<Fl_Menu_Item*>(mi), FL_MULTI_LABEL, static_cast<const char*>(ml));
}




void fl_menu_item_activate(MENUITEM mi) {
    static_cast<Fl_Menu_Item*>(mi)->activate();
}

void fl_menu_item_deactivate(MENUITEM mi) {
    static_cast<Fl_Menu_Item*>(mi)->deactivate();
}

void fl_menu_item_show(MENUITEM mi) {
    static_cast<Fl_Menu_Item*>(mi)->show();
}

void fl_menu_item_hide(MENUITEM mi) {
    static_cast<Fl_Menu_Item*>(mi)->hide();
}

int fl_menu_item_active(MENUITEM mi) {
    return static_cast<Fl_Menu_Item*>(mi)->active();
}

int fl_menu_item_visible(MENUITEM mi) {
    return static_cast<Fl_Menu_Item*>(mi)->visible();
}

int fl_menu_item_activevisible(MENUITEM mi) {
    return static_cast<Fl_Menu_Item*>(mi)->activevisible();
}


