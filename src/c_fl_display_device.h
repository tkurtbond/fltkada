

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_DISPLAY_DEVICE_GUARD
#define FL_DISPLAY_DEVICE_GUARD


typedef void* DISPLAYDEVICE;


extern "C" DISPLAYDEVICE new_fl_display_device(void * g);
extern "C" void free_fl_display_device(DISPLAYDEVICE d);


extern "C" DISPLAYDEVICE fl_display_device_display_device();


#endif


