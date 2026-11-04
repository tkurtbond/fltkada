

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#ifndef FL_WIDGET_TRACKER_GUARD
#define FL_WIDGET_TRACKER_GUARD


typedef void* WIDGETTRACKER;


extern "C" WIDGETTRACKER new_fl_widget_tracker(void * w);
extern "C" void free_fl_widget_tracker(WIDGETTRACKER t);


extern "C" int fl_widget_tracker_exists(WIDGETTRACKER t);


#endif

