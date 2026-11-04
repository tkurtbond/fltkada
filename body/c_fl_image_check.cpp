

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#include <FL/Fl_GIF_Image.H>
#include <FL/Fl_ICO_Image.H>
#include <FL/fl_utf8.h>
#include "c_fl_image_check.h"
#include <FL/Fl_Shared_Image.H>
#include <cstdio>
#include <cstring>
#include <new>
#include <stdint.h>
#include <vector>




//  Reading files

namespace {

enum Read_Result { read_ok, read_none, read_short_of_memory };

//  The first limit bytes of file name, or all of it if limit is 0.
Read_Result read_file(const char * name, std::vector<unsigned char> & into, std::size_t limit) {
    if (name == 0) {
        return read_none;
    }
    FILE *f = fl_fopen(name, "rb");
    if (f == 0) {
        return read_none;
    }
    Read_Result result = read_ok;
    try {
        unsigned char block[4096];
        std::size_t got;
        while ((limit == 0 || into.size() < limit) &&
               (got = std::fread(block, 1, sizeof block, f)) > 0) {
            into.insert(into.end(), block, block + got);
        }
        if (limit != 0 && into.size() > limit) {
            into.resize(limit);
        }
    } catch (...) {
        result = read_short_of_memory;
    }
    std::fclose(f);
    return result;
}

unsigned le16(const unsigned char * p) {
    return p[0] | (p[1] << 8);
}

uint32_t le32(const unsigned char * p) {
    return static_cast<uint32_t>(le16(p)) | (static_cast<uint32_t>(le16(p + 2)) << 16);
}

}




//  BMP and ICO

namespace {

//  Whether Fl_BMP_Image can safely read the BMP information header in the
//  n bytes at p (pofltk 87).  It trusts the count of colors, of a table of
//  256 on the stack (Fl_BMP_Image.cxx:254-264), and the size, whose
//  product it takes as an int.  An ICO's size is in its directory, a byte
//  each way.
bool dib_ok(const unsigned char * p, std::size_t n, bool in_ico) {
    if (n < 12) {
        return false;
    }
    int64_t w, h;
    unsigned depth;
    uint32_t colors = 0;
    if (static_cast<int32_t>(le32(p)) < 40) {
        w = le16(p + 4);
        h = le16(p + 6);
        depth = le16(p + 10);
    } else {
        if (n < 40) {
            return false;
        }
        w = static_cast<int32_t>(le32(p + 4));
        h = static_cast<int32_t>(le32(p + 8));
        if (h < 0) {
            h = -h;
        }
        if (in_ico) {
            w = h = 256;
        }
        depth = le16(p + 14);
        colors = le32(p + 32);
    }
    if (depth != 1 && depth != 4 && depth != 8 && depth != 16 && depth != 24 && depth != 32) {
        return false;
    }
    return colors <= 256 && w > 0 && h > 0 && w * h <= 0x7fffffff / 4;
}

//  A BMP's header follows its 14 byte file header.
bool bmp_data_ok(const unsigned char * p, std::size_t n) {
    return n >= 14 && dib_ok(p + 14, n - 14, false);
}

//  Which of an ICO's entries Fl_ICO_Image shows, the largest; -1 if there
//  is none.  Fl_ICO_Image.cxx:120-140.
int ico_pick(const Fl_ICO_Image & dir) {
    const Fl_ICO_Image::IconDirEntry *e = dir.icondirentry();
    if (e == 0) {
        return -1;
    }
    int picked = -1, largest = 0, bits = 0;
    for (int i = 0; i < dir.idcount(); i++) {
        int res = e[i].bWidth * e[i].bHeight;
        if (res > largest || (res == largest && e[i].wBitCount > bits)) {
            largest = res;
            bits = e[i].wBitCount;
            picked = i;
        }
    }
    return picked;
}

//  An ICO's chosen entry, a PNG or a BMP information header.
bool ico_data_ok(const char * name, const unsigned char * p, std::size_t n) {
    Fl_ICO_Image dir(name, -2, p, n);
    int k = ico_pick(dir);
    if (k < 0) {
        return true;
    }
    std::size_t at = static_cast<std::size_t>(dir.icondirentry()[k].dwImageOffset);
    if (at == 0 || at >= n) {
        return true;
    }
    if (n - at >= 8 && std::memcmp(p + at, "\x89PNG\r\n\x1a\n", 8) == 0) {
        return true;
    }
    return dib_ok(p + at, n - at, true);
}

}




//  GIF

namespace {

//  The bytes of a file or a block, as Fl_Image_Reader gives them.
struct Bytes {
    const unsigned char *p;
    std::size_t n, at;
    bool end() const {
        return at >= n;
    }
    int byte() {
        return at < n ? p[at++] : 0;
    }
    int word() {
        int low = byte();
        return low | (byte() << 8);
    }
    void skip(std::size_t k) {
        at = k < n - at ? at + k : n;
    }
};

//  Whether the LZW codes at r leave Fl_GIF_Image's tables sound, read as
//  lzw_decode reads them.  A code equal to the first free one, with no code
//  before it, makes an entry its own prefix, and lzw_decode then follows it
//  off its stack (pofltk 88).
bool lzw_ok(Bytes & r, int bits) {
    int size = bits + 1;
    const int clear = 1 << bits, eof = clear + 1, first = clear + 2;
    int mask = (1 << size) - 1, free_code = first;
    bool has_old = false;
    int blocklen = r.byte();
    int thisbyte = r.byte();
    blocklen--;
    int frombit = 0;
    while (!r.end()) {
        int code = thisbyte;
        for (int reach = 7; reach <= 15; reach += 8) {
            if (frombit + size <= reach) {
                break;
            }
            if (blocklen <= 0) {
                blocklen = r.byte();
                if (blocklen <= 0) {
                    return true;
                }
            }
            thisbyte = r.byte();
            blocklen--;
            code |= thisbyte << (reach + 1);
        }
        code = (code >> frombit) & mask;
        frombit = (frombit + size) % 8;
        if (code == clear) {
            size = bits + 1;
            mask = (1 << size) - 1;
            free_code = first;
            has_old = false;
            continue;
        }
        if (code == eof) {
            r.skip(static_cast<std::size_t>(blocklen > 0 ? blocklen : 0));
            r.byte();
            return true;
        }
        if (code > free_code) {
            return true;  //  where lzw_decode gives up
        }
        if (code == free_code && !has_old) {
            return false;
        }
        if (has_old) {
            if (free_code < 4096) {
                free_code++;
            }
            if (free_code > mask && size < 12) {
                size++;
                mask = (1 << size) - 1;
            }
        }
        has_old = true;
    }
    return true;
}

}

//  Whether Fl_GIF_Image, or an animation (anim), can safely read the n
//  bytes at p (pofltk 88).  What it reads past the first image matters only
//  to an animation, which reads to the end.
bool gif_data_ok(const unsigned char * data, std::size_t n, bool anim) {
    if (data == 0) {
        return true;
    }
    Bytes r = {data, n, 6};
    const int screen_w = r.word(), screen_h = r.word();
    int flags = r.byte();
    r.skip(2);
    if (flags & 0x80) {
        r.skip(static_cast<std::size_t>(3) * (2 << (flags & 7)));
    }
    if (anim && (screen_w == 0 || screen_h == 0 ||
                 static_cast<int64_t>(screen_w) * screen_h > 0x7fffffff / 4)) {
        return false;
    }
    while (!r.end()) {
        int kind = r.byte();
        if (kind == 0x21) {
            int type = r.byte(), blocklen = r.byte();
            if (type == 0xF9 && blocklen == 4) {
                r.skip(4);
                blocklen = r.byte();
            } else if (type == 0xFF) {
                r.skip(static_cast<std::size_t>(blocklen));
                blocklen = r.byte();
                if (blocklen) {
                    r.skip(static_cast<std::size_t>(blocklen));
                    blocklen = r.byte();
                }
            }
            while (blocklen > 0) {
                r.skip(static_cast<std::size_t>(blocklen));
                blocklen = r.byte();
            }
        } else if (kind == 0x2c) {
            int x = r.word(), y = r.word(), w = r.word(), h = r.word();
            flags = r.byte();
            if (flags & 0x80) {
                r.skip(static_cast<std::size_t>(3) * (2 << (flags & 7)));
            }
            int bits = r.byte();
            if (r.end()) {
                return true;
            }
            //  FLTK's warning says it goes on, with tables too small for the codes.
            if (w == 0 || h == 0 || bits > 8 || static_cast<int64_t>(w) * h > 0x7fffffff) {
                return false;
            }
            if (anim && (x + w > screen_w || y + h > screen_h)) {
                return false;
            }
            if (!lzw_ok(r, bits)) {
                return false;
            }
            if (!anim) {
                return true;
            }
        } else {
            return true;  //  the end of the image, or where FLTK stops
        }
    }
    return true;
}




//  Files

bool ico_dib_ok(const unsigned char * p, std::size_t n) {
    return dib_ok(p, n, true);
}

int ico_largest(const Fl_ICO_Image & dir) {
    return ico_pick(dir);
}

bool read_image_file(const char * name, std::vector<unsigned char> & into) {
    Read_Result got = read_file(name, into, 0);
    if (got == read_short_of_memory) {
        throw std::bad_alloc();
    }
    return got == read_ok;
}

bool bmp_file_ok(const char * name) {
    std::vector<unsigned char> head;
    Read_Result got = read_file(name, head, 64);
    return got == read_none ||
        (got == read_ok && bmp_data_ok(head.empty() ? 0 : &head[0], head.size()));
}

bool gif_file_ok(const char * name, bool anim) {
    std::vector<unsigned char> all;
    Read_Result got = read_file(name, all, 0);
    return got == read_none ||
        (got == read_ok && gif_data_ok(all.empty() ? 0 : &all[0], all.size(), anim));
}

//  XBM

namespace {

const std::size_t xbm_max_side = 1 << 20;  //  past which a number is wrong

bool xbm_space(unsigned char c) {
    return c == ' ' || c == '\t' || c == '\r' || c == '\n';
}

//  The number at p[i], of the n bytes at p, into v: decimal, or
//  hexadecimal after 0x.  False if there is none, or it is over max.
bool xbm_number(const unsigned char * p, std::size_t n, std::size_t & i,
        std::size_t max, std::size_t & v) {
    std::size_t k = i, base = 10;
    if (k + 1 < n && p[k] == '0' && (p[k + 1] == 'x' || p[k + 1] == 'X')) {
        k += 2;
        base = 16;
    }
    std::size_t start = k, r = 0;
    for (; k < n; k++) {
        std::size_t d =
            p[k] >= '0' && p[k] <= '9' ? p[k] - '0' :
            p[k] >= 'a' && p[k] <= 'f' ? p[k] - 'a' + 10 :
            p[k] >= 'A' && p[k] <= 'F' ? p[k] - 'A' + 10 : 16;
        if (d >= base) {
            break;
        }
        r = r * base + d;
        if (r > max) {
            return false;
        }
    }
    if (k == start) {
        return false;
    }
    i = k;
    v = r;
    return true;
}

bool parse_xbm(const unsigned char * p, std::size_t n, int & w_out, int & h_out,
        std::vector<unsigned char> & bits) {
    std::size_t i = 0, w = 0, h = 0;
    for (;;) {
        while (i < n && xbm_space(p[i])) i++;
        if (n - i < 7 || std::memcmp(p + i, "#define", 7) != 0) {
            break;
        }
        i += 7;
        while (i < n && xbm_space(p[i])) i++;
        std::size_t name = i;
        while (i < n && !xbm_space(p[i])) i++;
        std::size_t len = i - name, v;
        while (i < n && xbm_space(p[i])) i++;
        if (!xbm_number(p, n, i, xbm_max_side, v)) {
            return false;
        }
        if (len >= 5 && std::memcmp(p + name + len - 5, "width", 5) == 0) {
            w = v;
        }
        if (len >= 6 && std::memcmp(p + name + len - 6, "height", 6) == 0) {
            h = v;
        }
    }
    if (w == 0 || h == 0 || n - i < 6 || std::memcmp(p + i, "static", 6) != 0) {
        return false;
    }
    std::size_t open = i;
    while (open < n && p[open] != '{' && p[open] != ';') open++;
    if (open >= n || p[open] != '{') {
        return false;
    }
    //  X10's form holds shorts.
    std::size_t k = i;
    while (k + 4 <= open && std::memcmp(p + k, "char", 4) != 0) k++;
    if (k + 4 > open) {
        return false;
    }
    i = open + 1;
    const unsigned long long need = static_cast<unsigned long long>((w + 7) / 8) * h;
    //  Each byte is two characters at the least.
    if (need * 2 > n || need > 0x7fffffff) {
        return false;
    }
    bits.assign(static_cast<std::size_t>(need), 0);
    for (std::size_t b = 0; b < bits.size(); b++) {
        std::size_t v;
        while (i < n && xbm_space(p[i])) i++;
        if (!xbm_number(p, n, i, 255, v)) {
            return false;
        }
        bits[b] = static_cast<unsigned char>(v);
        while (i < n && xbm_space(p[i])) i++;
        if (i < n && p[i] == ',') {
            i++;
        } else if (b + 1 < bits.size()) {
            return false;
        }
        while (i < n && xbm_space(p[i])) i++;
    }
    if (i >= n || p[i] != '}') {
        return false;
    }
    w_out = static_cast<int>(w);
    h_out = static_cast<int>(h);
    return true;
}

}

Xbm_Result read_xbm(const char * name, int & w, int & h, std::vector<unsigned char> & bits) {
    std::vector<unsigned char> all;
    Read_Result got = read_file(name, all, 0);
    if (got == read_none) {
        return xbm_unreadable;
    }
    if (got != read_ok || all.empty()) {
        return xbm_refused;
    }
    return parse_xbm(&all[0], all.size(), w, h, bits) ? xbm_ok : xbm_refused;
}




//  As fl_check_images tells them apart, fl_images_core.cxx:88-102, after
//  Fl_Shared_Image::reload takes an XBM, Fl_Shared_Image.cxx:297.
bool shared_file_ok(const char * name) {
    std::vector<unsigned char> all;
    Read_Result got = read_file(name, all, 0);
    if (got != read_ok) {
        return got == read_none;
    }
    const std::size_t n = all.size();
    if (n >= 7 && std::memcmp(&all[0], "#define", 7) == 0) {
        int w, h;
        std::vector<unsigned char> bits;
        return parse_xbm(&all[0], n, w, h, bits);
    }
    if (n < 6) {
        return true;
    }
    const unsigned char *p = &all[0];
    if (std::memcmp(p, "GIF87a", 6) == 0 || std::memcmp(p, "GIF89a", 6) == 0) {
        return gif_data_ok(p, n, Fl_GIF_Image::animate);
    }
    if (std::memcmp(p, "BM", 2) == 0) {
        return bmp_data_ok(p, n);
    }
    if (std::memcmp(p, "\0\0\1\0", 4) == 0 && p[5] == 0) {
        return ico_data_ok(name, p, n);
    }
    return true;
}




//  Failing

namespace {

//  Fl_Image::ld, w and h are protected; a pointer to one, taken through a
//  class derived from Fl_Image, reaches it.
struct Fail_Setter : public Fl_Image {
    static void set(Fl_Image * i, int code) {
        void (Fl_Image::*setter)(int) = &Fail_Setter::ld;
        (i->*setter)(code);
    }
    static void size(Fl_Image * i, int w, int h) {
        void (Fl_Image::*set_w)(int) = &Fail_Setter::w;
        void (Fl_Image::*set_h)(int) = &Fail_Setter::h;
        (i->*set_w)(w);
        (i->*set_h)(h);
    }
};

}

void set_image_fail(Fl_Image * i, int code) {
    Fail_Setter::set(i, code);
}

void set_image_size(Fl_Image * i, int w, int h) {
    Fail_Setter::size(i, w, h);
}




//  Pool

const char * null_if_empty(const char * n) {
    return (n == 0 || *n == '\0') ? 0 : n;
}

namespace {

//  Fl_Shared_Image::alloc_image_ is protected, as above.
struct Pool_Setter : public Fl_Shared_Image {
    static bool give(Fl_Image * img) {
        int Fl_Shared_Image::*owns = &Pool_Setter::alloc_image_;
        Fl_Shared_Image **all = Fl_Shared_Image::images();
        const int n = Fl_Shared_Image::num_images();
        for (int k = 0; k < n; k++) {
            Fl_Shared_Image *s = all[k];
            if (s->image() == img && !(s->*owns)) {
                s->*owns = 1;
                s->release();
                return true;
            }
        }
        return false;
    }
};

}

void delete_unless_pooled(Fl_Image * i) {
    if (!Pool_Setter::give(i)) {
        delete i;
    }
}


