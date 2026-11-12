--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/grid_buttons.cxx: a row of five buttons in a one-row
--  Fl_Grid of seven columns, two of them empty and weighted to take the
--  spare width, with an empty group below as the window's resizable.
--  FLTK's columns are numbered from 0, FLTKAda's from 1.  Guided by
--  pofltk's GridButtons.Mod.


with

    FLTK.Static,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Grids,
    FLTK.Widgets.Groups.Windows.Double;


function Grid_Buttons
    return Integer
is

    package Btn renames FLTK.Widgets.Buttons;
    package Grp renames FLTK.Widgets.Groups;
    package Grd renames FLTK.Widgets.Groups.Grids;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;

begin

    FLTK.Static.Parse_Args;

    declare

        Win : Dbl.Double_Window := Dbl.Forge.Create (460, 200, "Fl_Grid Row with 5 Buttons");

        Grid : Grd.Grid := Grd.Forge.Create (Win, 0, 0, Win.Get_W, 50);

        B0 : constant Btn.Button := Btn.Forge.Create (Grid, 0, 0, 80, 30, "New");
        B1 : constant Btn.Button := Btn.Forge.Create (Grid, 0, 0, 80, 30, "Options");
        B3 : constant Btn.Button := Btn.Forge.Create (Grid, 0, 0, 80, 30, "About");
        B4 : constant Btn.Button := Btn.Forge.Create (Grid, 0, 0, 80, 30, "Help");
        B6 : constant Btn.Button := Btn.Forge.Create (Grid, 0, 0, 80, 30, "Quit");

        --  Empty group as the window's resizable.
        G1 : constant Grp.Group := Grp.Forge.Create (Win, 0, 50, Win.Get_W, Win.Get_H - 50);

    begin

        Grid.Set_Layout (1, 7, 10, 10);
        Grid.End_Current;

        --  Assign buttons to grid positions; no gap between New and Options,
        --  or between About and Help.
        Grid.Set_Widget (B0, 1, 1);
        Grid.Set_Widget (B1, 1, 2);
        Grid.Set_Column_Gap (2, 0);
        Grid.Set_Widget (B3, 1, 4);
        Grid.Set_Widget (B4, 1, 5);
        Grid.Set_Column_Gap (5, 0);
        Grid.Set_Widget (B6, 1, 7);

        --  The empty columns take the spare width.
        Grid.Set_Column_Weight (Grd.Size_Array'(0, 0, 50, 0, 0, 50, 0));

        Grid.End_Current;

        Win.End_Current;
        Win.Set_Resizable (G1);
        Win.Set_Size_Range (Win.Get_W, 100);
        Win.Show_With_Args;

        return FLTK.Run;

    end;

end Grid_Buttons;

