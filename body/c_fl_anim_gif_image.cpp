

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <FL/Fl_Anim_GIF_Image.H>
#include <FL/Fl_Widget.H>
#include "c_fl_anim_gif_image.h"




static const char * null_if_empty(const char * n) {
    return (n == 0 || *n == '\0') ? 0 : n;
}

ANIMGIFIMAGE new_fl_anim_gif_image(const char * f, void * c, unsigned short l) {
    Fl_Anim_GIF_Image *a = new Fl_Anim_GIF_Image(f, static_cast<Fl_Widget*>(c), l);
    return a;
}

ANIMGIFIMAGE new_fl_anim_gif_image2(const char * n, void * d, size_t s,
    void * c, unsigned short l) {
    Fl_Anim_GIF_Image *a = new Fl_Anim_GIF_Image(null_if_empty(n),
        static_cast<const unsigned char*>(d), s, static_cast<Fl_Widget*>(c), l);
    return a;
}

ANIMGIFIMAGE new_fl_anim_gif_image3() {
    Fl_Anim_GIF_Image *a = new Fl_Anim_GIF_Image();
    return a;
}

void free_fl_anim_gif_image(ANIMGIFIMAGE a) {
    delete static_cast<Fl_Anim_GIF_Image*>(a);
}




int fl_anim_gif_image_get_loop() {
    return Fl_Anim_GIF_Image::loop;
}

void fl_anim_gif_image_set_loop(int v) {
    Fl_Anim_GIF_Image::loop = v != 0;
}

double fl_anim_gif_image_get_min_delay() {
    return Fl_Anim_GIF_Image::min_delay;
}

void fl_anim_gif_image_set_min_delay(double v) {
    Fl_Anim_GIF_Image::min_delay = v;
}

int fl_anim_gif_image_frame_count(const char * n, void * d, size_t s) {
    return Fl_Anim_GIF_Image::frame_count(null_if_empty(n),
        static_cast<const unsigned char*>(d), s);
}




int fl_anim_gif_image_load(ANIMGIFIMAGE a, const char * n, void * d, size_t s) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->load(null_if_empty(n),
        static_cast<const unsigned char*>(d), s);
}

int fl_anim_gif_image_valid(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->valid();
}

const char * fl_anim_gif_image_name(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->name();
}




void * fl_anim_gif_image_get_canvas(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->canvas();
}

void fl_anim_gif_image_set_canvas(ANIMGIFIMAGE a, void * c, unsigned short l) {
    static_cast<Fl_Anim_GIF_Image*>(a)->canvas(static_cast<Fl_Widget*>(c), l);
}

int fl_anim_gif_image_canvas_w(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->canvas_w();
}

int fl_anim_gif_image_canvas_h(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->canvas_h();
}




int fl_anim_gif_image_frames(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->frames();
}

int fl_anim_gif_image_get_frame(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->frame();
}

void fl_anim_gif_image_set_frame(ANIMGIFIMAGE a, int f) {
    static_cast<Fl_Anim_GIF_Image*>(a)->frame(f);
}

void * fl_anim_gif_image_image(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->image();
}

void * fl_anim_gif_image_image2(ANIMGIFIMAGE a, int f) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->image(f);
}

double fl_anim_gif_image_get_delay(ANIMGIFIMAGE a, int f) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->delay(f);
}

void fl_anim_gif_image_set_delay(ANIMGIFIMAGE a, int f, double v) {
    static_cast<Fl_Anim_GIF_Image*>(a)->delay(f, v);
}

int fl_anim_gif_image_frame_x(ANIMGIFIMAGE a, int f) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->frame_x(f);
}

int fl_anim_gif_image_frame_y(ANIMGIFIMAGE a, int f) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->frame_y(f);
}

int fl_anim_gif_image_frame_w(ANIMGIFIMAGE a, int f) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->frame_w(f);
}

int fl_anim_gif_image_frame_h(ANIMGIFIMAGE a, int f) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->frame_h(f);
}




int fl_anim_gif_image_is_animated(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->is_animated();
}

int fl_anim_gif_image_playing(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->playing();
}

int fl_anim_gif_image_start(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->start();
}

int fl_anim_gif_image_stop(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->stop();
}

int fl_anim_gif_image_next(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->next();
}

double fl_anim_gif_image_get_speed(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->speed();
}

void fl_anim_gif_image_set_speed(ANIMGIFIMAGE a, double v) {
    static_cast<Fl_Anim_GIF_Image*>(a)->speed(v);
}

int fl_anim_gif_image_get_frame_uncache(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->frame_uncache();
}

void fl_anim_gif_image_set_frame_uncache(ANIMGIFIMAGE a, int v) {
    static_cast<Fl_Anim_GIF_Image*>(a)->frame_uncache(v != 0);
}

int fl_anim_gif_image_debug(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->debug();
}




void fl_anim_gif_image_resize(ANIMGIFIMAGE a, int w, int h) {
    static_cast<Fl_Anim_GIF_Image*>(a)->resize(w, h);
}

void fl_anim_gif_image_resize2(ANIMGIFIMAGE a, double s) {
    static_cast<Fl_Anim_GIF_Image*>(a)->resize(s);
}




ANIMGIFIMAGE fl_anim_gif_image_copy(ANIMGIFIMAGE a, int w, int h) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->copy(w, h);
}

ANIMGIFIMAGE fl_anim_gif_image_copy2(ANIMGIFIMAGE a) {
    return static_cast<Fl_Anim_GIF_Image*>(a)->copy();
}




void fl_anim_gif_image_color_average(ANIMGIFIMAGE a, int c, float b) {
    static_cast<Fl_Anim_GIF_Image*>(a)->color_average(c, b);
}

void fl_anim_gif_image_desaturate(ANIMGIFIMAGE a) {
    static_cast<Fl_Anim_GIF_Image*>(a)->desaturate();
}

void fl_anim_gif_image_uncache(ANIMGIFIMAGE a) {
    static_cast<Fl_Anim_GIF_Image*>(a)->uncache();
}




void fl_anim_gif_image_draw(ANIMGIFIMAGE a, int x, int y, int w, int h,
    int cx, int cy) {
    static_cast<Fl_Anim_GIF_Image*>(a)->draw(x, y, w, h, cx, cy);
}


