

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FL_PLUGIN_GUARD
#define FL_PLUGIN_GUARD


extern "C" void * new_fl_plugin(const char * k, const char * n, void * a);
extern "C" void free_fl_plugin(void * p);


extern "C" int fl_plugin_manager_plugins(const char * k);
extern "C" int fl_plugin_manager_has(const char * k, const char * n);
extern "C" void * fl_plugin_manager_object_at(const char * k, int i);
extern "C" void * fl_plugin_manager_object_named(const char * k, const char * n);
extern "C" const char * fl_plugin_manager_name(const char * k, int i);
extern "C" int fl_plugin_manager_load(const char * f);


#endif


