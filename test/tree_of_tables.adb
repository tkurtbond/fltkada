

--  Programmed by T. Kurt Bond and Claude Sonnet 5
--  Released into the public domain


--  Ada port of FLTK's own examples/tree-of-tables.cxx: six Tables, one
--  per math operation, each embedded as a tree item's widget. This is
--  the example test/tree_table1.adb's own table-embedding demo followed
--  -- this is a more direct port of the original, without tree_table1's
--  other restructuring/icon material.
--
--  The original formats cell text with printf's "%.2f" (fixed) or "%g"
--  (compact/scientific) depending on the operation; Ada's Text_IO has
--  no direct "%g" equivalent, so this uses fixed 2-decimal formatting
--  throughout, including for Exponent -- a purely cosmetic difference.


with

    Ada.Float_Text_IO,
    Ada.Numerics,
    Ada.Numerics.Elementary_Functions,
    FLTK.Draw,
    FLTK.Tree_Items,
    FLTK.Widgets.Groups.Tables,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows;

use type

    FLTK.Tree_Items.Item_Draw_Mode,
    FLTK.Widgets.Groups.Tables.Table_Context;


function Tree_Of_Tables
    return Integer
is


    package EF  renames Ada.Numerics.Elementary_Functions;
    package FIO renames Ada.Float_Text_IO;
    package FD  renames FLTK.Draw;
    package TI  renames FLTK.Tree_Items;
    package Tbl renames FLTK.Widgets.Groups.Tables;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package Win renames FLTK.Widgets.Groups.Windows;


    The_Window : Win.Window := Win.Forge.Create (700, 400, "Tree of tables");

    type Mode_Kind is (Addition, Subtract, Multiply, Divide, Exponent, Sin_Cos);

    Table_W : constant := 500;
    Table_H : constant := 156;


    function Trim_Int
           (N : in Integer)
        return String
    is
        S : constant String := Integer'Image (N);
    begin
        if N < 0 then
            return S;
        else
            return S (2 .. S'Last);
        end if;
    end Trim_Int;


    function Fmt2
           (F : in Float)
        return String
    is
        Buf : String (1 .. 24);
    begin
        FIO.Put (Buf, F, Aft => 2, Exp => 0);
        for I in Buf'Range loop
            if Buf (I) /= ' ' then
                return Buf (I .. Buf'Last);
            end if;
        end loop;
        return Buf;
    end Fmt2;


    function Cell_Text
           (M           : in Mode_Kind;
            Row, Column : in Natural)
        return String
    is
    begin
        case M is

        when Addition =>
            return Trim_Int (Row + Column);

        when Subtract =>
            return Trim_Int (Row - Column);

        when Multiply =>
            return Trim_Int (Row * Column);

        when Divide =>
            if Column = 0 then
                return "N/A";
            else
                return Fmt2 (Float (Row) / Float (Column));
            end if;

        when Exponent =>
            return Fmt2 (Float (Row) ** Column);

        when Sin_Cos =>
            return Fmt2
               (EF.Sin (Float (Row) / 10.0 * Ada.Numerics.Pi)
                * EF.Cos (Float (Column) / 10.0 * Ada.Numerics.Pi));

        end case;
    end Cell_Text;


    --  The overriding Draw_Cell below must immediately follow Math_Table's
    --  declaration (no other declarations in between) -- GNAT enforces
    --  this for tagged type extensions declared inside a subprogram body,
    --  which is why the helpers it calls are declared above instead.
    type Math_Table is new Tbl.Table with record
        Mode : Mode_Kind;
    end record;


    overriding procedure Draw_Cell
           (This        : in out Math_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0)
    is
    begin
        case Context is

        when Tbl.Start_Page =>
            FD.Set_Font (FLTK.Helvetica, 10);

        when Tbl.Row_Header | Tbl.Column_Header =>
            declare
                --  Table_Draw_Cell_Hook (fltk-widgets-groups-tables.adb)
                --  hands these two contexts 1-based Row/Column, unlike
                --  real FLTK's draw_cell(), which is 0-based throughout
                --  -- "- 1" below recovers the original's 0-based Val.
                Val  : constant Natural := (if Context = Tbl.Row_Header then Row else Column) - 1;
                Hue  : constant FLTK.Color :=
                   (if Context = Tbl.Row_Header
                    then This.Get_Row_Header_Color
                    else This.Get_Column_Header_Color);
                Text : constant String :=
                   (if This.Mode = Sin_Cos
                    then Fmt2 (Float (Val) / 10.0 * Ada.Numerics.Pi)
                    else Trim_Int (Val));
            begin
                FD.Push_Clip (X, Y, W, H);
                FD.Draw_Box (X, Y, W, H, FLTK.Thin_Up_Box, Hue);
                FD.Set_Color (FLTK.Black_Color);
                FD.Draw_Text (X, Y, W, H, Text, FLTK.Align_Center);
                FD.Pop_Clip;
            end;

        when Tbl.Within_Cell =>
            declare
                --  Is_Selected takes 1-based Positive row/column, which is
                --  exactly what the hook already hands Within_Cell -- no
                --  conversion needed here, unlike Cell_Text below, which
                --  wants the same 0-based values Val above does.
                Bg : constant FLTK.Color :=
                   (if This.Is_Selected (Row, Column)
                    then FLTK.Yellow_Color else FLTK.White_Color);
                Text : constant String := Cell_Text (This.Mode, Row - 1, Column - 1);
            begin
                FD.Push_Clip (X, Y, W, H);
                FD.Rect_Fill (X, Y, W, H, Bg);
                FD.Set_Color (FLTK.Grey0_Color);
                FD.Draw_Text (X, Y, W, H, Text, FLTK.Align_Center);
                FD.Rect (X, Y, W, H, This.Get_Background_Color);
                FD.Pop_Clip;
            end;

        when others =>
            null;

        end case;
    end Draw_Cell;


    type Table_Access is access all Math_Table'Class;
    type Table_Access_Array is array (Positive range <>) of Table_Access;

    --  Fl_Tree_Item::draw() (Fl_Tree_Item.cxx) keeps a widget-carrying
    --  item's height in sync with the widget's own height via
    --  Fl_Tree_Item::calc_item_height(), which only ever grows H, never
    --  shrinks it, and then calls widget()->resize() with that H --
    --  *before* laying out the label next to it. Under Sway, this
    --  table's height (never its width -- confirmed against an
    --  instrumented build of the original tree-of-tables.cxx, which
    --  shows the same width growth this Ada port does, but never a
    --  height change) gets bumped up once when Sway's post-map tiling
    --  resize arrives, which also hides the vertical scrollbar once the
    --  (now oversized) table can show all its rows without one.
    --
    --  Undoing that from within Draw_Cell (as an earlier version of
    --  this file did) fixes the table itself immediately, but too late
    --  to fix *that same frame's* label position -- calc_item_height()
    --  already read the inflated height before Draw_Cell ever runs, so
    --  each label would sit wherever the oversized row put it until the
    --  next redraw recalculated it against the (by-then-corrected)
    --  height, a one-frame lag visible as a flash when interacting with
    --  the window live, easy to miss in a screenshot taken a moment
    --  later. Fixing_Tree's overriding Draw clamps every table's height
    --  *before* delegating to the real tree draw -- and so before
    --  Fl_Tree_Item::calc_item_height() ever reads a stale one -- which
    --  keeps that first affected frame correct too.
    type Fixing_Tree is new Trs.Tree with record
        Tables : Table_Access_Array (1 .. 6) := (others => null);
    end record;

    overriding procedure Draw
           (This : in out Fixing_Tree)
    is
    begin
        for T of This.Tables loop
            if T /= null and then T.Get_H /= Table_H then
                T.Resize (T.Get_X, T.Get_Y, T.Get_W, Table_H);
            end if;
        end loop;
        Trs.Tree (This).Draw;
    end Draw;


    procedure Configure_Table
           (This : in out Math_Table)
    is
    begin
        This.Set_Rows (11);
        This.Set_All_Rows_Height (20);
        This.Set_Row_Headers (True);
        This.Set_Columns (11);
        This.Set_All_Columns_Width (60);
        This.Set_Column_Headers (True);
        This.Set_Column_Resize (True);
    end Configure_Table;


    The_Tree : Fixing_Tree :=
        (Trs.Forge.Create (The_Window, 10, 10, 680, 380) with Tables => (others => null));

    Table_Add  : aliased Math_Table :=
        (Tbl.Forge.Create (The_Tree, 0, 0, Table_W, Table_H) with Mode => Addition);
    Table_Sub  : aliased Math_Table :=
        (Tbl.Forge.Create (The_Tree, 0, 0, Table_W, Table_H) with Mode => Subtract);
    Table_Mul  : aliased Math_Table :=
        (Tbl.Forge.Create (The_Tree, 0, 0, Table_W, Table_H) with Mode => Multiply);
    Table_Div  : aliased Math_Table :=
        (Tbl.Forge.Create (The_Tree, 0, 0, Table_W, Table_H) with Mode => Divide);
    Table_Exp  : aliased Math_Table :=
        (Tbl.Forge.Create (The_Tree, 0, 0, Table_W, Table_H) with Mode => Exponent);
    Table_Trig : aliased Math_Table :=
        (Tbl.Forge.Create (The_Tree, 0, 0, Table_W, Table_H) with Mode => Sin_Cos);


begin


    The_Tree.Set_Root_Label ("Math Tables");
    The_Tree.Set_Item_Label_Font (FLTK.Courier);
    The_Tree.Set_Line_Spacing (4);
    The_Tree.Set_Item_Draw_Mode (TI.Draw_Label_And_Widget + TI.Draw_Height_From_Widget);
    The_Tree.Set_Select_Mode (TI.No_Selection);
    The_Tree.Set_Widget_Margin_Left (12);
    The_Tree.Set_Connector_Style (TI.Dotted_Connector);

    Configure_Table (Table_Add);
    Configure_Table (Table_Sub);
    Configure_Table (Table_Mul);
    Configure_Table (Table_Div);
    Configure_Table (Table_Exp);
    Configure_Table (Table_Trig);

    declare
        Item : TI.Tree_Item;
    begin
        Item := The_Tree.Add ("Arithmetic/Addition");
        TI.Set_Widget (Item, Table_Add);

        Item := The_Tree.Add ("Arithmetic/Subtract");
        TI.Set_Widget (Item, Table_Sub);

        Item := The_Tree.Add ("Arithmetic/Multiply");
        TI.Set_Widget (Item, Table_Mul);

        Item := The_Tree.Add ("Arithmetic/Divide  ");
        TI.Set_Widget (Item, Table_Div);

        Item := The_Tree.Add ("Misc/Exponent");
        TI.Set_Widget (Item, Table_Exp);

        Item := The_Tree.Add ("Misc/Sin*Cos ");
        TI.Set_Widget (Item, Table_Trig);
    end;

    The_Tree.Tables :=
       (Table_Add'Access, Table_Sub'Access, Table_Mul'Access,
        Table_Div'Access, Table_Exp'Access, Table_Trig'Access);

    The_Window.Set_Resizable (The_Window);

    The_Window.Show_With_Args;

    return FLTK.Run;


end Tree_Of_Tables;



