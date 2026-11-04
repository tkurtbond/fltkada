

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FL_EPS_FILE_SURFACE_GUARD
#define FL_EPS_FILE_SURFACE_GUARD


typedef void* EPSFILESURFACE;


extern "C" int fl_eps_file_surface_supported();


extern "C" EPSFILESURFACE new_fl_eps_file_surface(const char * n, int w, int h, unsigned int b,
    int * e);
extern "C" void free_fl_eps_file_surface(EPSFILESURFACE s);


extern "C" int fl_eps_file_surface_finish(EPSFILESURFACE s);


extern "C" void fl_eps_file_surface_printable_rect(EPSFILESURFACE s, int * w, int * h);
extern "C" void fl_eps_file_surface_get_origin(EPSFILESURFACE s, int * x, int * y);
extern "C" void fl_eps_file_surface_set_origin(EPSFILESURFACE s, int x, int y);
extern "C" void fl_eps_file_surface_translate(EPSFILESURFACE s, int x, int y);
extern "C" void fl_eps_file_surface_untranslate(EPSFILESURFACE s);


extern "C" void fl_eps_file_surface_draw(EPSFILESURFACE s, void * w, int dx, int dy);
extern "C" void fl_eps_file_surface_draw_decorated_window(EPSFILESURFACE s, void * w,
    int dx, int dy);
extern "C" void fl_eps_file_surface_print_window_part(EPSFILESURFACE s, void * w,
    int x, int y, int wd, int ht, int dx, int dy);


extern "C" void fl_eps_file_surface_set_current(EPSFILESURFACE s);


#endif


