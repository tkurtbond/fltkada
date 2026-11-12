--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 134: the shim took Fl_Color_Chooser::rgb's and hsv's
--  arguments as int while Ada passed doubles, so Set_RGB and Set_HSV
--  set the chooser to whatever was in the integer registers.  Found by
--  the port of FLTK's test/contrast.cxx, whose chooser showed 127500
--  where FLTK's shows 255.


with

    Ada.Exceptions,
    Checks,
    FLTK.Widgets.Groups.Color_Choosers;

use

    Checks;


procedure Test_Color_Chooser_Values is

    package CC renames FLTK.Widgets.Groups.Color_Choosers;

    Chooser : CC.Color_Chooser := CC.Forge.Create (0, 0, 200, 100);

    function Near
           (A, B : in Long_Float)
        return Boolean is
    begin
        return abs (A - B) < 1.0E-6;
    end Near;

begin

    Chooser.Set_RGB (1.0, 1.0, 1.0);
    Check (Near (Chooser.Get_Red, 1.0) and Near (Chooser.Get_Green, 1.0)
        and Near (Chooser.Get_Blue, 1.0), "Set_RGB (1, 1, 1) gives white");
    Check (Near (Chooser.Get_Saturation, 0.0) and Near (Chooser.Get_Value, 1.0),
        "white has saturation 0 and value 1");

    Chooser.Set_RGB (0.25, 0.5, 0.75);
    Check (Near (Chooser.Get_Red, 0.25) and Near (Chooser.Get_Green, 0.5)
        and Near (Chooser.Get_Blue, 0.75), "Set_RGB keeps fractions");

    Chooser.Set_HSV (2.0, 1.0, 1.0);
    Check (Near (Chooser.Get_Hue, 2.0) and Near (Chooser.Get_Saturation, 1.0)
        and Near (Chooser.Get_Value, 1.0), "Set_HSV (2, 1, 1) is kept");
    Check (Near (Chooser.Get_Red, 0.0) and Near (Chooser.Get_Green, 1.0)
        and Near (Chooser.Get_Blue, 0.0), "and is green");

    Chooser.Set_HSV (0.5, 0.5, 0.5);
    Check (Near (Chooser.Get_Hue, 0.5) and Near (Chooser.Get_Saturation, 0.5)
        and Near (Chooser.Get_Value, 0.5), "Set_HSV keeps fractions");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Color_Chooser_Values;
