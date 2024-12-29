

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_PAGED_DEVICE_GUARD
#define FL_PAGED_DEVICE_GUARD


extern "C" const int fl_page_format_media;
extern "C" const int fl_page_layout_portrait;
extern "C" const int fl_page_layout_landscape;
extern "C" const int fl_page_layout_reversed;
extern "C" const int fl_page_layout_orientation;
extern "C" const int fl_no_page_formats;


extern "C" void fl_paged_device_get_page_format(int i, const char ** n, int * w, int * h);


typedef void* PAGED_DEVICE;


extern "C" PAGED_DEVICE new_fl_paged_device(void);
extern "C" void free_fl_paged_device(PAGED_DEVICE p);


extern "C" int fl_paged_device_start_job(PAGED_DEVICE p, int c);
extern "C" int fl_paged_device_start_job2(PAGED_DEVICE p, int c, int * f, int * t);
extern "C" void fl_paged_device_end_job(PAGED_DEVICE p);
extern "C" int fl_paged_device_start_page(PAGED_DEVICE p);
extern "C" int fl_paged_device_end_page(PAGED_DEVICE p);


extern "C" void fl_paged_device_margins(PAGED_DEVICE p, int * l, int * t, int * r, int * b);
extern "C" int fl_paged_device_printable_rect(PAGED_DEVICE p, int * w, int * h);
extern "C" void fl_paged_device_get_origin(PAGED_DEVICE p, int * x, int * y);
extern "C" void fl_paged_device_set_origin(PAGED_DEVICE p, int x, int y);
extern "C" void fl_paged_device_rotate(PAGED_DEVICE p, float r);
extern "C" void fl_paged_device_scale(PAGED_DEVICE p, float x, float y);
extern "C" void fl_paged_device_translate(PAGED_DEVICE p, int x, int y);
extern "C" void fl_paged_device_untranslate(PAGED_DEVICE p);


extern "C" void fl_paged_device_print_widget(PAGED_DEVICE p, void * i, int dx, int dy);
extern "C" void fl_paged_device_print_window(PAGED_DEVICE p, void * i, int dx, int dy);
extern "C" void fl_paged_device_print_window_part(PAGED_DEVICE p, void * i, int x, int y,
    int w, int h, int dx, int dy);


#endif


