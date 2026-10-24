

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/table-simple.cxx: a simple table of
--  numbers with row and column headers.
--
--  Draw_Cell gets 1-based rows and columns, so the row headers print
--  Row - 1 to match the 0-based numbers the original shows.


with

    FLTK.Draw,
    FLTK.Widgets.Groups.Tables,
    FLTK.Widgets.Groups.Windows.Double;


function Table_Simple
    return Integer
is


    package FD  renames FLTK.Draw;
    package Tbl renames FLTK.Widgets.Groups.Tables;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;


    Max_Rows : constant := 30;
    Max_Cols : constant := 26;   --  A-Z

    type Data_Array is array (1 .. Max_Rows, 1 .. Max_Cols) of Integer;


    function Make_Data
        return Data_Array
    is
        Result : Data_Array;
    begin
        for R in Result'Range (1) loop
            for C in Result'Range (2) loop
                Result (R, C) := 1000 + ((R - 1) * 1000) + (C - 1);
            end loop;
        end loop;
        return Result;
    end Make_Data;


    function Image
           (N : in Integer)
        return String
    is
        S : constant String := Integer'Image (N);
    begin
        return S (S'First + 1 .. S'Last);
    end Image;


    --  "%03d:"
    function Row_Image
           (N : in Natural)
        return String
    is
        S : constant String := Image (N);
    begin
        if S'Length < 3 then
            return (1 .. 3 - S'Length => '0') & S & ":";
        else
            return S & ":";
        end if;
    end Row_Image;


    type My_Table is new Tbl.Table with record
        Data : Data_Array := Make_Data;
    end record;

    overriding procedure Draw_Cell
           (This        : in out My_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0);


    --  Draw the row/col headings
    --  Make this a dark thin upbox with the text inside.
    procedure Draw_Header
           (This       : in My_Table;
            S          : in String;
            X, Y, W, H : in Integer) is
    begin
        FD.Push_Clip (X, Y, W, H);
        FD.Draw_Box (X, Y, W, H, FLTK.Thin_Up_Box, This.Get_Row_Header_Color);
        FD.Set_Color (FLTK.Black_Color);
        FD.Draw_Text (X, Y, W, H, S, FLTK.Align_Center);
        FD.Pop_Clip;
    end Draw_Header;


    --  Draw the cell data
    --  Dark gray text on white background with subtle border
    procedure Draw_Data
           (This       : in My_Table;
            S          : in String;
            X, Y, W, H : in Integer) is
    begin
        FD.Push_Clip (X, Y, W, H);
        --  Draw cell bg
        FD.Set_Color (FLTK.White_Color);
        FD.Rect_Fill (X, Y, W, H);
        --  Draw cell data
        FD.Set_Color (FLTK.Grey0_Color);
        FD.Draw_Text (X, Y, W, H, S, FLTK.Align_Center);
        --  Draw box border
        FD.Set_Color (This.Get_Background_Color);
        FD.Rect (X, Y, W, H);
        FD.Pop_Clip;
    end Draw_Data;


    --  Handle drawing table's cells
    --  Fl_Table calls this function to draw each visible cell in the table.
    --  It's up to us to use FLTK's drawing functions to draw the cells the way we want.
    overriding procedure Draw_Cell
           (This        : in out My_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0) is
    begin
        case Context is
        when Tbl.Start_Page =>
            --  before page is drawn..
            FD.Set_Font (FLTK.Helvetica, 16);
        when Tbl.Column_Header =>
            --  "A", "B", "C", etc.
            Draw_Header
               (This, (1 => Character'Val (Character'Pos ('A') + Column - 1)), X, Y, W, H);
        when Tbl.Row_Header =>
            --  "000:", "001:", etc
            Draw_Header (This, Row_Image (Row - 1), X, Y, W, H);
        when Tbl.Within_Cell =>
            Draw_Data (This, Image (This.Data (Row, Column)), X, Y, W, H);
        when others =>
            null;
        end case;
    end Draw_Cell;


    The_Window : DW.Double_Window := DW.Forge.Create (900, 400, "Table Simple");

    The_Table : My_Table :=
        (Tbl.Forge.Create (The_Window, 10, 10, 880, 380) with others => <>);


begin


    --  Rows
    The_Table.Set_Rows (Max_Rows);            --  how many rows
    The_Table.Set_Row_Headers (True);         --  enable row headers (along left)
    The_Table.Set_All_Rows_Height (20);       --  default height of rows
    The_Table.Set_Row_Resize (False);         --  disable row resizing
    --  Cols
    The_Table.Set_Columns (Max_Cols);         --  how many columns
    The_Table.Set_Column_Headers (True);      --  enable column headers (along top)
    The_Table.Set_All_Columns_Width (80);     --  default width of columns
    The_Table.Set_Column_Resize (True);       --  enable column resizing
    The_Table.End_Current;                    --  end the Fl_Table group

    The_Window.End_Current;
    The_Window.Set_Resizable (The_Table);
    The_Window.Show_With_Args;
    return FLTK.Run;


end Table_Simple;
