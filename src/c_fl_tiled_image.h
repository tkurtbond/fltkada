

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_TILED_IMAGE_GUARD
#define FL_TILED_IMAGE_GUARD


typedef void* TILEDIMAGE;


extern "C" TILEDIMAGE new_fl_tiled_image(void * i, int w, int h);
extern "C" void free_fl_tiled_image(TILEDIMAGE t);
extern "C" TILEDIMAGE fl_tiled_image_copy(TILEDIMAGE t, int w, int h);
extern "C" TILEDIMAGE fl_tiled_image_copy2(TILEDIMAGE t);


extern "C" void * fl_tiled_image_get_image(TILEDIMAGE t);


extern "C" void fl_tiled_image_color_average(TILEDIMAGE t, int c, float b);
extern "C" void fl_tiled_image_desaturate(TILEDIMAGE t);


extern "C" void fl_tiled_image_draw(TILEDIMAGE t, int x, int y);
extern "C" void fl_tiled_image_draw2(TILEDIMAGE t, int x, int y, int w, int h, int cx, int cy);


#endif


