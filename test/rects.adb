

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK.Rects, after pofltk's examples/Rects.Mod:  laying out a Draw by
--  arithmetic on rectangles.  The box draws eight boxes, each inside the
--  last, gaining from the frame of the box kind, and from two insets.


with

    FLTK.Draw,
    FLTK.Rects,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double;


function Rects
    return Integer
is


    package Bx  renames FLTK.Widgets.Boxes;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;


    type Nest is new Bx.Box with null record;

    overriding procedure Draw
           (This : in out Nest);


    procedure Draw
           (This : in out Nest)
    is
        Area : FLTK.Rects.Rect := FLTK.Rects.Forge.Create (This);
    begin
        for I in 0 .. 7 loop
            FLTK.Draw.Draw_Box
               (Area.X, Area.Y, Area.W, Area.H, FLTK.Up_Box,
                FLTK.Grey_Ramp (FLTK.Greyscale'Val (FLTK.Greyscale'Pos ('A') + I * 3)));
            FLTK.Rects.Inset (Area, FLTK.Up_Box);
            FLTK.Rects.Inset (Area, 8);
            FLTK.Rects.Inset (Area, 4, 0, 0, 4);
        end loop;
    end Draw;


    Window : Dbl.Double_Window := Dbl.Forge.Create (300, 300, "Rects");
    Boxes  : constant Nest := (Bx.Forge.Create (Window, 10, 10, 280, 280) with null record);


begin


    Window.Set_Resizable (Boxes);
    Window.Show;

    return FLTK.Run;


end Rects;


