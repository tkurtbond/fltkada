

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/filename.H>
#include <string.h>
#include "c_fl_filename.h"




const int fl_path_max = FL_PATH_MAX;




void free_filename_file_list(void * l, int n) {
    struct dirent ** p = reinterpret_cast<struct dirent **>(l);
    fl_filename_free_list(&p, n);
}

const char * filename_dname(void * l, int n) {
    return (reinterpret_cast<struct dirent **>(l)[n])->d_name;
}




void filename_decode_uri(char *uri) {
    fl_decode_uri(uri);
}

int filename_absolute(char * to, int tolen, const char * from) {
    return fl_filename_absolute(to, tolen, from);
}

int filename_expand(char * to, int tolen, const char * from) {
    return fl_filename_expand(to, tolen, from);
}

const char * filename_ext(const char * buf) {
    return fl_filename_ext(buf);
}

int filename_isdir(const char * name) {
    return fl_filename_isdir(name);
}

int filename_list(const char * d, void * l, void * f) {
    return fl_filename_list(d, reinterpret_cast<struct dirent ***>(l),
        reinterpret_cast<Fl_File_Sort_F*>(f));
}

int filename_match(const char * name, const char * pattern) {
    return fl_filename_match(name, pattern);
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




int filename_alphasort(char * a, char * b) {
    struct dirent d_aye, d_bee;
    d_aye.d_name[0] = '\0';
    strncat (d_aye.d_name, a, 255);
    d_bee.d_name[0] = '\0';
    strncat (d_bee.d_name, b, 255);
    struct dirent * dp_aye = &d_aye;
    struct dirent * dp_bee = &d_bee;
    int result = fl_alphasort(&dp_aye, &dp_bee);
    return result < 0 ? 0 : result == 0 ? 1 : 2;
}

int filename_casealphasort(char * a, char * b) {
    struct dirent d_aye, d_bee;
    d_aye.d_name[0] = '\0';
    strncat (d_aye.d_name, a, 255);
    d_bee.d_name[0] = '\0';
    strncat (d_bee.d_name, b, 255);
    struct dirent * dp_aye = &d_aye;
    struct dirent * dp_bee = &d_bee;
    int result = fl_casealphasort(&dp_aye, &dp_bee);
    return result < 0 ? 0 : result == 0 ? 1 : 2;
}

int filename_numericsort(char * a, char * b) {
    struct dirent d_aye, d_bee;
    d_aye.d_name[0] = '\0';
    strncat (d_aye.d_name, a, 255);
    d_bee.d_name[0] = '\0';
    strncat (d_bee.d_name, b, 255);
    struct dirent * dp_aye = &d_aye;
    struct dirent * dp_bee = &d_bee;
    int result = fl_numericsort(&dp_aye, &dp_bee);
    return result < 0 ? 0 : result == 0 ? 1 : 2;
}

int filename_casenumericsort(char * a, char * b) {
    struct dirent d_aye, d_bee;
    d_aye.d_name[0] = '\0';
    strncat (d_aye.d_name, a, 255);
    d_bee.d_name[0] = '\0';
    strncat (d_bee.d_name, b, 255);
    struct dirent * dp_aye = &d_aye;
    struct dirent * dp_bee = &d_bee;
    int result = fl_casenumericsort(&dp_aye, &dp_bee);
    return result < 0 ? 0 : result == 0 ? 1 : 2;
}


