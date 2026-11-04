

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/filename.H>
#include <string.h>
#include <stdlib.h>
#include <string>
#include <pwd.h>
#include <sys/stat.h>
#include "c_fl_filename.h"




const int fl_path_max = FL_PATH_MAX;




void free_filename_file_list(void * l, int n) {
    struct dirent ** p = static_cast<struct dirent **>(l);
    fl_filename_free_list(&p, n);
}

const char * filename_dname(void * l, int n) {
    return (static_cast<struct dirent **>(l)[n])->d_name;
}




void filename_decode_uri(char *uri) {
    fl_decode_uri(uri);
}

int filename_absolute(char * to, int tolen, const char * from) {
    return fl_filename_absolute(to, tolen, from);
}

namespace {

//  Copies text into to, cut short to fit tolen bytes with its NUL.
void copy_out(const char * text, char * to, int tolen) {
    if (tolen <= 0) {
        return;
    }
    size_t n = strlen(text);
    if (n > static_cast<size_t>(tolen) - 1) {
        n = static_cast<size_t>(tolen) - 1;
    }
    memcpy(to, text, n);
    to[n] = '\0';
}

//  What fl_filename_expand does, which can't be called: it aborts on a
//  value that doesn't fit its buffer, rescans what it has put in, so a
//  value naming itself never ends, and reads value[-1] for an empty value
//  (Fl_System_Driver.cxx:247-289; pofltk 120).  Each value goes in as it
//  is.  Derived from pofltk's FlDialogs.cpp.  Returns how many went in.
int expand(std::string &text, size_t &start) {
    int count = 0;
    start = 0;
    for (size_t a = 0; a < text.size();) {
        size_t e = text.find('/', a);
        if (e == std::string::npos) {
            e = text.size();
        }
        const char * value = 0;
        if (text[a] == '~') {
            if (e <= a + 1) {
                value = getenv("HOME");
            } else {
                const passwd * p = getpwnam(text.substr(a + 1, e - a - 1).c_str());
                value = p ? p->pw_dir : 0;
            }
        } else if (text[a] == '$') {
            value = getenv(text.substr(a + 1, e - a - 1).c_str());
        }
        if (value) {
            //  As FLTK has it, a value starting with a slash ends all before it.
            if (*value == '/') {
                start = a;
            }
            size_t t = strlen(value);
            if (t && value[t - 1] == '/') {
                t--;
            }
            text.replace(a, e - a, value, t);
            a += t;
            count++;
            if (a >= text.size() || text[a] != '/') {
                continue;
            }
            a++;
        } else {
            a = e + 1;
        }
    }
    return count;
}

}

int filename_expand(char * to, int tolen, const char * from) {
    try {
        std::string text(from);
        size_t start;
        int r = expand(text, start);
        copy_out(text.c_str() + start, to, tolen);
        return r != 0;
    } catch (...) {
        copy_out(from, to, tolen);
        return 0;
    }
}

const char * filename_ext(const char * buf) {
    return fl_filename_ext(buf);
}

//  What fl_filename_isdir does, but without its copy of a name ending in
//  a slash into fn[FL_PATH_MAX], which a longer name overruns
//  (filename_isdir.cxx:62-76; pofltk 121).  stat takes the slash.
int filename_isdir(const char * name) {
    struct stat s;
    return !stat(name, &s) && S_ISDIR(s.st_mode);
}

int filename_list(const char * d, void * l, void * f) {
    return fl_filename_list(d, static_cast<struct dirent ***>(l),
        reinterpret_cast<Fl_File_Sort_F*>(f));
}

//  A bracket left open takes fl_filename_match past the end of the pattern
//  (filename_match.cxx, the '[' case; pofltk 122), so it gets copies with
//  NULs after them, where it stops.
int filename_match(const char * name, const char * pattern) {
    try {
        std::string n(name), p(pattern);
        n.append(16, '\0');
        p.append(16, '\0');
        return fl_filename_match(n.c_str(), p.c_str());
    } catch (...) {
        return 0;
    }
}

const char * filename_name(const char * name) {
    return fl_filename_name(name);
}

int filename_relative(char * to, int tolen, const char * from) {
    return fl_filename_relative(to, tolen, from);
}

char * filename_setext(char * to, int tolen, const char * ext) {
    return fl_filename_setext(to, tolen, ext);
}

int filename_open_uri(const char * uri, char * msg, int msglen) {
    return fl_open_uri(uri, msg, msglen);
}


