

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_LABEL_GUARD
#define FL_LABEL_GUARD




typedef void* LABEL;




extern "C" LABEL new_fl_label(const char * v, int f, int s, unsigned int h, int k, unsigned int p);
extern "C" void free_fl_label(LABEL l);




extern "C" void fl_label_set_value(LABEL l, const char * v);
extern "C" int fl_label_get_font(LABEL l);
extern "C" void fl_label_set_font(LABEL l, int f);
extern "C" int fl_label_get_size(LABEL l);
extern "C" void fl_label_set_size(LABEL l, int s);
extern "C" unsigned int fl_label_get_color(LABEL l);
extern "C" void fl_label_set_color(LABEL l, unsigned int h);
extern "C" int fl_label_get_type(LABEL l);
extern "C" void fl_label_set_type(LABEL l, int k);
extern "C" unsigned int fl_label_get_align(LABEL l);
extern "C" void fl_label_set_align(LABEL l, unsigned int p);
extern "C" void fl_label_set_image(LABEL l, void * i);
extern "C" void fl_label_set_deimage(LABEL l, void * i);


extern "C" void fl_label_draw(LABEL l, int x, int y, int w, int h, unsigned int p);
extern "C" void fl_label_measure(LABEL l, int &w, int &h);


#endif


