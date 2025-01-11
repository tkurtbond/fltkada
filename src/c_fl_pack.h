

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_PACK_GUARD
#define FL_PACK_GUARD


typedef void* PACK;


extern "C" PACK new_fl_pack(int x, int y, int w, int h, char * label);
extern "C" void free_fl_pack(PACK p);


extern "C" int fl_pack_get_spacing(PACK p);
extern "C" void fl_pack_set_spacing(PACK p, int t);


extern "C" void fl_pack_draw(PACK n);
extern "C" int fl_pack_handle(PACK n, int e);


#endif


