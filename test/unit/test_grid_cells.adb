


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Phase 12's Grid cells: Get_Cell reads where Set_Widget put a widget,
--  Cell_Widget finds it by row and column, and Set_Cell_Alignment and
--  Set_Cell_Minimum_Size lay the grid out again, which Fl_Grid::Cell's
--  own setters don't (FLTK-issues.md F27).


with

    Checks,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Grids,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Grid_Cells is

    package Bxs renames FLTK.Widgets.Boxes;
    package Grd renames FLTK.Widgets.Groups.Grids;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type Grd.Grid_Alignment;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 200, "Test_Grid_Cells");
    Grid   : Grd.Grid := Grd.Forge.Create (Window, 0, 0, 200, 200);
    A      : constant Bxs.Box := Bxs.Forge.Create (Grid, 0, 0, 20, 20, "a");
    B      : constant Bxs.Box := Bxs.Forge.Create (Grid, 0, 0, 10, 10, "b");

    procedure Settle is
    begin
        for N in 1 .. 10 loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
    end Settle;

    function Label_At
           (Row, Column : in Positive)
        return String
    is
        Item : constant access FLTK.Widgets.Widget'Class := Grid.Cell_Widget (Row, Column);
    begin
        return (if Item = null then "" else Item.Get_Label);
    end Label_At;

    function Place
        return String is
    begin
        return Integer'Image (A.Get_X) & Integer'Image (A.Get_Y)
            & Integer'Image (A.Get_W) & Integer'Image (A.Get_H);
    end Place;

    procedure Get_B is
        Ignore : constant Grd.Cell_Info := Grid.Get_Cell (B);
    begin
        null;
    end Get_B;

    procedure Align_B is
    begin
        Grid.Set_Cell_Alignment (B, Grd.Grid_Top_Left);
    end Align_B;

    procedure Size_B is
    begin
        Grid.Set_Cell_Minimum_Size (B, 5, 5);
    end Size_B;

    Info : Grd.Cell_Info;

begin

    Grid.Set_Layout (2, 2, Margin => 0, Gap => 0);
    Grid.Set_Widget (A, 1, 1);
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Settle;

    Check (Grid.Has_Cell (A) and not Grid.Has_Cell (B), "Has_Cell");
    Info := Grid.Get_Cell (A);
    Check (Info.Row = 1 and Info.Column = 1 and Info.Row_Span = 1 and Info.Column_Span = 1,
        "Get_Cell gives the row, column and spans Set_Widget set");
    Check (Info.Align = Grd.Grid_Fill, "and the alignment");
    Check (Info.Min_Width = 20 and Info.Min_Height = 20,
        "and the widget's size as the minimum:" & Natural'Image (Info.Min_Width) &
        Natural'Image (Info.Min_Height));
    Raises (Get_B'Unrestricted_Access, Constraint_Error'Identity,
        "Get_Cell of a widget with no cell raises Constraint_Error");
    Raises (Align_B'Unrestricted_Access, Constraint_Error'Identity,
        "so does Set_Cell_Alignment");
    Raises (Size_B'Unrestricted_Access, Constraint_Error'Identity,
        "and Set_Cell_Minimum_Size");

    Check (Label_At (1, 1) = "a", "Cell_Widget finds the widget at its row and column");
    Check (Label_At (2, 2) = "" and Label_At (3, 1) = "" and Label_At (1, 3) = "",
        "and null at an empty cell or past the grid");

    --  F27: FLTK's own setters leave the widget where it was.
    Check (A.Get_W > 20, "a filling cell stretches its widget:" & Place);
    Grid.Set_Cell_Alignment (A, Grd.Grid_Top_Left);
    Settle;
    Check (A.Get_X = 0 and A.Get_Y = 0 and A.Get_W = 20 and A.Get_H = 20,
        "Set_Cell_Alignment lays the grid out again (F27):" & Place);
    Check (Grid.Get_Cell (A).Align = Grd.Grid_Top_Left, "and Get_Cell reads it");
    Grid.Set_Cell_Minimum_Size (A, 40, 30);
    Settle;
    Check (A.Get_W = 40 and A.Get_H = 30,
        "Set_Cell_Minimum_Size lays it out again (F27):" & Place);
    Info := Grid.Get_Cell (A);
    Check (Info.Min_Width = 40 and Info.Min_Height = 30, "and Get_Cell reads it");

    Grid.Set_Widget (A, 1, 1, 2, 2);
    Info := Grid.Get_Cell (A);
    Check (Info.Row_Span = 2 and Info.Column_Span = 2, "Get_Cell reads the span");
    Grid.Set_Widget (A, 2, 2);
    Check (Label_At (1, 1) = "" and Label_At (2, 2) = "a",
        "a widget set elsewhere leaves its old cell");
    Info := Grid.Get_Cell (A);
    Check (Info.Row = 2 and Info.Column = 2 and Info.Row_Span = 1,
        "and Get_Cell reads the new one");
    Grid.Clear_Layout;
    Check (not Grid.Has_Cell (A) and Label_At (1, 1) = "",
        "Clear_Layout takes the cells away");

    Window.Hide;
    Summary;

end Test_Grid_Cells;
