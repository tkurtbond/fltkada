

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_SURFACE_DEVICE_GUARD
#define FL_SURFACE_DEVICE_GUARD


typedef void* SURFACEDEVICE;


extern "C" SURFACEDEVICE new_fl_surface_device(void * g);
extern "C" void free_fl_surface_device(SURFACEDEVICE s);


extern "C" void fl_surface_device_set_current(SURFACEDEVICE s);
extern "C" SURFACEDEVICE fl_surface_device_get_surface(void);


extern "C" void * fl_surface_device_get_driver(SURFACEDEVICE s);
extern "C" void fl_surface_device_set_driver(SURFACEDEVICE s, void * g);


#endif

