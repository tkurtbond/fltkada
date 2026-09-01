

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_Device.H>
#include <FL/Fl_Graphics_Driver.H>
#include <FL/Fl_Image.H>
#include "c_fl_graphics_driver.h"




//  Non-friend protected access

class Friend_Image : Fl_Image {
public:
    using Fl_Image::draw_scaled;
};




unsigned int fl_graphics_driver_color(GRAPHICSDRIVER g) {
    return static_cast<Fl_Graphics_Driver*>(g)->color();
}




int fl_graphics_driver_descent(GRAPHICSDRIVER g) {
    //  virtual so disable dispatch
    return static_cast<Fl_Graphics_Driver*>(g)->Fl_Graphics_Driver::descent();
}

int fl_graphics_driver_height(GRAPHICSDRIVER g) {
    //  virtual so disable dispatch
    return static_cast<Fl_Graphics_Driver*>(g)->Fl_Graphics_Driver::height();
}

double fl_graphics_driver_width(GRAPHICSDRIVER g, unsigned int c) {
    //  virtual so disable dispatch
    return static_cast<Fl_Graphics_Driver*>(g)->Fl_Graphics_Driver::width(c);
}

double fl_graphics_driver_width2(GRAPHICSDRIVER g, const char * s, int l) {
    //  virtual so disable dispatch
    return static_cast<Fl_Graphics_Driver*>(g)->Fl_Graphics_Driver::width(s,l);
}

int fl_graphics_driver_get_font(GRAPHICSDRIVER g) {
    return static_cast<Fl_Graphics_Driver*>(g)->font();
}

int fl_graphics_driver_size(GRAPHICSDRIVER g) {
    return static_cast<Fl_Graphics_Driver*>(g)->size();
}

void fl_graphics_driver_set_font(GRAPHICSDRIVER g, int f, int s) {
    //  virtual so disable dispatch
    static_cast<Fl_Graphics_Driver*>(g)->Fl_Graphics_Driver::font(f,s);
}




void fl_graphics_driver_draw_scaled(GRAPHICSDRIVER g, void * i, int x, int y, int w, int h) {
    //  Since FLTK 1.4.0, image scaling has moved from Fl_Graphics_Driver to
    //  Fl_Image itself, drawing through whichever driver is currently current.
    (void)g;
    (static_cast<Fl_Image*>(i)->*(&Friend_Image::draw_scaled))(x,y,w,h);
}


