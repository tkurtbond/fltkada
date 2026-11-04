

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 6, pofltk 60: a chart's maximum size of 0 means no
--  limit, but Fl_Chart::maxsize (0) (Fl_Chart.cxx:480-492) keeps the last
--  0 entries, all of them dropped.


with

    Ada.Exceptions,
    Checks,
    FLTK.Widgets.Charts;

use

    Checks,
    FLTK;


procedure Test_Chart_Maxsize is

    package Chr renames FLTK.Widgets.Charts;

    The_Chart : Chr.Chart := Chr.Forge.Create (0, 0, 300, 200);

begin

    Check (The_Chart.Get_Maximum_Size = 0, "a new chart has no limit");

    for N in 1 .. 3 loop
        The_Chart.Add (Long_Float (N), "", Red_Color);
    end loop;
    The_Chart.Set_Maximum_Size (3);
    Check (The_Chart.Get_Size = 3, "a limit of 3 keeps 3 entries");

    The_Chart.Set_Maximum_Size (0);
    Check (The_Chart.Get_Maximum_Size = 0, "the limit is set back to 0");
    Check (The_Chart.Get_Size = 3, "a limit of 0 keeps every entry");

    The_Chart.Add (4.0, "", Red_Color);
    Check (The_Chart.Get_Size = 4, "with no limit, a fourth entry is added");

    The_Chart.Set_Maximum_Size (2);
    Check (The_Chart.Get_Size = 2, "a limit of 2 keeps 2 entries");
    Check (The_Chart.Get_Maximum_Size = 2, "the limit reads 2");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Chart_Maxsize;
