

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#include <FL/Fl_PostScript.H>
#include <FL/Fl_Window.H>
#include <FL/platform.H>
#include <cerrno>
#include <new>
#include "c_fl_eps_file_surface.h"
#include "c_fl_file_sink.h"




//  An FLTK built with --disable-print has a stub EPS surface with no
//  driver (pofltk 104), and no PostScript file chooser title, which is how
//  the PostScript shim tells.

extern const char * fl_eps_chooser_title
    __asm__("_ZN25Fl_PostScript_File_Device18file_chooser_titleE")
    __attribute__((weak));

int fl_eps_file_surface_supported() {
    return &fl_eps_chooser_title != 0;
}




//  The EPS goes to the file through a File_Sink, so a failed write is no
//  Cairo error, and close() reports it through the close function, which
//  closes the Sink's stream.  close() is always called by the shim, so the
//  destructor, which alerts if it closes the file and that fails
//  (Fl_PostScript.cxx:2051-2058, pofltk 102), never closes it.

static int close_sink(FILE *f) {
    return fclose(f) != 0 ? -1 : 0;
}

class My_EPS_File_Surface : public Fl_EPS_File_Surface {
public:
    File_Sink *sink;
    bool closed;

    My_EPS_File_Surface(int w, int h, FILE *f, Fl_Color b, File_Sink *s)
        : Fl_EPS_File_Surface(w, h, f, b, close_sink), sink(s), closed(false) {}

    //  0, -1 if a write failed, or Cairo's error; once.
    int finish() {
        if (closed) {
            return 0;
        }
        closed = true;
        return close();
    }

    ~My_EPS_File_Surface() {
        finish();
        delete sink;
    }
};




//  Flattened C API

//  The surface is made at the screen's scale, which needs the display open
//  (Fl_PostScript.cxx:1996, PLAN.md, decision 5).  0, with E set to errno,
//  if the file can't be opened.
EPSFILESURFACE new_fl_eps_file_surface(const char * n, int w, int h, unsigned int b, int * e) {
    fl_open_display();
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
        return new My_EPS_File_Surface(w, h, f, static_cast<Fl_Color>(b), s);
    } catch (...) {
        fclose(f);
        delete s;
        *e = ENOMEM;
        return 0;
    }
}

void free_fl_eps_file_surface(EPSFILESURFACE s) {
    delete static_cast<My_EPS_File_Surface*>(s);
}




int fl_eps_file_surface_finish(EPSFILESURFACE s) {
    return static_cast<My_EPS_File_Surface*>(s)->finish();
}




void fl_eps_file_surface_printable_rect(EPSFILESURFACE s, int * w, int * h) {
    static_cast<Fl_EPS_File_Surface*>(s)->printable_rect(w,h);
}

void fl_eps_file_surface_get_origin(EPSFILESURFACE s, int * x, int * y) {
    static_cast<Fl_EPS_File_Surface*>(s)->origin(x,y);
}

void fl_eps_file_surface_set_origin(EPSFILESURFACE s, int x, int y) {
    static_cast<Fl_EPS_File_Surface*>(s)->origin(x,y);
}

void fl_eps_file_surface_translate(EPSFILESURFACE s, int x, int y) {
    static_cast<Fl_EPS_File_Surface*>(s)->translate(x,y);
}

void fl_eps_file_surface_untranslate(EPSFILESURFACE s) {
    static_cast<Fl_EPS_File_Surface*>(s)->untranslate();
}




void fl_eps_file_surface_draw(EPSFILESURFACE s, void * w, int dx, int dy) {
    static_cast<Fl_EPS_File_Surface*>(s)->draw(static_cast<Fl_Widget*>(w),dx,dy);
}

void fl_eps_file_surface_draw_decorated_window(EPSFILESURFACE s, void * w, int dx, int dy) {
    static_cast<Fl_EPS_File_Surface*>(s)->draw_decorated_window
        (static_cast<Fl_Window*>(w),dx,dy);
}

void fl_eps_file_surface_print_window_part(EPSFILESURFACE s, void * w,
        int x, int y, int wd, int ht, int dx, int dy) {
    static_cast<Fl_EPS_File_Surface*>(s)->print_window_part
        (static_cast<Fl_Window*>(w),x,y,wd,ht,dx,dy);
}




void fl_eps_file_surface_set_current(EPSFILESURFACE s) {
    static_cast<Fl_EPS_File_Surface*>(s)->set_current();
}


