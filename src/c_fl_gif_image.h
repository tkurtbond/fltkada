

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_GIF_IMAGE_GUARD
#define FL_GIF_IMAGE_GUARD


typedef void* GIFIMAGE;


extern "C" GIFIMAGE new_fl_gif_image(const char * f);
extern "C" void free_fl_gif_image(GIFIMAGE j);


#endif


