

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#include <FL/Fl_Plugin.H>
#include <new>
#include "c_fl_plugin.h"




//  A plugin an Ada object stands for.  Fl_Plugin adds itself to its class's
//  group of FLTK's plugin database, and its destructor removes it.  The Ada
//  side checks the name first: two of one name in a class share a node,
//  which the second removal frees again (pofltk 108).
class My_Plugin : public Fl_Plugin {
    public:
        My_Plugin(const char * k, const char * n, void * a) : Fl_Plugin(k, n), ada(a) {}
        void * ada;
};




//  0 if out of memory.
void * new_fl_plugin(const char * k, const char * n, void * a) {
    try {
        return static_cast<Fl_Plugin*>(new My_Plugin(k, n, a));
    } catch (...) {
        return 0;
    }
}

void free_fl_plugin(void * p) {
    delete static_cast<Fl_Plugin*>(p);
}




int fl_plugin_manager_plugins(const char * k) {
    Fl_Plugin_Manager m(k);
    return m.plugins();
}

int fl_plugin_manager_has(const char * k, const char * n) {
    Fl_Plugin_Manager m(k);
    return m.groupExists(n);
}

//  The Ada object of plugin i, or 0 for a plugin made in C++.  i must be in
//  range: plugin(i) makes a new group otherwise (pofltk 108).
void * fl_plugin_manager_object_at(const char * k, int i) {
    Fl_Plugin_Manager m(k);
    My_Plugin * p = dynamic_cast<My_Plugin*>(m.plugin(i));
    return p == 0 ? 0 : p->ada;
}

//  0 if the class has no plugin of that name, or it was made in C++.
void * fl_plugin_manager_object_named(const char * k, const char * n) {
    Fl_Plugin_Manager m(k);
    My_Plugin * p = dynamic_cast<My_Plugin*>(m.plugin(n));
    return p == 0 ? 0 : p->ada;
}

//  The name of plugin i, in its node of FLTK's plugin database, which lasts
//  until the plugin is removed.  The Ada side copies it at once.
const char * fl_plugin_manager_name(const char * k, int i) {
    Fl_Plugin_Manager m(k);
    return m.group(i);
}

int fl_plugin_manager_load(const char * f) {
    return Fl_Plugin_Manager::load(f) == 0;
}


