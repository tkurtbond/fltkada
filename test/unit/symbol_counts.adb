

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


package body Symbol_Counts is


    procedure Draw
           (Hue : in FLTK.Color)
    is
        pragma Unreferenced (Hue);
    begin
        Draws := Draws + 1;
    end Draw;


end Symbol_Counts;

