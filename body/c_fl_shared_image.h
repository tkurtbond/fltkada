

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_SHARED_IMAGE_GUARD
#define FL_SHARED_IMAGE_GUARD


typedef void* SHAREDIMAGE;


extern "C" SHAREDIMAGE fl_shared_image_get(const char * f, int w, int h);
extern "C" SHAREDIMAGE fl_shared_image_get2(void * r);
extern "C" SHAREDIMAGE fl_shared_image_find(const char * n, int w, int h);
extern "C" void fl_shared_image_release(SHAREDIMAGE i);
extern "C" SHAREDIMAGE fl_shared_image_copy(SHAREDIMAGE i, int w, int h);
extern "C" SHAREDIMAGE fl_shared_image_copy2(SHAREDIMAGE i);


extern "C" void fl_shared_image_color_average(SHAREDIMAGE i, int c, float b);
extern "C" void fl_shared_image_desaturate(SHAREDIMAGE i);


extern "C" int fl_shared_image_num_images();
extern "C" const char * fl_shared_image_name(SHAREDIMAGE i);
extern "C" int fl_shared_image_original(SHAREDIMAGE i);
extern "C" int fl_shared_image_refcount(SHAREDIMAGE i);
extern "C" void fl_shared_image_reload(SHAREDIMAGE i);
extern "C" void fl_shared_image_uncache(SHAREDIMAGE i);


extern "C" void fl_shared_image_scaling_algorithm(int v);
extern "C" void fl_shared_image_scale(SHAREDIMAGE i, int w, int h, int p, int e);
extern "C" void fl_shared_image_draw(SHAREDIMAGE i, int x, int y, int w, int h, int cx, int cy);
extern "C" void fl_shared_image_draw2(SHAREDIMAGE i, int x, int y);


extern "C" void fl_shared_image_register_images();
extern "C" void fl_shared_image_add_pnm_handler();
extern "C" void fl_shared_image_add_ada_handler();
extern "C" int fl_shared_image_pool_count();
extern "C" SHAREDIMAGE fl_shared_image_pool_take(int k);


#endif


