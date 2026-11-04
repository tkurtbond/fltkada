

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Fl.H>
#include <FL/Fl_Widget.H>
#include "c_fl_widget_tracker.h"




//  An Fl_Widget_Tracker registers the address of its own pointer with
//  Fl::watch_widget_pointer, so it must not move: it lives here, on the
//  heap.  ~Fl_Widget clears the pointer, and so does fl_widget_forget
//  when an FLTKAda widget is finalized, before any deferred delete.

WIDGETTRACKER new_fl_widget_tracker(void * w) {
    return new Fl_Widget_Tracker(static_cast<Fl_Widget*>(w));
}

void free_fl_widget_tracker(WIDGETTRACKER t) {
    delete static_cast<Fl_Widget_Tracker*>(t);
}




int fl_widget_tracker_exists(WIDGETTRACKER t) {
    return static_cast<Fl_Widget_Tracker*>(t)->exists();
}

