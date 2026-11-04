

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#ifndef FL_MULTI_LABEL_GUARD
#define FL_MULTI_LABEL_GUARD


typedef void* MULTILABEL;


extern "C" MULTILABEL new_fl_multi_label();
extern "C" void free_fl_multi_label(MULTILABEL ml);


extern "C" void fl_multi_label_set_a(MULTILABEL ml, int k, const char * v);
extern "C" void fl_multi_label_set_b(MULTILABEL ml, int k, const char * v);


extern "C" void fl_multi_label_widget(void * w, MULTILABEL ml);


#endif


