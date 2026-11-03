

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  For control_string_leak: a unit named like FLTKAda's own, so that
--  vg-check.sh takes its frames for FLTKAda's.


package FLTK.Control_Strings is


    --  Makes a C copy of Text with New_String and drops it.
    procedure Leak
           (Text : in String)
    with No_Inline;


end FLTK.Control_Strings;


