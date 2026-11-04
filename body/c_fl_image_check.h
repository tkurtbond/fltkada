

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FL_IMAGE_CHECK_GUARD
#define FL_IMAGE_CHECK_GUARD


#include <FL/Fl_Image.H>
#include <cstddef>
#include <vector>


//  Checks that FLTK can read an image's header without writing past what
//  it has (PLAN.md, Phase 5, pofltk 87 and 88).  Each is true when it can,
//  and when the file can't be opened, which FLTK reports itself.

bool bmp_file_ok(const char * name);
bool gif_file_ok(const char * name, bool anim);
bool gif_data_ok(const unsigned char * data, std::size_t n, bool anim);

//  A file of any kind that Fl_Shared_Image reads by its contents: a GIF,
//  read as an animation if Fl_GIF_Image::animate is set, a BMP, an ICO or
//  an XBM.
bool shared_file_ok(const char * name);

//  The XBM in file name, read as pofltk's parse_xbm does (pofltk 81):
//  <name>_width and <name>_height, other #defines allowed, and then every
//  byte of the bits, or it is refused.  Fl_XBM_Image takes any two
//  #defines as the size, leaves bits it can't find unset, and can't say it
//  failed.
enum Xbm_Result { xbm_ok, xbm_unreadable, xbm_refused };
Xbm_Result read_xbm(const char * name, int & w, int & h, std::vector<unsigned char> & bits);

//  Marks an image as failed, with one of Fl_Image's ERR_ codes.
void set_image_fail(Fl_Image * i, int code);

//  Sets an image's size, which Fl_Image keeps protected.
void set_image_size(Fl_Image * i, int w, int h);

//  A PNG, JPEG or SVG read from memory with a name is put in the shared
//  image pool, by an entry that doesn't own it (Fl_PNG_Image.cxx:239-242,
//  Fl_JPEG_Image.cxx:341-344, Fl_SVG_Image.cxx:299-302,
//  Fl_Shared_Image.cxx:133-146), and is left there when the image goes
//  (FLTK-issues.md, F8).  An empty name from Ada is passed on as NULL, so
//  the image isn't put in the pool.
const char * null_if_empty(const char * n);

//  Deletes an image, unless the pool has an entry for it that doesn't own
//  it: that entry is given the image, and the reference its loader made is
//  released, so the image goes with the entry's last reference.
void delete_unless_pooled(Fl_Image * i);


#endif


