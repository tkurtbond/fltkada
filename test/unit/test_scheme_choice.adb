


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Phase 12's Scheme_Choice: Init_Value picks the scheme in use, and
--  Switch_Scheme does what FLTK's own callback does, so a callback set in
--  its place can still switch, as pofltk's SchemeChoice.Callback does.
--  With nothing chosen, it does nothing, where FLTK's callback reads
--  before the menu (FLTK-issues.md F28).


with

    Checks,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Choices.Schemes;

use

    Checks;


procedure Test_Scheme_Choice is

    package Sch renames FLTK.Widgets.Menus.Choices.Schemes;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type FLTK.Widgets.Menus.Extended_Index;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 50, "Test_Scheme_Choice");
    Choice : Sch.Scheme_Choice := Sch.Forge.Create (Window, 0, 0, 200, 30);

    Called : Natural := 0;

    procedure Mine
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Called := Called + 1;
        Sch.Scheme_Choice (Item).Switch_Scheme;
    end Mine;

begin

    FLTK.Static.Set_Scheme ("plastic");
    Choice.Init_Value;
    Check (Choice.Chosen_Label = "plastic",
        "Init_Value picks the scheme in use: " & Choice.Chosen_Label);

    Choice.Set_Chosen (Choice.Find_Index ("gtk+"));
    Check (FLTK.Static.Get_Scheme = "plastic", "choosing an item doesn't switch by itself");
    Choice.Switch_Scheme;
    Check (FLTK.Static.Get_Scheme = "gtk+",
        "Switch_Scheme switches to the scheme chosen: " & FLTK.Static.Get_Scheme);

    Choice.Set_Callback (Mine'Unrestricted_Access);
    Choice.Set_Chosen (Choice.Find_Index ("gleam"));
    Choice.Do_Callback;
    Check (Called = 1 and FLTK.Static.Get_Scheme = "gleam",
        "a callback set in its place can still switch: " & FLTK.Static.Get_Scheme);

    Choice.Clear_Chosen;
    Check (Choice.Chosen_Index = FLTK.Widgets.Menus.No_Index, "nothing chosen");
    Choice.Switch_Scheme;
    Check (FLTK.Static.Get_Scheme = "gleam",
        "Switch_Scheme with nothing chosen does nothing (F28): " & FLTK.Static.Get_Scheme);

    --  pofltk's TestWidget: Set_System_Scheme reads FLTK_SCHEME, which
    --  Set_Scheme sets too (pofltk 156).
    FLTK.Static.Set_Scheme ("gtk+");
    FLTK.Static.Set_Scheme ("base");
    Check (FLTK.Static.Get_Scheme = "", "base is no scheme");
    FLTK.Probe.Set_Env ("FLTK_SCHEME", "Plastic");
    FLTK.Static.Set_System_Scheme;
    Check (FLTK.Static.Get_Scheme = "plastic",
        "Set_System_Scheme takes FLTK_SCHEME: " & FLTK.Static.Get_Scheme);
    FLTK.Static.Set_Scheme ("gtk+");
    FLTK.Static.Set_System_Scheme;
    Check (FLTK.Static.Get_Scheme = "gtk+",
        "after Set_Scheme, Set_System_Scheme keeps it: " & FLTK.Static.Get_Scheme);
    FLTK.Probe.Set_Env ("FLTK_SCHEME", "nonesuch");
    FLTK.Static.Set_System_Scheme;
    Check (FLTK.Static.Get_Scheme = "",
        "an unknown FLTK_SCHEME is no scheme: " & FLTK.Static.Get_Scheme);

    Summary;

end Test_Scheme_Choice;
