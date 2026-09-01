

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Device.H>
#include "c_fl_display_device.h"




DISPLAYDEVICE new_fl_display_device(void * g) {
    //  Since FLTK 1.4.0, Fl_Display_Device's constructor is private and it is
    //  a singleton; only the platform-provided instance can be obtained.
    (void)g;
    return Fl_Display_Device::display_device();
}

void free_fl_display_device(DISPLAYDEVICE d) {
    //  The instance returned by new_fl_display_device is the shared
    //  singleton owned by FLTK itself, so it must never be deleted here.
    (void)d;
}




DISPLAYDEVICE fl_display_device_display_device() {
    return Fl_Display_Device::display_device();
}


