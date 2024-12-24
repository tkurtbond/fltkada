

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Device.H>
#include "c_fl_display_device.h"




DISPLAYDEVICE new_fl_display_device(void * g) {
    Fl_Display_Device *d = new Fl_Display_Device(reinterpret_cast<Fl_Graphics_Driver*>(g));
    return d;
}

void free_fl_display_device(DISPLAYDEVICE d) {
    delete reinterpret_cast<Fl_Display_Device*>(d);
}




DISPLAYDEVICE fl_display_device_display_device() {
    return Fl_Display_Device::display_device();
}


