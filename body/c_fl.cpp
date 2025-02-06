

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Enumerations.H>
#include <FL/Fl.H>
#include <FL/Fl_Widget.H>
#include "c_fl.h"




const short fl_align_center             = FL_ALIGN_CENTER;
const short fl_align_top                = FL_ALIGN_TOP;
const short fl_align_bottom             = FL_ALIGN_BOTTOM;
const short fl_align_left               = FL_ALIGN_LEFT;
const short fl_align_right              = FL_ALIGN_RIGHT;
const short fl_align_inside             = FL_ALIGN_INSIDE;
const short fl_align_text_over_image    = FL_ALIGN_TEXT_OVER_IMAGE;
const short fl_align_image_over_text    = FL_ALIGN_IMAGE_OVER_TEXT;
const short fl_align_clip               = FL_ALIGN_CLIP;
const short fl_align_wrap               = FL_ALIGN_WRAP;
const short fl_align_image_next_to_text = FL_ALIGN_IMAGE_NEXT_TO_TEXT;
const short fl_align_text_next_to_image = FL_ALIGN_TEXT_NEXT_TO_IMAGE;
const short fl_align_image_backdrop     = FL_ALIGN_IMAGE_BACKDROP;
const short fl_align_top_left           = FL_ALIGN_TOP_LEFT;
const short fl_align_top_right          = FL_ALIGN_TOP_RIGHT;
const short fl_align_bottom_left        = FL_ALIGN_BOTTOM_LEFT;
const short fl_align_bottom_right       = FL_ALIGN_BOTTOM_RIGHT;
const short fl_align_left_top           = FL_ALIGN_LEFT_TOP;
const short fl_align_right_top          = FL_ALIGN_RIGHT_TOP;
const short fl_align_left_bottom        = FL_ALIGN_LEFT_BOTTOM;
const short fl_align_right_bottom       = FL_ALIGN_RIGHT_BOTTOM;
const short fl_align_nowrap             = FL_ALIGN_NOWRAP;
const short fl_align_all_position       = FL_ALIGN_POSITION_MASK;
const short fl_align_all_image          = FL_ALIGN_IMAGE_MASK;




const short fl_mod_command = FL_COMMAND >> 16;




size_t c_pointer_size() {
    return sizeof(void*);
}




unsigned int fl_enum_rgb_color(unsigned char r, unsigned char g, unsigned char b) {
    return fl_rgb_color(r, g, b);
}

unsigned int fl_enum_contrast(unsigned int f, unsigned int b) {
    return fl_contrast(f, b);
}




int fl_abi_check(int v) {
    return Fl::abi_check(v);
}

int fl_abi_version() {
    return Fl::abi_version();
}

int fl_api_version() {
    return Fl::api_version();
}

double fl_version() {
    return Fl::version();
}




void fl_awake() {
    Fl::awake();
}

void fl_lock() {
    Fl::lock();
}

void fl_unlock() {
    Fl::unlock();
}




int fl_get_damage() {
    return Fl::damage();
}

void fl_set_damage(int v) {
    Fl::damage(v);
}

void fl_flush() {
    Fl::flush();
}

void fl_redraw() {
    Fl::redraw();
}




short fl_inside_callback = 0;

void fl_delete_widget(void * w) {
    Fl::delete_widget(static_cast<Fl_Widget*>(w));
}




int fl_check() {
    short temp = fl_inside_callback;
    fl_inside_callback = 1;
    int ret = Fl::check();
    fl_inside_callback = temp;
    return ret;
}

int fl_ready() {
    short temp = fl_inside_callback;
    fl_inside_callback = 1;
    int ret = Fl::ready();
    fl_inside_callback = temp;
    return ret;
}

int fl_wait() {
    short temp = fl_inside_callback;
    fl_inside_callback = 1;
    int ret = Fl::wait();
    fl_inside_callback = temp;
    return ret;
}

double fl_wait2(double s) {
    short temp = fl_inside_callback;
    fl_inside_callback = 1;
    double ret = Fl::wait(s);
    fl_inside_callback = temp;
    return ret;
}

int fl_run() {
    short temp = fl_inside_callback;
    fl_inside_callback = 1;
    int ret = Fl::run();
    fl_inside_callback = temp;
    return ret;
}


