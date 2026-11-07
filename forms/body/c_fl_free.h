

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FL_FREE_GUARD
#define FL_FREE_GUARD


typedef void* FREE;


extern "C" FREE new_fl_free(int k, int x, int y, int w, int h, char * label);
extern "C" void free_fl_free(FREE f);


extern "C" void fl_free_draw(FREE f);
extern "C" int fl_free_handle(FREE f, int e);


#endif


