

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




const int fl_enum_num_red   = FL_NUM_RED;
const int fl_enum_num_green = FL_NUM_GREEN;
const int fl_enum_num_blue  = FL_NUM_BLUE;
const int fl_enum_num_gray  = FL_NUM_GRAY;




const unsigned int fl_enum_button1 = FL_BUTTON1;
const unsigned int fl_enum_button2 = FL_BUTTON2;
const unsigned int fl_enum_button3 = FL_BUTTON3;
#if FL_API_VERSION >= 10310
const unsigned int fl_enum_button4 = FL_BUTTON4;
const unsigned int fl_enum_button5 = FL_BUTTON5;
#else
//  woo, limited backwards compatibility
const unsigned int fl_enum_button4 = 8;
const unsigned int fl_enum_button5 = 16;
#endif
const unsigned int fl_enum_buttons = FL_BUTTONS;




const int fl_enum_left_mouse   = FL_LEFT_MOUSE;
const int fl_enum_middle_mouse = FL_MIDDLE_MOUSE;
const int fl_enum_right_mouse  = FL_RIGHT_MOUSE;
#if FL_API_VERSION >= 10310
const int fl_enum_back_mouse    = FL_BACK_MOUSE;
const int fl_enum_forward_mouse = FL_FORWARD_MOUSE;
#else
//  woo, limited backwards compatibility
const int fl_enum_back_mouse    = 4;
const int fl_enum_forward_mouse = 5;
#endif




unsigned int fl_enum_rgb_color2(unsigned char l) {
    return static_cast<unsigned int>(fl_rgb_color(l));
}

unsigned int fl_enum_rgb_color(unsigned char r, unsigned char g, unsigned char b) {
    return static_cast<unsigned int>(fl_rgb_color(r, g, b));
}

unsigned int fl_enum_color_cube(int r, int g, int b) {
    return static_cast<unsigned int>(fl_color_cube(r, g, b));
}

unsigned int fl_enum_gray_ramp(int l) {
    return static_cast<unsigned int>(fl_gray_ramp(l));
}

unsigned int fl_enum_darker(unsigned int c) {
    return static_cast<unsigned int>(fl_darker(static_cast<Fl_Color>(c)));
}

unsigned int fl_enum_lighter(unsigned int c) {
    return static_cast<unsigned int>(fl_lighter(static_cast<Fl_Color>(c)));
}

unsigned int fl_enum_contrast(unsigned int f, unsigned int b) {
    return static_cast<unsigned int>(fl_contrast
        (static_cast<Fl_Color>(f), static_cast<Fl_Color>(b)));
}

unsigned int fl_enum_inactive(unsigned int c) {
    return static_cast<unsigned int>(fl_inactive(static_cast<Fl_Color>(c)));
}

unsigned int fl_enum_color_average(unsigned int c1, unsigned int c2, float w) {
    return static_cast<unsigned int>(fl_color_average
        (static_cast<Fl_Color>(c1), static_cast<Fl_Color>(c2), w));
}




int fl_enum_box(int b) {
    return static_cast<int>(fl_box(static_cast<Fl_Boxtype>(b)));
}

int fl_enum_frame(int b) {
    return static_cast<int>(fl_frame(static_cast<Fl_Boxtype>(b)));
}

int fl_enum_down(int b) {
    return static_cast<int>(fl_down(static_cast<Fl_Boxtype>(b)));
}




const char * const fl_clip_image_char_ptr = Fl::clipboard_image;

const char * const fl_clip_plain_text_char_ptr = Fl::clipboard_plain_text;




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


