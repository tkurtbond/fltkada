

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_PRINTER_GUARD
#define FL_PRINTER_GUARD


typedef void* PRINTER;


extern "C" PRINTER new_fl_printer(void);
extern "C" void free_fl_printer(PRINTER p);


extern "C" const char * fl_printer_get_dialog_title();
extern "C" void fl_printer_set_dialog_title(const char * v);
extern "C" const char * fl_printer_get_dialog_printer();
extern "C" void fl_printer_set_dialog_printer(const char * v);
extern "C" const char * fl_printer_get_dialog_range();
extern "C" void fl_printer_set_dialog_range(const char * v);
extern "C" const char * fl_printer_get_dialog_copies();
extern "C" void fl_printer_set_dialog_copies(const char * v);
extern "C" const char * fl_printer_get_dialog_all();
extern "C" void fl_printer_set_dialog_all(const char * v);
extern "C" const char * fl_printer_get_dialog_pages();
extern "C" void fl_printer_set_dialog_pages(const char * v);
extern "C" const char * fl_printer_get_dialog_from();
extern "C" void fl_printer_set_dialog_from(const char * v);
extern "C" const char * fl_printer_get_dialog_to();
extern "C" void fl_printer_set_dialog_to(const char * v);
extern "C" const char * fl_printer_get_dialog_properties();
extern "C" void fl_printer_set_dialog_properties(const char * v);
extern "C" const char * fl_printer_get_dialog_copyno();
extern "C" void fl_printer_set_dialog_copyno(const char * v);
extern "C" const char * fl_printer_get_dialog_print_button();
extern "C" void fl_printer_set_dialog_print_button(const char * v);
extern "C" const char * fl_printer_get_dialog_cancel_button();
extern "C" void fl_printer_set_dialog_cancel_button(const char * v);
extern "C" const char * fl_printer_get_dialog_print_to_file();
extern "C" void fl_printer_set_dialog_print_to_file(const char * v);
extern "C" const char * fl_printer_get_property_title();
extern "C" void fl_printer_set_property_title(const char * v);
extern "C" const char * fl_printer_get_property_pagesize();
extern "C" void fl_printer_set_property_pagesize(const char * v);
extern "C" const char * fl_printer_get_property_mode();
extern "C" void fl_printer_set_property_mode(const char * v);
extern "C" const char * fl_printer_get_property_use();
extern "C" void fl_printer_set_property_use(const char * v);
extern "C" const char * fl_printer_get_property_save();
extern "C" void fl_printer_set_property_save(const char * v);
extern "C" const char * fl_printer_get_property_cancel();
extern "C" void fl_printer_set_property_cancel(const char * v);


extern "C" int fl_printer_start_job(PRINTER p, int c, char * msg, int n);
extern "C" int fl_printer_start_job2(PRINTER p, int c, int * f, int * t, char * msg, int n);
extern "C" void fl_printer_end_job(PRINTER p);
extern "C" int fl_printer_start_page(PRINTER p);
extern "C" int fl_printer_end_page(PRINTER p);


extern "C" void fl_printer_margins(PRINTER p, int * l, int * t, int * r, int * b);
extern "C" int fl_printer_printable_rect(PRINTER p, int * w, int * h);
extern "C" void fl_printer_get_origin(PRINTER p, int * x, int * y);
extern "C" void fl_printer_set_origin(PRINTER p, int x, int y);
extern "C" void fl_printer_rotate(PRINTER p, float r);
extern "C" void fl_printer_scale(PRINTER p, float x, float y);
extern "C" void fl_printer_translate(PRINTER p, int x, int y);
extern "C" void fl_printer_untranslate(PRINTER p);


extern "C" void fl_printer_print_widget(PRINTER p, void * i, int dx, int dy);
extern "C" void fl_printer_print_window_part(PRINTER p, void * i, int x, int y,
    int w, int h, int dx, int dy);


extern "C" void fl_printer_set_current(PRINTER p);


#endif


