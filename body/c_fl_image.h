

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_IMAGE_GUARD
#define FL_IMAGE_GUARD


extern "C" const int fl_image_err_no_image;
extern "C" const int fl_image_err_file_access;
extern "C" const int fl_image_err_format;


typedef void* IMAGE;


extern "C" IMAGE new_fl_image(int w, int h, int d);
extern "C" void free_fl_image(IMAGE i);


extern "C" int fl_image_get_rgb_scaling();
extern "C" void fl_image_set_rgb_scaling(int t);
extern "C" int fl_image_get_scaling_algorithm();
extern "C" void fl_image_set_scaling_algorithm(int t);
extern "C" IMAGE fl_image_copy(IMAGE i, int w, int h);
extern "C" IMAGE fl_image_copy2(IMAGE i);


extern "C" void fl_image_color_average(IMAGE i, int c, float b);
extern "C" void fl_image_desaturate(IMAGE i);


extern "C" void fl_image_inactive(IMAGE i);
extern "C" int fl_image_fail(IMAGE i);
extern "C" void fl_image_uncache(IMAGE i);


extern "C" int fl_image_w(IMAGE i);
extern "C" int fl_image_h(IMAGE i);
extern "C" int fl_image_d(IMAGE i);
extern "C" int fl_image_ld(IMAGE i);
extern "C" int fl_image_data_w(IMAGE i);
extern "C" int fl_image_data_h(IMAGE i);
extern "C" void fl_image_scale(IMAGE i, int w, int h, int p, int e);


extern "C" const void * fl_image_data(IMAGE i);
extern "C" int fl_image_count(IMAGE i);


extern "C" void fl_image_draw(IMAGE i, int x, int y);
extern "C" void fl_image_draw2(IMAGE i, int x, int y, int w, int h, int cx, int cy);
extern "C" void fl_image_draw_empty(IMAGE i, int x, int y);


#endif


