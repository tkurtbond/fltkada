

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A positioner, and a clock whose hands its two values set, after
--  pofltk's examples/Positions.Mod.  Drag the cross:  across sets the
--  hours, down the minutes.


with

    FLTK.Widgets.Clocks,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Positioners;


function Positions
    return Integer
is


    package Wdg renames FLTK.Widgets;
    package Clk renames FLTK.Widgets.Clocks;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Pos renames FLTK.Widgets.Positioners;


    Window : Win.Window := Win.Forge.Create (420, 220, "Positions");
    Place  : Pos.Positioner := Pos.Forge.Create (Window, 10, 10, 200, 200);
    Face   : Clk.Clock := Clk.Forge.Create (Window, 220, 10, 190, 200);


    procedure Moved
           (Ignore : in out Wdg.Widget'Class) is
    begin
        --  The steps keep both values whole.
        Face.Set_Time (Clk.Hour (Place.Get_Ecks), Clk.Minute (Place.Get_Why), 0);
    end Moved;


begin


    Place.Set_Ecks_Bounds (0.0, 23.0);
    Place.Set_Why_Bounds (0.0, 59.0);
    Place.Set_Ecks_Step (1.0);
    Place.Set_Why_Step (1.0);
    Place.Set_Coords (10.0, 10.0);
    Place.Set_Callback (Moved'Unrestricted_Access);

    Clk.Extra.Set_Kind (Face, Clk.Round_Face);
    Face.Set_Time (10, 10, 0);

    Window.Show;

    return FLTK.Run;


end Positions;


