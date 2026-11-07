

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#include <FL/forms.H>
#include "c_fl_forms_text.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_FormsText : public Ada_Resizing<Fl_FormsText> {
public:
    using Ada_Resizing<Fl_FormsText>::Ada_Resizing;

    friend void fl_forms_text_draw(FORMS_TEXT b);
    friend int fl_forms_text_handle(FORMS_TEXT b, int e);

    void draw();
    int handle(int e);
};

void My_FormsText::draw() {
    widget_draw_hook(this->user_data());
}

int My_FormsText::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

//  With no box, as pofltk's, and as FLTK's own fl_add_ functions make them.
FORMS_TEXT new_fl_forms_text(int x, int y, int w, int h, char * label) {
    My_FormsText *b = new My_FormsText(FL_NO_BOX, x, y, w, h, label);
    return b;
}

void free_fl_forms_text(FORMS_TEXT b) {
    if (fl_inside_callback) {
        fl_delete_widget(b);
    } else {
        delete static_cast<My_FormsText*>(b);
    }
}




void fl_forms_text_draw(FORMS_TEXT b) {
    static_cast<My_FormsText*>(b)->Fl_FormsText::draw();
}

int fl_forms_text_handle(FORMS_TEXT b, int e) {
    return static_cast<My_FormsText*>(b)->Fl_FormsText::handle(e);
}


