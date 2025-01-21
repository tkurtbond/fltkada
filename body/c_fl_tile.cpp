

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Tile.H>
#include "c_fl_tile.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Tile : public Fl_Tile {
public:
    using Fl_Tile::Fl_Tile;

    friend void fl_tile_draw(TILE n);
    friend int fl_tile_handle(TILE n, int e);

    void draw();
    int handle(int e);
};

void My_Tile::draw() {
    widget_draw_hook(this->user_data());
}

int My_Tile::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}




//  Flattened C API

TILE new_fl_tile(int x, int y, int w, int h, char* label) {
    My_Tile *b = new My_Tile(x, y, w, h, label);
    return b;
}

void free_fl_tile(TILE t) {
    delete static_cast<My_Tile*>(t);
}




void fl_tile_position(TILE t, int ox, int oy, int nx, int ny) {
    static_cast<Fl_Tile*>(t)->position(ox,oy,nx,ny);
}

void fl_tile_resize(TILE t, int x, int y, int w, int h) {
    static_cast<Fl_Tile*>(t)->resize(x, y, w, h);
}




void fl_tile_draw(TILE n) {
    static_cast<My_Tile*>(n)->Fl_Tile::draw();
}

int fl_tile_handle(TILE n, int e) {
    return static_cast<My_Tile*>(n)->Fl_Tile::handle(e);
}


