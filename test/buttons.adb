

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Another button test program functionality reproduced in Ada


with

    FLTK.Widgets.Buttons.Enter,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Buttons.Light.Round,
    FLTK.Widgets.Buttons.Repeat,
    FLTK.Widgets.Groups.Windows;


function Buttons
    return Integer
is


    package Btn renames FLTK.Widgets.Buttons;
    package Ent renames FLTK.Widgets.Buttons.Enter;
    package Lit renames FLTK.Widgets.Buttons.Light;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Ond renames FLTK.Widgets.Buttons.Light.Round;
    package Rpt renames FLTK.Widgets.Buttons.Repeat;
    package Win renames FLTK.Widgets.Groups.Windows;


    The_Win : Win.Window := Win.Forge.Create (320, 130);


    Base : Btn.Button := Btn.Forge.Create (The_Win, 10, 10, 130, 30, "Fl_Button");


    Enter  : Ent.Enter_Button  := Ent.Forge.Create (The_Win, 150, 10, 160, 30, "Fl_Return_Button");
    Repeat : Rpt.Repeat_Button := Rpt.Forge.Create (The_Win,  10, 50, 130, 30, "Fl_Repeat_Button");
    Light  : Lit.Light_Button  := Lit.Forge.Create (The_Win,  10, 90, 130, 30, "Fl_Light_Button");
    Round  : Ond.Round_Button  := Ond.Forge.Create (The_Win, 150, 50, 160, 30, "Fl_Round_Button");
    Check  : Chk.Check_Button  := Chk.Forge.Create (The_Win, 150, 90, 160, 30, "Fl_Check_Button");


begin


    Base.Set_Tooltip ("This is a Tooltip.");

    The_Win.Show_With_Args;

    return FLTK.Run;


end Buttons;


