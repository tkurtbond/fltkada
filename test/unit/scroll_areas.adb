

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


package body Scroll_Areas is


    procedure Draw
           (X, Y, W, H : in Integer) is
    begin
        Calls := Calls + 1;
        Last := (X, Y, W, H);
    end Draw;


end Scroll_Areas;


