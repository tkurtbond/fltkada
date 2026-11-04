--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Shortcut_Button (Fl_Shortcut_Button), ported from pofltk's
--  TestButtons.CheckShortcutButton.  Its value hides Fl_Button's value,
--  so the shim calls it as Fl_Shortcut_Button's.  A click makes it wait
--  for a key, which becomes its value; a capital is its letter with Shift
--  (Fl_Shortcut_Button.cxx, handle).  Any shortcut with a key or a
--  modifier raised Constraint_Error when read back, from any widget,
--  because the whole value was taken for a mouse button (FLTKAda-BUGS.md
--  72).


with

    Checks,
    FLTK.Probe,
    FLTK.Widgets.Buttons.Shortcut,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Shortcut_Button is

    package Prb renames FLTK.Probe;
    package SB  renames FLTK.Widgets.Buttons.Shortcut;
    package Win renames FLTK.Widgets.Groups.Windows;

    Calls : Natural := 0;

    procedure Count
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Calls := Calls + 1;
    end Count;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Shortcut_Button");

    Button : SB.Shortcut_Button := SB.Forge.Create (Window, 10, 10, 150, 25);

    Ignore : Boolean;

begin

    Check (Button.Get_Value = No_Key, "a shortcut button starts with none");
    Button.Set_Value (Mod_Ctrl + 'q');
    Check (Button.Get_Value = Mod_Ctrl + 'q', "its value reads back");
    Check (Button.Get_Shortcut = No_Key, "its value is not the button's own shortcut");
    Button.Set_Shortcut (Mod_Ctrl + 'w');
    Check (Button.Get_Shortcut = Mod_Ctrl + 'w', "a button's own shortcut reads back (72)");
    Button.Set_Shortcut (Mod_Alt + Left_Button);
    Check (Button.Get_Shortcut = Mod_Alt + Left_Button,
        "a shortcut with a mouse button reads back");
    Button.Set_Shortcut (No_Key);
    Button.Set_Value (No_Key);
    Check (Button.Get_Value = No_Key, "its value clears");

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    FLTK.Check;

    Button.Set_Callback (Count'Unrestricted_Access);
    Button.Set_When (When_Changed);
    Ignore := Button.Take_Focus;
    Ignore := Prb.Mouse (Window, Push, 50, 20);
    Ignore := Prb.Mouse (Window, Release, 50, 20, Clicks => 1);
    Check (Prb.Key (Keydown, Press ('k'), Mod_Alt, "k"), "the key reaches the waiting button");
    Check (Button.Get_Value = Mod_Alt + 'k' and Calls = 1,
        "a click, then a key, sets it and calls back once:" & Natural'Image (Calls));
    Ignore := Prb.Key (Keydown, Press ('k'), Mod_Shift, "K");
    Check (Button.Get_Value = Mod_Shift + 'k', "a capital is its letter with Shift");

    Summary;

end Test_Shortcut_Button;
