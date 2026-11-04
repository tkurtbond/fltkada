

//  Programmed by T. Kurt Bond and Claude Opus 5.5
//  Released into the public domain
//  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
//  author releases this derived work into the public domain, as FLTKAda is.


#ifndef FL_PDF_FILE_SURFACE_GUARD
#define FL_PDF_FILE_SURFACE_GUARD


typedef void* PDFFILESURFACE;


extern "C" int fl_pdf_file_surface_supported();
extern "C" const char * fl_pdf_file_surface_get_text(int i);
extern "C" int fl_pdf_file_surface_set_text(int i, const char * v);


extern "C" PDFFILESURFACE new_fl_pdf_file_surface();
extern "C" void free_fl_pdf_file_surface(PDFFILESURFACE s);


extern "C" int fl_pdf_file_surface_begin_document(PDFFILESURFACE s, const char * n,
    int f, int l);
extern "C" int fl_pdf_file_surface_begin_job(PDFFILESURFACE s, const char * n);
extern "C" int fl_pdf_file_surface_end_job(PDFFILESURFACE s);
extern "C" const char * fl_pdf_file_surface_message(PDFFILESURFACE s);
extern "C" const char * fl_pdf_file_surface_file_name(PDFFILESURFACE s);


extern "C" int fl_pdf_file_surface_begin_page(PDFFILESURFACE s);
extern "C" int fl_pdf_file_surface_end_page(PDFFILESURFACE s);


extern "C" void fl_pdf_file_surface_margins(PDFFILESURFACE s, int * l, int * t,
    int * r, int * b);
extern "C" int fl_pdf_file_surface_printable_rect(PDFFILESURFACE s, int * w, int * h);
extern "C" void fl_pdf_file_surface_get_origin(PDFFILESURFACE s, int * x, int * y);
extern "C" void fl_pdf_file_surface_set_origin(PDFFILESURFACE s, int x, int y);
extern "C" void fl_pdf_file_surface_rotate(PDFFILESURFACE s, float r);
extern "C" void fl_pdf_file_surface_scale(PDFFILESURFACE s, float x, float y);
extern "C" void fl_pdf_file_surface_translate(PDFFILESURFACE s, int x, int y);
extern "C" void fl_pdf_file_surface_untranslate(PDFFILESURFACE s);


extern "C" void fl_pdf_file_surface_set_current(PDFFILESURFACE s);


#endif


