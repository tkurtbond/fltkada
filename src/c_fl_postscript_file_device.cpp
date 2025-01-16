

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_PostScript.H>
#include "c_fl_postscript_file_device.h"




//  Making available protected methods

class My_PostScript_File_Device : Fl_PostScript_File_Device {
public:
    using Fl_PostScript_File_Device::driver;
};




//  Flattened C API

POSTSCRIPTFILEDEVICE new_fl_postscript_file_device(void) {
    Fl_PostScript_File_Device *p = new Fl_PostScript_File_Device();
    return p;
}

void free_fl_postscript_file_device(POSTSCRIPTFILEDEVICE p) {
    delete static_cast<Fl_PostScript_File_Device*>(p);
}




const char * fl_postscript_file_device_get_file_chooser_title() {
    return Fl_PostScript_File_Device::file_chooser_title;
}

void fl_postscript_file_device_set_file_chooser_title(const char * v) {
    Fl_PostScript_File_Device::file_chooser_title = v;
}




void * fl_postscript_file_device_get_driver(POSTSCRIPTFILEDEVICE p) {
    return (static_cast<Fl_PostScript_File_Device*>(p)->*(&My_PostScript_File_Device::driver))();
}




int fl_postscript_file_device_start_job(POSTSCRIPTFILEDEVICE p, int c) {
    return static_cast<Fl_PostScript_File_Device*>(p)->start_job(c, 0, 0);
}

int fl_postscript_file_device_start_job2(POSTSCRIPTFILEDEVICE p, int c, int * f, int * t) {
    return static_cast<Fl_PostScript_File_Device*>(p)->start_job(c, f, t);
}

int fl_postscript_file_device_start_job3(POSTSCRIPTFILEDEVICE p, void * o, int c, int f, int l) {
    return static_cast<Fl_PostScript_File_Device*>(p)->start_job
        (static_cast<FILE*>(o),
         c,
         static_cast<Fl_Paged_Device::Page_Format>(f),
         static_cast<Fl_Paged_Device::Page_Layout>(l));
}

int fl_postscript_file_device_start_job4(POSTSCRIPTFILEDEVICE p, int c, int f, int l) {
    return static_cast<Fl_PostScript_File_Device*>(p)->start_job
       (c,
        static_cast<Fl_Paged_Device::Page_Format>(f),
        static_cast<Fl_Paged_Device::Page_Layout>(l));
}

void fl_postscript_file_device_end_job(POSTSCRIPTFILEDEVICE p) {
    static_cast<Fl_PostScript_File_Device*>(p)->end_job();
}

int fl_postscript_file_device_start_page(POSTSCRIPTFILEDEVICE p) {
    return static_cast<Fl_PostScript_File_Device*>(p)->start_page();
}

int fl_postscript_file_device_end_page(POSTSCRIPTFILEDEVICE p) {
    return static_cast<Fl_PostScript_File_Device*>(p)->end_page();
}




void fl_postscript_file_device_margins(POSTSCRIPTFILEDEVICE p, int * l, int * t, int * r, int * b) {
    static_cast<Fl_PostScript_File_Device*>(p)->margins(l,t,r,b);
}

int fl_postscript_file_device_printable_rect(POSTSCRIPTFILEDEVICE p, int * w, int * h) {
    return static_cast<Fl_PostScript_File_Device*>(p)->printable_rect(w,h);
}

void fl_postscript_file_device_get_origin(POSTSCRIPTFILEDEVICE p, int * x, int * y) {
    static_cast<Fl_PostScript_File_Device*>(p)->origin(x,y);
}

void fl_postscript_file_device_set_origin(POSTSCRIPTFILEDEVICE p, int x, int y) {
    static_cast<Fl_PostScript_File_Device*>(p)->origin(x,y);
}

void fl_postscript_file_device_rotate(POSTSCRIPTFILEDEVICE p, float r) {
    static_cast<Fl_PostScript_File_Device*>(p)->rotate(r);
}

void fl_postscript_file_device_scale(POSTSCRIPTFILEDEVICE p, float x, float y) {
    static_cast<Fl_PostScript_File_Device*>(p)->scale(x,y);
}

void fl_postscript_file_device_translate(POSTSCRIPTFILEDEVICE p, int x, int y) {
    static_cast<Fl_PostScript_File_Device*>(p)->translate(x,y);
}

void fl_postscript_file_device_untranslate(POSTSCRIPTFILEDEVICE p) {
    static_cast<Fl_PostScript_File_Device*>(p)->untranslate();
}


