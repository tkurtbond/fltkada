//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FL_COLUMN_FITTER_GUARD
#define FL_COLUMN_FITTER_GUARD


#include <vector>
#include "c_fl_widget.h"


//  A browser's column widths, where a width of -1 is a share of what the
//  browser's inside leaves after the other widths, shared equally (PLAN.md,
//  Phase 30).  Ported from pofltk's Keeps (src/FlBrowsers.cpp).
//
//  Fl_Browser::column_widths keeps the pointer it is given, so the browser
//  keeps the widths FLTK reads, given, beside the widths as asked.  The
//  -1s are worked out when the widths are set, on a resize, and as each
//  line is drawn, for the width it is drawn in, so that a vertical
//  scrollbar coming or going is allowed for.  Only given's elements are
//  written after it is handed to FLTK, so the pointer stays good.

class Column_Fitter {
public:
    virtual ~Column_Fitter() {}

    //  Takes n widths, none below -1, and returns the array for
    //  column_widths, ended with a 0.  Can throw std::bad_alloc, leaving
    //  the widths as they were.
    const int * set_widths(const int * w, int n) {
        std::vector<int> a(w, w + n);
        a.push_back(0);
        std::vector<int> g(a);
        asked.swap(a);
        given.swap(g);
        refit();
        return given.data();
    }

    //  Works the -1s out for a width W, up to the 0 that ends the list.
    void fit(int W) const {
        if (asked.empty()) {
            return;
        }
        int shares = 0, rest = W;
        size_t n = 0;
        for (; asked[n] != 0; n++) {
            if (asked[n] < 0) {
                shares++;
            } else {
                rest -= asked[n];
            }
        }
        if (shares == 0) {
            return;
        }
        if (rest < 0) {
            rest = 0;
        }
        //  Each share is what is left over the shares left, so the last
        //  takes the remainder; at least 1, since 0 would end FLTK's list.
        for (size_t i = 0; i < n; i++) {
            if (asked[i] < 0) {
                int s = rest / shares--;
                given[i] = s < 1 ? 1 : s;
                rest -= s;
            }
        }
    }

    //  Works the -1s out for the browser's inside.
    virtual void refit() const = 0;

private:
    std::vector<int> asked;
    mutable std::vector<int> given;
};


template <class B> class Fitting_Columns : public Ada_Resizing<B>, public Column_Fitter {
public:
    using Ada_Resizing<B>::Ada_Resizing;

    void base_resize(int x, int y, int w, int h) override {
        Ada_Resizing<B>::base_resize(x, y, w, h);
        refit();
    }

    void refit() const override {
        int X, Y, W, H;
        this->bbox(X, Y, W, H);
        fit(W);
    }
};


#endif

