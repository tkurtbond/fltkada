

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  A symbol drawing procedure that counts its calls, for test_kept_strings.
--  FLTK calls it as a C function, so it is at library level, with no static
--  link.


with

    FLTK;


package Symbol_Counts is


    Draws : Natural := 0;

    procedure Draw
           (Hue : in FLTK.Color);
    pragma Convention (C, Draw);


end Symbol_Counts;

