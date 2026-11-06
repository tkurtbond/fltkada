

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 99: Set_Step_Top and Set_Step_Bottom each set the whole
--  step, as FLTK's step (double) and step (int) do, though the names say
--  top and bottom.  Set_Step (To) is now the name for both, and the old
--  names, kept as obsolescent, still do the same.


with

    Ada.Exceptions,
    Checks,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Valuators.Counters,
    FLTK.Widgets.Valuators.Sliders;

use

    Checks;


procedure Test_Valuator_Step is

    package Win renames FLTK.Widgets.Groups.Windows;
    package Cnt renames FLTK.Widgets.Valuators.Counters;
    package Sld renames FLTK.Widgets.Valuators.Sliders;

    Window  : Win.Window := Win.Forge.Create (300, 100);
    Slider  : Sld.Slider := Sld.Forge.Create (Window, 0, 0, 300, 20, "");
    Counter : Cnt.Counter := Cnt.Forge.Create (Window, 0, 40, 300, 20, "");

    procedure Step_Is
           (Expected : in Long_Float;
            What     : in String) is
    begin
        Check (Slider.Get_Step = Expected,
            What & " gives a step of" & Long_Float'Image (Expected) & ", got"
            & Long_Float'Image (Slider.Get_Step));
    end Step_Is;

begin

    Slider.Set_Step (4);
    Step_Is (4.0, "Set_Step (4)");
    Slider.Set_Step (0.25);
    Step_Is (0.25, "Set_Step (0.25)");
    Slider.Set_Step (0.1);
    Step_Is (1.0 / 10.0, "Set_Step (0.1)");
    Slider.Set_Step (1.0, 4);
    Step_Is (0.25, "Set_Step (1.0, 4)");

    pragma Warnings (Off, "*obsolescent*");
    Slider.Set_Step_Bottom (4);
    Step_Is (4.0, "Set_Step_Bottom (4), obsolescent,");
    Slider.Set_Step_Top (0.25);
    Step_Is (0.25, "Set_Step_Top (0.25), obsolescent,");
    pragma Warnings (On, "*obsolescent*");

    Counter.Set_Long_Step (10.0);
    Counter.Set_Step (0.5);
    Check (Counter.Get_Step = 0.5,
        "a counter's Set_Step (0.5) gives 0.5, got" & Long_Float'Image (Counter.Get_Step));
    Check (Counter.Get_Long_Step = 10.0, "and leaves the long step alone");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Valuator_Step;
