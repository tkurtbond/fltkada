//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.
//
//  Written by tools/gen-constants.py; edit that, not this.


//  FLTK's value of each constant the Ada test, fltk-test_glu_constants.adb,
//  checks, in the same order.


#include <GL/glu.h>


extern "C" const long long c_glu_constants[];

extern "C" const long long c_glu_constants[] =
{
    //  Quadric draw styles (gluQuadricDrawStyle)
    GLU_POINT,
    GLU_LINE,
    GLU_FILL,
    GLU_SILHOUETTE,
    //  Quadric normals (gluQuadricNormals)
    GLU_SMOOTH,
    GLU_FLAT,
    GLU_NONE,
    //  Quadric orientations (gluQuadricOrientation)
    GLU_OUTSIDE,
    GLU_INSIDE
};
