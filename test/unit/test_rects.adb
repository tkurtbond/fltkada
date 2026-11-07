

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK.Rects against FLTK's own Fl_Rect.  The expected values are what
--  Fl_Rect gave in a C++ program built with fltk-config, FLTK 1.4.5.


with

    Ada.Exceptions,
    Checks,
    FLTK.Rects,
    FLTK.Widgets.Boxes;

use

    Checks;

use type

    FLTK.Rects.Rect;


procedure Test_Rects is

    package R renames FLTK.Rects;

    function Image
           (This : in R.Rect)
        return String is
    begin
        return Integer'Image (This.X) & Integer'Image (This.Y)
            & Integer'Image (This.W) & Integer'Image (This.H);
    end Image;

    procedure Expect
           (Got      : in R.Rect;
            X, Y, W, H : in Integer;
            Label    : in String)
    is
        Want : constant R.Rect := (X, Y, W, H);
    begin
        Check (Got = Want, Label & ":" & Image (Got) & " (want" & Image (Want) & ")");
    end Expect;

    Box_Cases : constant array (1 .. 4) of FLTK.Box_Kind :=
       (FLTK.Up_Box, FLTK.Thin_Down_Box, FLTK.Engraved_Frame, FLTK.No_Box);

    type Four is array (1 .. 4) of Integer;

    Box_Wants : constant array (Box_Cases'Range) of Four :=
       ((12, 22, 96, 46), (11, 21, 98, 48), (12, 22, 96, 46), (10, 20, 100, 50));

    Area : R.Rect;

begin

    Expect (R.Forge.Create (30, 40), 0, 0, 30, 40, "Create (W, H)");
    Expect (R.Forge.Create (1, 2, 3, 4), 1, 2, 3, 4, "Create (X, Y, W, H)");
    Expect (Area, 0, 0, 0, 0, "a Rect starts empty");

    for I in Box_Cases'Range loop
        Expect (R.Forge.Create (10, 20, 100, 50, Box_Cases (I)),
            Box_Wants (I) (1), Box_Wants (I) (2), Box_Wants (I) (3), Box_Wants (I) (4),
            "Create with " & FLTK.Box_Kind'Image (Box_Cases (I)));
        Area := R.Forge.Create (10, 20, 100, 50);
        R.Inset (Area, Box_Cases (I));
        Expect (Area,
            Box_Wants (I) (1), Box_Wants (I) (2), Box_Wants (I) (3), Box_Wants (I) (4),
            "Inset with " & FLTK.Box_Kind'Image (Box_Cases (I)));
    end loop;

    Area := R.Forge.Create (10, 20, 100, 50);
    R.Inset (Area, 3);
    Expect (Area, 13, 23, 94, 44, "Inset (3)");
    R.Inset (Area, 1, 2, 3, 4);
    Expect (Area, 14, 25, 90, 38, "Inset (1, 2, 3, 4)");
    R.Set_Right (Area, 200);
    R.Set_Bottom (Area, 300);
    Expect (Area, 14, 25, 186, 275, "Set_Right (200), Set_Bottom (300)");
    Check (R.Get_Right (Area) = 200 and R.Get_Bottom (Area) = 300,
        "Get_Right, Get_Bottom:" & Integer'Image (R.Get_Right (Area))
        & Integer'Image (R.Get_Bottom (Area)));

    R.Inset (Area, -4);
    Expect (Area, 10, 21, 194, 283, "Inset (-4) enlarges");

    declare
        Box : constant FLTK.Widgets.Boxes.Box :=
            FLTK.Widgets.Boxes.Forge.Create (5, 6, 70, 80);
    begin
        Expect (R.Forge.Create (Box), 5, 6, 70, 80, "Create (Widget)");
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Rects;


