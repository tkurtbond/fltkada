

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_XBM_IMAGE_GUARD
#define FL_XBM_IMAGE_GUARD


typedef void* XBMIMAGE;


extern "C" XBMIMAGE new_fl_xbm_image(const char * f);
extern "C" void free_fl_xbm_image(XBMIMAGE b);


#endif


