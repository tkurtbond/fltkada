

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_GUARD
#define FL_GUARD


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


extern "C" unsigned int fl_enum_rgb_color(unsigned char r, unsigned char g, unsigned char b);
extern "C" unsigned int fl_enum_contrast(unsigned int f, unsigned int b);


extern "C" int fl_abi_check(int v);
extern "C" int fl_abi_version();
extern "C" int fl_api_version();
extern "C" double fl_version();


extern "C" void fl_awake();
extern "C" void fl_lock();
extern "C" void fl_unlock();


extern "C" int fl_get_damage();
extern "C" void fl_set_damage(int v);
extern "C" void fl_flush();
extern "C" void fl_redraw();


extern "C" int fl_check();
extern "C" int fl_ready();
extern "C" int fl_wait();
extern "C" int fl_wait2(double s);
extern "C" int fl_run();


#endif


