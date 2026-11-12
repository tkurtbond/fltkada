--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK's test/buttons.cxx: each kind of button, each with a tooltip
--  naming it, a keypad of compact buttons, and a choice of scheme.


with

    FLTK.Widgets.Buttons.Enter,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Buttons.Light.Round,
    FLTK.Widgets.Buttons.Repeat,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Choices.Schemes;


function Buttons
    return Integer
is

    package Btn renames FLTK.Widgets.Buttons;
    package Ent renames FLTK.Widgets.Buttons.Enter;
    package Lit renames FLTK.Widgets.Buttons.Light;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Ond renames FLTK.Widgets.Buttons.Light.Round;
    package Rpt renames FLTK.Widgets.Buttons.Repeat;
    package Grp renames FLTK.Widgets.Groups;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Sch renames FLTK.Widgets.Menus.Choices.Schemes;


    The_Win : Win.Window := Win.Forge.Create (420, 170);

    B1 : Btn.Button        := Btn.Forge.Create (The_Win,  10, 10, 130, 30, "Fl_Button");
    B2 : Ent.Enter_Button  := Ent.Forge.Create (The_Win, 150, 10, 160, 30, "Fl_Return_Button");
    B3 : Rpt.Repeat_Button := Rpt.Forge.Create (The_Win,  10, 50, 130, 30, "Fl_Repeat_Button");
    B4 : Ond.Round_Button  := Ond.Forge.Create (The_Win, 150, 50, 160, 30, "Fl_Round_Button");
    B5 : Lit.Light_Button  := Lit.Forge.Create (The_Win,  10, 90, 130, 30, "Fl_Light_Button");
    B6 : Chk.Check_Button  := Chk.Forge.Create (The_Win, 150, 90, 160, 30, "Fl_Check_Button");

    Keypad : Grp.Group := Grp.Forge.Create (The_Win, 320, 10, 90, 120);

    K7  : aliased Btn.Button := Btn.Forge.Create (Keypad, 320,  10, 30, 30, "7");
    K8  : aliased Btn.Button := Btn.Forge.Create (Keypad, 350,  10, 30, 30, "8");
    K9  : aliased Btn.Button := Btn.Forge.Create (Keypad, 380,  10, 30, 30, "9");
    K4  : aliased Btn.Button := Btn.Forge.Create (Keypad, 320,  40, 30, 30, "4");
    K5  : aliased Btn.Button := Btn.Forge.Create (Keypad, 350,  40, 30, 30, "5");
    K6  : aliased Btn.Button := Btn.Forge.Create (Keypad, 380,  40, 30, 30, "6");
    K1  : aliased Btn.Button := Btn.Forge.Create (Keypad, 320,  70, 30, 30, "1");
    K2  : aliased Btn.Button := Btn.Forge.Create (Keypad, 350,  70, 30, 30, "2");
    K3  : aliased Btn.Button := Btn.Forge.Create (Keypad, 380,  70, 30, 30, "3");
    K0  : aliased Btn.Button := Btn.Forge.Create (Keypad, 320, 100, 60, 30, "0");
    Dot : aliased Btn.Button := Btn.Forge.Create (Keypad, 380, 100, 30, 30, ".");

    type Button_Access is access all Btn.Button;

    Keys : constant array (0 .. 10) of Button_Access :=
       (K0'Access, K1'Access, K2'Access, K3'Access, K4'Access, K5'Access,
        K6'Access, K7'Access, K8'Access, K9'Access, Dot'Access);

    --  At the window's right edge, so its menu doesn't cover the buttons.
    Scheme_Choice : Sch.Scheme_Choice :=
        Sch.Forge.Create (The_Win, 180, 130, 130, 30, "Active FLTK Scheme:");

begin

    B1.Set_Tooltip ("Fl_Button");
    B2.Set_Tooltip ("Fl_Return_Button");
    B3.Set_Tooltip ("Fl_Repeat_Button");
    B4.Set_Tooltip ("Fl_Round_Button");
    B5.Set_Tooltip ("Fl_Light_Button");
    B6.Set_Tooltip ("Fl_Check_Button");

    for Key of Keys loop
        Key.Set_Compact (True);
        Key.Set_Selection_Color (FLTK.Selection_Color);
    end loop;

    Scheme_Choice.Set_Tooltip ("Fl_Scheme_Choice");

    The_Win.Set_Resizable (The_Win);
    The_Win.Set_Size_Range (320, 130);
    The_Win.Show_With_Args;

    return FLTK.Run;

end Buttons;
