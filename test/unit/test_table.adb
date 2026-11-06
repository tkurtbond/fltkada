


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestTable: rows, columns and headers, cells drawn
--  by Draw_Cell, where cells are, a click, row and cell selection, and Tab
--  between cells.  The widgets in a table's cells are in
--  test_table_children.  pofltk's Area has three kinds, the widget's
--  inside its frame, the cells' and inside the cells' box; Bounding_Region
--  (Fl_Table::get_bounds) gives the last, and the headers' regions give
--  the edges of the other two.  Also checks that a row or column past the
--  last raises Range_Error (FLTKAda-BUGS.md 112, FLTK-issues.md F33), and
--  that Bounding_Region raises for a context with no region (113).


with

    Ada.Exceptions,
    Checks,
    FLTK.Draw,
    FLTK.Events,
    FLTK.Probe,
    FLTK.Widgets.Groups.Tables.Row,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;

use type

    FLTK.Widgets.Groups.Tables.Row.Row_Select_Mode,
    FLTK.Widgets.Groups.Tables.Tab_Navigation,
    FLTK.Widgets.Groups.Tables.Table_Context;


procedure Test_Table is

    package Prb renames FLTK.Probe;
    package Tab renames FLTK.Widgets.Groups.Tables;
    package TR  renames FLTK.Widgets.Groups.Tables.Row;
    package Win renames FLTK.Widgets.Groups.Windows;

    --  Fills cell 1, 1 red and 2, 2 blue, the rest white, the headers
    --  green, and counts what it is asked to draw.
    type Grid is new TR.Row_Table with record
        Cells, Headers, Pages : Natural := 0;
    end record;

    overriding procedure Draw_Cell
           (This        : in out Grid;
            Context     : in     Tab.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0) is
    begin
        case Context is
        when Tab.Within_Cell =>
            This.Cells := This.Cells + 1;
            if Row = 1 and Column = 1 then
                FLTK.Draw.Rect_Fill (X, Y, W, H, Red_Color);
            elsif Row = 2 and Column = 2 then
                FLTK.Draw.Rect_Fill (X, Y, W, H, Blue_Color);
            else
                FLTK.Draw.Rect_Fill (X, Y, W, H, White_Color);
            end if;
        when Tab.Row_Header | Tab.Column_Header =>
            This.Headers := This.Headers + 1;
            FLTK.Draw.Rect_Fill (X, Y, W, H, Green_Color);
        when Tab.Start_Page | Tab.End_Page =>
            This.Pages := This.Pages + 1;
        when others =>
            null;
        end case;
    end Draw_Cell;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 200, "Test_Table");
    T      : Grid := (TR.Forge.Create (Window, 0, 0, 300, 200) with others => <>);

    Calls       : Natural := 0;
    Last_Row    : Natural := 0;
    Last_Column : Natural := 0;
    Last_Context : Tab.Table_Context := Tab.No_Context;

    procedure Called
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        This : Grid renames Grid (Item);
    begin
        Calls := Calls + 1;
        Last_Row := This.Callback_Row;
        Last_Column := This.Callback_Column;
        Last_Context := This.Callback_Context;
    end Called;

    procedure Click
           (X, Y : in Integer)
    is
        Ignore : Boolean;
    begin
        Ignore := Prb.Mouse (Window, Push, X, Y);
        Ignore := Prb.Mouse (Window, Release, X, Y);
    end Click;

    --  True if Action raises Tab.Range_Error.
    generic
        with procedure Action;
    function Raises_Range_Error
        return Boolean;

    function Raises_Range_Error
        return Boolean is
    begin
        Action;
        return False;
    exception
    when Tab.Range_Error =>
        return True;
    end Raises_Range_Error;

    procedure Get_Row_Past is
        Ignore : constant Positive := T.Get_Row_Height (6);
    begin
        null;
    end Get_Row_Past;

    procedure Set_Row_Past is
    begin
        T.Set_Row_Height (6, 20);
    end Set_Row_Past;

    procedure Get_Column_Past is
        Ignore : constant Positive := T.Get_Column_Width (5);
    begin
        null;
    end Get_Column_Past;

    procedure Set_Column_Past is
    begin
        T.Set_Column_Width (5, 20);
    end Set_Column_Past;

    function Get_Row_Raises    is new Raises_Range_Error (Get_Row_Past);
    function Set_Row_Raises    is new Raises_Range_Error (Set_Row_Past);
    function Get_Column_Raises is new Raises_Range_Error (Get_Column_Past);
    function Set_Column_Raises is new Raises_Range_Error (Set_Column_Past);

    function Bounds_Raises
        return Boolean
    is
        Ignore_X, Ignore_Y, Ignore_W, Ignore_H : Integer;
    begin
        T.Bounding_Region (Tab.Within_Cell, Ignore_X, Ignore_Y, Ignore_W, Ignore_H);
        return False;
    exception
    when Constraint_Error =>
        return True;
    end Bounds_Raises;

    X, Y, W, H, AX, AY, AW, AH : Integer;
    R1, C1 : Positive;
    R2, C2 : Natural;
    S1, S2, S3, S4 : Natural;
    Ok : Boolean;

begin

    T.End_Current;
    Window.End_Current;
    T.Set_Callback (Called'Unrestricted_Access);
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;

    --  Rows, columns, headers
    Check (T.Get_Rows = 0 and T.Get_Columns = 0
            and not T.Row_Headers_Enabled and not T.Column_Headers_Enabled,
        "empty to start with");
    T.Set_Rows (5);
    T.Set_Columns (4);
    T.Set_Row_Headers (True);
    T.Set_Row_Header_Width (40);
    T.Set_Column_Headers (True);
    T.Set_Column_Header_Height (25);
    T.Set_All_Rows_Height (20);
    T.Set_All_Columns_Width (50);
    T.Set_Column_Width (4, 60);
    T.Set_Row_Height (5, 30);
    Check (T.Get_Rows = 5 and T.Get_Columns = 4 and T.Row_Headers_Enabled
            and T.Column_Headers_Enabled and T.Get_Row_Header_Width = 40
            and T.Get_Column_Header_Height = 25,
        "Set_Rows, Set_Columns, the headers");
    Check (T.Get_Row_Height (1) = 20 and T.Get_Row_Height (5) = 30
            and T.Get_Column_Width (1) = 50 and T.Get_Column_Width (4) = 60,
        "row heights and column widths");
    Check (Get_Row_Raises and Set_Row_Raises, "a row past the last raises Range_Error");
    Check (Get_Column_Raises and Set_Column_Raises,
        "a column past the last raises Range_Error");
    Check (T.Get_Rows = 5 and T.Get_Columns = 4, "and leaves the table as it was");
    T.Set_Row_Header_Color (Yellow_Color);
    T.Set_Column_Header_Color (Cyan_Color);
    Check (T.Get_Row_Header_Color = Yellow_Color and T.Get_Column_Header_Color = Cyan_Color,
        "header colours");
    T.Set_Row_Resize (True);
    T.Set_Column_Resize (True);
    T.Set_Row_Resize_Minimum (5);
    T.Set_Column_Resize_Minimum (7);
    Check (T.Row_Resize_Allowed and T.Column_Resize_Allowed
            and T.Get_Row_Resize_Minimum = 5 and T.Get_Column_Resize_Minimum = 7,
        "resizing");
    T.Set_Table_Box (No_Box);
    T.Set_Scrollbar_Size (12);
    Check (T.Get_Table_Box = No_Box and T.Get_Scrollbar_Size = 12
            and not T.Is_Interactive_Resize,
        "Set_Table_Box, Set_Scrollbar_Size");

    --  Drawing
    Ok := Prb.Capture (T);
    Check (Ok and T.Cells > 0 and T.Headers > 0 and T.Pages = 2,
        "Draw_Cell: cells, headers, start and end" & Natural'Image (T.Cells)
        & Natural'Image (T.Headers) & Natural'Image (T.Pages));
    T.Cell_Dimensions (Tab.Within_Cell, 1, 1, X, Y, W, H);
    Check (X = 41 and Y = 26 and W = 50 and H = 20,
        "Cell_Dimensions: past the headers and the frame");
    T.Bounding_Region (Tab.Row_Header, AX, AY, AW, AH);
    Check (AX = 1 and AY = 26 and AW = 40 and AH = 173,
        "Bounding_Region: the row headers, inside the table's frame");
    T.Bounding_Region (Tab.Column_Header, AX, AY, AW, AH);
    Check (AX = 41 and AY = 1 and AW = 258 and AH = 25,
        "Bounding_Region: the column headers, beside the row headers");
    T.Bounding_Region (Tab.Dead_Zone, AX, AY, AW, AH);
    Check (AX = 41 and AY = 26 and AW = 258 and AH = 173,
        "Bounding_Region: inside the cells' box, No_Box");
    Check (Bounds_Raises, "Bounding_Region: Within_Cell raises Constraint_Error");
    Check (Prb.Pixel (X + 25, Y + 10) = Prb.To_RGB (255, 0, 0)
            and Prb.Pixel (X + 75, Y + 30) = Prb.To_RGB (0, 0, 255)
            and Prb.Pixel (X + 75, Y + 10) = Prb.To_RGB (255, 255, 255),
        "Draw_Cell draws each cell where it is");
    Check (Prb.Pixel (20, Y + 10) = Prb.To_RGB (0, 255, 0), "and the headers");
    Prb.Release;
    T.Get_Visible_Cells (R1, C1, R2, C2);
    Check (R1 = 1 and R2 = 5 and C1 = 1 and C2 = 4, "Get_Visible_Cells");
    T.Set_Table_Box (Thin_Down_Frame);
    T.Bounding_Region (Tab.Dead_Zone, AX, AY, AW, AH);
    Check (AX = 42 and AY = 27 and AW = 256 and AH = 171,
        "Bounding_Region: inside the cells' box");
    T.Set_Rows (50);
    T.Bounding_Region (Tab.Column_Header, AX, AY, AW, AH);
    Check (AX = 41 and AW = 258 - 12, "Bounding_Region: beside the scrollbar");
    T.Set_Rows (5);
    T.Set_Table_Box (No_Box);

    --  A click in a cell selects its row and calls back.
    Click (X + 75, Y + 30);
    Check (Calls > 0 and Last_Row = 2 and Last_Column = 2 and Last_Context = Tab.Within_Cell,
        "a click: Callback_Row, Callback_Column, Callback_Context");
    Check (T.Is_Row_Selected (2) and not T.Is_Row_Selected (1), "a click selects its row");
    Check (T.Get_Row_Select_Mode = TR.Select_Multiple, "Select_Multiple to start with");
    Check (T.Select_Row (4) and then not T.Select_Row (4)
            and then T.Is_Row_Selected (4) and then T.Is_Row_Selected (2),
        "Select_Row");
    T.Set_Row_Select_Mode (TR.Select_Single);
    Check (T.Select_Row (1) and then T.Is_Row_Selected (1)
            and then not T.Is_Row_Selected (2) and then not T.Is_Row_Selected (4),
        "Select_Single");
    T.Set_Row_Select_Mode (TR.Select_Multiple);
    T.Select_All_Rows;
    Check (T.Is_Row_Selected (3) and T.Is_Row_Selected (5), "Select_All_Rows");
    T.Select_All_Rows (TR.Deselected);
    Check (not T.Is_Row_Selected (1), "and none");

    --  Cell selection
    T.Set_Selection (2, 2, 3, 4);
    T.Get_Selection (S1, S2, S3, S4);
    Check (S1 = 2 and S2 = 2 and S3 = 3 and S4 = 4
            and T.Is_Selected (3, 3) and not T.Is_Selected (1, 1),
        "Set_Selection, Get_Selection, Is_Selected");
    Check (T.Move_Cursor (3, 3, False), "Move_Cursor");

    --  Tab: the next widget, or with Navigate_Cells the next cell
    Check (T.Get_Tab_Mode = Tab.Widget_Focus, "Widget_Focus to start with");
    FLTK.Events.Set_Focus (T);
    T.Set_Selection (2, 2, 2, 2);
    Check (not Prb.Key (Keydown, Tab_Key, Mod_None, (1 => ASCII.HT)),
        "Tab: the table leaves it to FLTK");
    T.Set_Tab_Mode (Tab.Navigate_Cells);
    Check (T.Get_Tab_Mode = Tab.Navigate_Cells
            and then Prb.Key (Keydown, Tab_Key, Mod_None, (1 => ASCII.HT)),
        "Navigate_Cells: the table takes Tab");
    T.Get_Selection (S1, S2, S3, S4);
    Check (S1 = 2 and S2 = 3 and S3 = 2 and S4 = 3, "and moves to the next cell");
    Ok := Prb.Key (Keydown, Tab_Key, Mod_Shift, (1 => ASCII.HT));
    T.Get_Selection (S1, S2, S3, S4);
    Check (Ok and S1 = 2 and S2 = 2, "Shift-Tab: the cell before");
    T.Set_Tab_Mode (Tab.Widget_Focus);
    FLTK.Events.Set_Focus (Window);
    T.Set_Rows (100);
    T.Set_Row_Position (50);
    Check (T.Get_Row_Position = 50, "Set_Row_Position");
    T.Redraw_Range (1, 2, 1, 2);

    --  A plain table
    declare
        Plain : Tab.Table := Tab.Forge.Create (0, 0, 100, 100);
    begin
        Plain.End_Current;
        Check (Plain.Get_Rows = 0 and Plain.Number_Of_Children = 0, "a plain table");
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Table;
