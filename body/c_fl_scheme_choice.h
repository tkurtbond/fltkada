

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain


#ifndef FL_SCHEME_CHOICE_GUARD
#define FL_SCHEME_CHOICE_GUARD


typedef void* SCHEMECHOICE;


extern "C" SCHEMECHOICE new_fl_scheme_choice(int x, int y, int w, int h, char * label);
extern "C" void free_fl_scheme_choice(SCHEMECHOICE c);


extern "C" void fl_scheme_choice_init_value(SCHEMECHOICE c);


extern "C" void fl_scheme_choice_draw(SCHEMECHOICE n);
extern "C" int fl_scheme_choice_handle(SCHEMECHOICE n, int e);


#endif


