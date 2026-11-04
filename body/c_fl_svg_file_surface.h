

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FL_SVG_FILE_SURFACE_GUARD
#define FL_SVG_FILE_SURFACE_GUARD


typedef void* SVGFILESURFACE;


extern "C" int fl_svg_file_surface_supported();


extern "C" SVGFILESURFACE new_fl_svg_file_surface(const char * n, int w, int h, int * e);
extern "C" void free_fl_svg_file_surface(SVGFILESURFACE s);


extern "C" int fl_svg_file_surface_finish(SVGFILESURFACE s);


extern "C" void fl_svg_file_surface_printable_rect(SVGFILESURFACE s, int * w, int * h);
extern "C" void fl_svg_file_surface_get_origin(SVGFILESURFACE s, int * x, int * y);
extern "C" void fl_svg_file_surface_set_origin(SVGFILESURFACE s, int x, int y);
extern "C" void fl_svg_file_surface_translate(SVGFILESURFACE s, int x, int y);
extern "C" void fl_svg_file_surface_untranslate(SVGFILESURFACE s);


extern "C" void fl_svg_file_surface_draw(SVGFILESURFACE s, void * w, int dx, int dy);
extern "C" void fl_svg_file_surface_draw_decorated_window(SVGFILESURFACE s, void * w,
    int dx, int dy);
extern "C" void fl_svg_file_surface_print_window_part(SVGFILESURFACE s, void * w,
    int x, int y, int wd, int ht, int dx, int dy);


extern "C" void fl_svg_file_surface_set_current(SVGFILESURFACE s);


#endif


