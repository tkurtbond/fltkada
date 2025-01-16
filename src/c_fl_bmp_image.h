

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_BMP_IMAGE_GUARD
#define FL_BMP_IMAGE_GUARD


typedef void* BMPIMAGE;


extern "C" BMPIMAGE new_fl_bmp_image(const char * f);
extern "C" void free_fl_bmp_image(BMPIMAGE b);


#endif


