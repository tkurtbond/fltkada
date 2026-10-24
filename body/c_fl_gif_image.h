

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_GIF_IMAGE_GUARD
#define FL_GIF_IMAGE_GUARD


#include <stddef.h>


typedef void* GIFIMAGE;


extern "C" GIFIMAGE new_fl_gif_image(const char * f);
extern "C" GIFIMAGE new_fl_gif_image2(const char * n, void * d, size_t l);
extern "C" void free_fl_gif_image(GIFIMAGE j);


extern "C" int fl_gif_image_get_animate();
extern "C" void fl_gif_image_set_animate(int a);
extern "C" int fl_gif_image_is_animated(const char * f);


#endif


