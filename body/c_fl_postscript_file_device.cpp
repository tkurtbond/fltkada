

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_PostScript.H>
#include <cerrno>
#include <cstdio>
#include <unistd.h>
#include "c_fl_postscript_file_device.h"




//  A job given a file writes through a Sink.  Under Pango, on any error
//  from Cairo, FLTK's end_job fcloses the stream it was given and then
//  writes to it (Fl_PostScript.cxx:1956-1959; pofltk 101).  So FLTK gets a
//  stream of the shim's, which tells Cairo every write worked, so that a
//  failed write is no Cairo error, and remembers that one failed.  The Sink
//  writes to its own copy of the file's descriptor, so the program's FILE
//  is never touched, and can be closed before the job ends.
//
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.

struct Sink {
    int fd;       //  the copy of the file's descriptor, or -1
    bool failed;  //  a write failed
    bool closed;  //  FLTK closed the stream: Cairo had an error
};

static size_t sink_put(Sink *s, const char *p, size_t n) {
    size_t done = 0;
    while (s->fd >= 0 && !s->failed && done < n) {
        ssize_t w = write(s->fd, p + done, n - done);
        if (w > 0) {
            done += static_cast<size_t>(w);
        } else if (w < 0 && errno == EINTR) {
            continue;
        } else {
            s->failed = true;
        }
    }
    return n;
}

#if defined(__linux__)

static ssize_t sink_write(void *c, const char *p, size_t n) {
    return static_cast<ssize_t>(sink_put(static_cast<Sink*>(c), p, n));
}

static int sink_close(void *c) {
    static_cast<Sink*>(c)->closed = true;
    return 0;
}

static FILE * sink_open(Sink *s) {
    cookie_io_functions_t f = {0, sink_write, 0, sink_close};
    return fopencookie(s, "w", f);
}

#else

static int sink_write(void *c, const char *p, int n) {
    return static_cast<int>(sink_put(static_cast<Sink*>(c), p, static_cast<size_t>(n)));
}

static int sink_close(void *c) {
    static_cast<Sink*>(c)->closed = true;
    return 0;
}

static FILE * sink_open(Sink *s) {
    return funopen(s, 0, sink_write, 0, sink_close);
}

#endif




//  Making available protected methods, and keeping the Sink

class My_PostScript_File_Device : public Fl_PostScript_File_Device {
public:
    using Fl_PostScript_File_Device::driver;

    FILE *stream;  //  the Sink's stream, given to FLTK, or 0
    Sink sink;
    bool in_job;   //  a job started, not yet ended

    My_PostScript_File_Device() : stream(0), in_job(false) {
        sink.fd = -1;
        sink.failed = sink.closed = false;
    }

    //  Closes the stream and the Sink's descriptor, once.  0 if all was
    //  written, 1 if a write failed, 2 if Cairo had an error.
    int close_stream() {
        bool by_fltk = sink.closed;
        if (stream != 0 && !by_fltk) {
            fclose(stream);
        }
        stream = 0;
        if (sink.fd >= 0 && close(sink.fd) != 0) {
            sink.failed = true;
        }
        sink.fd = -1;
        int result = by_fltk ? 2 : sink.failed ? 1 : 0;
        sink.failed = sink.closed = false;
        return result;
    }

    //  Ends the job, if one is started.  FLTK's destructor doesn't, so
    //  Cairo's surface would never be finished, and the file would stay
    //  empty (FLTKAda-BUGS.md 121).
    int finish() {
        if (!in_job) {
            return 0;
        }
        in_job = false;
        end_job();
        return close_stream();
    }

    ~My_PostScript_File_Device() {
        finish();
        close_stream();
    }
};




//  Flattened C API

POSTSCRIPTFILEDEVICE new_fl_postscript_file_device(void) {
    My_PostScript_File_Device *p = new My_PostScript_File_Device();
    return p;
}

void free_fl_postscript_file_device(POSTSCRIPTFILEDEVICE p) {
    delete static_cast<My_PostScript_File_Device*>(p);
}




//  An FLTK built with --disable-print (FL_NO_PRINT_SUPPORT) has stubs for
//  the device's methods but no file_chooser_title, which is defined only in
//  Fl_PostScript.cxx (:18, 49), and it says so only in config.h, which isn't
//  installed (pofltk 104).  So the shim names it weakly, and its address
//  says whether this FLTK prints.

extern const char * fl_ps_chooser_title
    __asm__("_ZN25Fl_PostScript_File_Device18file_chooser_titleE")
    __attribute__((weak));

int fl_postscript_file_device_supported() {
    return &fl_ps_chooser_title != 0;
}

const char * fl_postscript_file_device_get_file_chooser_title() {
    if (&fl_ps_chooser_title == 0 || fl_ps_chooser_title == 0) {
        return "";
    }
    return fl_ps_chooser_title;
}

void fl_postscript_file_device_set_file_chooser_title(const char * v) {
    if (&fl_ps_chooser_title != 0) {
        fl_ps_chooser_title = v;
    }
}




void * fl_postscript_file_device_get_driver(POSTSCRIPTFILEDEVICE p) {
    return static_cast<My_PostScript_File_Device*>(p)->driver();
}




int fl_postscript_file_device_start_job(POSTSCRIPTFILEDEVICE p, int c) {
    return static_cast<Fl_PostScript_File_Device*>(p)->Fl_Paged_Device::start_job(c, 0, 0);
}

int fl_postscript_file_device_start_job2(POSTSCRIPTFILEDEVICE p, int c, int * f, int * t) {
    return static_cast<Fl_PostScript_File_Device*>(p)->Fl_Paged_Device::start_job(c, f, t);
}

//  3 if the stream can't be made.
int fl_postscript_file_device_start_job3(POSTSCRIPTFILEDEVICE p, void * o, int c, int f, int l) {
    My_PostScript_File_Device *d = static_cast<My_PostScript_File_Device*>(p);
    FILE *out = static_cast<FILE*>(o);
    d->close_stream();
    if (fflush(out) != 0 || (d->sink.fd = dup(fileno(out))) < 0) {
        return 3;
    }
    d->stream = sink_open(&d->sink);
    if (d->stream == 0) {
        d->close_stream();
        return 3;
    }
    int r = d->start_job
        (d->stream,
         c,
         static_cast<Fl_Paged_Device::Page_Format>(f),
         static_cast<Fl_Paged_Device::Page_Layout>(l));
    d->in_job = r == 0;
    return r;
}

int fl_postscript_file_device_start_job4(POSTSCRIPTFILEDEVICE p, int c, int f, int l) {
    My_PostScript_File_Device *d = static_cast<My_PostScript_File_Device*>(p);
    int r = d->start_job
       (c,
        static_cast<Fl_Paged_Device::Page_Format>(f),
        static_cast<Fl_Paged_Device::Page_Layout>(l));
    d->in_job = r == 0;
    return r;
}

//  For a job given a file, 1 if a write failed, 2 if Cairo had an error.
int fl_postscript_file_device_end_job(POSTSCRIPTFILEDEVICE p) {
    return static_cast<My_PostScript_File_Device*>(p)->finish();
}

int fl_postscript_file_device_start_page(POSTSCRIPTFILEDEVICE p) {
    return static_cast<Fl_PostScript_File_Device*>(p)->start_page();
}

int fl_postscript_file_device_end_page(POSTSCRIPTFILEDEVICE p) {
    return static_cast<Fl_PostScript_File_Device*>(p)->end_page();
}




void fl_postscript_file_device_margins(POSTSCRIPTFILEDEVICE p, int * l, int * t, int * r, int * b) {
    static_cast<Fl_PostScript_File_Device*>(p)->margins(l,t,r,b);
}

int fl_postscript_file_device_printable_rect(POSTSCRIPTFILEDEVICE p, int * w, int * h) {
    return static_cast<Fl_PostScript_File_Device*>(p)->printable_rect(w,h);
}

void fl_postscript_file_device_get_origin(POSTSCRIPTFILEDEVICE p, int * x, int * y) {
    static_cast<Fl_PostScript_File_Device*>(p)->origin(x,y);
}

void fl_postscript_file_device_set_origin(POSTSCRIPTFILEDEVICE p, int x, int y) {
    static_cast<Fl_PostScript_File_Device*>(p)->origin(x,y);
}

void fl_postscript_file_device_rotate(POSTSCRIPTFILEDEVICE p, float r) {
    static_cast<Fl_PostScript_File_Device*>(p)->rotate(r);
}

void fl_postscript_file_device_scale(POSTSCRIPTFILEDEVICE p, float x, float y) {
    static_cast<Fl_PostScript_File_Device*>(p)->scale(x,y);
}

void fl_postscript_file_device_translate(POSTSCRIPTFILEDEVICE p, int x, int y) {
    static_cast<Fl_PostScript_File_Device*>(p)->translate(x,y);
}

void fl_postscript_file_device_untranslate(POSTSCRIPTFILEDEVICE p) {
    static_cast<Fl_PostScript_File_Device*>(p)->untranslate();
}


