


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestLayout: where a flex, grid, pack, scroll,
--  tabs, wizard and tile put their children.  Layouts are made by their
--  Layout procedures, or by drawing them into an image (FLTK.Probe), as
--  FLTK does before it shows them; the window is never shown.  pofltk's
--  checks that Clear deleted the children become checks that it removed
--  them, since Ada owns them here (Groups.Clear); test_group_clear has
--  more of that.  Grid cells are in test_grid_cells and test_grid_range,
--  tile size ranges in test_layout_methods.


with

    Ada.Exceptions,
    Checks,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Flex,
    FLTK.Widgets.Groups.Grids,
    FLTK.Widgets.Groups.Packed,
    FLTK.Widgets.Groups.Scrolls,
    FLTK.Widgets.Groups.Spinners,
    FLTK.Widgets.Groups.Tabbed,
    FLTK.Widgets.Groups.Tiled,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Groups.Wizards,
    System;

use

    Checks,
    FLTK;

use type

    FLTK.Widgets.Groups.Flex.Flex_Kind,
    FLTK.Widgets.Groups.Packed.Pack_Kind,
    FLTK.Widgets.Groups.Scrolls.Scroll_Kind,
    System.Address;


procedure Test_Layout is

    package Bxs renames FLTK.Widgets.Boxes;
    package Flx renames FLTK.Widgets.Groups.Flex;
    package Grd renames FLTK.Widgets.Groups.Grids;
    package Grp renames FLTK.Widgets.Groups;
    package Pck renames FLTK.Widgets.Groups.Packed;
    package Prb renames FLTK.Probe;
    package Scr renames FLTK.Widgets.Groups.Scrolls;
    package Spn renames FLTK.Widgets.Groups.Spinners;
    package Tbd renames FLTK.Widgets.Groups.Tabbed;
    package Til renames FLTK.Widgets.Groups.Tiled;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Wiz renames FLTK.Widgets.Groups.Wizards;

    function At_Place
           (Item                : in FLTK.Widgets.Widget'Class;
            X, Y, Width, Height : in Integer)
        return Boolean is
    begin
        return Item.Get_X = X and Item.Get_Y = Y
            and Item.Get_W = Width and Item.Get_H = Height;
    end At_Place;

    function Same
           (Item  : access FLTK.Widgets.Widget'Class;
            Other : in     FLTK.Widgets.Widget'Class)
        return Boolean is
    begin
        return Item /= null and then Item.all'Address = Other'Address;
    end Same;

    Window : Win.Window := Win.Forge.Create (0, 0, 600, 600, "Test_Layout");

    L, T, R, B, Row_Gap, Column_Gap : Integer;

begin

    --  A flex column, 300 high, one child fixed at 50
    declare
        Flex    : Flx.Flex_Group := Flx.Forge.Create (Window, 0, 0, 100, 300);
        A, B2, C : constant Bxs.Box := Bxs.Forge.Create (Flex, 0, 0, 0, 0);
    begin
        Flex.End_Current;
        Flex.Get_Margin (L, T, R, B);
        Check (Flex.Get_Gap = 0 and L = 0 and T = 0 and R = 0 and B = 0,
            "a flex has no gap or margins to start with");
        Flex.Set_Fixed (B2, 50);
        Flex.Layout;
        Check (Flex.Get_Kind = Flx.Vertical_Flex and Flex.Is_Fixed (B2)
                and not Flex.Is_Fixed (A),
            "a flex is a column to start with; Is_Fixed");
        Check (At_Place (A, 0, 0, 100, 125) and At_Place (B2, 0, 125, 100, 50)
                and At_Place (C, 0, 175, 100, 125),
            "its children share the height left by the fixed one");
        Flex.Set_Gap (10);
        Flex.Set_Margin (5, 5, 5, 5);
        Flex.Layout;
        Flex.Get_Margin (L, T, R, B);
        Check (Flex.Get_Gap = 10 and L = 5 and B = 5
                and At_Place (A, 5, 5, 90, 110) and At_Place (B2, 5, 125, 90, 50),
            "gap and margins");
    end;

    --  A flex row, laid out by drawing it
    declare
        Row        : Flx.Flex_Group := Flx.Forge.Create (Window, 100, 0, 300, 50);
        D, Content : constant Bxs.Box := Bxs.Forge.Create (Row, 0, 0, 0, 0);
    begin
        Row.Set_Kind (Flx.Horizontal_Flex);
        Row.End_Current;
        Check (Prb.Capture (Row) and Row.Get_Kind = Flx.Horizontal_Flex
                and At_Place (D, 100, 0, 150, 50) and At_Place (Content, 250, 0, 150, 50),
            "a flex row, laid out when drawn after End_Current");
        Prb.Release;
    end;

    --  A grid, 2 by 2
    declare
        Grid       : Grd.Grid := Grd.Forge.Create (Window, 0, 300, 200, 100);
        W1, W2, W3 : constant Bxs.Box := Bxs.Forge.Create (Grid, 0, 0, 0, 0);
    begin
        Grid.End_Current;
        Grid.Set_Layout (2, 2);
        Grid.Set_Widget (W1, 1, 1, Grd.Grid_Fill);
        Grid.Set_Widget (W2, 1, 2, Grd.Grid_Fill);
        Grid.Set_Widget (W3, 2, 1, 1, 2, Grd.Grid_Fill);
        Grid.Layout;
        Check (Grid.Get_Rows = 2 and Grid.Get_Columns = 2, "Set_Layout gives rows and columns");
        Check (At_Place (W1, 0, 300, 100, 50) and At_Place (W2, 100, 300, 100, 50)
                and At_Place (W3, 0, 350, 200, 50),
            "each child fills its cell; one spans the second row");
        Check (Grid.Get_Column_Weight (1) = 50 and Grid.Get_Column_Gap (1) = -1
                and Grid.Get_Column_Width (1) = 0,
            "a column's weight starts at 50, its gap at the grid's (-1), its width at 0");
        Grid.Set_Column_Weight (1, 0);
        Grid.Set_Column_Width (1, 40);
        Grid.Set_Gap (0, 10);
        Grid.Layout;
        Grid.Get_Gap (Row_Gap, Column_Gap);
        Check (Row_Gap = 0 and Column_Gap = 10 and Grid.Computed_Column_Width (1) = 40
                and Grid.Computed_Column_Width (2) = 150 and At_Place (W2, 50, 300, 150, 50),
            "a column of fixed width, with a gap, leaves the rest to the other");
        Grid.Set_Margin (1, 2, 3, 4);
        Grid.Get_Margin (L, T, R, B);
        Check (L = 1 and T = 2 and R = 3 and B = 4, "a grid's margins");
        Grid.Set_Row_Height (2, 30);
        Grid.Set_Row_Weight (2, 0);
        Check (Grid.Get_Row_Height (2) = 30 and Grid.Get_Row_Weight (2) = 0,
            "a row's height and weight");
        Grid.Set_Widget (W1, 2, 2, Grd.Grid_Center);
        Check (Grid.Number_Of_Children = 3 and Same (Grid.Cell_Widget (2, 2), W1),
            "placing a child again moves it, keeping it a child");
    end;

    --  A pack: children at their own heights, spaced
    declare
        Pack : Pck.Packed_Group := Pck.Forge.Create (Window, 200, 300, 100, 200);
        P1   : constant Bxs.Box := Bxs.Forge.Create (Pack, 0, 0, 100, 20);
        P2   : constant Bxs.Box := Bxs.Forge.Create (Pack, 0, 0, 100, 30);
        Ignore : Boolean;
    begin
        Pack.End_Current;
        Pack.Set_Spacing (5);
        --  Fl_Pack sets its own size as it draws, so the capture is the
        --  size the pack was, not the size it is.
        Ignore := Prb.Capture (Pack);
        Prb.Release;
        Check (Pack.Get_Kind = Pck.Vertical_Pack and Pack.Get_Spacing = 5
                and P1.Get_Y = 300 and P2.Get_Y = 325 and P2.Get_H = 30 and Pack.Get_H = 55,
            "a pack stacks its children, spaced, when drawn, and fits itself to them");
        Pack.Set_Resizable (P2);
        Pack.Clear;
        Check (Pack.Number_Of_Children = 0 and Pack.Get_Resizable = null,
            "Clear removes a pack's children and leaves it no resizable, as Fl_Pack::clear does");
    end;

    --  A scroll: its scrollbars are children FLTK made
    declare
        Scroll  : Scr.Scroll := Scr.Forge.Create (Window, 300, 0, 100, 100);
        Content : constant Bxs.Box := Bxs.Forge.Create (Scroll, 300, 0, 300, 300);
    begin
        Scroll.End_Current;
        Check (Scroll.Number_Of_Children = 3 and Scroll.Get_Kind = Scr.Both,
            "a scroll has its content and two scrollbars, both shown when needed");
        Check (Scroll.Get_Scrollbar_Size = 0,
            "a scroll's scrollbar size is 0, Fl::scrollbar_size (), to start with");
        Scroll.Scroll_To (20, 50);
        Check (Scroll.Get_Scroll_X = 20 and Scroll.Get_Scroll_Y = 50 and Content.Get_Y = -50,
            "Scroll_To moves the content");
        Scroll.Set_Kind (Scr.Vertical);
        Check (Scroll.Get_Kind = Scr.Vertical, "Set_Kind and Get_Kind agree");
        Check (Prb.Capture (Scroll) and Scroll.V_Bar.Is_Visible and not Scroll.H_Bar.Is_Visible,
            "a vertical scroll shows only its vertical scrollbar");
        Prb.Release;
        Scroll.Set_Kind (Scr.Horizontal);
        Check (Scroll.Get_Kind = Scr.Horizontal, "Set_Kind (Horizontal)");
        Scroll.Clear;
        Check (Scroll.Number_Of_Children = 2, "Clear removes the content, not the scrollbars");
        Check (Prb.Capture (Scroll), "and the scroll still draws");
        Prb.Release;
    end;

    --  Tabs
    declare
        Tabs   : Tbd.Tabbed_Group := Tbd.Forge.Create (Window, 300, 100, 200, 150);
        G1     : Grp.Group := Grp.Forge.Create (Tabs, 300, 125, 200, 125, "One");
        G2     : Grp.Group := Grp.Forge.Create (Tabs, 300, 125, 200, 125, "Two");
    begin
        G1.End_Current;
        G2.End_Current;
        Tabs.End_Current;
        Check (Same (Tabs.Get_Visible, G1), "the first tab is shown to start with");
        Tabs.Set_Visible (G2);
        Check (Same (Tabs.Get_Visible, G2) and G2.Is_Visible and not G1.Is_Visible,
            "Set_Visible shows another, hiding the first");
        Tabs.Get_Client_Area (0, L, T, R, B);
        Check (L = 300 and T > 100 and R = 200 and T + B = 250,
            "Get_Client_Area is below the tabs");
        Tabs.Set_Tab_Alignment (Align_Left);
        Check (Tabs.Get_Tab_Alignment = Align_Left, "Set_Tab_Alignment");
    end;

    --  A wizard
    declare
        Wizard     : Wiz.Wizard := Wiz.Forge.Create (Window, 300, 300, 100, 100);
        W1         : Bxs.Box := Bxs.Forge.Create (Wizard, 300, 300, 100, 100);
        W2, W3     : constant Bxs.Box := Bxs.Forge.Create (Wizard, 300, 300, 100, 100);
    begin
        Wizard.End_Current;
        Check (Same (Wizard.Get_Visible, W1), "a wizard shows its first page");
        Wizard.Next;
        Wizard.Next;
        Wizard.Next;
        Check (Same (Wizard.Get_Visible, W3), "Next goes on to the last, and stays there");
        Wizard.Prev;
        Check (Same (Wizard.Get_Visible, W2), "Prev goes back");
        Wizard.Set_Visible (W1);
        Check (Same (Wizard.Get_Visible, W1) and W1.Is_Visible and not W2.Is_Visible,
            "Set_Visible");
    end;

    --  A tile
    declare
        Tile  : Til.Tiled_Group := Til.Forge.Create (Window, 0, 450, 300, 100);
        Left  : constant Bxs.Box := Bxs.Forge.Create (Tile, 0, 450, 150, 100);
        Right : constant Bxs.Box := Bxs.Forge.Create (Tile, 150, 450, 150, 100);
    begin
        Tile.End_Current;
        Tile.Position (150, 450, 100, 450);
        Check (At_Place (Left, 0, 450, 100, 100) and At_Place (Right, 100, 450, 200, 100),
            "Position moves the border, resizing both sides");
        Tile.Set_Size_Range (Left, 80, 50);
        Tile.Position (100, 450, 20, 450);
        Check (Left.Get_W = 80, "a size range set after a move stops the next one");
    end;

    --  A group with members FLTK made: a spinner
    declare
        Spinner : Spn.Spinner := Spn.Forge.Create (Window, 450, 450, 100, 25);
    begin
        Spinner.Clear;
        Check (Prb.Capture (Spinner), "Clear leaves a spinner's own parts, and it draws");
        Prb.Release;
    end;

    Window.End_Current;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Layout;
