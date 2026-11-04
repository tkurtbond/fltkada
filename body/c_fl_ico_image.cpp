

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#include <FL/Fl_ICO_Image.H>
#include <FL/Fl_PNG_Image.H>
#include "c_fl_ico_image.h"
#include "c_fl_image_check.h"
#include <cstring>
#include <vector>




//  An ICO image that can take the pixels of a PNG entry, through
//  Fl_Image's protected setters.

namespace {

class My_ICO_Image : public Fl_ICO_Image {
public:
    using Fl_ICO_Image::Fl_ICO_Image;

    void adopt(const Fl_RGB_Image & png) {
        const int dw = png.data_w(), dh = png.data_h(), dd = png.d();
        const int row = dw * dd;
        const int from = png.ld() ? png.ld() : row;
        uchar *copy = new uchar[static_cast<std::size_t>(row) * static_cast<std::size_t>(dh)];
        const uchar *src = reinterpret_cast<const uchar*>(png.data()[0]);
        for (int y = 0; y < dh; y++) {
            std::memcpy(copy + static_cast<std::size_t>(y) * row,
                        src + static_cast<std::size_t>(y) * from, row);
        }
        if (alloc_array) {
            delete[] const_cast<uchar*>(array);
        }
        array = copy;
        alloc_array = 1;
        w(dw);
        h(dh);
        d(dd);
        ld(0);
        data(reinterpret_cast<const char * const *>(&array), 1);
    }
};

//  Image id of the ICO in the n bytes at p, id -1 its largest, as
//  Fl_ICO_Image reads it but for a PNG entry.  Fl_ICO_Image reads that by
//  the name of its file, and calls fopen with none for one in memory
//  (pofltk 82), so it is decoded here, from its offset in the data.  A
//  bitmap entry's header is checked first (pofltk 87).  FLTK copies name,
//  which is only for its messages.
My_ICO_Image * load_ico(const char *name, const unsigned char * p, std::size_t n, int id) {
    My_ICO_Image *dir = new My_ICO_Image(name, -2, p, n);
    if (dir->idcount() <= 0) {
        set_image_fail(dir, Fl_Image::ERR_FORMAT);
        return dir;
    }
    const int k = id == -1 ? ico_largest(*dir) : id;
    if (k < 0 || k >= dir->idcount()) {
        set_image_fail(dir, Fl_Image::ERR_FORMAT);
        return dir;
    }
    const Fl_ICO_Image::IconDirEntry &e = dir->icondirentry()[k];
    const std::size_t at = static_cast<std::size_t>(e.dwImageOffset);
    std::size_t size = static_cast<std::size_t>(e.dwBytesInRes);
    if (e.dwImageOffset <= 0 || at >= n || e.dwBytesInRes <= 0) {
        set_image_fail(dir, Fl_Image::ERR_FORMAT);
        return dir;
    }
    if (n - at >= 8 && std::memcmp(p + at, "\x89PNG\r\n\x1a\n", 8) == 0) {
        if (size > n - at) {
            size = n - at;
        }
        Fl_PNG_Image png(0, p + at, static_cast<int>(size));
        if (png.fail()) {
            set_image_fail(dir, png.fail());
        } else {
            dir->adopt(png);
        }
        return dir;
    }
    if (!ico_dib_ok(p + at, n - at)) {
        set_image_fail(dir, Fl_Image::ERR_FORMAT);
        return dir;
    }
    delete dir;
    return new My_ICO_Image(name, id, p, n);
}

}




//  Flattened C API

//  The file is read whole and loaded from memory, so file and memory act
//  alike.  0 if it doesn't fit in memory.
ICOIMAGE new_fl_ico_image(const char *name, int id) {
    try {
        std::vector<unsigned char> all;
        if (!read_image_file(name, all)) {
            My_ICO_Image *i = new My_ICO_Image(0, -2, 0, 0);
            set_image_fail(i, Fl_Image::ERR_FILE_ACCESS);
            return i;
        }
        return load_ico(name, all.empty() ? 0 : &all[0], all.size(), id);
    } catch (...) {
        return 0;
    }
}

ICOIMAGE new_fl_ico_image2(const unsigned char *data, unsigned long size, int id) {
    try {
        return load_ico(0, data, size, id);
    } catch (...) {
        return 0;
    }
}

void free_fl_ico_image(ICOIMAGE i) {
    delete static_cast<My_ICO_Image*>(i);
}




int fl_ico_image_idcount(ICOIMAGE i) {
    return static_cast<Fl_ICO_Image*>(i)->idcount();
}

//  Entry k's fields, in the order of Fl_ICO_Image::IconDirEntry.
void fl_ico_image_entry(ICOIMAGE i, int k, unsigned int *fields) {
    const Fl_ICO_Image::IconDirEntry &e = static_cast<Fl_ICO_Image*>(i)->icondirentry()[k];
    fields[0] = static_cast<unsigned int>(e.bWidth);
    fields[1] = static_cast<unsigned int>(e.bHeight);
    fields[2] = static_cast<unsigned int>(e.bColorCount);
    fields[3] = static_cast<unsigned int>(e.bReserved);
    fields[4] = static_cast<unsigned int>(e.wPlanes);
    fields[5] = static_cast<unsigned int>(e.wBitCount);
    fields[6] = static_cast<unsigned int>(e.dwBytesInRes);
    fields[7] = static_cast<unsigned int>(e.dwImageOffset);
}


