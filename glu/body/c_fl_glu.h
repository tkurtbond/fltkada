//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FL_GLU_GUARD
#define FL_GLU_GUARD


typedef void* GLUQUADRIC;


extern "C" void fl_glu_perspective(double fovy, double aspect, double n, double f);
extern "C" void fl_glu_look_at(double ex, double ey, double ez, double cx, double cy, double cz,
        double ux, double uy, double uz);
extern "C" void fl_glu_ortho_2d(double l, double r, double b, double t);
extern "C" void fl_glu_pick_matrix(double x, double y, double w, double h,
        int vx, int vy, int vw, int vh);

extern "C" GLUQUADRIC fl_glu_new_quadric();
extern "C" void fl_glu_delete_quadric(GLUQUADRIC q);
extern "C" void fl_glu_quadric_draw_style(GLUQUADRIC q, unsigned int style);
extern "C" void fl_glu_quadric_normals(GLUQUADRIC q, unsigned int normals);
extern "C" void fl_glu_quadric_orientation(GLUQUADRIC q, unsigned int o);
extern "C" void fl_glu_quadric_texture(GLUQUADRIC q, int on);

extern "C" void fl_glu_cylinder(GLUQUADRIC q, double base, double top, double height,
        int slices, int stacks);
extern "C" void fl_glu_sphere(GLUQUADRIC q, double r, int slices, int stacks);
extern "C" void fl_glu_disk(GLUQUADRIC q, double inner, double outer, int slices, int loops);
extern "C" void fl_glu_partial_disk(GLUQUADRIC q, double inner, double outer,
        int slices, int loops, double start, double sweep);


#endif
