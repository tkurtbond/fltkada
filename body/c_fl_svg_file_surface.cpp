

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#include <FL/Fl_SVG_File_Surface.H>
#include <FL/Fl_Window.H>
#include <FL/fl_config.h>
#include <cerrno>
#include <new>
#include "c_fl_svg_file_surface.h"
#include "c_fl_file_sink.h"




//  An FLTK built without SVG support has a stub SVG surface with no driver,
//  which writes nothing (drivers/SVG/Fl_SVG_File_Surface.cxx:1003-1013).
//  fl_config.h, which is installed, says which.

int fl_svg_file_surface_supported() {
#if defined(FLTK_USE_SVG) && FLTK_USE_SVG
    return 1;
#else
    return 0;
#endif
}




//  The SVG goes to the file through a File_Sink, and close() reports a
//  failed write through the close function, which closes the Sink's
//  stream.  close() deletes the surface's driver, so after it the surface
//  must not be made current, or drawn on (Fl_SVG_File_Surface.cxx:369-376,
//  Fl_Device.cxx:91-98).

static int close_sink(FILE *f) {
    return fclose(f) != 0 ? -1 : 0;
}

class My_SVG_File_Surface : public Fl_SVG_File_Surface {
public:
    File_Sink *sink;
    bool closed;

    My_SVG_File_Surface(int w, int h, FILE *f, File_Sink *s)
        : Fl_SVG_File_Surface(w, h, f, close_sink), sink(s), closed(false) {}

    //  0, or -1 if a write failed; once.
    int finish() {
        if (closed) {
            return 0;
        }
        closed = true;
        return close();
    }

    ~My_SVG_File_Surface() {
        finish();
        delete sink;
    }
};




//  Flattened C API

//  0, with E set to errno, if the file can't be opened.
SVGFILESURFACE new_fl_svg_file_surface(const char * n, int w, int h, int * e) {
    File_Sink *s = new (std::nothrow) File_Sink;
    if (s == 0) {
        *e = ENOMEM;
        return 0;
    }
    FILE *f = file_sink_open(s, n);
    if (f == 0) {
        *e = errno;
        delete s;
        return 0;
    }
    try {
        return new My_SVG_File_Surface(w, h, f, s);
    } catch (...) {
        fclose(f);
        delete s;
        *e = ENOMEM;
        return 0;
    }
}

void free_fl_svg_file_surface(SVGFILESURFACE s) {
    delete static_cast<My_SVG_File_Surface*>(s);
}




int fl_svg_file_surface_finish(SVGFILESURFACE s) {
    return static_cast<My_SVG_File_Surface*>(s)->finish();
}




void fl_svg_file_surface_printable_rect(SVGFILESURFACE s, int * w, int * h) {
    static_cast<Fl_SVG_File_Surface*>(s)->printable_rect(w,h);
}

void fl_svg_file_surface_get_origin(SVGFILESURFACE s, int * x, int * y) {
    static_cast<Fl_SVG_File_Surface*>(s)->origin(x,y);
}

void fl_svg_file_surface_set_origin(SVGFILESURFACE s, int x, int y) {
    static_cast<Fl_SVG_File_Surface*>(s)->origin(x,y);
}

void fl_svg_file_surface_translate(SVGFILESURFACE s, int x, int y) {
    static_cast<Fl_SVG_File_Surface*>(s)->translate(x,y);
}

void fl_svg_file_surface_untranslate(SVGFILESURFACE s) {
    static_cast<Fl_SVG_File_Surface*>(s)->untranslate();
}




void fl_svg_file_surface_draw(SVGFILESURFACE s, void * w, int dx, int dy) {
    static_cast<Fl_SVG_File_Surface*>(s)->draw(static_cast<Fl_Widget*>(w),dx,dy);
}

void fl_svg_file_surface_draw_decorated_window(SVGFILESURFACE s, void * w, int dx, int dy) {
    static_cast<Fl_SVG_File_Surface*>(s)->draw_decorated_window
        (static_cast<Fl_Window*>(w),dx,dy);
}

void fl_svg_file_surface_print_window_part(SVGFILESURFACE s, void * w,
        int x, int y, int wd, int ht, int dx, int dy) {
    static_cast<Fl_SVG_File_Surface*>(s)->print_window_part
        (static_cast<Fl_Window*>(w),x,y,wd,ht,dx,dy);
}




void fl_svg_file_surface_set_current(SVGFILESURFACE s) {
    static_cast<Fl_SVG_File_Surface*>(s)->set_current();
}


