//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.
//
//  Written by tools/gen-constants.py; edit that, not this.


//  FLTK's value of each constant the Ada test, fltk-test_forms_constants.adb,
//  checks, in the same order.


#include <FL/Fl_Free.H>
#include <FL/Fl_Timer.H>


extern "C" const long long c_forms_constants[];

extern "C" const long long c_forms_constants[] =
{
    //  Timer kinds (Fl_Timer::type)
    FL_NORMAL_TIMER,
    FL_VALUE_TIMER,
    FL_HIDDEN_TIMER,
    //  Free kinds (Fl_Free::type); a representation clause gives FLTK's values
    FL_NORMAL_FREE,
    FL_SLEEPING_FREE,
    FL_INPUT_FREE,
    FL_CONTINUOUS_FREE,
    FL_ALL_FREE
};
