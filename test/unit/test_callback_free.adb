


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 104:  a widget freed in a callback must leave the window
--  it was in.  FLTK deletes it later (Fl::delete_widget), and hides it now,
--  which redraws its group (Fl.cxx:1827, Fl_Widget.cxx:263-267).  It must be
--  hidden while it is still in its group, or nothing is redrawn and the
--  window goes on showing it.


with

    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Static,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Callback_Free is

    package Wdg renames FLTK.Widgets;
    package Btn renames FLTK.Widgets.Buttons;
    package Win renames FLTK.Widgets.Groups.Windows;

    type Button_Access is access Btn.Button;
    procedure Free is new Ada.Unchecked_Deallocation (Btn.Button, Button_Access);

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Callback_Free");
    Button : Button_Access :=
        new Btn.Button'(Btn.Forge.Create (Window, 10, 10, 100, 30, "free me"));

    Called      : Boolean := False;
    Damaged     : Boolean := False;
    Ignore      : Boolean;
    Ignore_Time : Long_Float;

    procedure Free_Self
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Called := True;
        Free (Button);
        Damaged := Window.Is_Damaged;
    end Free_Self;

    --  The callback must run inside FLTK's dispatch, as a click's does:
    --  Do_Callback called from here would delete the widget at once.
    procedure Click is
    begin
        Button.Do_Callback;
    end Click;

begin

    Button.Set_Callback (Free_Self'Unrestricted_Access);
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    for Tries in 1 .. 100 loop
        exit when not Window.Is_Damaged;
        Ignore_Time := FLTK.Wait (0.02);
    end loop;
    Check (not Window.Is_Damaged, "the window shown has been drawn");

    FLTK.Static.Add_Timeout (0.0, Click'Unrestricted_Access);
    for Tries in 1 .. 100 loop
        exit when Called;
        Ignore_Time := FLTK.Wait (0.02);
    end loop;
    Check (Called, "the callback ran");
    Check (Damaged, "a widget freed in its callback redraws its window");
    Check (Window.Number_Of_Children = 0, "a widget freed in its callback leaves its window");

    Ignore := FLTK.Check;
    Window.Hide;
    Summary;

end Test_Callback_Free;


