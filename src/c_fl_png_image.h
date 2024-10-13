

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_PNG_IMAGE_GUARD
#define FL_PNG_IMAGE_GUARD




typedef void* PNG_IMAGE;




extern "C" PNG_IMAGE new_fl_png_image(const char * f);
extern "C" PNG_IMAGE new_fl_png_image2(const char *name, void *data, int size);
extern "C" void free_fl_png_image(PNG_IMAGE p);


#endif

