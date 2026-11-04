

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#ifndef FL_ANIM_GIF_IMAGE_GUARD
#define FL_ANIM_GIF_IMAGE_GUARD


#include <stddef.h>


typedef void* ANIMGIFIMAGE;


extern "C" ANIMGIFIMAGE new_fl_anim_gif_image(const char * f, void * c, unsigned short l);
extern "C" ANIMGIFIMAGE new_fl_anim_gif_image2(const char * n, void * d, size_t s,
    void * c, unsigned short l);
extern "C" ANIMGIFIMAGE new_fl_anim_gif_image3();
extern "C" void free_fl_anim_gif_image(ANIMGIFIMAGE a);


extern "C" int fl_anim_gif_image_get_loop();
extern "C" void fl_anim_gif_image_set_loop(int v);
extern "C" double fl_anim_gif_image_get_min_delay();
extern "C" void fl_anim_gif_image_set_min_delay(double v);
extern "C" int fl_anim_gif_image_frame_count(const char * n, void * d, size_t s);


extern "C" int fl_anim_gif_image_load(ANIMGIFIMAGE a, const char * n, void * d, size_t s);
extern "C" int fl_anim_gif_image_valid(ANIMGIFIMAGE a);
extern "C" const char * fl_anim_gif_image_name(ANIMGIFIMAGE a);


extern "C" void * fl_anim_gif_image_get_canvas(ANIMGIFIMAGE a);
extern "C" void fl_anim_gif_image_set_canvas(ANIMGIFIMAGE a, void * c, unsigned short l);
extern "C" int fl_anim_gif_image_canvas_w(ANIMGIFIMAGE a);
extern "C" int fl_anim_gif_image_canvas_h(ANIMGIFIMAGE a);


extern "C" int fl_anim_gif_image_frames(ANIMGIFIMAGE a);
extern "C" int fl_anim_gif_image_get_frame(ANIMGIFIMAGE a);
extern "C" void fl_anim_gif_image_set_frame(ANIMGIFIMAGE a, int f);
extern "C" void * fl_anim_gif_image_image(ANIMGIFIMAGE a);
extern "C" void * fl_anim_gif_image_image2(ANIMGIFIMAGE a, int f);
extern "C" double fl_anim_gif_image_get_delay(ANIMGIFIMAGE a, int f);
extern "C" void fl_anim_gif_image_set_delay(ANIMGIFIMAGE a, int f, double v);
extern "C" int fl_anim_gif_image_frame_x(ANIMGIFIMAGE a, int f);
extern "C" int fl_anim_gif_image_frame_y(ANIMGIFIMAGE a, int f);
extern "C" int fl_anim_gif_image_frame_w(ANIMGIFIMAGE a, int f);
extern "C" int fl_anim_gif_image_frame_h(ANIMGIFIMAGE a, int f);


extern "C" int fl_anim_gif_image_is_animated(ANIMGIFIMAGE a);
extern "C" int fl_anim_gif_image_playing(ANIMGIFIMAGE a);
extern "C" int fl_anim_gif_image_start(ANIMGIFIMAGE a);
extern "C" int fl_anim_gif_image_stop(ANIMGIFIMAGE a);
extern "C" int fl_anim_gif_image_next(ANIMGIFIMAGE a);
extern "C" double fl_anim_gif_image_get_speed(ANIMGIFIMAGE a);
extern "C" void fl_anim_gif_image_set_speed(ANIMGIFIMAGE a, double v);
extern "C" int fl_anim_gif_image_get_frame_uncache(ANIMGIFIMAGE a);
extern "C" void fl_anim_gif_image_set_frame_uncache(ANIMGIFIMAGE a, int v);
extern "C" int fl_anim_gif_image_debug(ANIMGIFIMAGE a);


extern "C" void fl_anim_gif_image_resize(ANIMGIFIMAGE a, int w, int h);
extern "C" void fl_anim_gif_image_resize2(ANIMGIFIMAGE a, double s);


extern "C" ANIMGIFIMAGE fl_anim_gif_image_copy(ANIMGIFIMAGE a, int w, int h);
extern "C" ANIMGIFIMAGE fl_anim_gif_image_copy2(ANIMGIFIMAGE a);


extern "C" void fl_anim_gif_image_color_average(ANIMGIFIMAGE a, int c, float b);
extern "C" void fl_anim_gif_image_desaturate(ANIMGIFIMAGE a);
extern "C" void fl_anim_gif_image_uncache(ANIMGIFIMAGE a);


extern "C" void fl_anim_gif_image_draw(ANIMGIFIMAGE a, int x, int y, int w, int h,
    int cx, int cy);


//  C++ linkage, for c_fl_widget.cpp.
class Fl_Widget;
void anim_gif_canvas_gone(const Fl_Widget * w);


#endif


