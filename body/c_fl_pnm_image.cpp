

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <FL/Fl_PNM_Image.H>
#include <FL/fl_utf8.h>
#include <cctype>
#include <cstdio>
#include <cstdlib>
#include "c_fl_pnm_image.h"




//  The maxval of the binary PNM (P5, P6) named filename, found as
//  Fl_PNM_Image's constructor finds it (Fl_PNM_Image.cxx:85-125): the
//  format is the number after the first character, and the width, height
//  and maxval are the first nonzero numbers after it, past '#' lines.
//  0 for another format, or a header it can't read.
static int binary_pnm_maxval(const char * filename) {
    FILE * fp = fl_fopen(filename, "rb");
    if (fp == 0) {
        return 0;
    }
    char line[1024];
    char * lineptr = fgets(line, sizeof(line), fp);
    int maxval = 0;
    if (lineptr != 0) {
        lineptr++;
        int format = atoi(lineptr);
        while (isdigit(static_cast<unsigned char>(*lineptr))) {
            lineptr++;
        }
        if (format == 5 || format == 6) {
            for (int field = 0; field < 3 && lineptr != 0; field++) {
                maxval = 0;
                while (lineptr != 0 && maxval == 0) {
                    if (*lineptr == '\0' || *lineptr == '#') {
                        lineptr = fgets(line, sizeof(line), fp);
                    } else if (isdigit(static_cast<unsigned char>(*lineptr))) {
                        maxval = static_cast<int>(strtol(lineptr, &lineptr, 10));
                    } else {
                        lineptr++;
                    }
                }
            }
        }
    }
    fclose(fp);
    return maxval;
}

//  Fl_PNM_Image reads the samples of a binary PNM whose maxval is under 256
//  as they are, with fread (Fl_PNM_Image.cxx:178-187), where it scales the
//  text forms by 255 * val / maxval (pofltk 45).  This scales them after,
//  clamping a sample over the maxval to 255.  Fl_PNM_Image's rows are
//  w * d bytes, with no ld.
void pnm_scale_samples(Fl_RGB_Image * img, const char * filename) {
    if (img->fail() || img->array == 0) {
        return;
    }
    int maxval = binary_pnm_maxval(filename);
    if (maxval <= 0 || maxval >= 255) {
        return;
    }
    uchar * a = const_cast<uchar*>(img->array);
    size_t n = static_cast<size_t>(img->data_w()) * img->data_h() * img->d();
    for (size_t i = 0; i < n; i++) {
        int v = a[i] * 255 / maxval;
        a[i] = static_cast<uchar>(v > 255 ? 255 : v);
    }
    img->uncache();
}




PNMIMAGE new_fl_pnm_image(const char * f) {
    try {
        Fl_PNM_Image *p = new Fl_PNM_Image(f);
        pnm_scale_samples(p, f);
        return p;
    } catch (...) {
        return 0;
    }
}

void free_fl_pnm_image(PNMIMAGE p) {
    delete static_cast<Fl_PNM_Image*>(p);
}


