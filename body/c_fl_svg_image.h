

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#ifndef FL_SVG_IMAGE_GUARD
#define FL_SVG_IMAGE_GUARD


#include <stddef.h>


typedef void* SVGIMAGE;


extern "C" int fl_svg_image_available();


extern "C" SVGIMAGE new_fl_svg_image(const char * f);
extern "C" SVGIMAGE new_fl_svg_image2(const char * n, const char * d);
extern "C" SVGIMAGE new_fl_svg_image3(const char * n, void * d, size_t l);
extern "C" void free_fl_svg_image(SVGIMAGE s);


extern "C" int fl_svg_image_get_proportional(SVGIMAGE s);
extern "C" void fl_svg_image_set_proportional(SVGIMAGE s, int p);
extern "C" void fl_svg_image_resize(SVGIMAGE s, int w, int h);
extern "C" void fl_svg_image_normalize(SVGIMAGE s);


extern "C" SVGIMAGE fl_svg_image_copy(SVGIMAGE s, int w, int h);
extern "C" SVGIMAGE fl_svg_image_copy2(SVGIMAGE s);


extern "C" void fl_svg_image_color_average(SVGIMAGE s, int c, float b);
extern "C" void fl_svg_image_desaturate(SVGIMAGE s);


extern "C" void fl_svg_image_draw(SVGIMAGE s, int x, int y, int w, int h, int cx, int cy);


#endif


