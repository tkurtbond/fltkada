

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's Forms classes, which are in a library of their own, fltk_forms,
--  bound by the separate library fltkada_forms (fltkada_forms.gpr):
--  Timers, Frees, Bitmaps, Pixmaps and Texts.  They are children of
--  FLTK.Widgets, not of FLTK, as each widget needs the private part of
--  FLTK.Widgets.  The rest of FLTK's Forms compatibility, its fl_ functions
--  and macros, isn't bound: FLTKAda's own calls do what they do.


package FLTK.Widgets.Forms is

    pragma Linker_Options ("-lfltk_forms");

end FLTK.Widgets.Forms;


