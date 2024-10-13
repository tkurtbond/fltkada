

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_RGB_IMAGE_GUARD
#define FL_RGB_IMAGE_GUARD




typedef void* RGB_IMAGE;




extern "C" RGB_IMAGE new_fl_rgb_image(void *data, int w, int h, int d, int ld);
extern "C" RGB_IMAGE new_fl_rgb_image2(void *pix, unsigned int c);
extern "C" void free_fl_rgb_image(RGB_IMAGE i);
extern "C" size_t fl_rgb_image_get_max_size();
extern "C" void fl_rgb_image_set_max_size(size_t v);
extern "C" RGB_IMAGE fl_rgb_image_copy(RGB_IMAGE i, int w, int h);
extern "C" RGB_IMAGE fl_rgb_image_copy2(RGB_IMAGE i);




extern "C" void fl_rgb_image_color_average(RGB_IMAGE i, int c, float b);
extern "C" void fl_rgb_image_desaturate(RGB_IMAGE i);


extern "C" void fl_rgb_image_uncache(RGB_IMAGE i);


extern "C" void fl_rgb_image_draw2(RGB_IMAGE i, int x, int y);
extern "C" void fl_rgb_image_draw(RGB_IMAGE i, int x, int y, int w, int h, int cx, int cy);


#endif

