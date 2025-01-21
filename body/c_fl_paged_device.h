

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


typedef void* PAGEDDEVICE;


extern "C" PAGEDDEVICE new_fl_paged_device(void);
extern "C" void free_fl_paged_device(PAGEDDEVICE p);


extern "C" int fl_paged_device_start_job(PAGEDDEVICE p, int c);
extern "C" int fl_paged_device_start_job2(PAGEDDEVICE p, int c, int * f, int * t);
extern "C" void fl_paged_device_end_job(PAGEDDEVICE p);
extern "C" int fl_paged_device_start_page(PAGEDDEVICE p);
extern "C" int fl_paged_device_end_page(PAGEDDEVICE p);


extern "C" void fl_paged_device_margins(PAGEDDEVICE p, int * l, int * t, int * r, int * b);
extern "C" int fl_paged_device_printable_rect(PAGEDDEVICE p, int * w, int * h);
extern "C" void fl_paged_device_get_origin(PAGEDDEVICE p, int * x, int * y);
extern "C" void fl_paged_device_set_origin(PAGEDDEVICE p, int x, int y);
extern "C" void fl_paged_device_rotate(PAGEDDEVICE p, float r);
extern "C" void fl_paged_device_scale(PAGEDDEVICE p, float x, float y);
extern "C" void fl_paged_device_translate(PAGEDDEVICE p, int x, int y);
extern "C" void fl_paged_device_untranslate(PAGEDDEVICE p);


extern "C" void fl_paged_device_print_widget(PAGEDDEVICE p, void * i, int dx, int dy);
extern "C" void fl_paged_device_print_window(PAGEDDEVICE p, void * i, int dx, int dy);
extern "C" void fl_paged_device_print_window_part(PAGEDDEVICE p, void * i, int x, int y,
    int w, int h, int dx, int dy);


#endif


