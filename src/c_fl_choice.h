

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_CHOICE_GUARD
#define FL_CHOICE_GUARD


typedef void* CHOICE;


extern "C" CHOICE new_fl_choice(int x, int y, int w, int h, char * label);
extern "C" void free_fl_choice(CHOICE b);


extern "C" int fl_choice_value(CHOICE c);
extern "C" int fl_choice_set_value(CHOICE c, void * i);
extern "C" int fl_choice_set_value2(CHOICE c, int p);


extern "C" void fl_choice_draw(CHOICE n);
extern "C" int fl_choice_handle(CHOICE n, int e);


#endif


