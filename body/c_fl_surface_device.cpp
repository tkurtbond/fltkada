

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Device.H>
#include "c_fl_surface_device.h"




//  Adding relevant friends

class My_Surface_Device : public Fl_Surface_Device {
public:
    using Fl_Surface_Device::Fl_Surface_Device;
    friend SURFACEDEVICE new_fl_surface_device(void * g);
};




//  Flattened C API

SURFACEDEVICE new_fl_surface_device(void * g) {
    My_Surface_Device *s = new My_Surface_Device(static_cast<Fl_Graphics_Driver*>(g));
    return s;
}

void free_fl_surface_device(SURFACEDEVICE s) {
    delete static_cast<My_Surface_Device*>(s);
}




void fl_surface_device_set_current(SURFACEDEVICE s) {
    //  virtual so disable dispatch
    static_cast<Fl_Surface_Device*>(s)->Fl_Surface_Device::set_current();
}

SURFACEDEVICE fl_surface_device_get_surface(void) {
    return Fl_Surface_Device::surface();
}




void * fl_surface_device_get_driver(SURFACEDEVICE s) {
    return static_cast<Fl_Surface_Device*>(s)->driver();
}

void fl_surface_device_set_driver(SURFACEDEVICE s, void * g) {
    static_cast<Fl_Surface_Device*>(s)->driver(static_cast<Fl_Graphics_Driver*>(g));
}


