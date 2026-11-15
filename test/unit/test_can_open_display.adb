--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK.Static.Can_Open_Display, asked before any display is open (PLAN.md,
--  Phase 30):  True where FLTK could open one, False where Open_Display
--  would end the program, and True whatever the environment once one is
--  open.  After pofltk's TestDisplay.Mod.


with

    Ada.Environment_Variables,
    Checks,
    FLTK.Static;

use

    Checks;


procedure Test_Can_Open_Display is

    package Env renames Ada.Environment_Variables;
    package Sta renames FLTK.Static;

    use type Sta.Display_Platform;

    type Saved_Variable (Length : Natural) is record
        Set   : Boolean;
        Value : String (1 .. Length);
    end record;

    function Save
           (Name : in String)
        return Saved_Variable is
    begin
        if Env.Exists (Name) then
            return (Env.Value (Name)'Length, True, Env.Value (Name));
        else
            return (0, False, "");
        end if;
    end Save;

    procedure Restore
           (Name  : in String;
            Saved : in Saved_Variable) is
    begin
        if Saved.Set then
            Env.Set (Name, Saved.Value);
        else
            Env.Clear (Name);
        end if;
    end Restore;

    Backend : constant Saved_Variable := Save ("FLTK_BACKEND");
    Display : constant Saved_Variable := Save ("DISPLAY");
    Wayland : constant Saved_Variable := Save ("WAYLAND_DISPLAY");

    --  None that can be opened:  X11 chosen, and no server at its display.
    procedure Unreachable is
    begin
        Env.Set ("FLTK_BACKEND", "x11");
        Env.Set ("DISPLAY", ":9999");
        Env.Set ("WAYLAND_DISPLAY", "no-such-wayland-display");
    end Unreachable;

    procedure Restore_All is
    begin
        Restore ("FLTK_BACKEND", Backend);
        Restore ("DISPLAY", Display);
        Restore ("WAYLAND_DISPLAY", Wayland);
    end Restore_All;

begin

    Check (Sta.Can_Open_Display, "Can_Open_Display: the test's display");

    Unreachable;
    Check (not Sta.Can_Open_Display, "False where FLTK would end the program");

    Env.Set ("FLTK_BACKEND", "no-such-backend");
    Check (not Sta.Can_Open_Display, "False for a backend FLTK doesn't know");

    Restore_All;
    Check (Sta.Can_Open_Display, "True again");
    Check (Sta.Get_Display_Platform /= Sta.Other_Platform, "a display opened");

    Unreachable;
    Check (Sta.Can_Open_Display, "True once one is open, whatever the environment");
    Restore_All;

    Summary;

end Test_Can_Open_Display;
