

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Menu_Item.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Image.H>
#include <cstdlib>
#include <cstring>
#include "c_fl_menuitem.h"




//  Exports from Ada

extern "C" void menu_item_callback_hook(void * cobj, void * ud);




//  Label Ownership

//  Text labels are always strdup'd, so that they are owned by the item the
//  same way Fl_Menu_ owns the labels of the items it adds.  Image and multi
//  labels point to objects owned on the Ada side, and are never freed here.

static void free_text_label(Fl_Menu_Item * mi) {
    if (mi->text != 0 &&
        mi->labeltype_ != _FL_IMAGE_LABEL &&
        mi->labeltype_ != _FL_MULTI_LABEL)
    {
        free(const_cast<char*>(mi->text));
    }
    mi->text = 0;
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
    return static_cast<Fl_Menu_Item*>(mi)->label();
}

void fl_menu_item_set_label(MENUITEM mi, const char *t) {
    free_text_label(static_cast<Fl_Menu_Item*>(mi));
    static_cast<Fl_Menu_Item*>(mi)->label(t==0?0:strdup(t));
}

void fl_menu_item_set_label2(MENUITEM mi, int k, const char * t) {
    free_text_label(static_cast<Fl_Menu_Item*>(mi));
    static_cast<Fl_Menu_Item*>(mi)->label(static_cast<Fl_Labeltype>(k), t==0?0:strdup(t));
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
    return static_cast<Fl_Menu_Item*>(mi)->labeltype();
}

void fl_menu_item_set_labeltype(MENUITEM mi, int t) {
    static_cast<Fl_Menu_Item*>(mi)->labeltype(static_cast<Fl_Labeltype>(t));
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

void fl_menu_item_set_flags(MENUITEM mi, int f) {
    static_cast<Fl_Menu_Item*>(mi)->flags = f;
}




void fl_menu_item_image(MENUITEM mi, void * i) {
    free_text_label(static_cast<Fl_Menu_Item*>(mi));
    static_cast<Fl_Menu_Item*>(mi)->image(static_cast<Fl_Image*>(i));
}

void fl_menu_item_multi_label(MENUITEM mi, void * ml) {
    free_text_label(static_cast<Fl_Menu_Item*>(mi));
    static_cast<Fl_Menu_Item*>(mi)->multi_label(static_cast<Fl_Multi_Label*>(ml));
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


