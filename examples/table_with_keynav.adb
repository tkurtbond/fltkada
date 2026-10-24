

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/table-with-keynav.cxx: a times table
--  with keyboard navigation and mouse selection, showing the sum of the
--  selected cells.
--
--  Draw_Cell gets 1-based rows and columns, so the values shown use
--  Row - 1 and Column - 1 to match the 0-based numbers the original shows.


with

    FLTK.Draw,
    FLTK.Events,
    FLTK.Static,
    FLTK.Widgets.Buttons.Toggle,
    FLTK.Widgets.Groups.Tables.Row,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text.Outputs,
    GNAT.OS_Lib;

use type

    FLTK.Event_Kind,
    FLTK.Keypress;


function Table_With_Keynav
    return Integer
is


    package FD  renames FLTK.Draw;
    package Tog renames FLTK.Widgets.Buttons.Toggle;
    package Tbl renames FLTK.Widgets.Groups.Tables;
    package TR  renames FLTK.Widgets.Groups.Tables.Row;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;
    package Op  renames FLTK.Widgets.Inputs.Text.Outputs;

    use type Tbl.Table_Context;


    function Image
           (N : in Integer)
        return String
    is
        S : constant String := Integer'Image (N);
    begin
        return S (S'First + 1 .. S'Last);
    end Image;


    type My_Table is new TR.Row_Table with null record;

    --  Handle drawing all cells in table
    overriding procedure Draw_Cell
           (This        : in out My_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0);

    --  Keyboard and mouse events
    overriding function Handle
           (This  : in out My_Table;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;


    --  GLOBALS
    type Toggle_Access is access Tog.Toggle_Button;
    type Table_Access is access My_Table;
    type Output_Access is access Op.Output;

    G_Rowselect : Toggle_Access;   --  toggle to enable row selection
    G_Table     : Table_Access;    --  table widget
    G_Sum       : Output_Access;   --  displays sum of user's selection


    function Is_Selected_Cell
           (This        : in My_Table;
            Row, Column : in Positive)
        return Boolean is
    begin
        return (if G_Rowselect.Is_On
                then This.Is_Row_Selected (Row)
                else This.Is_Selected (Row, Column));
    end Is_Selected_Cell;


    overriding procedure Draw_Cell
           (This        : in out My_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0) is
    begin
        case Context is
        when Tbl.Column_Header | Tbl.Row_Header =>
            FD.Set_Font (FLTK.Helvetica_Bold, 14);
            FD.Push_Clip (X, Y, W, H);
            declare
                C : constant FLTK.Color :=
                    (if Context = Tbl.Column_Header
                     then This.Get_Column_Header_Color
                     else This.Get_Row_Header_Color);
            begin
                FD.Draw_Box (X, Y, W, H, FLTK.Thin_Up_Box, C);
                FD.Set_Color (FLTK.Black_Color);
                --  Draw text for headers
                FD.Draw_Text
                   (X, Y, W, H,
                    Image (if Context = Tbl.Column_Header then Column - 1 else Row - 1),
                    FLTK.Align_Center);
            end;
            FD.Pop_Clip;

        when Tbl.Within_Cell =>
            --  Keyboard nav and mouse selection highlighting
            FD.Draw_Box
               (X, Y, W, H, FLTK.Thin_Up_Box,
                (if Is_Selected_Cell (This, Row, Column)
                 then FLTK.Yellow_Color
                 else FLTK.White_Color));
            --  Draw text for the cell
            FD.Push_Clip (X + 3, Y + 3, W - 6, H - 6);
            FD.Set_Font (FLTK.Helvetica, 14);
            FD.Set_Color (FLTK.Black_Color);
            --  factor row + col for data cells
            FD.Draw_Text
               (X + 3, Y + 3, W - 6, H - 6, Image ((Row - 1) * (Column - 1)), FLTK.Align_Right);
            FD.Pop_Clip;

        when others =>
            null;
        end case;
    end Draw_Cell;


    --  Update the displayed sum value
    function Get_Selection_Sum
           (This : in My_Table)
        return Integer
    is
        Sum : Integer := -1;
    begin
        for R in 1 .. This.Get_Rows loop
            for C in 1 .. This.Get_Columns loop
                if Is_Selected_Cell (This, R, C) then
                    if Sum = -1 then
                        Sum := 0;
                    end if;
                    Sum := Sum + (R - 1) * (C - 1);
                end if;
            end loop;
        end loop;
        return Sum;
    end Get_Selection_Sum;


    --  Update the "Selection sum:" display
    procedure Update_Sum
           (This : in My_Table)
    is
        Sum : constant Integer := Get_Selection_Sum (This);
    begin
        declare
            S : constant String := (if Sum = -1 then "(nothing selected)" else Image (Sum));
        begin
            if Sum = -1 then
                G_Sum.Set_Background_Color (FLTK.Color (48));
            else
                G_Sum.Set_Background_Color (FLTK.White_Color);
            end if;
            --  Update only if different (lets one copy/paste from sum)
            if S /= G_Sum.Get_Value then
                G_Sum.Set_Value (S);
                G_Sum.Redraw;
            end if;
        end;
    end Update_Sum;


    overriding function Handle
           (This  : in out My_Table;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome
    is
        Ret : FLTK.Event_Outcome := TR.Row_Table (This).Handle (Event);
    begin
        if Event = FLTK.Keydown and then FLTK.Events.Last_Key = FLTK.Escape_Key then
            GNAT.OS_Lib.OS_Exit (0);
        end if;
        case Event is
        when FLTK.Push | FLTK.Release | FLTK.Keyup | FLTK.Keydown | FLTK.Drag =>
            --  *don't* indicate we 'handled' these, just update
            --  ('handling' prevents e.g. tab nav)
            Update_Sum (This);
            This.Redraw;
        when FLTK.Focus | FLTK.Unfocus =>
            --  tells FLTK we're interested in keyboard events
            Ret := FLTK.Handled;
        when others =>
            null;
        end case;
        return Ret;
    end Handle;


    --  User changed the 'row select' toggle button
    procedure Row_Select_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Item.Nearest_Window.Redraw;   --  redraw with changes applied
        Update_Sum (G_Table.all);
    end Row_Select_CB;


    Win_W : constant := 862;
    Win_H : constant := 312;

    The_Window : DW.Double_Window := DW.Forge.Create (Win_W, Win_H, "Table With Keynav");


begin


    --  disable arrow focus nav (we want arrows to control cells)
    FLTK.Static.Set_Option (FLTK.Static.Arrow_Focus, False);

    --  Create table
    G_Table := new My_Table'
        (TR.Forge.Create
            (The_Window, 10, 30, Win_W - 20, Win_H - 70, "Times Table")
         with null record);
    G_Table.Set_Tooltip
       ("Use mouse or Shift + Arrow Keys to make selections." & ASCII.LF &
        "Sum of selected values is shown.");

    --  Row init
    G_Table.Set_Row_Headers (True);
    G_Table.Set_Row_Header_Width (70);
    G_Table.Set_Row_Resize (True);
    G_Table.Set_Rows (11);
    G_Table.Set_All_Rows_Height (20);
    --  Col init
    G_Table.Set_Column_Headers (True);
    G_Table.Set_Column_Header_Height (20);
    G_Table.Set_Column_Resize (True);
    G_Table.Set_Columns (11);
    G_Table.Set_All_Columns_Width (70);
    G_Table.End_Current;   --  Fl_Table derives from Fl_Group, so end() it

    --  Row select toggle button
    G_Rowselect := new Tog.Toggle_Button'
        (Tog.Forge.Create (The_Window, 140, 10, 12, 12, "Row selection"));
    G_Rowselect.Set_Alignment (FLTK.Align_Left);
    G_Rowselect.Set_State (FLTK.Widgets.Buttons.Off);
    G_Rowselect.Set_Selection_Color (FLTK.Yellow_Color);
    G_Rowselect.Set_Callback (Row_Select_CB'Unrestricted_Access);
    G_Rowselect.Set_Tooltip ("Click to toggle row vs. row/col selection");

    --  Selection sum display
    G_Sum := new Op.Output'
        (Op.Forge.Create
            (The_Window, 140, G_Table.Get_Y + G_Table.Get_H + 10, 160, 25, "Selection Sum:"));
    G_Sum.Set_Value ("(nothing selected)");
    G_Sum.Set_Background_Color (FLTK.Color (48));
    G_Sum.Set_Tooltip ("This field shows the sum of the selected cells in the table");

    The_Window.End_Current;
    The_Window.Set_Resizable (G_Table.all);
    The_Window.Show;
    return FLTK.Run;


end Table_With_Keynav;
