

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FL_UTF8_GUARD
#define FL_UTF8_GUARD


extern "C" void fl_utf8_text_free(char * p);


extern "C" int fl_utf8_text_nonspacing(unsigned int ucs);
extern "C" int fl_utf8_text_wcwidth(unsigned int ucs);
extern "C" unsigned int fl_utf8_text_tolower(unsigned int ucs);
extern "C" unsigned int fl_utf8_text_toupper(unsigned int ucs);


extern "C" int fl_utf8_text_test(const char * a, int n);
extern "C" int fl_utf8_text_next_composed(const char * a, int n, int at);
extern "C" int fl_utf8_text_previous_composed(const char * a, int n, int at);


extern "C" char * fl_utf8_text_case(const char * a, int n, int upper, int * got);
extern "C" int fl_utf8_text_strcasecmp(const char * a, int na, const char * b, int nb);
extern "C" int fl_utf8_text_strncasecmp(const char * a, int na, const char * b, int nb, int n);


extern "C" int fl_utf8_text_locale();
extern "C" char * fl_utf8_text_to_mb(const char * a, int n, int * got);
extern "C" char * fl_utf8_text_from_mb(const char * a, int n, int * got);


#endif

