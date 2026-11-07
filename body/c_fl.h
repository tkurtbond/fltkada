

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_GUARD
#define FL_GUARD


#include <cstddef>


extern "C" const short fl_align_center;
extern "C" const short fl_align_top;
extern "C" const short fl_align_bottom;
extern "C" const short fl_align_left;
extern "C" const short fl_align_right;
extern "C" const short fl_align_inside;
extern "C" const short fl_align_text_over_image;
extern "C" const short fl_align_image_over_text;
extern "C" const short fl_align_clip;
extern "C" const short fl_align_wrap;
extern "C" const short fl_align_image_next_to_text;
extern "C" const short fl_align_text_next_to_image;
extern "C" const short fl_align_image_backdrop;
extern "C" const short fl_align_top_left;
extern "C" const short fl_align_top_right;
extern "C" const short fl_align_bottom_left;
extern "C" const short fl_align_bottom_right;
extern "C" const short fl_align_left_top;
extern "C" const short fl_align_right_top;
extern "C" const short fl_align_left_bottom;
extern "C" const short fl_align_right_bottom;
extern "C" const short fl_align_nowrap;
extern "C" const short fl_align_all_position;
extern "C" const short fl_align_all_image;


extern "C" const short fl_mod_command;


extern "C" size_t c_pointer_size();


extern "C" void fl_define_box_and_label_types();


extern "C" const int fl_enum_num_red;
extern "C" const int fl_enum_num_green;
extern "C" const int fl_enum_num_blue;
extern "C" const int fl_enum_num_gray;


extern "C" const unsigned int fl_enum_button1;
extern "C" const unsigned int fl_enum_button2;
extern "C" const unsigned int fl_enum_button3;
extern "C" const unsigned int fl_enum_button4;
extern "C" const unsigned int fl_enum_button5;
extern "C" const unsigned int fl_enum_buttons;


extern "C" const int fl_enum_left_mouse;
extern "C" const int fl_enum_middle_mouse;
extern "C" const int fl_enum_right_mouse;
extern "C" const int fl_enum_back_mouse;
extern "C" const int fl_enum_forward_mouse;


extern "C" unsigned int fl_enum_rgb_color2(unsigned char l);
extern "C" unsigned int fl_enum_rgb_color(unsigned char r, unsigned char g, unsigned char b);
extern "C" unsigned int fl_enum_color_cube(int r, int g, int b);
extern "C" unsigned int fl_enum_gray_ramp(int l);
extern "C" unsigned int fl_enum_darker(unsigned int c);
extern "C" unsigned int fl_enum_lighter(unsigned int c);
extern "C" unsigned int fl_enum_contrast(unsigned int f, unsigned int b, int c, int s);
extern "C" double fl_enum_lightness(unsigned int c);
extern "C" double fl_enum_luminance(unsigned int c);
extern "C" unsigned int fl_enum_inactive(unsigned int c);
extern "C" unsigned int fl_enum_color_average(unsigned int c1, unsigned int c2, float w);


extern "C" int fl_get_normal_size();
extern "C" void fl_set_normal_size(int s);


extern "C" int fl_enum_box(int b);
extern "C" int fl_enum_frame(int b);
extern "C" int fl_enum_down(int b);


extern "C" const char * const fl_clip_image_char_ptr;
extern "C" const char * const fl_clip_plain_text_char_ptr;


extern "C" int fl_abi_check(int v);
extern "C" int fl_abi_version();
extern "C" int fl_api_version();
extern "C" double fl_version();


extern "C" short fl_inside_callback;
extern "C" void fl_delete_widget(void * w);


extern "C" int fl_check();
extern "C" int fl_ready();
extern "C" int fl_wait();
extern "C" double fl_wait2(double s);
extern "C" int fl_run();


#endif


