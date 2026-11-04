

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FL_ICO_IMAGE_GUARD
#define FL_ICO_IMAGE_GUARD


typedef void* ICOIMAGE;


extern "C" ICOIMAGE new_fl_ico_image(const char *name, int id);
extern "C" ICOIMAGE new_fl_ico_image2(const unsigned char *data, unsigned long size, int id);
extern "C" void free_fl_ico_image(ICOIMAGE i);


extern "C" int fl_ico_image_idcount(ICOIMAGE i);
extern "C" void fl_ico_image_entry(ICOIMAGE i, int k, unsigned int *fields);


#endif


