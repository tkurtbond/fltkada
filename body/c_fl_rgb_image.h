

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_RGB_IMAGE_GUARD
#define FL_RGB_IMAGE_GUARD


typedef void* RGBIMAGE;


extern "C" RGBIMAGE new_fl_rgb_image(void *data, int w, int h, int d, int ld);
extern "C" RGBIMAGE new_fl_rgb_image2(void *pix, unsigned int c);
extern "C" void free_fl_rgb_image(RGBIMAGE i);
extern "C" size_t fl_rgb_image_get_max_size();
extern "C" void fl_rgb_image_set_max_size(size_t v);
extern "C" RGBIMAGE fl_rgb_image_copy(RGBIMAGE i, int w, int h);
extern "C" RGBIMAGE fl_rgb_image_copy2(RGBIMAGE i);


extern "C" void fl_rgb_image_color_average(RGBIMAGE i, int c, float b);
extern "C" void fl_rgb_image_desaturate(RGBIMAGE i);


extern "C" void fl_rgb_image_uncache(RGBIMAGE i);


extern "C" const void * fl_rgb_image_data(RGBIMAGE i);


extern "C" void fl_rgb_image_draw2(RGBIMAGE i, int x, int y);
extern "C" void fl_rgb_image_draw(RGBIMAGE i, int x, int y, int w, int h, int cx, int cy);


#endif


