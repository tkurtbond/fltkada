

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_XBM_Image.H>
#include "c_fl_xbm_image.h"
#include "c_fl_image_check.h"
#include <cstring>




//  The shim reads the file itself (pofltk 81), and gives FLTK the bits.
//  Fl_XBM_Image of "" opens nothing and is empty (Fl_XBM_Image.cxx:45);
//  its data () points at array, which Fl_Bitmap's constructor set
//  (Fl_Bitmap.H:49), and the array is FLTK's to delete, which
//  Fl_XBM_Image leaves it not (alloc_array 0, Fl_XBM_Image.cxx:76-77).
XBMIMAGE new_fl_xbm_image(const char * f) {
    try {
        int w = 0, h = 0;
        std::vector<unsigned char> bits;
        Xbm_Result got = read_xbm(f, w, h, bits);
        uchar *array = 0;
        if (got == xbm_ok) {
            array = new uchar[bits.size()];
            std::memcpy(array, &bits[0], bits.size());
        }
        Fl_XBM_Image *b = new (std::nothrow) Fl_XBM_Image("");
        if (b == 0) {
            delete[] array;
            return 0;
        }
        if (got == xbm_ok) {
            b->array = array;
            b->alloc_array = 1;
            set_image_size(b, w, h);
        } else {
            set_image_fail(b, got == xbm_unreadable ? Fl_Image::ERR_FILE_ACCESS : Fl_Image::ERR_FORMAT);
        }
        return b;
    } catch (...) {
        return 0;
    }
}

void free_fl_xbm_image(XBMIMAGE b) {
    delete static_cast<Fl_XBM_Image*>(b);
}


