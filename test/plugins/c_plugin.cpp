

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


//  A shared library for test_plugins: a plugin of class "loaded", named
//  PLUGIN, made as the library loads, which no Ada object stands for.  The
//  Makefile builds it as bin/unit/plugins/one.so and two.so.


#include <FL/Fl_Plugin.H>




namespace {

class Loaded : public Fl_Plugin {
    public:
        Loaded() : Fl_Plugin("loaded", PLUGIN) {}
};

Loaded loaded;

}  // namespace


