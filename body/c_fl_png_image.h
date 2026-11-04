

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_PNG_IMAGE_GUARD
#define FL_PNG_IMAGE_GUARD


typedef void* PNGIMAGE;


extern "C" PNGIMAGE new_fl_png_image(const char * f);
extern "C" PNGIMAGE new_fl_png_image2(const char *name, void *data, int size);
extern "C" void free_fl_png_image(PNGIMAGE p);


extern "C" int fl_png_image_write(const char *name, void *rgb);


#endif


