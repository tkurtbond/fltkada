

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#ifndef FL_FILE_SINK_GUARD
#define FL_FILE_SINK_GUARD

#include <cstdio>


//  A file the shim opens itself, written through a stream of its own, so
//  that FLTK and Cairo see every write work, and the failure of one is
//  remembered instead.  Closing the stream closes the file, and fails if
//  any write or the close failed.  FLTK's EPS and SVG surfaces close the
//  stream with the close function they are given.

struct File_Sink {
    int fd;       //  the file's descriptor, or -1
    bool failed;  //  a write, or closing the file, failed
};

//  Opens Name for writing, as fopen "w" would, through S, which must last
//  until the stream is closed.  0, with errno set, if it can't.
FILE * file_sink_open(File_Sink *s, const char *name);

//  Writes N bytes at P to FD, retrying an interrupted write; whether all
//  were written.
bool file_sink_write_all(int fd, const char *p, size_t n);


extern "C" const char * fl_file_sink_message(int e);


#endif


