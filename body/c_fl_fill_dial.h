

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_FILL_DIAL_GUARD
#define FL_FILL_DIAL_GUARD


typedef void* FILLDIAL;


extern "C" FILLDIAL new_fl_fill_dial(int x, int y, int w, int h, char* label);
extern "C" void free_fl_fill_dial(FILLDIAL v);


extern "C" void fl_fill_dial_draw(FILLDIAL v);
extern "C" int fl_fill_dial_handle(FILLDIAL v, int e);


#endif


