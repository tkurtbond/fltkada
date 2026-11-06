

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    FLTK.Draw;


package body Scroll_Areas is


    procedure Draw
           (X, Y, W, H : in Integer) is
    begin
        Calls := Calls + 1;
        Last := (X, Y, W, H);
        if Fill then
            FLTK.Draw.Set_Color (Hue);
            FLTK.Draw.Rect_Fill (X, Y, W, H);
        end if;
    end Draw;


end Scroll_Areas;


