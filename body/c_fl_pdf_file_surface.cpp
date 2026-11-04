

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#include <FL/Fl.H>
#include <FL/Fl_PDF_File_Surface.H>
#include <FL/Fl_Window.H>
#include <FL/platform.H>
#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fcntl.h>
#include <new>
#include <poll.h>
#include <string>
#include <sys/stat.h>
#include <thread>
#include <unistd.h>
#include "c_fl_file_sink.h"
#include "c_fl_pdf_file_surface.h"




//  Under X11 and Wayland, FLTK writes PDF only if it was built with Pango
//  (FL/Fl_PDF_File_Surface.H).  Without it, Fl_PDF_File_Surface is a
//  PostScript device that writes nothing, and its begin_document and
//  begin_job fail (Fl_PostScript.cxx:1475-1493).  The Pango surface's
//  end_job is only in an FLTK built with Pango.  An FLTK built with
//  --disable-print has none of the dialog's texts (Fl_Device.cxx:169,
//  pofltk 104), so the shim names them weakly too, by their mangled names,
//  as a class's static can't be declared weak without defining it.

extern void fl_pdf_pango_end_job()
    __asm__("_ZN25Fl_PDF_Pango_File_Surface7end_jobEv")
    __attribute__((weak));

extern const char * fl_pdf_title
    __asm__("_ZN19Fl_PDF_File_Surface19format_dialog_titleE")
    __attribute__((weak));

extern const char * fl_pdf_page_size
    __asm__("_ZN19Fl_PDF_File_Surface23format_dialog_page_sizeE")
    __attribute__((weak));

extern const char * fl_pdf_orientation
    __asm__("_ZN19Fl_PDF_File_Surface25format_dialog_orientationE")
    __attribute__((weak));

extern const char * fl_pdf_default
    __asm__("_ZN19Fl_PDF_File_Surface21format_dialog_defaultE")
    __attribute__((weak));

int fl_pdf_file_surface_supported() {
    return &fl_pdf_pango_end_job != 0 && &fl_pdf_title != 0;
}




//  The texts of FLTK's "PDF document settings" dialog.  FLTK keeps the
//  pointers, so the shim keeps the copies.  Without them, each is "", and
//  setting one returns 0.

static const char ** const texts[] = {
    &fl_pdf_title,
    &fl_pdf_page_size,
    &fl_pdf_orientation,
    &fl_pdf_default
};

static std::string text_kept[sizeof texts / sizeof texts[0]];

const char * fl_pdf_file_surface_get_text(int i) {
    return texts[i] != 0 && *texts[i] != 0 ? *texts[i] : "";
}

int fl_pdf_file_surface_set_text(int i, const char * v) {
    if (texts[i] == 0) {
        return 0;
    }
    text_kept[i] = v;
    *texts[i] = text_kept[i].c_str();
    return 1;
}




//  FLTK reports a failed write, and any Cairo error, only with fl_alert,
//  which waits for the user (Fl_PostScript.cxx:1774-1793, pofltk 102).  So
//  a document named by the program is written to a FIFO that a thread of
//  the shim's copies to the file: FLTK's writes all work, and a failed one
//  is remembered instead.  A document named in FLTK's file chooser is
//  written by FLTK, and a timer watches end_job for the alert, closes it
//  and says so.

struct Copier {
    int in;       //  the FIFO's read end
    int hold;     //  a write end of the FIFO's, until FLTK has its own
    int stop[2];  //  a pipe, written to stop the copy at once
    int out;      //  the file
    bool failed;  //  a read, a write or closing the file failed
    std::thread thread;
};

//  Copies until every write end of the FIFO is closed, or until stopped.
//  After a failed write, the rest is read and dropped, so that FLTK's
//  writes never wait.
static void copy(Copier *c) {
    char buffer[65536];
    for (;;) {
        struct pollfd p[2] = {{c->in, POLLIN, 0}, {c->stop[0], POLLIN, 0}};
        if (poll(p, 2, -1) < 0) {
            if (errno == EINTR) {
                continue;
            }
            c->failed = true;
            break;
        }
        if (p[1].revents != 0) {
            break;
        }
        ssize_t n = read(c->in, buffer, sizeof buffer);
        if (n == 0) {
            break;
        }
        if (n < 0) {
            if (errno == EINTR || errno == EAGAIN) {
                continue;
            }
            c->failed = true;
            break;
        }
        if (!c->failed && !file_sink_write_all(c->out, buffer, static_cast<size_t>(n))) {
            c->failed = true;
        }
    }
}

//  Closes what is open, but the file, and frees C.
static void free_copier(Copier *c) {
    if (c->in >= 0) {
        close(c->in);
    }
    if (c->hold >= 0) {
        close(c->hold);
    }
    if (c->stop[0] >= 0) {
        close(c->stop[0]);
        close(c->stop[1]);
    }
    delete c;
}

static bool alerted;

static void watch(void *before) {
    Fl_Window *m = Fl::modal();
    if (m != 0 && m != before) {
        alerted = true;
        m->hide();
    }
    Fl::repeat_timeout(0.01, watch, before);
}

class My_PDF_File_Surface : public Fl_PDF_File_Surface {
public:
    bool in_job;
    Copier *copier;
    std::string name;     //  the document's file
    std::string message;  //  why the last thing that failed did

    My_PDF_File_Surface() : Fl_PDF_File_Surface(), in_job(false), copier(0) {}

    void fail(const std::string &m) {
        message = m;
    }

    //  FLTK's message, kept, and freed as allocated (Fl_PostScript.cxx:1735).
    void fail(char *m, const char *otherwise) {
        message = m ? m : otherwise;
        delete[] m;
    }

    //  The FIFO is read from before FLTK opens it, through a write end of
    //  the shim's that keeps the read from ending.  0, or 2.
    int begin(const char *n, Page_Format f, Page_Layout l) {
        Copier *c = new (std::nothrow) Copier;
        if (c == 0) {
            fail(strerror(ENOMEM));
            return 2;
        }
        c->in = c->hold = c->stop[0] = c->stop[1] = -1;
        c->failed = false;
        c->out = open(n, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0666);
        if (c->out < 0) {
            fail(n + std::string(": ") + strerror(errno));
            free_copier(c);
            return 2;
        }
        const char *tmp = getenv("TMPDIR");
        std::string dir = std::string(tmp && tmp[0] ? tmp : "/tmp") + "/fltkada-pdf-XXXXXX";
        std::string fifo;
        bool ready = false;
        if (mkdtemp(&dir[0]) == 0) {
            fail(dir + ": " + strerror(errno));
            dir.clear();
        } else {
            fifo = dir + "/fifo";
            if (mkfifo(fifo.c_str(), 0600) != 0) {
                fail(fifo + ": " + strerror(errno));
                fifo.clear();
            } else if ((c->in = open(fifo.c_str(), O_RDONLY | O_NONBLOCK | O_CLOEXEC)) < 0
                       || (c->hold = open(fifo.c_str(), O_WRONLY | O_CLOEXEC)) < 0
                       || pipe(c->stop) != 0) {
                fail(fifo + ": " + strerror(errno));
            } else {
                try {
                    c->thread = std::thread(copy, c);
                    ready = true;
                } catch (...) {
                    fail("no thread to copy the PDF to " + std::string(n));
                }
            }
        }
        int r = 2;
        if (ready) {
            char *m = 0;
            r = begin_document(fifo.c_str(), f, l, &m);
            if (r != 0) {
                fail(m, "FLTK can't write PDF here");
            }
            close(c->hold);
            c->hold = -1;
            if (r != 0) {
                //  FLTK may have left its end of the FIFO open.
                ssize_t w;
                do {
                    w = write(c->stop[1], "", 1);
                } while (w < 0 && errno == EINTR);
                c->thread.join();
            }
        }
        if (!fifo.empty()) {
            unlink(fifo.c_str());
        }
        if (!dir.empty()) {
            rmdir(dir.c_str());
        }
        if (r != 0) {
            close(c->out);
            free_copier(c);
            return 2;
        }
        copier = c;
        name = n;
        in_job = true;
        return 0;
    }

    //  0, 1 if the user cancelled, or 2.
    int choose(const char *n) {
        char *m = 0;
        int r = begin_job(n[0] ? n : 0, &m);
        if (r == 0) {
            const char *f = pdf_filename();
            name = f ? f : "";
            in_job = true;
        } else if (r == 1) {
            delete[] m;
        } else {
            fail(m, "the file chooser failed");
        }
        return r == 1 ? 1 : (r == 0 ? 0 : 2);
    }

    //  0, 1 if the PDF couldn't all be written, or 2 if FLTK reported an
    //  error.
    int finish() {
        if (!in_job) {
            return 0;
        }
        in_job = false;
        alerted = false;
        Fl::add_timeout(0, watch, Fl::modal());
        end_job();
        Fl::remove_timeout(watch);
        bool failed = false;
        if (copier != 0) {
            copier->thread.join();
            if (close(copier->out) != 0) {
                copier->failed = true;
            }
            failed = copier->failed;
            free_copier(copier);
            copier = 0;
        }
        if (alerted) {
            fail("FLTK reported an error writing " + name);
            return 2;
        }
        if (failed) {
            fail(name + ": the PDF couldn't all be written");
            return 1;
        }
        return 0;
    }

    ~My_PDF_File_Surface() {
        finish();
    }
};




//  Flattened C API

//  The surface is made at the screen's scale, which needs the display open
//  (PLAN.md, decision 5).
PDFFILESURFACE new_fl_pdf_file_surface() {
    fl_open_display();
    try {
        return new My_PDF_File_Surface;
    } catch (...) {
        return 0;
    }
}

void free_fl_pdf_file_surface(PDFFILESURFACE s) {
    delete static_cast<My_PDF_File_Surface*>(s);
}




int fl_pdf_file_surface_begin_document(PDFFILESURFACE s, const char * n, int f, int l) {
    try {
        return static_cast<My_PDF_File_Surface*>(s)->begin
            (n, static_cast<Fl_Paged_Device::Page_Format>(f),
             static_cast<Fl_Paged_Device::Page_Layout>(l));
    } catch (...) {
        static_cast<My_PDF_File_Surface*>(s)->fail("out of memory");
        return 2;
    }
}

int fl_pdf_file_surface_begin_job(PDFFILESURFACE s, const char * n) {
    try {
        return static_cast<My_PDF_File_Surface*>(s)->choose(n);
    } catch (...) {
        static_cast<My_PDF_File_Surface*>(s)->fail("out of memory");
        return 2;
    }
}

int fl_pdf_file_surface_end_job(PDFFILESURFACE s) {
    try {
        return static_cast<My_PDF_File_Surface*>(s)->finish();
    } catch (...) {
        return 2;
    }
}

const char * fl_pdf_file_surface_message(PDFFILESURFACE s) {
    return static_cast<My_PDF_File_Surface*>(s)->message.c_str();
}

const char * fl_pdf_file_surface_file_name(PDFFILESURFACE s) {
    return static_cast<My_PDF_File_Surface*>(s)->name.c_str();
}




int fl_pdf_file_surface_begin_page(PDFFILESURFACE s) {
    return static_cast<Fl_PDF_File_Surface*>(s)->begin_page();
}

int fl_pdf_file_surface_end_page(PDFFILESURFACE s) {
    return static_cast<Fl_PDF_File_Surface*>(s)->end_page();
}




void fl_pdf_file_surface_margins(PDFFILESURFACE s, int * l, int * t, int * r, int * b) {
    static_cast<Fl_PDF_File_Surface*>(s)->margins(l,t,r,b);
}

int fl_pdf_file_surface_printable_rect(PDFFILESURFACE s, int * w, int * h) {
    return static_cast<Fl_PDF_File_Surface*>(s)->printable_rect(w,h);
}

void fl_pdf_file_surface_get_origin(PDFFILESURFACE s, int * x, int * y) {
    static_cast<Fl_PDF_File_Surface*>(s)->origin(x,y);
}

void fl_pdf_file_surface_set_origin(PDFFILESURFACE s, int x, int y) {
    static_cast<Fl_PDF_File_Surface*>(s)->origin(x,y);
}

void fl_pdf_file_surface_rotate(PDFFILESURFACE s, float r) {
    static_cast<Fl_PDF_File_Surface*>(s)->rotate(r);
}

void fl_pdf_file_surface_scale(PDFFILESURFACE s, float x, float y) {
    static_cast<Fl_PDF_File_Surface*>(s)->scale(x,y);
}

void fl_pdf_file_surface_translate(PDFFILESURFACE s, int x, int y) {
    static_cast<Fl_PDF_File_Surface*>(s)->translate(x,y);
}

void fl_pdf_file_surface_untranslate(PDFFILESURFACE s) {
    static_cast<Fl_PDF_File_Surface*>(s)->untranslate();
}




void fl_pdf_file_surface_set_current(PDFFILESURFACE s) {
    static_cast<Fl_PDF_File_Surface*>(s)->set_current();
}


