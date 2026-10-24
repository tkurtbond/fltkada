

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#ifndef FL_GLUT_GUARD
#define FL_GLUT_GUARD


extern "C" void fl_glut_init(int * argc, void * argv);
extern "C" void fl_glut_init_display_mode(unsigned int m);
extern "C" void fl_glut_init_window_position(int x, int y);
extern "C" void fl_glut_init_window_size(int w, int h);
extern "C" void fl_glut_main_loop();


extern "C" int fl_glut_create_window(const char * t);
extern "C" int fl_glut_create_sub_window(int win, int x, int y, int w, int h);
extern "C" void fl_glut_destroy_window(int win);
extern "C" void fl_glut_post_redisplay();
extern "C" void fl_glut_post_window_redisplay(int win);
extern "C" void fl_glut_swap_buffers();
extern "C" int fl_glut_get_window();
extern "C" void fl_glut_set_window(int win);


extern "C" void fl_glut_set_window_title(const char * t);
extern "C" void fl_glut_set_icon_title(const char * t);
extern "C" void fl_glut_position_window(int x, int y);
extern "C" void fl_glut_reshape_window(int w, int h);
extern "C" void fl_glut_pop_window();
extern "C" void fl_glut_push_window();
extern "C" void fl_glut_iconify_window();
extern "C" void fl_glut_show_window();
extern "C" void fl_glut_hide_window();
extern "C" void fl_glut_full_screen();
extern "C" void fl_glut_set_cursor(int c);
extern "C" void fl_glut_warp_pointer(int x, int y);


extern "C" void fl_glut_establish_overlay();
extern "C" void fl_glut_remove_overlay();
extern "C" void fl_glut_use_layer(unsigned int l);
extern "C" void fl_glut_post_overlay_redisplay();
extern "C" void fl_glut_show_overlay();
extern "C" void fl_glut_hide_overlay();


extern "C" int fl_glut_create_menu(void * f);
extern "C" void fl_glut_destroy_menu(int m);
extern "C" int fl_glut_get_menu();
extern "C" void fl_glut_set_menu(int m);
extern "C" void fl_glut_add_menu_entry(const char * t, int v);
extern "C" void fl_glut_add_sub_menu(const char * t, int s);
extern "C" void fl_glut_change_to_menu_entry(int i, const char * t, int v);
extern "C" void fl_glut_change_to_sub_menu(int i, const char * t, int s);
extern "C" void fl_glut_remove_menu_item(int i);
extern "C" void fl_glut_attach_menu(int b);
extern "C" void fl_glut_detach_menu(int b);


extern "C" void fl_glut_display_func(void * f);
extern "C" void fl_glut_reshape_func(void * f);
extern "C" void fl_glut_keyboard_func(void * f);
extern "C" void fl_glut_mouse_func(void * f);
extern "C" void fl_glut_motion_func(void * f);
extern "C" void fl_glut_passive_motion_func(void * f);
extern "C" void fl_glut_entry_func(void * f);
extern "C" void fl_glut_visibility_func(void * f);
extern "C" void fl_glut_special_func(void * f);
extern "C" void fl_glut_overlay_display_func(void * f);
extern "C" void fl_glut_idle_func(void * f);
extern "C" void fl_glut_timer_func(unsigned int msec, void * f, void * d);
extern "C" void fl_glut_menu_state_func(void * f);
extern "C" void fl_glut_menu_status_func(void * f);


extern "C" int fl_glut_get(unsigned int t);
extern "C" int fl_glut_device_get(unsigned int t);
extern "C" int fl_glut_layer_get(unsigned int t);
extern "C" int fl_glut_get_modifiers();
extern "C" int fl_glut_extension_supported(const char * n);
extern "C" void * fl_glut_get_proc_address(const char * n);


#endif


