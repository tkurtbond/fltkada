--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 89: Keypress had no function keys (FL_F + n), so a
--  program couldn't tell F1 from any other key, as FLTK's test/fonts.cxx
--  does to open its editor.  Nor had it FLTK's other named keys: Pause,
--  Print, Menu, the shift keys themselves, and the rest.
--  tools/gen-constants.py checks their values against FLTK's.


with

    Ada.Exceptions,
    Checks,
    FLTK.Events,
    FLTK.Probe,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Function_Keys is

    package Win renames FLTK.Widgets.Groups.Windows;

    type Key_Window is new Win.Window with record
        Got : Keypress := Escape_Key;
    end record;

    overriding function Handle
           (This  : in out Key_Window;
            Event : in     Event_Kind)
        return Event_Outcome;

    function Handle
           (This  : in out Key_Window;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        if Event = Keydown and then Is_Function_Key (FLTK.Events.Last_Key) then
            This.Got := FLTK.Events.Last_Key;
            return Handled;
        end if;
        return Win.Window (This).Handle (Event);
    end Handle;

    Window : Key_Window :=
       (Win.Forge.Create (0, 0, 200, 100, "Test_Function_Keys") with Got => Escape_Key);

begin

    Check (Function_Key (1) /= Function_Key (2), "F1 and F2 differ");
    Check (Is_Function_Key (Function_Key (1)) and Is_Function_Key (Function_Key (35)),
        "F1 and F35 are function keys");
    Check (not Is_Function_Key (Escape_Key) and not Is_Function_Key (Left_Shift_Key),
        "Escape and the left shift key aren't");
    Check (not Is_Keypad (Function_Key (1)), "F1 isn't a keypad key");
    for N in Function_Key_Number loop
        if Function_Number (Function_Key (N)) /= N then
            Check (False, "Function_Number gives back F" & Function_Key_Number'Image (N));
        end if;
    end loop;
    Check (True, "Function_Number gives back each of F1 to F35");

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    --  On a desktop the shown window has the focus.  Under Xvfb nothing
    --  has, and FLTK then offers a key only as a shortcut (Fl.cxx:1532).
    FLTK.Events.Set_Focus (Window);
    Check (FLTK.Probe.Handle_Key (Window, Keydown, Function_Key (1)), "F1 is handled");
    Check (Window.Got = Function_Key (1), "the window got F1 from Last_Key");
    Check (Function_Number (Window.Got) = 1, "which is function key 1");

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Function_Keys;
