

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


//  FLTK's UTF-8 functions, on Ada's strings, which have a length and no
//  NUL.  Many of FLTK's functions walk past the end they are given, on
//  text that stops in a character (pofltk 115), so each is given a copy
//  with zeros on both sides (Text), and what it returns is kept within
//  the text.  What FLTK writes goes to a buffer made here, big enough
//  for anything it writes (pofltk 116 to 118); the caller copies it and
//  frees it with fl_utf8_text_free.


#include <cstdlib>
#include <cstring>
#include <FL/fl_utf8.h>
#include "c_fl_utf8.h"




namespace {

//  Longer than any step of FLTK's past the end: a codepoint and its
//  continuation bytes, 4 bytes, or two of them for a flag.
const int pad = 16;

class Text {
public:
    char * block;
    char * s;
    int n;
    Text(const char * a, int len)
        : block(static_cast<char*>(std::calloc(std::size_t(len) + 2 * pad, 1))),
          s(block ? block + pad : 0),
          n(block ? len : 0) {
        if (block && len > 0) {
            std::memcpy(s, a, std::size_t(len));
        }
    }
    ~Text() {
        std::free(block);
    }
    bool ok() const {
        return block != 0;
    }
    int within(const char * p) const {
        return p < s ? 0 : p > s + n ? n : int(p - s);
    }
private:
    Text(const Text &);
    Text & operator=(const Text &);
};

//  A buffer for n bytes and a NUL, or 0.
char * buffer(std::size_t n) {
    return static_cast<char*>(std::calloc(n + 1, 1));
}

}




void fl_utf8_text_free(char * p) {
    std::free(p);
}




int fl_utf8_text_nonspacing(unsigned int ucs) {
    return fl_nonspacing(ucs) != 0;
}

int fl_utf8_text_wcwidth(unsigned int ucs) {
    return fl_wcwidth_(ucs);
}

unsigned int fl_utf8_text_tolower(unsigned int ucs) {
    return unsigned(fl_tolower(ucs));
}

unsigned int fl_utf8_text_toupper(unsigned int ucs) {
    return unsigned(fl_toupper(ucs));
}




//  fl_utf8test reads no further than its end.
int fl_utf8_text_test(const char * a, int n) {
    return fl_utf8test(a, unsigned(n));
}

int fl_utf8_text_next_composed(const char * a, int n, int at) {
    Text t(a, n);
    if (!t.ok()) {
        return -1;
    }
    return t.within(fl_utf8_next_composed_char(t.s + at, t.s + n));
}

int fl_utf8_text_previous_composed(const char * a, int n, int at) {
    Text t(a, n);
    if (!t.ok()) {
        return -1;
    }
    return t.within(fl_utf8_previous_composed_char(t.s + at, t.s));
}




//  fl_utf_tolower and fl_utf_toupper take no size and write no NUL
//  (pofltk 116).  Each byte of the text gives 3 bytes at most: a bad one
//  is read as CP1252 or Latin-1, and fl_utf8encode writes at most 4 for a
//  character of 2 to 4.
char * fl_utf8_text_case(const char * a, int n, int upper, int * got) {
    Text t(a, n);
    char * out = buffer(std::size_t(n) * 4 + 4);
    if (!t.ok() || !out) {
        std::free(out);
        return 0;
    }
    const unsigned char * p = reinterpret_cast<const unsigned char*>(t.s);
    *got = upper ? fl_utf_toupper(p, n, out) : fl_utf_tolower(p, n, out);
    return out;
}

//  These stop at a NUL; the copies end with one.
int fl_utf8_text_strcasecmp(const char * a, int na, const char * b, int nb) {
    Text s(a, na), t(b, nb);
    return s.ok() && t.ok() ? fl_utf_strcasecmp(s.s, t.s) : 0;
}

int fl_utf8_text_strncasecmp(const char * a, int na, const char * b, int nb, int n) {
    Text s(a, na), t(b, nb);
    return s.ok() && t.ok() ? fl_utf_strncasecmp(s.s, t.s, n) : 0;
}




int fl_utf8_text_locale() {
    return fl_utf8locale() != 0;
}

//  In a UTF-8 locale these write nothing, not even a NUL, to a buffer too
//  short (pofltk 118).  So they are asked the size first.  fl_utf8from_mb
//  in another locale counts one too many for 1024 bytes or more, so there
//  what it wrote is measured instead.
char * fl_utf8_text_to_mb(const char * a, int n, int * got) {
    Text t(a, n);
    if (!t.ok()) {
        return 0;
    }
    unsigned need = fl_utf8to_mb(t.s, unsigned(n), 0, 0);
    char * out = buffer(need);
    if (!out) {
        return 0;
    }
    unsigned wrote = fl_utf8to_mb(t.s, unsigned(n), out, need + 1);
    *got = int(wrote < need ? wrote : need);
    return out;
}

char * fl_utf8_text_from_mb(const char * a, int n, int * got) {
    Text t(a, n);
    if (!t.ok()) {
        return 0;
    }
    unsigned need = fl_utf8from_mb(0, 0, t.s, unsigned(n));
    char * out = buffer(need);
    if (!out) {
        return 0;
    }
    fl_utf8from_mb(out, need + 1, t.s, unsigned(n));
    *got = fl_utf8locale() ? int(need) : int(std::strlen(out));
    return out;
}

