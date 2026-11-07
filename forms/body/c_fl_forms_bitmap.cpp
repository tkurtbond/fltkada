

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#include <FL/Fl_FormsBitmap.H>
#include "c_fl_forms_bitmap.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_FormsBitmap : public Ada_Resizing<Fl_FormsBitmap> {
public:
    using Ada_Resizing<Fl_FormsBitmap>::Ada_Resizing;

    friend void fl_forms_bitmap_draw(FORMS_BITMAP b);
    friend int fl_forms_bitmap_handle(FORMS_BITMAP b, int e);

    void draw();
    int handle(int e);
};

void My_FormsBitmap::draw() {
    widget_draw_hook(this->user_data());
}

int My_FormsBitmap::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

//  With no box, as pofltk's, and as FLTK's own fl_add_ functions make them.
FORMS_BITMAP new_fl_forms_bitmap(int x, int y, int w, int h, char * label) {
    My_FormsBitmap *b = new My_FormsBitmap(FL_NO_BOX, x, y, w, h, label);
    return b;
}

void free_fl_forms_bitmap(FORMS_BITMAP b) {
    if (fl_inside_callback) {
        fl_delete_widget(b);
    } else {
        delete static_cast<My_FormsBitmap*>(b);
    }
}




//  Not set(), which keeps its bits' pointer, deletes whatever image the
//  widget had, its own or not, and leaks the one it makes, as the widget
//  has no destructor (pofltk 106).  The Ada side keeps the image.
void fl_forms_bitmap_set_bitmap(FORMS_BITMAP b, void * i) {
    static_cast<Fl_FormsBitmap*>(b)->bitmap(static_cast<Fl_Bitmap*>(i));
    static_cast<Fl_FormsBitmap*>(b)->redraw();
}



void fl_forms_bitmap_draw(FORMS_BITMAP b) {
    static_cast<My_FormsBitmap*>(b)->Fl_FormsBitmap::draw();
}

int fl_forms_bitmap_handle(FORMS_BITMAP b, int e) {
    return static_cast<My_FormsBitmap*>(b)->Fl_FormsBitmap::handle(e);
}


