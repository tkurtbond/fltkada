

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/table-with-right-column-stretch-fit.cxx: a
--  table whose right column always stretches to fill the table's width.
--
--  Draw_Cell gets 1-based rows and columns, so the cells print Row - 1 to
--  match the 0-based numbers the original shows.  The original reads the
--  protected tox and tow members directly; here they come from
--  Bounding_Region for the column headers, which FLTK fills in from those
--  same two members.


with

    FLTK.Draw,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Tables,
    FLTK.Widgets.Groups.Windows.Double;


function Table_With_Right_Column_Stretch_Fit
    return Integer
is


    package FD  renames FLTK.Draw;
    package Btn renames FLTK.Widgets.Buttons;
    package Tbl renames FLTK.Widgets.Groups.Tables;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;


    function Image
           (N : in Integer)
        return String
    is
        S : constant String := Integer'Image (N);
    begin
        return S (S'First + 1 .. S'Last);
    end Image;


    --  Derive a type from Table
    type My_Table is new Tbl.Table with null record;

    overriding procedure Draw_Cell
           (This        : in out My_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0);

    --  Handle window resizing
    overriding procedure Resize
           (This       : in out My_Table;
            X, Y, W, H : in     Integer);


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
        FD.Draw_Text (X, Y, W, H, S, FLTK.Align_Left);
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
        FD.Draw_Text (X, Y, W, H, S, FLTK.Align_Left);
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
            FD.Set_Font (FLTK.Helvetica, 14);
        when Tbl.Column_Header =>
            --  Draw column headers
            case Column is
            when 1 => Draw_Header (This, " #Id", X, Y, W, H);
            when 2 => Draw_Header (This, " Date / Time", X, Y, W, H);
            when others => null;
            end case;
        when Tbl.Row_Header =>
            --  Draw row headers
            null;
        when Tbl.Within_Cell =>
            --  Draw data in cells
            case Column is
            when 1 => Draw_Data (This, " #" & Image (Row - 1), X, Y, W, H);
            when 2 => Draw_Data (This, " 2017-01-02 / 09:20:25." & Image (Row - 1), X, Y, W, H);
            when others => null;
            end case;
        when others =>
            null;
        end case;
    end Draw_Cell;


    --  Fix the right column's size to precisely match width of window
    procedure Fix_Column_Size
           (This : in out My_Table)
    is
        X, Y, W, H         : Integer;
        TOX, TOY, TOW, TOH : Integer;
    begin
        if This.Get_Rows = 0 then
            return;   --  early exit if no rows to work with
        end if;
        --  get xywh of right column cell in first row
        This.Cell_Dimensions (Tbl.Within_Cell, 1, 2, X, Y, W, H);
        --  the table's outer x position and width
        This.Bounding_Region (Tbl.Column_Header, TOX, TOY, TOW, TOH);
        declare
            --  we just need X pos and width. Compute offset from table's outer size
            Off  : constant Integer := (X + W) - (TOX + TOW);
            --  save old col width
            Oldw : constant Integer := This.Get_Column_Width (2);
        begin
            --  set new column width based on offset for perfect fit
            This.Set_Column_Width (2, Oldw - Off);
        end;
    end Fix_Column_Size;


    overriding procedure Resize
           (This       : in out My_Table;
            X, Y, W, H : in     Integer) is
    begin
        Tbl.Table (This).Resize (X, Y, W, H);
        Fix_Column_Size (This);   --  after letting window resize, fix our right most column
    end Resize;


    type Table_Access is access My_Table;

    The_Table : Table_Access;


    --  Add more rows
    procedure More_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        The_Table.Set_Rows (The_Table.Get_Rows + 1);
        Fix_Column_Size (The_Table.all);
    end More_CB;


    --  Remove rows
    procedure Less_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        if The_Table.Get_Rows > 0 then
            The_Table.Set_Rows (The_Table.Get_Rows - 1);
        end if;
        Fix_Column_Size (The_Table.all);
    end Less_CB;


    Win_W : constant := 500;

    The_Window : DW.Double_Window :=
        DW.Forge.Create (Win_W, 400, "Table With Right Column Stretch Fit");


begin


    The_Table := new My_Table'
        (Tbl.Forge.Create (The_Window, 10, 10, Win_W - 20, 340) with null record);
    --  Rows
    The_Table.Set_Rows (10);                  --  how many rows
    The_Table.Set_Row_Headers (False);        --  disable row headers (along left)
    The_Table.Set_All_Rows_Height (20);       --  default height of rows
    The_Table.Set_Row_Resize (False);         --  disable interactive row resizing
    --  Cols
    The_Table.Set_Columns (2);                --  how many columns
    The_Table.Set_Column_Headers (True);      --  enable column headers (along top)
    The_Table.Set_Column_Width (1, 50);       --  fixed width for left column
    --  fixed width for right column (changed later by Fix_Column_Size..)
    The_Table.Set_Column_Width (2, 300);
    The_Table.Set_Column_Resize (False);      --  disable interactive column resizing
    The_Table.End_Current;                    --  end the Fl_Table group
    Fix_Column_Size (The_Table.all);          --  apply our auto-column-sizing behavior

    declare
        More : Btn.Button := Btn.Forge.Create (The_Window, 10, 360, 100, 25, "+ Row");
        Less : Btn.Button := Btn.Forge.Create (The_Window, 220, 360, 100, 25, "- Row");
    begin
        More.Set_Callback (More_CB'Unrestricted_Access);
        Less.Set_Callback (Less_CB'Unrestricted_Access);

        The_Window.End_Current;
        The_Window.Set_Resizable (The_Table.all);
        The_Window.Show_With_Args;
        return FLTK.Run;
    end;


end Table_With_Right_Column_Stretch_Fit;
