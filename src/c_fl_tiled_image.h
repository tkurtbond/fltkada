

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_TILED_IMAGE_GUARD
#define FL_TILED_IMAGE_GUARD




typedef void* TILED_IMAGE;




extern "C" TILED_IMAGE new_fl_tiled_image(void * i, int w, int h);
extern "C" void free_fl_tiled_image(TILED_IMAGE t);
extern "C" TILED_IMAGE fl_tiled_image_copy(TILED_IMAGE t, int w, int h);
extern "C" TILED_IMAGE fl_tiled_image_copy2(TILED_IMAGE t);




extern "C" void * fl_tiled_image_get_image(TILED_IMAGE t);


extern "C" void fl_tiled_image_color_average(TILED_IMAGE t, int c, float b);
extern "C" void fl_tiled_image_desaturate(TILED_IMAGE t);


extern "C" void fl_tiled_image_draw(TILED_IMAGE t, int x, int y);
extern "C" void fl_tiled_image_draw2(TILED_IMAGE t, int x, int y, int w, int h, int cx, int cy);


#endif

