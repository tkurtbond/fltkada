

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/tree-of-tables.cxx: six Tables, one per
--  math operation, each shown next to its tree item.
--
--  Draw_Cell is handed 1-based rows and columns for cells, and for the
--  header that is being numbered, so they are shifted back to 0-based
--  values for the arithmetic.  Fixed_Image and General_Image reproduce
--  printf's "%.2f" and "%g", rounding exact halves to even as C does.


with

    Ada.Numerics.Long_Elementary_Functions,
    Ada.Strings.Fixed,
    FLTK.Draw,
    FLTK.Tree_Items,
    FLTK.Widgets.Groups.Tables,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Tree_Items.Item_Draw_Mode,
    FLTK.Widgets.Groups.Tables.Table_Context;


function Tree_Of_Tables
    return Integer
is


    package LEF renames Ada.Numerics.Long_Elementary_Functions;
    package FD  renames FLTK.Draw;
    package TI  renames FLTK.Tree_Items;
    package Tbl renames FLTK.Widgets.Groups.Tables;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;


    PI : constant := 3.14159;


    function Image
           (Value : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Integer'Image (Value), Ada.Strings.Both);
    end Image;


    --  printf's "%.<Aft>f"
    function Fixed_Image
           (Value : in Long_Float;
            Aft   : in Natural)
        return String
    is
        Scaled : constant Long_Long_Integer := Long_Long_Integer
           (Long_Float'Unbiased_Rounding (abs Value * 10.0 ** Aft));
        Digits_Image : constant String :=
            Ada.Strings.Fixed.Trim (Long_Long_Integer'Image (Scaled), Ada.Strings.Left);
        Padded : constant String :=
            (if Digits_Image'Length <= Aft
             then (1 .. Aft + 1 - Digits_Image'Length => '0') & Digits_Image
             else Digits_Image);
        Sign : constant String := (if Long_Float'Copy_Sign (1.0, Value) < 0.0 then "-" else "");
    begin
        if Aft = 0 then
            return Sign & Padded;
        end if;
        return Sign & Padded (Padded'First .. Padded'Last - Aft) & "." &
            Padded (Padded'Last - Aft + 1 .. Padded'Last);
    end Fixed_Image;


    function Strip_Zeros
           (Text : in String)
        return String
    is
        Last : Natural := Text'Last;
    begin
        if Ada.Strings.Fixed.Index (Text, ".") = 0 then
            return Text;
        end if;
        while Text (Last) = '0' loop
            Last := Last - 1;
        end loop;
        if Text (Last) = '.' then
            Last := Last - 1;
        end if;
        return Text (Text'First .. Last);
    end Strip_Zeros;


    --  printf's "%g"
    function General_Image
           (Value : in Long_Float)
        return String
    is
        Precision : constant := 6;
        Exponent  : Integer;
        Mantissa  : Long_Float;
    begin
        if Value = 0.0 then
            return "0";
        end if;
        Exponent := Integer (Long_Float'Floor (LEF.Log (abs Value, 10.0)));
        if Long_Float'Unbiased_Rounding (abs Value / 10.0 ** (Exponent - Precision + 1))
            >= 10.0 ** Precision
        then
            Exponent := Exponent + 1;
        end if;
        if Exponent < -4 or Exponent >= Precision then
            Mantissa := Value / 10.0 ** Exponent;
            return Strip_Zeros (Fixed_Image (Mantissa, Precision - 1)) &
                (if Exponent < 0 then "e-" else "e+") &
                (if abs Exponent < 10 then "0" else "") & Image (abs Exponent);
        else
            return Strip_Zeros (Fixed_Image (Value, Precision - 1 - Exponent));
        end if;
    end General_Image;


    type Mode_Kind is (Addition, Subtract, Multiply, Divide, Exponent, Sin_Cos);


    type My_Table is new Tbl.Table with record
        Mode : Mode_Kind;
    end record;

    overriding procedure Resize
           (This       : in out My_Table;
            X, Y, W, H : in     Integer);

    --  Handle drawing table's cells
    --      Table calls this procedure to draw each visible cell in the table.
    --      It's up to us to use FLTK's drawing subprograms to draw the cells
    --      the way we want.
    overriding procedure Draw_Cell
           (This        : in out My_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0);


    function Create
           (Parent     : in out Trs.Tree'Class;
            X, Y, W, H : in     Integer;
            Mode       : in     Mode_Kind)
        return My_Table is
    begin
        return This : My_Table := (Tbl.Forge.Create (Parent, X, Y, W, H) with Mode => Mode) do
            This.Set_Rows (11);
            This.Set_All_Rows_Height (20);
            This.Set_Row_Headers (True);
            This.Set_Columns (11);
            This.Set_All_Columns_Width (60);
            This.Set_Column_Headers (True);
            This.Set_Column_Resize (True);   --  enable column resizing
        end return;
    end Create;


    overriding procedure Resize
           (This       : in out My_Table;
            X, Y, W, H : in     Integer)
    is
        pragma Unreferenced (H);
    begin
        --  don't exceed 700 in width, disallow changes in height
        Tbl.Table (This).Resize (X, Y, Integer'Min (W, 718), This.Get_H);
    end Resize;


    overriding procedure Draw_Cell
           (This        : in out My_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0) is
    begin
        case Context is
        when Tbl.Start_Page =>      --  before page is drawn..
            FD.Set_Font (FLTK.Helvetica, 10);   --  set the font for our drawing operations

        when Tbl.Column_Header | Tbl.Row_Header =>   --  Drawing column/row headers
            declare
                Val : constant Natural :=
                    (if Context = Tbl.Column_Header then Column else Row) - 1;
                Col : constant FLTK.Color :=
                    (if Context = Tbl.Column_Header
                     then This.Get_Column_Header_Color
                     else This.Get_Row_Header_Color);
                S : constant String :=
                    (if This.Mode = Sin_Cos
                     then Fixed_Image ((Long_Float (Val) / 10.0) * PI, 2)
                     else Image (Val));
            begin
                FD.Push_Clip (X, Y, W, H);
                FD.Draw_Box (X, Y, W, H, FLTK.Thin_Up_Box, Col);
                FD.Set_Color (FLTK.Black_Color);
                FD.Draw_Text (X, Y, W, H, S, FLTK.Align_Center);
                FD.Pop_Clip;
            end;

        when Tbl.Within_Cell =>     --  Draw data in cells
            declare
                R : constant Natural := Row - 1;
                C : constant Natural := Column - 1;
                Col : constant FLTK.Color :=
                    (if This.Is_Selected (Row, Column)
                     then FLTK.Yellow_Color
                     else FLTK.White_Color);
                S : constant String :=
                    (case This.Mode is
                     when Addition => Image (R + C),
                     when Subtract => Image (R - C),
                     when Multiply => Image (R * C),
                     when Divide =>
                        (if C = 0
                         then "N/A"
                         else Fixed_Image (Long_Float (Float (R) / Float (C)), 2)),
                     when Exponent => General_Image (Long_Float (Float (R) ** C)),
                     when Sin_Cos =>
                        Fixed_Image
                           (LEF.Sin ((Long_Float (R) / 10.0) * PI) *
                            LEF.Cos ((Long_Float (C) / 10.0) * PI), 2));
            begin
                FD.Push_Clip (X, Y, W, H);
                FD.Set_Color (Col);
                FD.Rect_Fill (X, Y, W, H);                           --  bg
                FD.Set_Color (FLTK.Grey0_Color);
                FD.Draw_Text (X, Y, W, H, S, FLTK.Align_Center);    --  text
                FD.Set_Color (This.Get_Background_Color);
                FD.Rect (X, Y, W, H);                                --  box
                FD.Pop_Clip;
            end;

        when others =>
            null;
        end case;
    end Draw_Cell;


    type Table_Access is access My_Table;

    Table : Table_Access;
    Item  : TI.Tree_Item;


begin


    declare
        Win : DW.Double_Window := DW.Forge.Create (700, 400, "Tree of tables");

        Win_W : constant Integer := Win.Get_W;
        Win_H : constant Integer := Win.Get_H;

        --  Create tree
        Tree : Trs.Tree := Trs.Forge.Create (Win, 10, 10, Win_W - 20, Win_H - 20);
    begin
        Tree.Set_Root_Label ("Math Tables");
        Tree.Set_Item_Label_Font (FLTK.Courier);   --  font to use for items
        Tree.Set_Line_Spacing (4);                 --  extra space between items
        Tree.Set_Item_Draw_Mode
           (Tree.Get_Item_Draw_Mode +
            TI.Draw_Label_And_Widget +      --  draw item with widget next to it
            TI.Draw_Height_From_Widget);    --  make item height follow table's height
        Tree.Set_Select_Mode (TI.No_Selection);
        Tree.Set_Widget_Margin_Left (12);          --  space between item and table
        Tree.Set_Connector_Style (TI.Dotted_Connector);

        --  Create tables, assign each a tree item
        Table := new My_Table'(Create (Tree, 0, 0, 500, 156, Addition));
        Item := Tree.Add ("Arithmetic/Addition");
        TI.Set_Widget (Item, Table.all);

        Table := new My_Table'(Create (Tree, 0, 0, 500, 156, Subtract));
        Item := Tree.Add ("Arithmetic/Subtract");
        TI.Set_Widget (Item, Table.all);

        Table := new My_Table'(Create (Tree, 0, 0, 500, 156, Multiply));
        Item := Tree.Add ("Arithmetic/Multiply");
        TI.Set_Widget (Item, Table.all);

        Table := new My_Table'(Create (Tree, 0, 0, 500, 156, Divide));
        Item := Tree.Add ("Arithmetic/Divide  ");
        TI.Set_Widget (Item, Table.all);

        Table := new My_Table'(Create (Tree, 0, 0, 500, 156, Exponent));
        Item := Tree.Add ("Misc/Exponent");
        TI.Set_Widget (Item, Table.all);

        Table := new My_Table'(Create (Tree, 0, 0, 500, 156, Sin_Cos));
        Item := Tree.Add ("Misc/Sin*Cos ");
        TI.Set_Widget (Item, Table.all);

        Win.End_Current;
        Win.Set_Resizable (Win);
        Win.Show_With_Args;
        return FLTK.Run;
    end;


end Tree_Of_Tables;
