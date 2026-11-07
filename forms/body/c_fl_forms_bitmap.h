

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FORMS_BITMAP_GUARD
#define FORMS_BITMAP_GUARD


typedef void* FORMS_BITMAP;


extern "C" FORMS_BITMAP new_fl_forms_bitmap(int x, int y, int w, int h, char * label);
extern "C" void free_fl_forms_bitmap(FORMS_BITMAP b);

extern "C" void fl_forms_bitmap_set_bitmap(FORMS_BITMAP b, void * i);


extern "C" void fl_forms_bitmap_draw(FORMS_BITMAP b);
extern "C" int fl_forms_bitmap_handle(FORMS_BITMAP b, int e);


#endif


