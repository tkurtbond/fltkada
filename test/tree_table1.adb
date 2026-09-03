

--  Programmed by T. Kurt Bond and Claude Sonnet 5
--  Released into the public domain


--  Exercises the FLTK.Widgets.Groups.Trees / FLTK.Tree_Items binding:
--  building a tree from slash-separated paths (with parent items created
--  automatically), walking it depth-first, opening every branch, multi-
--  selecting items, reading back the current selection, embedding
--  another widget (here an FLTK.Widgets.Groups.Tables.Table) in place
--  of a tree item's label (the "Data" branch), restructuring items with
--  Insert/Move_Above/Swap_Children/Deparent/Reparent, and assigning a
--  per-item icon.


with

    Ada.Strings.Fixed,
    Ada.Text_IO,
    FLTK.Draw,
    FLTK.Images.Bitmaps,
    FLTK.Tree_Items,
    FLTK.Widgets,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Tables,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows;

use type

    FLTK.Tree_Items.Item_Draw_Mode,
    FLTK.Widgets.Groups.Tables.Table_Context;


function Tree_Table1
    return Integer
is


    package SF  renames Ada.Strings.Fixed;
    package TIO renames Ada.Text_IO;
    package FD  renames FLTK.Draw;
    package Bmp renames FLTK.Images.Bitmaps;
    package TI  renames FLTK.Tree_Items;
    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Tbl renames FLTK.Widgets.Groups.Tables;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package Win renames FLTK.Widgets.Groups.Windows;


    The_Window : Win.Window := Win.Forge.Create (620, 460, "Tree Test");

    The_Tree : Trs.Tree := Trs.Forge.Create (The_Window, 10, 10, 600, 330);


    --  A Table that fills its own cells in with "<row letter><column
    --  number>" labels, eg. row 0 reads A1, A2, A3, ...; row 1 reads
    --  B1, B2, B3, ...; and so on. Overriding Draw_Cell is how FLTK's
    --  own tree-of-tables.cxx example gives its tables content too
    --  (there, via draw_cell()) -- see FLTK.Widgets.Groups.Tables.
    type Labeled_Table is new Tbl.Table with null record;

    overriding procedure Draw_Cell
           (This        : in out Labeled_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0)
    is
    begin
        case Context is

        when Tbl.Start_Page =>
            FD.Set_Font (FLTK.Helvetica, 12);

        when Tbl.Row_Header | Tbl.Column_Header =>
            declare
                Number : constant String :=
                    Integer'Image ((if Context = Tbl.Row_Header then Row else Column) + 1);
            begin
                FD.Push_Clip (X, Y, W, H);
                FD.Draw_Box (X, Y, W, H, FLTK.Thin_Up_Box, FLTK.Background_Color);
                FD.Set_Color (FLTK.Black_Color);
                FD.Draw_Text (X, Y, W, H, Number (2 .. Number'Last), FLTK.Align_Center);
                FD.Pop_Clip;
            end;

        when Tbl.Within_Cell =>
            declare
                Row_Letter : constant Character := Character'Val (Character'Pos ('A') + Row);
                Number     : constant String := Integer'Image (Column + 1);
                Cell_Label : constant String := Row_Letter & Number (2 .. Number'Last);
            begin
                FD.Push_Clip (X, Y, W, H);
                FD.Draw_Box (X, Y, W, H, FLTK.Flat_Box, FLTK.White_Color);
                FD.Set_Color (FLTK.Black_Color);
                FD.Draw_Text (X, Y, W, H, Cell_Label, FLTK.Align_Center);
                FD.Pop_Clip;
            end;

        when others =>
            null;

        end case;
    end Draw_Cell;


    --  Constructing this with The_Tree as parent makes it a child
    --  widget of the tree, the same way tree->begin()/table = new
    --  MyTable(...)/tree->end() does in FLTK's own tree-of-tables.cxx
    --  example -- distinct from, and in addition to, the Tree_Item
    --  hierarchy that The_Tree.Add builds. Tree_Items.Set_Widget below
    --  is what actually places it into a specific item's row.
    Grid : Labeled_Table :=
       (Tbl.Forge.Create (The_Tree, 0, 0, 500, 100) with null record);

    --  A tiny 8x8 checkerboard, used as a per-item user icon below.
    Icon_Data : constant FLTK.Color_Component_Array (1 .. 8) :=
        (16#AA#, 16#55#, 16#AA#, 16#55#, 16#AA#, 16#55#, 16#AA#, 16#55#);
    Icon : Bmp.Bitmap := Bmp.Forge.Create (Icon_Data, 8, 8);

    Status : Bx.Box := Bx.Forge.Create (The_Window, 10, 350, 600, 25);

    Print_Button : Btn.Button :=
        Btn.Forge.Create (The_Window, 10, 385, 195, 30, "Print Tree");

    Select_Button : Btn.Button :=
        Btn.Forge.Create (The_Window, 215, 385, 195, 30, "Select All");


    procedure Print_Whole_Tree
           (Ignore : in out Wdg.Widget'Class)
    is
        Item : TI.Tree_Item := The_Tree.First;
    begin
        TIO.Put_Line ("--  Tree contents  --");
        while not TI.Is_Null (Item) loop
            TIO.Put_Line
               (SF."*" (TI.Depth (Item) * 4, ' ') & TI.Get_Label (Item)
                & (if TI.Has_Widget (Item) then "  [has an embedded widget]" else "")
                & (if TI.Has_User_Icon (Item) then "  [has a user icon]" else ""));
            Item := TI.Next (Item);
        end loop;
    end Print_Whole_Tree;


    procedure Select_Everything
           (Ignore : in out Wdg.Widget'Class)
    is
        Changed : constant Natural := The_Tree.Select_All;
    begin
        TIO.Put_Line (Integer'Image (Changed) & " item(s) newly selected");
    end Select_Everything;


    procedure Show_Selection
           (Ignore : in out Wdg.Widget'Class)
    is
        Chosen : constant TI.Tree_Item_Array := The_Tree.Selected_Items;
        Count_Image : constant String := Integer'Image (Chosen'Length);
    begin
        Status.Set_Label (Count_Image (2 .. Count_Image'Last) & " item(s) selected");
        TIO.Put ("Selected:");
        for Item of Chosen loop
            TIO.Put (' ' & TI.Get_Label (Item));
        end loop;
        TIO.New_Line;
    end Show_Selection;


    Ignore_Item : TI.Tree_Item;

    Fred_Item        : TI.Tree_Item;
    Bart_Item        : TI.Tree_Item;
    Homer_Item       : TI.Tree_Item;
    Wilma_Item       : TI.Tree_Item;
    Pebbles_Item     : TI.Tree_Item;
    Flintstones_Item : TI.Tree_Item;
    Simpsons_Item    : TI.Tree_Item;


    procedure Open_All
    is
        Item : TI.Tree_Item := The_Tree.First;
    begin
        while not TI.Is_Null (Item) loop
            if TI.Has_Children (Item) then
                The_Tree.Open (Item);
            end if;
            Item := TI.Next (Item);
        end loop;
    end Open_All;


begin


    Fred_Item    := The_Tree.Add ("Flintstones/Fred");
    Wilma_Item   := The_Tree.Add ("Flintstones/Wilma");
    Pebbles_Item := The_Tree.Add ("Flintstones/Pebbles");
    Homer_Item   := The_Tree.Add ("Simpsons/Homer");
    Ignore_Item  := The_Tree.Add ("Simpsons/Marge");
    Bart_Item    := The_Tree.Add ("Simpsons/Bart");
    Ignore_Item  := The_Tree.Add ("Simpsons/Lisa");

    Flintstones_Item := The_Tree.Find ("Flintstones");
    Simpsons_Item    := The_Tree.Find ("Simpsons");

    --  Insert: give Simpsons a new first child rather than appending.
    Ignore_Item := The_Tree.Insert (Simpsons_Item, "Maggie", 0);

    --  Move_Above: reorder Bart ahead of Homer.
    if not TI.Move_Above (Bart_Item, Homer_Item) then
        TIO.Put_Line ("Move_Above failed unexpectedly");
    end if;

    --  Swap_Children: swap two of Flintstones' immediate children.
    if not TI.Swap_Children (Flintstones_Item, Wilma_Item, Pebbles_Item) then
        TIO.Put_Line ("Swap_Children failed unexpectedly");
    end if;

    --  Deparent/Reparent: detach an item from one branch (leaving it
    --  parentless) and adopt it into another. Done on a throwaway
    --  single-child branch so the child index involved is unambiguous.
    Ignore_Item := The_Tree.Add ("Temp/Orphan");
    declare
        Temp_Item   : constant TI.Tree_Item := The_Tree.Find ("Temp");
        Orphan_Item : constant TI.Tree_Item := TI.Deparent (Temp_Item, 1);
    begin
        if TI.Is_Null (Orphan_Item)
            or else not TI.Reparent (Flintstones_Item, Orphan_Item, 0)
        then
            TIO.Put_Line ("Deparent/Reparent failed unexpectedly");
        end if;
        The_Tree.Remove (Temp_Item);
    end;

    --  Per-item icon.
    TI.Set_User_Icon (Fred_Item, Icon);

    --  A tree item whose label area is replaced by a live Table widget.
    Grid.Set_Rows (4);
    Grid.Set_All_Rows_Height (20);
    Grid.Set_Row_Headers (True);
    Grid.Set_Columns (5);
    Grid.Set_All_Columns_Width (60);
    Grid.Set_Column_Headers (True);

    declare
        Grid_Item : constant TI.Tree_Item := The_Tree.Add ("Data/Grid");
    begin
        TI.Set_Widget (Grid_Item, Grid);
    end;

    --  Show the label next to the widget rather than hiding it, and let
    --  the table's own height (not the item's default single-line
    --  height) control the row -- matches tree-of-tables.cxx's
    --  FL_TREE_ITEM_DRAW_LABEL_AND_WIDGET | FL_TREE_ITEM_HEIGHT_FROM_WIDGET.
    The_Tree.Set_Item_Draw_Mode (TI.Draw_Label_And_Widget + TI.Draw_Height_From_Widget);
    The_Tree.Set_Widget_Margin_Left (12);

    The_Tree.Set_Select_Mode (TI.Multi_Selection);
    The_Tree.Set_When (FLTK.When_Changed);
    The_Tree.Set_Callback (Show_Selection'Unrestricted_Access);

    Open_All;

    Status.Set_Box (FLTK.Down_Box);
    Status.Set_Label ("0 item(s) selected");

    Print_Button.Set_Callback (Print_Whole_Tree'Unrestricted_Access);
    Select_Button.Set_Callback (Select_Everything'Unrestricted_Access);

    Print_Whole_Tree (The_Tree);

    The_Window.Show_With_Args;

    return FLTK.Run;


end Tree_Table1;


