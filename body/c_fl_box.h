

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_BOX_GUARD
#define FL_BOX_GUARD


typedef void* BOX;


extern "C" BOX new_fl_box(int x, int y, int w, int h, char * label);
extern "C" BOX new_fl_box2(int k, int x, int y, int w, int h, char * label);
extern "C" void free_fl_box(BOX b);


extern "C" void fl_box_draw(BOX n);
extern "C" int fl_box_handle(BOX n, int e);


#endif


