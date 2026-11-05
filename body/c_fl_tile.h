

//  Programmed by Jedidiah Barber
//  Released into the public domain


#ifndef FL_TILE_GUARD
#define FL_TILE_GUARD


typedef void* TILE;


extern "C" TILE new_fl_tile(int x, int y, int w, int h, char * label);
extern "C" void free_fl_tile(TILE t);


extern "C" void fl_tile_position(TILE t, int ox, int oy, int nx, int ny);
extern "C" void fl_tile_resize(TILE t, int x, int y, int w, int h);
extern "C" void fl_tile_size_range(TILE t, int i, int minw, int minh, int maxw, int maxh);
extern "C" void fl_tile_init_size_range(TILE t, int minw, int minh);


extern "C" void fl_tile_draw(TILE n);
extern "C" int fl_tile_handle(TILE n, int e);


#endif


