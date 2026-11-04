

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_POSTSCRIPT_FILE_DEVICE_GUARD
#define FL_POSTSCRIPT_FILE_DEVICE_GUARD


typedef void* POSTSCRIPTFILEDEVICE;


extern "C" POSTSCRIPTFILEDEVICE new_fl_postscript_file_device(void);
extern "C" void free_fl_postscript_file_device(POSTSCRIPTFILEDEVICE p);


extern "C" const char * fl_postscript_file_device_get_file_chooser_title();
extern "C" void fl_postscript_file_device_set_file_chooser_title(const char * v);


extern "C" void * fl_postscript_file_device_get_driver(POSTSCRIPTFILEDEVICE p);


extern "C" int fl_postscript_file_device_start_job(POSTSCRIPTFILEDEVICE p, int c);
extern "C" int fl_postscript_file_device_start_job2(POSTSCRIPTFILEDEVICE p, int c, int * f, int * t);
extern "C" int fl_postscript_file_device_start_job3(POSTSCRIPTFILEDEVICE p, void * o, int c, int f, int l);
extern "C" int fl_postscript_file_device_start_job4(POSTSCRIPTFILEDEVICE p, int c, int f, int l);
extern "C" int fl_postscript_file_device_end_job(POSTSCRIPTFILEDEVICE p);
extern "C" int fl_postscript_file_device_start_page(POSTSCRIPTFILEDEVICE p);
extern "C" int fl_postscript_file_device_end_page(POSTSCRIPTFILEDEVICE p);


extern "C" void fl_postscript_file_device_margins(POSTSCRIPTFILEDEVICE p, int * l, int * t,
    int * r, int * b);
extern "C" int fl_postscript_file_device_printable_rect(POSTSCRIPTFILEDEVICE p, int * w, int * h);
extern "C" void fl_postscript_file_device_get_origin(POSTSCRIPTFILEDEVICE p, int * x, int * y);
extern "C" void fl_postscript_file_device_set_origin(POSTSCRIPTFILEDEVICE p, int x, int y);
extern "C" void fl_postscript_file_device_rotate(POSTSCRIPTFILEDEVICE p, float r);
extern "C" void fl_postscript_file_device_scale(POSTSCRIPTFILEDEVICE p, float x, float y);
extern "C" void fl_postscript_file_device_translate(POSTSCRIPTFILEDEVICE p, int x, int y);
extern "C" void fl_postscript_file_device_untranslate(POSTSCRIPTFILEDEVICE p);


#endif


