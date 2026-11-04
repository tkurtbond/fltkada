


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 5, pofltk 21: Fl_Grid::widget checks a row against
--  rows () with > where it means >=, and so makes a cell one past the
--  end of the grid's rows (Fl_Grid.cxx:834-842).  A span past the grid's
--  edge, and one the grid was later cut smaller than (FLTK-issues.md F5),
--  make Fl_Grid::layout read past its rows and columns
--  (Fl_Grid.cxx:470-478).


with

    Ada.Exceptions,
    Checks,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Grids,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Grid_Range is

    package Bxs renames FLTK.Widgets.Boxes;
    package Grd renames FLTK.Widgets.Groups.Grids;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 200, "Test_Grid_Range");
    Grid   : Grd.Grid := Grd.Forge.Create (Window, 0, 0, 200, 200);
    B      : constant Bxs.Box := Bxs.Forge.Create (Grid, 0, 0, 10, 10);
    C      : constant Bxs.Box := Bxs.Forge.Create (Grid, 0, 0, 10, 10);

begin

    Grid.Set_Layout (2, 2, Margin => 0, Gap => 0);

    --  pofltk 21: a row or column just past the grid.
    Check (not Grid.Set_Widget (B, 3, 1), "row 3 of a 2 by 2 grid is refused");
    Check (not Grid.Set_Widget (B, 1, 3), "column 3 of a 2 by 2 grid is refused");
    Check (Grid.Set_Widget (B, 2, 2), "row 2, column 2 is placed");

    --  A span past the grid's edge.
    Check (not Grid.Set_Widget (B, 1, 1, 3, 1), "a span of 3 rows from row 1 is refused");
    Check (not Grid.Set_Widget (B, 2, 1, 1, 2 + 1), "a span of 3 columns is refused");
    Check (not Grid.Set_Widget (B, 2, 2, 2, 1), "a span of 2 rows from row 2 is refused");

    --  F5: the grid cut smaller than a span.
    Check (Grid.Set_Widget (B, 1, 1, 2, 2), "a span of the whole grid is placed");
    Grid.Layout;
    Check (B.Get_W = 200 and then B.Get_H = 200,
        "the span fills the grid:" & Integer'Image (B.Get_W) & Integer'Image (B.Get_H));
    Grid.Set_Layout (1, 1);
    Grid.Layout;
    Check (B.Get_W = 200 and then B.Get_H = 200,
        "the span fills the grid cut to 1 by 1:"
        & Integer'Image (B.Get_W) & Integer'Image (B.Get_H));

    --  F5: a cell the cut hid, shown again by a grid made larger.
    Grid.Set_Layout (1, 3);
    Check (Grid.Set_Widget (C, 1, 2, 1, 2), "a span of columns 2 and 3 is placed");
    Grid.Set_Layout (1, 1);
    Grid.Layout;
    Grid.Set_Layout (1, 2);
    Grid.Layout;
    Check (C.Get_X = 100 and then C.Get_W = 100,
        "a hidden cell shown again fits the grid:"
        & Integer'Image (C.Get_X) & Integer'Image (C.Get_W));

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Window.Hide;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Grid_Range;


