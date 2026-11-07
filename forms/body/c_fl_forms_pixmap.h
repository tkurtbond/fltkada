

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FORMS_PIXMAP_GUARD
#define FORMS_PIXMAP_GUARD


typedef void* FORMS_PIXMAP;


extern "C" FORMS_PIXMAP new_fl_forms_pixmap(int x, int y, int w, int h, char * label);
extern "C" void free_fl_forms_pixmap(FORMS_PIXMAP b);

extern "C" void fl_forms_pixmap_set_pixmap(FORMS_PIXMAP p, void * i);


extern "C" void fl_forms_pixmap_draw(FORMS_PIXMAP b);
extern "C" int fl_forms_pixmap_handle(FORMS_PIXMAP b, int e);


#endif


