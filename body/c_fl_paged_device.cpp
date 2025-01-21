

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Paged_Device.H>
#include <FL/Fl_Widget.H>
#include <FL/Fl_Window.H>
#include "c_fl_paged_device.h"




//  Enums and macro constants

const int fl_page_format_media = Fl_Paged_Device::MEDIA;

const int fl_page_layout_portrait    = Fl_Paged_Device::PORTRAIT;
const int fl_page_layout_landscape   = Fl_Paged_Device::LANDSCAPE;
const int fl_page_layout_reversed    = Fl_Paged_Device::REVERSED;
const int fl_page_layout_orientation = Fl_Paged_Device::ORIENTATION;

const int fl_no_page_formats = NO_PAGE_FORMATS;




//  Helper functions

void fl_paged_device_get_page_format(int i, const char ** n, int * w, int * h) {
    *n = Fl_Paged_Device::page_formats[i].name;
    *w = Fl_Paged_Device::page_formats[i].height;
    *h = Fl_Paged_Device::page_formats[i].width;
}




//  Adding relevant friends

class My_Paged_Device : public Fl_Paged_Device {
public:
    using Fl_Paged_Device::Fl_Paged_Device;
    friend PAGEDDEVICE new_fl_paged_device(void);
};




//  Flattened C API

PAGEDDEVICE new_fl_paged_device(void) {
    My_Paged_Device *p = new My_Paged_Device();
    return p;
}

void free_fl_paged_device(PAGEDDEVICE p) {
    delete static_cast<My_Paged_Device*>(p);
}




int fl_paged_device_start_job(PAGEDDEVICE p, int c) {
    //  virtual so disable dispatch
    return static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::start_job(c, 0, 0);
}

int fl_paged_device_start_job2(PAGEDDEVICE p, int c, int * f, int * t) {
    //  virtual so disable dispatch
    return static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::start_job(c, f, t);
}

void fl_paged_device_end_job(PAGEDDEVICE p) {
    //  virtual so disable dispatch
    static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::end_job();
}

int fl_paged_device_start_page(PAGEDDEVICE p) {
    //  virtual so disable dispatch
    return static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::start_page();
}

int fl_paged_device_end_page(PAGEDDEVICE p) {
    //  virtual so disable dispatch
    return static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::end_page();
}




void fl_paged_device_margins(PAGEDDEVICE p, int * l, int * t, int * r, int * b) {
    //  virtual so disable dispatch
    static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::margins(l,t,r,b);
}

int fl_paged_device_printable_rect(PAGEDDEVICE p, int * w, int * h) {
    //  virtual so disable dispatch
    return static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::printable_rect(w,h);
}

void fl_paged_device_get_origin(PAGEDDEVICE p, int * x, int * y) {
    //  virtual so disable dispatch
    static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::origin(x,y);
}

void fl_paged_device_set_origin(PAGEDDEVICE p, int x, int y) {
    //  virtual so disable dispatch
    static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::origin(x,y);
}

void fl_paged_device_rotate(PAGEDDEVICE p, float r) {
    //  virtual so disable dispatch
    static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::rotate(r);
}

void fl_paged_device_scale(PAGEDDEVICE p, float x, float y) {
    //  virtual so disable dispatch
    static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::scale(x,y);
}

void fl_paged_device_translate(PAGEDDEVICE p, int x, int y) {
    //  virtual so disable dispatch
    static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::translate(x,y);
}

void fl_paged_device_untranslate(PAGEDDEVICE p) {
    //  virtual so disable dispatch
    static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::untranslate();
}




void fl_paged_device_print_widget(PAGEDDEVICE p, void * i, int dx, int dy) {
    //  virtual so disable dispatch
    static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::print_widget
        (static_cast<Fl_Widget*>(i),dx,dy);
}

void fl_paged_device_print_window(PAGEDDEVICE p, void * i, int dx, int dy) {
    static_cast<Fl_Paged_Device*>(p)->print_window(static_cast<Fl_Window*>(i),dx,dy);
}

void fl_paged_device_print_window_part(PAGEDDEVICE p, void * i, int x, int y,
    int w, int h, int dx, int dy)
{
    //  virtual so disable dispatch
    static_cast<Fl_Paged_Device*>(p)->Fl_Paged_Device::print_window_part
        (static_cast<Fl_Window*>(i),x,y,w,h,dx,dy);
}


