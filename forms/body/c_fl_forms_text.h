

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FORMS_TEXT_GUARD
#define FORMS_TEXT_GUARD


typedef void* FORMS_TEXT;


extern "C" FORMS_TEXT new_fl_forms_text(int x, int y, int w, int h, char * label);
extern "C" void free_fl_forms_text(FORMS_TEXT b);


extern "C" void fl_forms_text_draw(FORMS_TEXT b);
extern "C" int fl_forms_text_handle(FORMS_TEXT b, int e);


#endif


