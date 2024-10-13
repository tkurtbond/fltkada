

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_JPEG_IMAGE_GUARD
#define FL_JPEG_IMAGE_GUARD




typedef void* JPEG_IMAGE;




extern "C" JPEG_IMAGE new_fl_jpeg_image(const char * f);
extern "C" JPEG_IMAGE new_fl_jpeg_image2(const char * n, void *data);
extern "C" void free_fl_jpeg_image(JPEG_IMAGE j);


#endif

