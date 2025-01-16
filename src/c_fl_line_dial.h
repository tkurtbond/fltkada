

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_LINE_DIAL_GUARD
#define FL_LINE_DIAL_GUARD


typedef void* LINEDIAL;


extern "C" LINEDIAL new_fl_line_dial(int x, int y, int w, int h, char* label);
extern "C" void free_fl_line_dial(LINEDIAL v);


extern "C" void fl_line_dial_draw(LINEDIAL v);
extern "C" int fl_line_dial_handle(LINEDIAL v, int e);


#endif


