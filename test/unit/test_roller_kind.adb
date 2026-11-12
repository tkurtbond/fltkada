--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda bug 131: a Roller couldn't be made horizontal.  FLTK's Fl_Roller
--  is vertical unless its type () is FL_HORIZONTAL (Fl_Roller.cxx, handle
--  and draw), and FLTKAda bound no way to set it.  FLTK's test/valuators
--  has a horizontal one.


with

    Checks,
    FLTK.Probe,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Valuators.Rollers;

use

    Checks,
    FLTK;

use type

    FLTK.Widgets.Valuators.Rollers.Roller_Kind;


procedure Test_Roller_Kind is

    package Prb renames FLTK.Probe;
    package Rol renames FLTK.Widgets.Valuators.Rollers;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (300, 200, "Roller");
    Across : Rol.Roller := Rol.Forge.Create (Window, 50, 50, 90, 20);

    Ignore : Boolean;


    --  Push at (X1, Y1), drag to (X2, Y2) and release there.
    procedure Drag
           (X1, Y1, X2, Y2 : in Integer) is
    begin
        Ignore := Prb.Mouse (Window, Push, X1, Y1);
        Ignore := Prb.Mouse (Window, FLTK.Drag, X2, Y2);
        Ignore := Prb.Mouse (Window, Release, X2, Y2);
    end Drag;


begin

    Window.End_Current;
    Check (Across.Get_Kind = Rol.Vertical_Roller, "a roller starts vertical");
    Across.Set_Kind (Rol.Horizontal_Roller);
    Check (Across.Get_Kind = Rol.Horizontal_Roller, "Set_Kind makes it horizontal");

    Window.Show;
    while not Window.Is_Shown loop
        Ignore := FLTK.Wait (0.02) = 0.0;
    end loop;

    --  A roller's step is 1/1000 (Fl_Roller.cxx, the constructor), and
    --  each pixel dragged is one step (handle).
    Drag (60, 60, 60, 66);
    Check (Across.Get_Value = 0.0,
        "a vertical drag doesn't move a horizontal roller:" & Across.Get_Value'Image);
    Drag (60, 60, 80, 60);
    Check (abs (Across.Get_Value - 0.02) < 1.0E-9,
        "a drag of 20 pixels to the right moves it to 0.02:" & Across.Get_Value'Image);

    Window.Hide;
    Summary;

end Test_Roller_Kind;
