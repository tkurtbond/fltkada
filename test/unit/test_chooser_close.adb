

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 91: a File_Chooser freed in its own callback.
--  Enter in the file name calls the callback, and then hides the chooser's
--  window (Fl_File_Chooser2.cxx:820-823), from freed memory if the
--  callback freed the chooser.  A chooser freed in a callback of its extra
--  widget is freed inside its own window's event.  Run from test/unit,
--  where the file chosen is.


with

    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.File_Choosers,
    FLTK.Probe,
    FLTK.Widgets.Buttons;

use

    Checks,
    FLTK;


procedure Test_Chooser_Close is

    package Prb renames FLTK.Probe;
    package FC  renames FLTK.File_Choosers;
    package Btn renames FLTK.Widgets.Buttons;

    type Chooser_Access is access FC.File_Chooser;
    procedure Free is new Ada.Unchecked_Deallocation (FC.File_Chooser, Chooser_Access);

    Chooser : Chooser_Access;
    Calls   : Natural := 0;

    procedure Closes
           (Item : in out FC.File_Chooser'Class)
    is
        pragma Unreferenced (Item);
    begin
        Calls := Calls + 1;
        Free (Chooser);
    end Closes;

    procedure Button_Closes
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Calls := Calls + 1;
        Free (Chooser);
    end Button_Closes;

    Ignore : Boolean;

    procedure Pump
           (Times : in Positive) is
    begin
        for N in 1 .. Times loop
            Ignore := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    procedure Open is
    begin
        Chooser := new FC.File_Chooser'(FC.Forge.Create ("Test_Chooser_Close", "*", "."));
    end Open;

    procedure Show_It is
    begin
        Chooser.Show;
        while not Chooser.Is_Shown loop
            exit when FLTK.Wait < 0;
        end loop;
        Pump (5);
    end Show_It;

begin

    --  pofltk 91: freed in its callback, which Enter in the file name calls.
    Open;
    Chooser.Set_Callback (Closes'Unrestricted_Access);
    Chooser.Set_Selected ("test_chooser_close.adb");
    Show_It;
    Check (Prb.Modal, "the chooser is shown");
    Ignore := Prb.Modal_Key (Enter_Key, Text => (1 => ASCII.CR));
    Pump (5);
    Check (Calls = 1 and then Chooser = null, "a chooser freed in its callback:"
        & Natural'Image (Calls));
    Check (not Prb.Modal, "is no longer shown");

    --  Freed in a callback of its extra widget.
    declare
        Closer : Btn.Button := Btn.Forge.Create (0, 0, 100, 25, "Close");
    begin
        Calls := 0;
        Open;
        Closer.Set_Callback (Button_Closes'Unrestricted_Access);
        Chooser.Add_Extra (Closer);
        Show_It;
        Closer.Do_Callback;
        Pump (5);
        Check (Calls = 1 and then Chooser = null and then not Prb.Modal,
            "a chooser freed in a callback of its extra widget");
        Check (Closer.Parent = null, "its extra widget outlives it");
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Chooser_Close;
