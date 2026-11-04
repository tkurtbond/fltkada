

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_PNM_IMAGE_GUARD
#define FL_PNM_IMAGE_GUARD


typedef void* PNMIMAGE;


extern "C" PNMIMAGE new_fl_pnm_image(const char * f);
extern "C" void free_fl_pnm_image(PNMIMAGE p);


class Fl_RGB_Image;
void pnm_scale_samples(Fl_RGB_Image * img, const char * filename);


#endif


