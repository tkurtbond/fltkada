

//  Programmed by Jedidiah Barber
//  Released into the public domain


#include <cerrno>
#include <cstdio>
#include <cstring>
#include <new>
#include <FL/Fl_Text_Buffer.H>
#include <FL/fl_utf8.h>
#include "c_fl_text_buffer.h"




class My_Text_Buffer : public Fl_Text_Buffer {
public:
    using Fl_Text_Buffer::Fl_Text_Buffer;
    int reference_count = 0;
};




//  FLTK's own transcoding warning, which is static in Fl_Text_Buffer.cxx,
//  kept from the first buffer made so it can be put back.

static void (*default_transcoding_warning)(Fl_Text_Buffer*) = 0;

TEXTBUFFER new_fl_text_buffer(int rs, int pgs) {
    My_Text_Buffer *tb = new My_Text_Buffer(rs, pgs);
    if (default_transcoding_warning == 0) {
        default_transcoding_warning = tb->transcoding_warning_action;
    }
    return tb;
}

void upref_fl_text_buffer(TEXTBUFFER tb) {
    static_cast<My_Text_Buffer*>(tb)->reference_count += 1;
}

void free_fl_text_buffer(TEXTBUFFER tb) {
    if (static_cast<My_Text_Buffer*>(tb)->reference_count <= 0) {
        delete static_cast<My_Text_Buffer*>(tb);
    } else {
        static_cast<My_Text_Buffer*>(tb)->reference_count -= 1;
    }
}




void fl_text_buffer_add_modify_callback(TEXTBUFFER tb, void * cb, void * ud) {
    static_cast<Fl_Text_Buffer*>(tb)->add_modify_callback
        (reinterpret_cast<Fl_Text_Modify_Cb>(cb), ud);
}

void fl_text_buffer_add_predelete_callback(TEXTBUFFER tb, void * cb, void * ud) {
    static_cast<Fl_Text_Buffer*>(tb)->add_predelete_callback
        (reinterpret_cast<Fl_Text_Predelete_Cb>(cb), ud);
}

void fl_text_buffer_remove_modify_callback(TEXTBUFFER tb, void * cb, void * ud) {
    static_cast<Fl_Text_Buffer*>(tb)->remove_modify_callback
        (reinterpret_cast<Fl_Text_Modify_Cb>(cb), ud);
}

void fl_text_buffer_remove_predelete_callback(TEXTBUFFER tb, void * cb, void * ud) {
    static_cast<Fl_Text_Buffer*>(tb)->remove_predelete_callback
        (reinterpret_cast<Fl_Text_Predelete_Cb>(cb), ud);
}

void fl_text_buffer_call_modify_callbacks(TEXTBUFFER tb) {
    static_cast<Fl_Text_Buffer*>(tb)->call_modify_callbacks();
}

void fl_text_buffer_call_predelete_callbacks(TEXTBUFFER tb) {
    static_cast<Fl_Text_Buffer*>(tb)->call_predelete_callbacks();
}




//  These return errno, or 0, where FLTK returns 1 for a file it couldn't
//  open and 2 for one it couldn't read or write (Fl_Text_Buffer.cxx:
//  2005-2064), so that the Ada side can say why.

static int file_error() {
    return errno != 0 ? errno : EIO;
}

//  FLTK's insertfile loses the end of a file whose last bytes begin a
//  UTF-8 sequence longer than what is left, such as a Latin-1 file
//  ending in an accented letter: utf8_input_filter stops there and
//  insertfile takes its 0 for the end (Fl_Text_Buffer.cxx:1971-1977,
//  2020-2032; FLTK-issues.md F26).  This is its loop, except that at the
//  end of the file the rest is decoded, each bad byte as CP1252, as
//  fl_utf8decode decodes it.

int fl_text_buffer_insertfile(TEXTBUFFER tb, char * n, int p, int b) {
    Fl_Text_Buffer *buffer = static_cast<Fl_Text_Buffer*>(tb);
    if (b < 1) {
        return EINVAL;
    }
    errno = 0;
    FILE *fp = fl_fopen(n, "r");
    if (fp == 0) {
        return file_error();
    }
    //  Each byte in becomes at most 3 out (fl_utf8encode of a CP1252 byte).
    char *in = new (std::nothrow) char[b + 4];
    char *out = new (std::nothrow) char[3 * (b + 4) + 1];
    if (in == 0 || out == 0) {
        delete[] in;
        delete[] out;
        fclose(fp);
        return ENOMEM;
    }
    buffer->input_file_was_transcoded = 0;
    int kept = 0;
    while (true) {
        int r = static_cast<int>(fread(in + kept, 1, b, fp));
        bool ended = r < b;
        char *at = in, *end = in + kept + r;
        char *q = out;
        while (at < end) {
            int l = fl_utf8len1(*at);
            if (at + l > end) {
                if (!ended) {
                    break;
                }
                l = static_cast<int>(end - at);
            }
            while (l > 0) {
                int lp;
                char multibyte[5];
                unsigned u = fl_utf8decode(at, at + l, &lp);
                int lq = fl_utf8encode(u, multibyte);
                if (lp != l || lq != l) {
                    buffer->input_file_was_transcoded = 1;
                }
                memcpy(q, multibyte, lq);
                q += lq;
                at += lp;
                l -= lp;
            }
        }
        kept = static_cast<int>(end - at);
        memmove(in, at, kept);
        if (q > out) {
            int made = static_cast<int>(q - out);
            buffer->insert(p, out, made);
            p += made;
        }
        if (ended) {
            break;
        }
    }
    int e = ferror(fp) ? file_error() : 0;
    fclose(fp);
    delete[] in;
    delete[] out;
    if (e == 0 && buffer->input_file_was_transcoded && buffer->transcoding_warning_action) {
        buffer->transcoding_warning_action(buffer);
    }
    return e;
}

int fl_text_buffer_appendfile(TEXTBUFFER tb, char * n, int b) {
    return fl_text_buffer_insertfile(tb, n, static_cast<Fl_Text_Buffer*>(tb)->length(), b);
}

int fl_text_buffer_loadfile(TEXTBUFFER tb, char * n, int b) {
    Fl_Text_Buffer *buffer = static_cast<Fl_Text_Buffer*>(tb);
    buffer->select(0, buffer->length());
    buffer->remove_selection();
    return fl_text_buffer_appendfile(tb, n, b);
}

int fl_text_buffer_outputfile(TEXTBUFFER tb, char * n, int f, int t, int b) {
    if (b < 1) {
        return EINVAL;
    }
    errno = 0;
    return static_cast<Fl_Text_Buffer*>(tb)->outputfile(n,f,t,b) == 0 ? 0 : file_error();
}

int fl_text_buffer_savefile(TEXTBUFFER tb, char * n, int b) {
    return fl_text_buffer_outputfile(tb, n, 0, static_cast<Fl_Text_Buffer*>(tb)->length(), b);
}

int fl_text_buffer_was_transcoded(TEXTBUFFER tb) {
    return static_cast<Fl_Text_Buffer*>(tb)->input_file_was_transcoded;
}

int fl_text_buffer_get_transcoding_warning(TEXTBUFFER tb) {
    return static_cast<Fl_Text_Buffer*>(tb)->transcoding_warning_action != 0;
}

void fl_text_buffer_set_transcoding_warning(TEXTBUFFER tb, int on) {
    static_cast<Fl_Text_Buffer*>(tb)->transcoding_warning_action =
        on ? default_transcoding_warning : 0;
}

const char * fl_text_buffer_file_encoding_warning_message() {
    return Fl_Text_Buffer::file_encoding_warning_message;
}




void fl_text_buffer_insert(TEXTBUFFER tb, int p, const char * item) {
    static_cast<Fl_Text_Buffer*>(tb)->insert(p, item);
}

void fl_text_buffer_append(TEXTBUFFER tb, const char * item) {
    static_cast<Fl_Text_Buffer*>(tb)->append(item);
}

void fl_text_buffer_replace(TEXTBUFFER tb, int s, int f, const char * text) {
    static_cast<Fl_Text_Buffer*>(tb)->replace(s, f, text);
}

void fl_text_buffer_remove(TEXTBUFFER tb, int s, int f) {
    static_cast<Fl_Text_Buffer*>(tb)->remove(s, f);
}

char * fl_text_buffer_get_text(TEXTBUFFER tb) {
    return static_cast<Fl_Text_Buffer*>(tb)->text();
}

void fl_text_buffer_set_text(TEXTBUFFER tb, char * t) {
    static_cast<Fl_Text_Buffer*>(tb)->text(t);
}

char fl_text_buffer_byte_at(TEXTBUFFER tb, int p) {
    return static_cast<Fl_Text_Buffer*>(tb)->byte_at(p);
}

unsigned int fl_text_buffer_char_at(TEXTBUFFER tb, int p) {
    return static_cast<Fl_Text_Buffer*>(tb)->char_at(p);
}

char * fl_text_buffer_text_range(TEXTBUFFER tb, int s, int f) {
    return static_cast<Fl_Text_Buffer*>(tb)->text_range(s, f);
}

int fl_text_buffer_next_char(TEXTBUFFER tb, int p) {
    return static_cast<Fl_Text_Buffer*>(tb)->next_char(p);
}

//  prev_char_clipped, which is 0 at 0 where prev_char is -1, from no
//  further than length(): past it, FLTK gives back the place it's given
//  (FLTK-issues.md F6).

int fl_text_buffer_prev_char(TEXTBUFFER tb, int p) {
    Fl_Text_Buffer *buffer = static_cast<Fl_Text_Buffer*>(tb);
    if (p > buffer->length()) {
        p = buffer->length();
    }
    return buffer->prev_char_clipped(p);
}




int fl_text_buffer_count_displayed_characters(TEXTBUFFER tb, int s, int f) {
    return static_cast<Fl_Text_Buffer*>(tb)->count_displayed_characters(s,f);
}

int fl_text_buffer_count_lines(TEXTBUFFER tb, int s, int f) {
    return static_cast<Fl_Text_Buffer*>(tb)->count_lines(s,f);
}

int fl_text_buffer_estimate_lines(TEXTBUFFER tb, int s, int f, int l) {
    return static_cast<Fl_Text_Buffer*>(tb)->estimate_lines(s,f,l);
}

int fl_text_buffer_length(TEXTBUFFER tb) {
    return static_cast<Fl_Text_Buffer*>(tb)->length();
}

int fl_text_buffer_get_tab_distance(TEXTBUFFER tb) {
    return static_cast<Fl_Text_Buffer*>(tb)->tab_distance();
}

void fl_text_buffer_set_tab_distance(TEXTBUFFER tb, int t) {
    static_cast<Fl_Text_Buffer*>(tb)->tab_distance(t);
}




int fl_text_buffer_selection_position(TEXTBUFFER tb, int * s, int * e) {
    return static_cast<Fl_Text_Buffer*>(tb)->selection_position(s, e);
}

int fl_text_buffer_secondary_selection_position(TEXTBUFFER tb, int * s, int * e) {
    return static_cast<Fl_Text_Buffer*>(tb)->secondary_selection_position(s,e);
}

void fl_text_buffer_select(TEXTBUFFER tb, int s, int e) {
    static_cast<Fl_Text_Buffer*>(tb)->select(s, e);
}

void fl_text_buffer_secondary_select(TEXTBUFFER tb, int s, int e) {
    static_cast<Fl_Text_Buffer*>(tb)->secondary_select(s,e);
}

int fl_text_buffer_selected(TEXTBUFFER tb) {
    return static_cast<Fl_Text_Buffer*>(tb)->selected();
}

int fl_text_buffer_secondary_selected(TEXTBUFFER tb) {
    return static_cast<Fl_Text_Buffer*>(tb)->secondary_selected();
}

char * fl_text_buffer_selection_text(TEXTBUFFER tb) {
    return static_cast<Fl_Text_Buffer*>(tb)->selection_text();
}

char * fl_text_buffer_secondary_selection_text(TEXTBUFFER tb) {
    return static_cast<Fl_Text_Buffer*>(tb)->secondary_selection_text();
}

void fl_text_buffer_replace_selection(TEXTBUFFER tb, char * t) {
    static_cast<Fl_Text_Buffer*>(tb)->replace_selection(t);
}

void fl_text_buffer_replace_secondary_selection(TEXTBUFFER tb, char * t) {
    static_cast<Fl_Text_Buffer*>(tb)->replace_secondary_selection(t);
}

void fl_text_buffer_remove_selection(TEXTBUFFER tb) {
    static_cast<Fl_Text_Buffer*>(tb)->remove_selection();
}

void fl_text_buffer_remove_secondary_selection(TEXTBUFFER tb) {
    static_cast<Fl_Text_Buffer*>(tb)->remove_secondary_selection();
}

void fl_text_buffer_unselect(TEXTBUFFER tb) {
    static_cast<Fl_Text_Buffer*>(tb)->unselect();
}

void fl_text_buffer_secondary_unselect(TEXTBUFFER tb) {
    static_cast<Fl_Text_Buffer*>(tb)->secondary_unselect();
}




void fl_text_buffer_highlight(TEXTBUFFER tb, int f, int t) {
    static_cast<Fl_Text_Buffer*>(tb)->highlight(f,t);
}

char * fl_text_buffer_highlight_text(TEXTBUFFER tb) {
    return static_cast<Fl_Text_Buffer*>(tb)->highlight_text();
}

void fl_text_buffer_unhighlight(TEXTBUFFER tb) {
    static_cast<Fl_Text_Buffer*>(tb)->unhighlight();
}

int fl_text_buffer_highlight_position(TEXTBUFFER tb, int * s, int * e) {
    return static_cast<Fl_Text_Buffer*>(tb)->highlight_position(s, e);
}

int fl_text_buffer_highlighted(TEXTBUFFER tb) {
    return static_cast<Fl_Text_Buffer*>(tb)->highlight();
}




int fl_text_buffer_findchar_forward(TEXTBUFFER tb, int start, unsigned int item, int * found) {
    return static_cast<Fl_Text_Buffer*>(tb)->findchar_forward(start, item, found);
}

int fl_text_buffer_findchar_backward(TEXTBUFFER tb, int start, unsigned int item, int * found) {
    return static_cast<Fl_Text_Buffer*>(tb)->findchar_backward(start, item, found);
}

//  With matchCase set, FLTK's search_forward and search_backward compare
//  the needle with memcmp(sp, address(bp), l), and never check bp against
//  length() (Fl_Text_Buffer.cxx:1312, 1364), so they read past the text
//  (pofltk 36).  That search is done here instead, a byte at a time with
//  byte_at.  A string of whole UTF-8 characters can only match at the start
//  of a character, so this finds what FLTK's would.  Without matchCase FLTK
//  reads through char_at, which checks.  Forward from length() FLTK finds
//  nothing, not even an empty string, and so does this.

static int search_exact(const Fl_Text_Buffer * tb, int start, const char * item, int * found,
                        bool backward) {
    int n = static_cast<int>(std::strlen(item));
    int last = tb->length() - n;
    int p = start;
    if (backward) {
        if (p > last) { p = last; }
    } else if (p >= tb->length()) {
        return 0;
    }
    for (; p >= 0 && p <= last; p += backward ? -1 : 1) {
        int i = 0;
        while (i < n && tb->byte_at(p + i) == item[i]) { ++i; }
        if (i == n) {
            *found = p;
            return 1;
        }
    }
    return 0;
}

int fl_text_buffer_search_forward(TEXTBUFFER tb, int start, const char * item, int * found, int mcase) {
    Fl_Text_Buffer *buffer = static_cast<Fl_Text_Buffer*>(tb);
    if (mcase) {
        return search_exact(buffer, start, item, found, false);
    }
    return buffer->search_forward(start, item, found, 0);
}

//  From past length(), prev_char returns the position it is given
//  (Fl_Text_Buffer.cxx:2072-2091), so FLTK's search_backward never ends
//  there (FLTK-issues.md F6).  The start is clamped to length() first.

int fl_text_buffer_search_backward(TEXTBUFFER tb, int start, const char * item, int * found, int mcase) {
    Fl_Text_Buffer *buffer = static_cast<Fl_Text_Buffer*>(tb);
    if (mcase) {
        return search_exact(buffer, start, item, found, true);
    }
    if (start > buffer->length()) {
        start = buffer->length();
    }
    return buffer->search_backward(start, item, found, 0);
}




int fl_text_buffer_is_word_separator(TEXTBUFFER tb, int p) {
    return static_cast<Fl_Text_Buffer*>(tb)->is_word_separator(p);
}

int fl_text_buffer_word_start(TEXTBUFFER tb, int p) {
    return static_cast<Fl_Text_Buffer*>(tb)->word_start(p);
}

int fl_text_buffer_word_end(TEXTBUFFER tb, int p) {
    return static_cast<Fl_Text_Buffer*>(tb)->word_end(p);
}

int fl_text_buffer_line_start(TEXTBUFFER tb, int p) {
    return static_cast<Fl_Text_Buffer*>(tb)->line_start(p);
}

int fl_text_buffer_line_end(TEXTBUFFER tb, int p) {
    return static_cast<Fl_Text_Buffer*>(tb)->line_end(p);
}

char * fl_text_buffer_line_text(TEXTBUFFER tb, int p) {
    return static_cast<Fl_Text_Buffer*>(tb)->line_text(p);
}

int fl_text_buffer_skip_lines(TEXTBUFFER tb, int s, int l) {
    return static_cast<Fl_Text_Buffer*>(tb)->skip_lines(s, l);
}

int fl_text_buffer_rewind_lines(TEXTBUFFER tb, int s, int l) {
    return static_cast<Fl_Text_Buffer*>(tb)->rewind_lines(s, l);
}

int fl_text_buffer_skip_displayed_characters(TEXTBUFFER tb, int s, int n) {
    return static_cast<Fl_Text_Buffer*>(tb)->skip_displayed_characters(s,n);
}




void fl_text_buffer_canundo(TEXTBUFFER tb, char f) {
    return static_cast<Fl_Text_Buffer*>(tb)->canUndo(f);
}

//  FLTK sets the cursor position only when there was something to undo
//  (Fl_Text_Buffer.cxx:563-606).
int fl_text_buffer_undo(TEXTBUFFER tb, int &cp) {
    cp = 0;
    return static_cast<Fl_Text_Buffer*>(tb)->undo(&cp);
}

int fl_text_buffer_redo(TEXTBUFFER tb, int &cp) {
    cp = 0;
    return static_cast<Fl_Text_Buffer*>(tb)->redo(&cp);
}

int fl_text_buffer_can_undo(TEXTBUFFER tb) {
    return static_cast<Fl_Text_Buffer*>(tb)->can_undo();
}

int fl_text_buffer_can_redo(TEXTBUFFER tb) {
    return static_cast<Fl_Text_Buffer*>(tb)->can_redo();
}

void fl_text_buffer_copy(TEXTBUFFER tb, TEXTBUFFER tb2, int s, int f, int i) {
    static_cast<Fl_Text_Buffer*>(tb)->copy(static_cast<Fl_Text_Buffer*>(tb2),s,f,i);
}

int fl_text_buffer_utf8_align(TEXTBUFFER tb, int p) {
    return static_cast<Fl_Text_Buffer*>(tb)->utf8_align(p);
}


