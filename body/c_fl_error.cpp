

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl.H>
#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "c_fl_error.h"




//  Obtaining general error messages from errno

char * get_error_message() {
    return strerror(errno);
}




//  Exports from Ada

extern "C" void error_warning_hook(const char * m);
extern "C" void error_error_hook(const char * m);
extern "C" void error_fatal_hook(const char * m);


//  This is the size used internally in FLTK anyway
const int error_bsize = 1024;


//  Some prep needed to convert vargs to a single char*

void warning_hook_prep(const char * m, ...) {
    va_list args;
    char buf[error_bsize];
    va_start(args, m);
    vsnprintf(buf, error_bsize, m, args);
    va_end(args);
    error_warning_hook(buf);
}

void error_hook_prep(const char * m, ...) {
    va_list args;
    char buf[error_bsize];
    va_start(args, m);
    vsnprintf(buf, error_bsize, m, args);
    va_end(args);
    error_error_hook(buf);
}

//  Fl::fatal must not return (Fl.H:557-559): its callers go on as if it
//  had not, and crash (Fl_x.cxx:550-551).  A handler may leave by raising
//  an exception; one that returns ends the program here, with status 1 as
//  FLTK's own does (FLTKAda-BUGS.md 66).
void fatal_hook_prep(const char * m, ...) {
    va_list args;
    char buf[error_bsize];
    va_start(args, m);
    vsnprintf(buf, error_bsize, m, args);
    va_end(args);
    error_fatal_hook(buf);
    exit(1);
}




//  Original function pointers

void (*original_warning)(const char *, ...) = Fl::warning;
void (*original_error)(const char *, ...) = Fl::error;
void (*original_fatal)(const char *, ...) = Fl::fatal;


void fl_error_default_warning(const char * m) {
    (*original_warning)(m);
}

void fl_error_default_error(const char * m) {
    (*original_error)(m);
}

void fl_error_default_fatal(const char * m) {
    (*original_fatal)(m);
}




//  Tying it all together

void fl_error_set_hooks() {
    Fl::warning = &warning_hook_prep;
    Fl::error = &error_hook_prep;
    Fl::fatal = &fatal_hook_prep;
}


