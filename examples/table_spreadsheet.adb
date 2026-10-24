

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/table-spreadsheet.cxx: a simple
--  interactive spreadsheet that moves a single Integer_Input around over
--  whichever cell is being edited, with row, column and grand totals.
--
--  Table rows and columns are 1-based here, so the values array is too,
--  and the last row and column (the totals) are Get_Rows and Get_Columns.
--  The original's row_edit/col_edit of 0 is 1 here for the same reason.
--  FLTK's FL_WHEN_NOT_CHANGED is the binding's When_Interact flag.


with

    FLTK.Draw,
    FLTK.Events,
    FLTK.Widgets.Groups.Tables,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text.Whole_Number,
    GNAT.OS_Lib;

use type

    FLTK.Callback_Flag,
    FLTK.Event_Kind,
    FLTK.Keypress;


function Table_Spreadsheet
    return Integer
is


    package FD  renames FLTK.Draw;
    package Tbl renames FLTK.Widgets.Groups.Tables;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;
    package WN  renames FLTK.Widgets.Inputs.Text.Whole_Number;


    Max_Cols : constant := 10;
    Max_Rows : constant := 10;


    function Image
           (N : in Integer)
        return String
    is
        S : constant String := Integer'Image (N);
    begin
        return (if N < 0 then S else S (S'First + 1 .. S'Last));
    end Image;


    --  Like C's atoi: an optional sign then as many digits as there are
    function Atoi
           (S : in String)
        return Integer
    is
        Result   : Integer := 0;
        Negative : Boolean := False;
        Index    : Positive := S'First;
    begin
        if Index <= S'Last and then S (Index) in '+' | '-' then
            Negative := S (Index) = '-';
            Index := Index + 1;
        end if;
        while Index <= S'Last and then S (Index) in '0' .. '9' loop
            Result := Result * 10 + (Character'Pos (S (Index)) - Character'Pos ('0'));
            Index := Index + 1;
        end loop;
        return (if Negative then -Result else Result);
    end Atoi;


    type Input_Access is access WN.Integer_Input;

    type Value_Array is array (1 .. Max_Rows, 1 .. Max_Cols) of Integer;

    type Spreadsheet is new Tbl.Table with record
        Input    : Input_Access;   --  single instance of Integer_Input widget
        Values   : Value_Array;    --  array of data for cells
        Row_Edit : Positive;       --  row/col being modified
        Col_Edit : Positive;
    end record;

    overriding procedure Draw_Cell
           (This        : in out Spreadsheet;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0);


    type Spreadsheet_Access is access Spreadsheet;

    --  The callbacks below only get the widget, so they find the
    --  spreadsheet through this instead of the original's user data pointer
    The_Table : Spreadsheet_Access;


    --  Apply value from input widget to values[row][col] array and hide (done editing)
    procedure Set_Value_Hide
           (This : in out Spreadsheet) is
    begin
        This.Values (This.Row_Edit, This.Col_Edit) := Atoi (This.Input.Get_Value);
        This.Input.Hide;
        --  XXX: if we don't do this, cursor can disappear!
        This.Nearest_Window.Set_Cursor (FLTK.Default_Mouse);
    end Set_Value_Hide;


    --  Start editing a new cell: move the Integer_Input widget to specified row/column
    --  Preload the widget with the cell's current value,
    --  and make the widget 'appear' at the cell's location.
    procedure Start_Editing
           (This : in out Spreadsheet;
            R, C : in     Positive)
    is
        X, Y, W, H : Integer;
    begin
        This.Row_Edit := R;                          --  Now editing this row/col
        This.Col_Edit := C;
        This.Set_Selection (R, C, R, C);             --  Clear any previous multicell selection
        This.Cell_Dimensions (Tbl.Within_Cell, R, C, X, Y, W, H);   --  Find X/Y/W/H of cell
        This.Input.Resize (X, Y, W, H);              --  Move input widget there
        declare
            --  Load input widget with cell's current value
            S      : constant String := Image (This.Values (R, C));
            Ignore : Boolean;
        begin
            This.Input.Set_Value (S);
            This.Input.Set_Position_Mark (0, S'Length);   --  Select entire input field
            This.Input.Show;   --  Show the input widget, now that we've positioned it
            Ignore := This.Input.Take_Focus;   --  Put keyboard focus into the input widget
        end;
    end Start_Editing;


    --  Tell the input widget it's done editing, and to 'hide'
    procedure Done_Editing
           (This : in out Spreadsheet) is
    begin
        if This.Input.Is_Visible then   --  input widget visible, ie. edit in progress?
            Set_Value_Hide (This);      --  Transfer its current contents to cell and hide
            This.Row_Edit := 1;         --  Disable these until needed again
            This.Col_Edit := 1;
        end if;
    end Done_Editing;


    --  Return the sum of all rows in this column
    function Sum_Rows
           (This : in Spreadsheet;
            C    : in Positive)
        return Integer
    is
        Sum : Integer := 0;
    begin
        for R in 1 .. This.Get_Rows - 1 loop   --  -1: don't include cell data in 'totals' column
            Sum := Sum + This.Values (R, C);
        end loop;
        return Sum;
    end Sum_Rows;


    --  Return the sum of all cols in this row
    function Sum_Cols
           (This : in Spreadsheet;
            R    : in Positive)
        return Integer
    is
        Sum : Integer := 0;
    begin
        for C in 1 .. This.Get_Columns - 1 loop   --  -1: don't include cell data in 'totals' column
            Sum := Sum + This.Values (R, C);
        end loop;
        return Sum;
    end Sum_Cols;


    --  Return the sum of all cells in table
    function Sum_All
           (This : in Spreadsheet)
        return Integer
    is
        Sum : Integer := 0;
    begin
        --  -1: don't include cell data in 'totals' column
        for C in 1 .. This.Get_Columns - 1 loop
            for R in 1 .. This.Get_Rows - 1 loop     --  -1: ""
                Sum := Sum + This.Values (R, C);
            end loop;
        end loop;
        return Sum;
    end Sum_All;


    --  Handle drawing all cells in table
    overriding procedure Draw_Cell
           (This        : in out Spreadsheet;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0) is
    begin
        case Context is
        when Tbl.Start_Page =>                    --  table about to redraw
            null;

        when Tbl.Column_Header =>                 --  table wants us to draw a column heading
            FD.Set_Font (FLTK.Helvetica_Bold, 14);   --  set font for heading to bold
            FD.Push_Clip (X, Y, W, H);               --  clip region for text
            FD.Draw_Box (X, Y, W, H, FLTK.Thin_Up_Box, This.Get_Column_Header_Color);
            FD.Set_Color (FLTK.Black_Color);
            if Column = This.Get_Columns then        --  Last column? show 'TOTAL'
                FD.Draw_Text (X, Y, W, H, "TOTAL", FLTK.Align_Center);
            else                                     --  Not last column? show column letter
                FD.Draw_Text
                   (X, Y, W, H,
                    (1 => Character'Val (Character'Pos ('A') + Column - 1)),
                    FLTK.Align_Center);
            end if;
            FD.Pop_Clip;

        when Tbl.Row_Header =>                    --  table wants us to draw a row heading
            FD.Set_Font (FLTK.Helvetica_Bold, 14);   --  set font for row heading to bold
            FD.Push_Clip (X, Y, W, H);
            FD.Draw_Box (X, Y, W, H, FLTK.Thin_Up_Box, This.Get_Row_Header_Color);
            FD.Set_Color (FLTK.Black_Color);
            if Row = This.Get_Rows then              --  Last row? Show 'Total'
                FD.Draw_Text (X, Y, W, H, "TOTAL", FLTK.Align_Center);
            else                                     --  Not last row? show row#
                FD.Draw_Text (X, Y, W, H, Image (Row), FLTK.Align_Center);
            end if;
            FD.Pop_Clip;

        when Tbl.Within_Cell =>                   --  table wants us to draw a cell
            if Row = This.Row_Edit and Column = This.Col_Edit and This.Input.Is_Visible then
                return;   --  dont draw for cell with input widget over it
            end if;
            --  Background
            if Column < This.Get_Columns and Row < This.Get_Rows then
                FD.Draw_Box
                   (X, Y, W, H, FLTK.Thin_Up_Box,
                    (if This.Is_Selected (Row, Column)
                     then FLTK.Yellow_Color
                     else FLTK.White_Color));
            else
                FD.Draw_Box
                   (X, Y, W, H, FLTK.Thin_Up_Box,
                    (if This.Is_Selected (Row, Column)
                     then FLTK.Color (16#DDFFDD00#)
                     else FLTK.Color (16#BBDDBB00#)));   --  money green
            end if;
            --  Text
            FD.Push_Clip (X + 3, Y + 3, W - 6, H - 6);
            FD.Set_Color (FLTK.Black_Color);
            if Column = This.Get_Columns or Row = This.Get_Rows then
                --  Last row or col? Show total
                FD.Set_Font (FLTK.Helvetica_Bold, 14);   --  ..in bold font
                declare
                    S : constant String :=
                        (if Column = This.Get_Columns and Row = This.Get_Rows
                         then Image (Sum_All (This))        --  Last row+col? Total all cells
                         elsif Column = This.Get_Columns
                         then Image (Sum_Cols (This, Row))  --  Row subtotal
                         else Image (Sum_Rows (This, Column)));   --  Col subtotal
                begin
                    FD.Draw_Text (X + 3, Y + 3, W - 6, H - 6, S, FLTK.Align_Right);
                end;
            else
                --  Not last row or col? Show cell contents
                FD.Set_Font (FLTK.Helvetica, 14);   --  ..in regular font
                FD.Draw_Text
                   (X + 3, Y + 3, W - 6, H - 6, Image (This.Values (Row, Column)),
                    FLTK.Align_Right);
            end if;
            FD.Pop_Clip;

        when Tbl.Row_Column_Resize =>             --  table resizing rows or columns
            if This.Input.Is_Visible then
                declare
                    CX, CY, CW, CH : Integer;
                begin
                    This.Cell_Dimensions
                       (Tbl.Dead_Zone, This.Row_Edit, This.Col_Edit, CX, CY, CW, CH);
                    This.Input.Resize (CX, CY, CW, CH);
                    This.Reset_Sizes;
                end;
            end if;

        when others =>
            null;
        end case;
    end Draw_Cell;


    --  A table event occurred on cell R, C
    procedure Cell_Event
           (This : in out Spreadsheet;
            R, C : in     Positive)
    is
        Ignore : FLTK.Event_Outcome;
    begin
        case FLTK.Events.Last is              --  see what FLTK event caused it
        when FLTK.Push =>                     --  mouse click?
            Done_Editing (This);              --  finish editing previous
            if R /= This.Get_Rows and C /= This.Get_Columns then
                --  only edit cells not in total's columns
                Start_Editing (This, R, C);   --  start new edit
            end if;

        when FLTK.Keydown =>                  --  key press in table?
            if FLTK.Events.Last_Key = FLTK.Escape_Key then
                GNAT.OS_Lib.OS_Exit (0);      --  ESC closes app
            end if;
            Done_Editing (This);              --  finish any previous editing
            if C = This.Get_Columns or R = This.Get_Rows then
                return;                       --  no editing of totals column
            end if;
            declare
                Text : constant String := FLTK.Events.Text;
            begin
                if Text'Length > 0 then
                    case Text (Text'First) is
                    when '0' .. '9' | '+' | '-' =>
                        --  any of these should start editing new cell
                        Start_Editing (This, R, C);   --  start new edit
                        --  pass typed char to input
                        Ignore := This.Input.Handle (FLTK.Events.Last);
                    when ASCII.CR | ASCII.LF =>       --  let enter key edit the cell
                        Start_Editing (This, R, C);   --  start new edit
                    when others =>
                        null;
                    end case;
                end if;
            end;

        when others =>
            null;
        end case;
    end Cell_Event;


    --  Callback whenever someone clicks on different parts of the table
    procedure Event_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        This    : Spreadsheet renames Spreadsheet (Item);
        Context : constant Tbl.Table_Context := This.Callback_Context;
    begin
        case Context is
        when Tbl.Within_Cell =>                   --  A table event occurred on a cell
            Cell_Event (This, This.Callback_Row, This.Callback_Column);

        when Tbl.Dead_Zone | Tbl.Row_Header | Tbl.Column_Header =>
            --  A table event occurred on dead zone in table, or on row/column header
            Done_Editing (This);                  --  done editing, hide

        when others =>
            null;
        end case;
    end Event_Callback;


    --  input widget's callback
    procedure Input_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Set_Value_Hide (The_Table.all);
    end Input_CB;


    Win_W : constant := 862;
    Win_H : constant := 322;

    The_Window : DW.Double_Window := DW.Forge.Create (Win_W, Win_H, "Table Spreadsheet");


begin


    The_Table := new Spreadsheet'
        (Tbl.Forge.Create
            (The_Window, 10, 10, Win_W - 20, Win_H - 20)
         with Input    => null,
              Values   => (others => (others => 0)),
              Row_Edit => 1,
              Col_Edit => 1);

    --  What the original's Spreadsheet constructor does
    declare
        T : Spreadsheet renames The_Table.all;
    begin
        T.Set_Callback (Event_Callback'Unrestricted_Access);
        T.Set_When (FLTK.When_Interact + T.Get_When);
        --  Create input widget that we'll use whenever user clicks on a cell
        T.Begin_Current;
        T.Input := new WN.Integer_Input'(WN.Forge.Create (T.Get_W / 2, T.Get_H / 2, 0, 0));
        T.Input.Hide;                                   --  hide until needed
        T.Input.Set_Callback (Input_CB'Unrestricted_Access);
        --  callback triggered when user hits Enter
        T.Input.Set_When (FLTK.When_Enter_Key_Always);
        T.Input.Set_Maximum_Size (5);
        T.Input.Set_Background_Color (FLTK.Yellow_Color);   --  yellow to standout during editing
        for C in 1 .. Max_Cols loop
            for R in 1 .. Max_Rows loop
                T.Values (R, C) := (C - 1) + ((R - 1) * Max_Cols);   --  initialize cells
            end loop;
        end loop;
        T.End_Current;
        T.Row_Edit := 1;
        T.Col_Edit := 1;
        T.Set_Selection (1, 1, 1, 1);
    end;

    --  enable tab navigation of table cells (instead of fltk widgets)
    The_Table.Set_Tab_Mode (Tbl.Navigate_Cells);
    The_Table.Set_Tooltip
       ("Use keyboard to navigate cells:" & ASCII.LF &
        "Arrow keys or Tab/Shift-Tab");
    --  Table rows
    The_Table.Set_Row_Headers (True);
    The_Table.Set_Row_Header_Width (70);
    The_Table.Set_Row_Resize (True);
    The_Table.Set_Rows (Max_Rows + 1);               --  +1: leaves room for 'total row'
    The_Table.Set_All_Rows_Height (25);
    --  Table cols
    The_Table.Set_Column_Headers (True);
    The_Table.Set_Column_Header_Height (25);
    The_Table.Set_Column_Resize (True);
    The_Table.Set_Columns (Max_Cols + 1);            --  +1: leaves room for 'total column'
    The_Table.Set_All_Columns_Width (70);
    --  Show window
    The_Window.End_Current;
    The_Window.Set_Resizable (The_Table.all);
    The_Window.Show;
    return FLTK.Run;


end Table_Spreadsheet;
