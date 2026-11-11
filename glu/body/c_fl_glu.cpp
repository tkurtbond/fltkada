//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


//  The part of GLU FLTK.GLU binds, as pofltk's FlGlu.cpp does.


#include <FL/glu.h>
#include "c_fl_glu.h"




//  Conversions

static GLUquadric * quad(GLUQUADRIC q) {
    return static_cast<GLUquadric*>(q);
}




//  The View

void fl_glu_perspective(double fovy, double aspect, double n, double f) {
    gluPerspective(fovy, aspect, n, f);
}

void fl_glu_look_at(double ex, double ey, double ez, double cx, double cy, double cz,
        double ux, double uy, double uz) {
    gluLookAt(ex, ey, ez, cx, cy, cz, ux, uy, uz);
}

void fl_glu_ortho_2d(double l, double r, double b, double t) {
    gluOrtho2D(l, r, b, t);
}

void fl_glu_pick_matrix(double x, double y, double w, double h,
        int vx, int vy, int vw, int vh) {
    GLint v[4] = {vx, vy, vw, vh};
    gluPickMatrix(x, y, w, h, v);
}




//  Quadrics

GLUQUADRIC fl_glu_new_quadric() {
    return gluNewQuadric();
}

void fl_glu_delete_quadric(GLUQUADRIC q) {
    gluDeleteQuadric(quad(q));
}

void fl_glu_quadric_draw_style(GLUQUADRIC q, unsigned int style) {
    gluQuadricDrawStyle(quad(q), style);
}

void fl_glu_quadric_normals(GLUQUADRIC q, unsigned int normals) {
    gluQuadricNormals(quad(q), normals);
}

void fl_glu_quadric_orientation(GLUQUADRIC q, unsigned int o) {
    gluQuadricOrientation(quad(q), o);
}

void fl_glu_quadric_texture(GLUQUADRIC q, int on) {
    gluQuadricTexture(quad(q), on ? GL_TRUE : GL_FALSE);
}

void fl_glu_cylinder(GLUQUADRIC q, double base, double top, double height,
        int slices, int stacks) {
    gluCylinder(quad(q), base, top, height, slices, stacks);
}

void fl_glu_sphere(GLUQUADRIC q, double r, int slices, int stacks) {
    gluSphere(quad(q), r, slices, stacks);
}

void fl_glu_disk(GLUQUADRIC q, double inner, double outer, int slices, int loops) {
    gluDisk(quad(q), inner, outer, slices, loops);
}

void fl_glu_partial_disk(GLUQUADRIC q, double inner, double outer,
        int slices, int loops, double start, double sweep) {
    gluPartialDisk(quad(q), inner, outer, slices, loops, start, sweep);
}

