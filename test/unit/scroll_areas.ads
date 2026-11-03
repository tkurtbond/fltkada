

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  An area drawing procedure for FLTK.Draw.Scroll that records its calls,
--  for test_wrong_state.  The binding calls it through its address, so it
--  is at library level, with no static link.


package Scroll_Areas is


    type Area_Record is array (1 .. 4) of Integer;

    Calls : Natural     := 0;
    Last  : Area_Record := (others => -1);

    procedure Draw
           (X, Y, W, H : in Integer);


end Scroll_Areas;


