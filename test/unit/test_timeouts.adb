--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Zero timeouts, the idiom FLTKAda uses where pofltk has Later (PLAN.md,
--  Phase 30, "Why Later isn't ported, checked"):  each Add_Timeout calls
--  its procedure once, Remove_Timeout drops every pending call, one added
--  from inside its own call waits for the next pass of the event loop,
--  and one added in a callback runs inside it if the callback runs a
--  nested loop.


with

    Checks,
    FLTK.Static,
    FLTK.Widgets.Buttons;

use

    Checks;


procedure Test_Timeouts is

    package Btn renames FLTK.Widgets.Buttons;
    package Sta renames FLTK.Static;

    Calls, Inside : Natural := 0;
    In_Callback   : Boolean := False;
    Again         : Boolean := False;

    procedure Tick is
    begin
        Calls := Calls + 1;
        if In_Callback then
            Inside := Inside + 1;
        end if;
        if Again then
            Again := False;
            Sta.Add_Timeout (0.0, Tick'Unrestricted_Access);
        end if;
    end Tick;

    procedure Nested
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        In_Callback := True;
        Sta.Add_Timeout (0.0, Tick'Unrestricted_Access);
        FLTK.Check;  --  a nested loop, as a modal dialog runs
        In_Callback := False;
    end Nested;

    Button : Btn.Button := Btn.Forge.Create (0, 0, 10, 10, "b");

begin

    Sta.Add_Timeout (0.0, Tick'Unrestricted_Access);
    Sta.Add_Timeout (0.0, Tick'Unrestricted_Access);
    Check (Sta.Has_Timeout (Tick'Unrestricted_Access), "two adds are pending");
    FLTK.Check;
    Check (Calls = 2 and not Sta.Has_Timeout (Tick'Unrestricted_Access),
        "two adds call it twice, and none is left:" & Calls'Image);

    Calls := 0;
    Sta.Add_Timeout (0.0, Tick'Unrestricted_Access);
    Sta.Add_Timeout (0.0, Tick'Unrestricted_Access);
    Sta.Remove_Timeout (Tick'Unrestricted_Access);
    FLTK.Check;
    Check (Calls = 0, "Remove_Timeout drops both:" & Calls'Image);

    Calls := 0;
    Again := True;
    Sta.Add_Timeout (0.0, Tick'Unrestricted_Access);
    FLTK.Check;
    Check (Calls = 1, "one added from inside its call waits:" & Calls'Image);
    FLTK.Check;
    Check (Calls = 2, "and runs on the next pass:" & Calls'Image);

    Calls := 0;
    Button.Set_Callback (Nested'Unrestricted_Access);
    Button.Do_Callback;
    Check (Calls = 1 and Inside = 1,
        "one added in a callback runs inside it, in a nested loop:" & Calls'Image & Inside'Image);

    Summary;

end Test_Timeouts;
