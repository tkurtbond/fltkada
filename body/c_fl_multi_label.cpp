

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Enumerations.H>
#include <FL/Fl_Multi_Label.H>
#include <FL/Fl_Widget.H>
#include "c_fl_multi_label.h"




//  Labeltypes other than the normal and none ones have to be registered
//  before they are drawn, which the C++ macros do as a side effect.

static Fl_Labeltype defined_labeltype(int k) {
    switch (k) {
    case _FL_SHADOW_LABEL:
        return FL_SHADOW_LABEL;
    case _FL_ENGRAVED_LABEL:
        return FL_ENGRAVED_LABEL;
    case _FL_EMBOSSED_LABEL:
        return FL_EMBOSSED_LABEL;
    case _FL_MULTI_LABEL:
        return FL_MULTI_LABEL;
    case _FL_ICON_LABEL:
        return FL_ICON_LABEL;
    case _FL_IMAGE_LABEL:
        return FL_IMAGE_LABEL;
    default:
        return static_cast<Fl_Labeltype>(k);
    }
}




//  Flattened C API

//  The text, images, and chained multi labels are all owned on the Ada side.

MULTILABEL new_fl_multi_label() {
    Fl_Multi_Label *ml = new Fl_Multi_Label;
    ml->labela = 0;
    ml->labelb = 0;
    ml->typea = FL_NO_LABEL;
    ml->typeb = FL_NO_LABEL;
    return ml;
}

void free_fl_multi_label(MULTILABEL ml) {
    delete static_cast<Fl_Multi_Label*>(ml);
}




void fl_multi_label_set_a(MULTILABEL ml, int k, const char * v) {
    static_cast<Fl_Multi_Label*>(ml)->typea = defined_labeltype(k);
    static_cast<Fl_Multi_Label*>(ml)->labela = v;
}

void fl_multi_label_set_b(MULTILABEL ml, int k, const char * v) {
    static_cast<Fl_Multi_Label*>(ml)->typeb = defined_labeltype(k);
    static_cast<Fl_Multi_Label*>(ml)->labelb = v;
}




//  Fl_Multi_Label::label(Fl_Widget *) sets the type and the pointer, and
//  leaves a label copy_label made marked as the widget's to free: the text
//  leaks, and the widget frees the multi-label (pofltk 55).  label(0)
//  frees the text and clears the mark first.
void fl_multi_label_widget(void * w, MULTILABEL ml) {
    Fl_Widget *wd = static_cast<Fl_Widget*>(w);
    wd->label(static_cast<const char *>(0));
    static_cast<Fl_Multi_Label*>(ml)->label(wd);
    wd->redraw();
}


