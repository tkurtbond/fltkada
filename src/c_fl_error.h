

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_ERROR_GUARD
#define FL_ERROR_GUARD


extern "C" const int error_bsize;


extern "C" void fl_error_default_warning(const char * m);
extern "C" void fl_error_default_error(const char * m);
extern "C" void fl_error_default_fatal(const char * m);


extern "C" void fl_error_set_hooks();


#endif


