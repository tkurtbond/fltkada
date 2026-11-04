


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 92: a File_Chooser keeps its extra widget's
--  pointer.  The next Add_Extra reads the old one's height to shrink the
--  window (Fl_File_Chooser.cxx:487-493), and the destructor removes it from
--  the window (:330), so an extra widget finalized first is read from
--  freed memory.  An extra widget finalized should take its room with it,
--  and Eject_Extra should then return null.


with

    Ada.Exceptions,
    Checks,
    FLTK.File_Choosers,
    FLTK.Probe,
    FLTK.Widgets.Boxes;

use

    Checks,
    FLTK;


procedure Test_Chooser_Extra is

    package Prb renames FLTK.Probe;
    package FC  renames FLTK.File_Choosers;
    package Box renames FLTK.Widgets.Boxes;

    Ignore_Done : Boolean;

    procedure Pump
           (Times : in Positive) is
    begin
        for N in 1 .. Times loop
            Ignore_Done := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    Chooser : FC.File_Chooser := FC.Forge.Create ("Test_Chooser_Extra", "*", ".");

    Plain : Natural;

begin

    Chooser.Show;
    while not Chooser.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Pump (5);
    Plain := Prb.Modal_H;
    Check (Plain > 0, "the chooser is shown:" & Natural'Image (Plain));

    --  An extra widget finalized while it is the chooser's.
    declare
        Gone : Box.Box := Box.Forge.Create (0, 0, 100, 30);
    begin
        Chooser.Add_Extra (Gone);
        Check (Prb.Modal_H = Plain + 34, "the window grows for an extra widget:"
            & Natural'Image (Prb.Modal_H));
    end;
    Pump (2);
    Check (Prb.Modal_H = Plain, "a finalized extra widget takes its room with it:"
        & Natural'Image (Prb.Modal_H));

    declare
        Next : Box.Box := Box.Forge.Create (0, 0, 100, 20);
    begin
        Check (Chooser.Eject_Extra (Next) = null,
            "a finalized extra widget is not returned");
        Check (Prb.Modal_H = Plain + 24, "the window fits the next one:"
            & Natural'Image (Prb.Modal_H));
        Chooser.Remove_Extra;
        Check (Prb.Modal_H = Plain, "Remove_Extra leaves none:" & Natural'Image (Prb.Modal_H));
    end;

    --  An extra widget finalized, and then the chooser.
    declare
        Last : Box.Box := Box.Forge.Create (0, 0, 100, 30);
    begin
        Chooser.Add_Extra (Last);
    end;
    Chooser.Hide;
    Pump (2);

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Chooser_Extra;


