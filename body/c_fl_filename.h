

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_FILENAME_GUARD
#define FL_FILENAME_GUARD


extern "C" const int fl_path_max;


extern "C" void free_filename_file_list(void * l, int n);
extern "C" const char * filename_dname(void * l, int n);


extern "C" void filename_decode_uri(char *uri);
extern "C" int filename_absolute(char * to, int tolen, const char * from);
extern "C" int filename_expand(char * to, int tolen, const char * from);
extern "C" const char * filename_ext(const char * buf);
extern "C" int filename_isdir(const char * name);
extern "C" int filename_list(const char * d, void * l, void * f);
extern "C" int filename_match(const char * name, const char * pattern);
extern "C" const char * filename_name(const char * name);
extern "C" int filename_relative(char * to, int tolen, const char * from);
extern "C" char * filename_setext(char * to, int tolen, const char * ext);
extern "C" int filename_open_uri(const char * uri, char * msg, int msglen);


#endif


