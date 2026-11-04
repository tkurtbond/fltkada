--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  pofltk 10: when FLTK calls a widget's callback, it clears the widget's
--  changed flag afterwards, unless the callback is FLTK's default one
--  (Fl_Widget.cxx:385-386).  FLTKAda puts its own callback on a widget only
--  once Set_Callback gives it one.  So a widget with an Ada callback has
--  Has_Changed only inside it, and one with none keeps it.  Do_Callback
--  calls the Ada callback itself, not FLTK's do_callback, so it clears
--  nothing.  The spec of Has_Changed says this; this test checks it.


with

    Checks,
    FLTK.Probe,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Changed_Callback is

    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window  : Win.Window := Win.Forge.Create (200, 100, "Changed");
    With_CB : Chk.Check_Button := Chk.Forge.Create (Window, 10, 10, 80, 30, "with");
    Without : constant Chk.Check_Button := Chk.Forge.Create (Window, 100, 10, 80, 30, "without");

    Inside : Boolean := False;
    Calls  : Natural := 0;

    procedure Note
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Calls  := Calls + 1;
        Inside := Item.Has_Changed;
    end Note;

    procedure Click
           (X, Y : in Integer)
    is
        Ignore : Boolean;
    begin
        Ignore := Prb.Mouse (Window, Push, X, Y);
        Ignore := Prb.Mouse (Window, Release, X, Y);
    end Click;

    Ignore : Boolean;

begin

    Window.End_Current;
    With_CB.Set_Callback (Note'Unrestricted_Access);
    Window.Show;
    while not Window.Is_Shown loop
        Ignore := FLTK.Wait (0.02) = 0.0;
    end loop;

    Click (30, 25);
    Check (Calls = 1, "a click calls the callback:" & Natural'Image (Calls));
    Check (Inside, "inside the callback the button has changed");
    Check (not With_CB.Has_Changed, "after FLTK's callback it hasn't");

    Click (120, 25);
    Check (Without.Has_Changed, "a button with no callback has changed after a click");

    With_CB.Set_Changed;
    With_CB.Do_Callback;
    Check (Calls = 2 and then Inside, "Do_Callback calls it, changed");
    Check (With_CB.Has_Changed, "and after Do_Callback it still has changed");

    Summary;

end Test_Changed_Callback;
