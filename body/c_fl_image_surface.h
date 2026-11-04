

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_IMAGE_SURFACE_GUARD
#define FL_IMAGE_SURFACE_GUARD


typedef void* IMAGESURFACE;


extern "C" IMAGESURFACE new_fl_image_surface(int w, int h, int r);
extern "C" void free_fl_image_surface(IMAGESURFACE s);


extern "C" void fl_image_surface_draw(IMAGESURFACE s, void * w, int dx, int dy);
extern "C" void fl_image_surface_draw_decorated_window(IMAGESURFACE s, void * w, int dx, int dy);


extern "C" void * fl_image_surface_image(IMAGESURFACE s);
extern "C" void * fl_image_surface_highres_image(IMAGESURFACE s);


extern "C" int fl_image_surface_mask(IMAGESURFACE s, void * m);
extern "C" void fl_image_surface_rescale(IMAGESURFACE s);
extern "C" void fl_image_surface_copy_offscreen(IMAGESURFACE s, int x, int y, int w, int h,
    int sx, int sy);


extern "C" void fl_image_surface_set_current(IMAGESURFACE s);


#endif


