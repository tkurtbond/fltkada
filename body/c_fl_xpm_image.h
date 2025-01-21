

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_XPM_IMAGE_GUARD
#define FL_XPM_IMAGE_GUARD


typedef void* XPMIMAGE;


extern "C" XPMIMAGE new_fl_xpm_image(const char * f);
extern "C" void free_fl_xpm_image(XPMIMAGE j);


#endif


