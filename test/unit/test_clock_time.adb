

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 6, pofltk 76: Fl_Clock_Output::value (v) stores v, then
--  sets the hands, which store the seconds past midnight in place of v
--  when they move (Fl_Clock.cxx:125-146).  So Get_Time after Set_Time
--  gave back what was set only when the hands were already there.


with

    Ada.Exceptions,
    Checks,
    FLTK.Widgets.Clocks;

use

    Checks;


procedure Test_Clock_Time is

    package Clk renames FLTK.Widgets.Clocks;

    use type Clk.Time_Value;

    The_Clock : Clk.Clock := Clk.Forge.Create (0, 0, 100, 100);

    First  : constant Clk.Time_Value := 1_000_000_000;
    Second : constant Clk.Time_Value := First + 3_661;

begin

    The_Clock.Set_Time (First);
    Check (The_Clock.Get_Time = First, "a time set is read back");
    The_Clock.Set_Time (Second);
    Check (The_Clock.Get_Time = Second, "another time, with the hands moved, is read back");
    The_Clock.Set_Time (Second);
    Check (The_Clock.Get_Time = Second, "the same time set twice is read back");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Clock_Time;
