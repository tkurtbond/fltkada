

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Tile.H>
#include "c_fl_tile.h"
#include "c_fl_widget.h"
#include "c_fl.h"




//  Exports from Ada

extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);




//  Attaching all relevant hooks and friends

class My_Tile : public Ada_Resizing<Fl_Tile> {
public:
    using Ada_Resizing<Fl_Tile>::Ada_Resizing;

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
    if (fl_inside_callback) {
        fl_delete_widget(t);
    } else {
        delete static_cast<My_Tile*>(t);
    }
}




void fl_tile_position(TILE t, int ox, int oy, int nx, int ny) {
    static_cast<Fl_Tile*>(t)->move_intersection(ox,oy,nx,ny);
}

void fl_tile_resize(TILE t, int x, int y, int w, int h) {
    ada_default_resize(static_cast<Fl_Widget*>(t), x, y, w, h);
}

//  Once there are size ranges, move_intersection starts from the sizes
//  init_sizes saved, which a move made without ranges left as they were, so
//  the next move would put the children back (pofltk 24).  Saving the sizes
//  first changes nothing else: with ranges, FLTK saves them after every move.
void fl_tile_size_range(TILE t, int i, int minw, int minh, int maxw, int maxh) {
    Fl_Tile * tile = static_cast<Fl_Tile*>(t);
    tile->init_sizes();
    tile->size_range(i, minw, minh, maxw, maxh);
}

void fl_tile_init_size_range(TILE t, int minw, int minh) {
    Fl_Tile * tile = static_cast<Fl_Tile*>(t);
    tile->init_sizes();
    tile->init_size_range(minw, minh);
}




void fl_tile_draw(TILE n) {
    static_cast<My_Tile*>(n)->Fl_Tile::draw();
}

int fl_tile_handle(TILE n, int e) {
    return static_cast<My_Tile*>(n)->Fl_Tile::handle(e);
}


