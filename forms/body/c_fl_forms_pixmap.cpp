

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#include <FL/Fl_FormsPixmap.H>
#include "c_fl_forms_pixmap.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_FormsPixmap : public Ada_Resizing<Fl_FormsPixmap> {
public:
    using Ada_Resizing<Fl_FormsPixmap>::Ada_Resizing;

    friend void fl_forms_pixmap_draw(FORMS_PIXMAP b);
    friend int fl_forms_pixmap_handle(FORMS_PIXMAP b, int e);

    void draw();
    int handle(int e);
};

void My_FormsPixmap::draw() {
    widget_draw_hook(this->user_data());
}

int My_FormsPixmap::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

//  With no box, as pofltk's, and as FLTK's own fl_add_ functions make them.
FORMS_PIXMAP new_fl_forms_pixmap(int x, int y, int w, int h, char * label) {
    My_FormsPixmap *b = new My_FormsPixmap(FL_NO_BOX, x, y, w, h, label);
    return b;
}

void free_fl_forms_pixmap(FORMS_PIXMAP b) {
    if (fl_inside_callback) {
        fl_delete_widget(b);
    } else {
        delete static_cast<My_FormsPixmap*>(b);
    }
}




//  Not set(), for the reasons fl_forms_bitmap_set_bitmap gives (pofltk
//  106).  The Ada side keeps the image.
void fl_forms_pixmap_set_pixmap(FORMS_PIXMAP p, void * i) {
    static_cast<Fl_FormsPixmap*>(p)->Pixmap(static_cast<Fl_Pixmap*>(i));
    static_cast<Fl_FormsPixmap*>(p)->redraw();
}



void fl_forms_pixmap_draw(FORMS_PIXMAP b) {
    static_cast<My_FormsPixmap*>(b)->Fl_FormsPixmap::draw();
}

int fl_forms_pixmap_handle(FORMS_PIXMAP b, int e) {
    return static_cast<My_FormsPixmap*>(b)->Fl_FormsPixmap::handle(e);
}


