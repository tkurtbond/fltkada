

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_LINE_DIAL_GUARD
#define FL_LINE_DIAL_GUARD


typedef void* LINE_DIAL;


extern "C" LINE_DIAL new_fl_line_dial(int x, int y, int w, int h, char* label);
extern "C" void free_fl_line_dial(LINE_DIAL v);


extern "C" void fl_line_dial_draw(LINE_DIAL v);
extern "C" int fl_line_dial_handle(LINE_DIAL v, int e);


#endif


