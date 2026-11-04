

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#include <cerrno>
#include <cstring>
#include <fcntl.h>
#include <unistd.h>
#include "c_fl_file_sink.h"




bool file_sink_write_all(int fd, const char *p, size_t n) {
    size_t done = 0;
    while (done < n) {
        ssize_t w = write(fd, p + done, n - done);
        if (w > 0) {
            done += static_cast<size_t>(w);
        } else if (w < 0 && errno == EINTR) {
            continue;
        } else {
            return false;
        }
    }
    return true;
}

static size_t sink_put(File_Sink *s, const char *p, size_t n) {
    if (s->fd >= 0 && !s->failed && !file_sink_write_all(s->fd, p, n)) {
        s->failed = true;
    }
    return n;
}

static int sink_finish(File_Sink *s) {
    if (s->fd >= 0 && close(s->fd) != 0) {
        s->failed = true;
    }
    s->fd = -1;
    return s->failed ? -1 : 0;
}

#if defined(__linux__)

static ssize_t sink_write(void *c, const char *p, size_t n) {
    return static_cast<ssize_t>(sink_put(static_cast<File_Sink*>(c), p, n));
}

static int sink_close(void *c) {
    return sink_finish(static_cast<File_Sink*>(c));
}

static FILE * sink_stream(File_Sink *s) {
    cookie_io_functions_t f = {0, sink_write, 0, sink_close};
    return fopencookie(s, "w", f);
}

#else

static int sink_write(void *c, const char *p, int n) {
    return static_cast<int>(sink_put(static_cast<File_Sink*>(c), p, static_cast<size_t>(n)));
}

static int sink_close(void *c) {
    return sink_finish(static_cast<File_Sink*>(c));
}

static FILE * sink_stream(File_Sink *s) {
    return funopen(s, 0, sink_write, 0, sink_close);
}

#endif

FILE * file_sink_open(File_Sink *s, const char *name) {
    s->failed = false;
    s->fd = open(name, O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0666);
    if (s->fd < 0) {
        return 0;
    }
    FILE *f = sink_stream(s);
    if (f == 0) {
        int e = errno;
        close(s->fd);
        s->fd = -1;
        errno = e;
    }
    return f;
}




//  Flattened C API

const char * fl_file_sink_message(int e) {
    return strerror(e);
}


