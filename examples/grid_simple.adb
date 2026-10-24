

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  An Ada port of FLTK's examples/grid-simple.cxx, a 3x3 Fl_Grid with buttons.
--  There are no deliberate differences in behaviour. Grid rows and columns are
--  numbered from 1 in this binding, so the C++ cell (0, 0) is (1, 1) here, and
--  the widgets are added to their parents through the Forge.Create Parent
--  overloads rather than by being created while a group is current.


with

    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Grids,
    FLTK.Widgets.Groups.Windows.Double;


function Grid_Simple
    return Integer
is


    package Btn renames FLTK.Widgets.Buttons;
    package Grd renames FLTK.Widgets.Groups.Grids;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;


    Win : Dbl.Double_Window := Dbl.Forge.Create (320, 180, "3x3 Fl_Grid with Buttons");

    --  Create the Fl_Grid container with five buttons
    Grid : Grd.Grid := Grd.Forge.Create (Win, 0, 0, Win.Get_W, Win.Get_H);

    B0 : constant Btn.Button := Btn.Forge.Create (Grid, 0, 0, 0, 0, "New");
    B1 : constant Btn.Button := Btn.Forge.Create (Grid, 0, 0, 0, 0, "Options");
    B3 : constant Btn.Button := Btn.Forge.Create (Grid, 0, 0, 0, 0, "About");
    B4 : constant Btn.Button := Btn.Forge.Create (Grid, 0, 0, 0, 0, "Help");
    B6 : constant Btn.Button := Btn.Forge.Create (Grid, 0, 0, 0, 0, "Quit");


begin


    Grid.Set_Layout (3, 3, 10, 10);
    Grid.Set_Background_Color (FLTK.White_Color);

    --  Assign buttons to grid positions
    Grid.Set_Widget (B0, 1, 1);
    Grid.Set_Widget (B1, 1, 3);
    Grid.Set_Widget (B3, 2, 2);
    Grid.Set_Widget (B4, 3, 1);
    Grid.Set_Widget (B6, 3, 3);
    --  Grid.Show_Grid (True);  --  enable to display grid helper lines

    Grid.End_Current;
    Win.End_Current;

    Win.Set_Resizable (Grid);
    Win.Set_Size_Range (300, 100);
    Win.Show_With_Args;

    return FLTK.Run;


end Grid_Simple;


