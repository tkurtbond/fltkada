--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/table.cxx: a Row_Table of 500 by 500 cells, each showing
--  its 0-based row and column, with inputs, check buttons and choices
--  below it that set every aspect of it: the numbers of rows and columns,
--  their sizes and scroll positions, the headers' sizes and colors, whether
--  the headers show and rows and columns can be resized by dragging, the
--  boxes, the colors, and the selection mode.  The table's callbacks are
--  written to a terminal at the bottom, as FLTK's numbers.
--
--  FLTKAda gives Draw_Cell, Callback_Row and Callback_Column 1-based
--  rows and columns, so they are shown less one.  Guided by pofltk's
--  Table.Mod.


with

    Ada.Strings.Fixed,
    FLTK.Asks,
    FLTK.Draw,
    FLTK.Events,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Groups.Tables.Row,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Menus.Choices;

use type

    FLTK.Callback_Flag,
    FLTK.Widgets.Buttons.State,
    FLTK.Widgets.Groups.Tables.Table_Context;


function Table
    return Integer
is

    package FD  renames FLTK.Draw;
    package Btn renames FLTK.Widgets.Buttons;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Tbl renames FLTK.Widgets.Groups.Tables;
    package TR  renames FLTK.Widgets.Groups.Tables.Row;
    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Inp renames FLTK.Widgets.Inputs;
    package Txt renames FLTK.Widgets.Inputs.Text;
    package Chc renames FLTK.Widgets.Menus.Choices;


    Terminal_Height : constant := 120;


    --  Integer'Image without the leading blank
    function Image
           (N : in Integer)
        return String
    is
        S : constant String := Integer'Image (N);
    begin
        if N < 0 then
            return S;
        else
            return S (S'First + 1 .. S'Last);
        end if;
    end Image;


    --  C's atoi: leading white space, a sign, then digits
    function Atoi
           (S : in String)
        return Integer
    is
        I        : Positive := S'First;
        N        : Integer := 0;
        Negative : Boolean := False;
    begin
        while I <= S'Last and then S (I) in ' ' | ASCII.HT .. ASCII.CR loop
            I := I + 1;
        end loop;
        if I <= S'Last and then S (I) in '-' | '+' then
            Negative := S (I) = '-';
            I := I + 1;
        end if;
        while I <= S'Last and then S (I) in '0' .. '9' loop
            exit when N > (Integer'Last - 9) / 10;
            N := N * 10 + (Character'Pos (S (I)) - Character'Pos ('0'));
            I := I + 1;
        end loop;
        return (if Negative then -N else N);
    end Atoi;


    --  FLTK's number for each context (Fl_Table::TableContext)
    function Context_Number
           (Context : in Tbl.Table_Context)
        return Integer is
    begin
        case Context is
        when Tbl.No_Context        => return 0;
        when Tbl.Start_Page        => return 16#01#;
        when Tbl.End_Page          => return 16#02#;
        when Tbl.Row_Header        => return 16#04#;
        when Tbl.Column_Header     => return 16#08#;
        when Tbl.Within_Cell       => return 16#10#;
        when Tbl.Dead_Zone         => return 16#20#;
        when Tbl.Row_Column_Resize => return 16#40#;
        end case;
    end Context_Number;


    The_Window : Win.Window := Win.Forge.Create (900, 730 + Terminal_Height);

    TTY : Trm.Terminal := Trm.Forge.Create
        (The_Window, 0, 730, The_Window.Get_W, Terminal_Height);


    type Demo_Table is new TR.Row_Table with record
        Cell_BG_Color  : FLTK.Color := FLTK.White_Color;
        Cell_FG_Color  : FLTK.Color := FLTK.Black_Color;
        Show_Callbacks : Boolean := False;
    end record;

    overriding procedure Draw_Cell
           (This        : in out Demo_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0);

    --  Handle drawing all cells in table
    procedure Draw_Cell
           (This        : in out Demo_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0)
    is
        --  FLTK's 0-based row and column, as FLTK passes them
        R : constant Integer :=
            (if Context in Tbl.Row_Header | Tbl.Within_Cell then Row - 1 else Row);
        C : constant Integer :=
            (if Context in Tbl.Column_Header | Tbl.Within_Cell then Column - 1 else Column);
        S : constant String := Image (R) & "/" & Image (C);
    begin
        case Context is
        when Tbl.Start_Page =>
            FD.Set_Font (FLTK.Helvetica, 16);
        when Tbl.Column_Header | Tbl.Row_Header =>
            FD.Push_Clip (X, Y, W, H);
            FD.Draw_Box (X, Y, W, H, FLTK.Thin_Up_Box,
                (if Context = Tbl.Column_Header
                 then This.Get_Column_Header_Color
                 else This.Get_Row_Header_Color));
            FD.Set_Color (FLTK.Black_Color);
            FD.Draw_Text (X, Y, W, H, S, FLTK.Align_Center);
            FD.Pop_Clip;
        when Tbl.Within_Cell =>
            FD.Push_Clip (X, Y, W, H);
            --  BG COLOR
            FD.Set_Color
               (if This.Is_Row_Selected (Row)
                then This.Get_Selection_Color
                else This.Cell_BG_Color);
            FD.Rect_Fill (X, Y, W, H);
            --  TEXT
            FD.Set_Color (This.Cell_FG_Color);
            FD.Draw_Text (X, Y, W, H, S, FLTK.Align_Center);
            --  BORDER
            FD.Set_Color (This.Get_Background_Color);
            FD.Rect (X, Y, W, H);
            FD.Pop_Clip;
        when Tbl.Dead_Zone =>
            TTY.Print ("TABLE CONTEXT CALLED" & ASCII.LF);
        when Tbl.End_Page | Tbl.Row_Column_Resize | Tbl.No_Context =>
            null;
        end case;
    end Draw_Cell;


    The_Table : Demo_Table := (TR.Forge.Create (The_Window, 20, 20, 860, 460, "Demo")
        with others => <>);


    --  Callback whenever someone clicks on different parts of the table
    procedure Event_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        This : Demo_Table renames Demo_Table (Item);
        Name : constant String := This.Get_Label;
    begin
        if This.Show_Callbacks then
            TTY.Print ("'" & (if Name = "" then "?" else Name) & "' callback: Row=" &
                Image (This.Callback_Row - 1) & " Col=" & Image (This.Callback_Column - 1) &
                " Context=" & Image (Context_Number (This.Callback_Context)) &
                " Event=" & Image (FLTK.Event_Kind'Pos (FLTK.Events.Last)) &
                " InteractiveResize? " & Image (Boolean'Pos (This.Is_Interactive_Resize)) &
                ASCII.LF);
        end if;
    end Event_Callback;


    function Value_Of
           (Item : in FLTK.Widgets.Widget'Class)
        return Integer is
    begin
        return Atoi (Inp.Input'Class (Item).Get_Value);
    end Value_Of;


    procedure Set_Rows_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Table.Set_Rows (Integer'Max (Value_Of (Item), 0));
    end Set_Rows_CB;


    procedure Set_Cols_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Table.Set_Columns (Integer'Max (Value_Of (Item), 0));
    end Set_Cols_CB;


    procedure Set_Row_Header_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Table.Set_Row_Headers (Btn.Button'Class (Item).Get_State = Btn.On);
    end Set_Row_Header_CB;


    procedure Set_Col_Header_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Table.Set_Column_Headers (Btn.Button'Class (Item).Get_State = Btn.On);
    end Set_Col_Header_CB;


    procedure Set_Row_Resize_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Table.Set_Row_Resize (Btn.Button'Class (Item).Get_State = Btn.On);
    end Set_Row_Resize_CB;


    procedure Set_Col_Resize_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Table.Set_Column_Resize (Btn.Button'Class (Item).Get_State = Btn.On);
    end Set_Col_Resize_CB;


    procedure Set_Position_Row_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Top_Row : constant Integer := Value_Of (Item);
    begin
        if Top_Row < 0 or Top_Row >= The_Table.Get_Rows then
            FLTK.Asks.Alert ("Must be in range 0 thru #rows");
        else
            The_Table.Set_Row_Position (Top_Row + 1);
        end if;
    end Set_Position_Row_CB;


    procedure Set_Position_Col_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Left_Col : constant Integer := Value_Of (Item);
    begin
        if Left_Col < 0 or Left_Col >= The_Table.Get_Columns then
            FLTK.Asks.Alert ("Must be in range 0 thru #cols");
        else
            The_Table.Set_Column_Position (Left_Col + 1);
        end if;
    end Set_Position_Col_CB;


    procedure Set_Row_Header_Width_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Val : constant Integer := Value_Of (Item);
    begin
        if Val < 1 then
            Inp.Input'Class (Item).Set_Value ("1");
        end if;
        The_Table.Set_Row_Header_Width (Integer'Max (Val, 1));
    end Set_Row_Header_Width_CB;


    procedure Set_Col_Header_Height_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Val : constant Integer := Value_Of (Item);
    begin
        if Val < 1 then
            Inp.Input'Class (Item).Set_Value ("1");
        end if;
        The_Table.Set_Column_Header_Height (Integer'Max (Val, 1));
    end Set_Col_Header_Height_CB;


    procedure Set_Row_Header_Color_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Val : constant Integer := Value_Of (Item);
    begin
        if Val < 0 then
            FLTK.Asks.Alert ("Must be a color >0");
        else
            The_Table.Set_Row_Header_Color (FLTK.Color (Val));
        end if;
    end Set_Row_Header_Color_CB;


    procedure Set_Col_Header_Color_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Val : constant Integer := Value_Of (Item);
    begin
        if Val < 0 then
            FLTK.Asks.Alert ("Must be a color >0");
        else
            The_Table.Set_Column_Header_Color (FLTK.Color (Val));
        end if;
    end Set_Col_Header_Color_CB;


    procedure Set_Row_Height_All_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Val : constant Integer := Value_Of (Item);
    begin
        if Val < 0 then
            Inp.Input'Class (Item).Set_Value ("0");
        end if;
        The_Table.Set_All_Rows_Height (Integer'Max (Val, 0));
    end Set_Row_Height_All_CB;


    procedure Set_Col_Width_All_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Val : constant Integer := Value_Of (Item);
    begin
        if Val < 0 then
            Inp.Input'Class (Item).Set_Value ("0");
        end if;
        The_Table.Set_All_Columns_Width (Integer'Max (Val, 0));
    end Set_Col_Width_All_CB;


    procedure Set_Table_Color_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Val : constant Integer := Value_Of (Item);
    begin
        if Val < 0 then
            FLTK.Asks.Alert ("Must be a color >0");
        else
            The_Table.Set_Background_Color (FLTK.Color (Val));
        end if;
        The_Table.Redraw;
    end Set_Table_Color_CB;


    procedure Set_Cell_FG_Color_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Val : constant Integer := Value_Of (Item);
    begin
        if Val < 0 then
            FLTK.Asks.Alert ("Must be a color >0");
        else
            The_Table.Cell_FG_Color := FLTK.Color (Val);
        end if;
        The_Table.Redraw;
    end Set_Cell_FG_Color_CB;


    procedure Set_Cell_BG_Color_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Val : constant Integer := Value_Of (Item);
    begin
        if Val < 0 then
            FLTK.Asks.Alert ("Must be a color >0");
        else
            The_Table.Cell_BG_Color := FLTK.Color (Val);
        end if;
        The_Table.Redraw;
    end Set_Cell_BG_Color_CB;


    subtype Choice_Name is String (1 .. 15);

    function Pad
           (S : in String)
        return Choice_Name is
    begin
        return Ada.Strings.Fixed.Head (S, Choice_Name'Length);
    end Pad;

    type Box_Choice is record
        Name : Choice_Name;
        Box  : FLTK.Box_Kind;
    end record;

    type Box_Choice_Array is array (Positive range <>) of Box_Choice;

    Table_Box_Choices : constant Box_Choice_Array :=
       ((Pad ("No Box"),          FLTK.No_Box),
        (Pad ("Flat Box"),        FLTK.Flat_Box),
        (Pad ("Up Box"),          FLTK.Up_Box),
        (Pad ("Down Box"),        FLTK.Down_Box),
        (Pad ("Up Frame"),        FLTK.Up_Frame),
        (Pad ("Down Frame"),      FLTK.Down_Frame),
        (Pad ("Thin Up Box"),     FLTK.Thin_Up_Box),
        (Pad ("Thin Down Box"),   FLTK.Thin_Down_Box),
        (Pad ("Thin Up Frame"),   FLTK.Thin_Up_Frame),
        (Pad ("Thin Down Frame"), FLTK.Thin_Down_Frame),
        (Pad ("Engraved Box"),    FLTK.Engraved_Box),
        (Pad ("Embossed Box"),    FLTK.Embossed_Box),
        (Pad ("Engraved Frame"),  FLTK.Engraved_Frame),
        (Pad ("Embossed Frame"),  FLTK.Embossed_Frame),
        (Pad ("Border Box"),      FLTK.Border_Box),
        (Pad ("Shadow Box"),      FLTK.Shadow_Box),
        (Pad ("Border Frame"),    FLTK.Border_Frame));

    --  FLTK comments out the boxes, as opposed to frames, here
    Widget_Box_Choices : constant Box_Choice_Array :=
       ((Pad ("No Box"),          FLTK.No_Box),
        (Pad ("Up Frame"),        FLTK.Up_Frame),
        (Pad ("Down Frame"),      FLTK.Down_Frame),
        (Pad ("Thin Up Frame"),   FLTK.Thin_Up_Frame),
        (Pad ("Thin Down Frame"), FLTK.Thin_Down_Frame),
        (Pad ("Engraved Frame"),  FLTK.Engraved_Frame),
        (Pad ("Embossed Frame"),  FLTK.Embossed_Frame),
        (Pad ("Border Frame"),    FLTK.Border_Frame));


    --  Each choice's items share one callback, which goes by the item chosen
    procedure Table_Box_Choice_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Table.Set_Table_Box
            (Table_Box_Choices (Chc.Choice'Class (Item).Chosen_Index).Box);
        The_Table.Redraw;
    end Table_Box_Choice_CB;


    procedure Widget_Box_Choice_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Table.Set_Box (Widget_Box_Choices (Chc.Choice'Class (Item).Chosen_Index).Box);
        The_Table.Resize
           (The_Table.Get_X, The_Table.Get_Y, The_Table.Get_W, The_Table.Get_H);
    end Widget_Box_Choice_CB;


    procedure Type_Choice_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Table.Set_Row_Select_Mode
            (TR.Row_Select_Mode'Val (Chc.Choice'Class (Item).Chosen_Index - 1));
    end Type_Choice_CB;


    --  The controls, in FLTK's order; their values are set below, once the
    --  table is set up

    --  ROW
    Set_Rows       : Txt.Text_Input := Txt.Forge.Create (The_Window, 150, 500, 120, 25, "Rows");
    Row_Height_All : Txt.Text_Input :=
        Txt.Forge.Create (The_Window, 400, 500, 120, 25, "Row Height");
    Position_Row   : Txt.Text_Input :=
        Txt.Forge.Create (The_Window, 650, 500, 120, 25, "Row Position");

    --  COL
    Set_Cols      : Txt.Text_Input := Txt.Forge.Create (The_Window, 150, 530, 120, 25, "Cols");
    Col_Width_All : Txt.Text_Input :=
        Txt.Forge.Create (The_Window, 400, 530, 120, 25, "Col Width");
    Position_Col  : Txt.Text_Input :=
        Txt.Forge.Create (The_Window, 650, 530, 120, 25, "Col Position");

    --  ROW HEADER
    Row_Header_Width : Txt.Text_Input :=
        Txt.Forge.Create (The_Window, 150, 570, 120, 25, "Row Header Width");
    Row_Header_Color : Txt.Text_Input :=
        Txt.Forge.Create (The_Window, 400, 570, 120, 25, "Row Header Color");
    Row_Header : Chk.Check_Button :=
        Chk.Forge.Create (The_Window, 550, 570, 120, 25, "Row Headers?");
    Row_Resize : Chk.Check_Button :=
        Chk.Forge.Create (The_Window, 700, 570, 120, 25, "Row Resize?");

    --  COL HEADER
    Col_Header_Height : Txt.Text_Input :=
        Txt.Forge.Create (The_Window, 150, 600, 120, 25, "Col Header Height");
    Col_Header_Color : Txt.Text_Input :=
        Txt.Forge.Create (The_Window, 400, 600, 120, 25, "Col Header Color");
    Col_Header : Chk.Check_Button :=
        Chk.Forge.Create (The_Window, 550, 600, 120, 25, "Col Headers?");
    Col_Resize : Chk.Check_Button :=
        Chk.Forge.Create (The_Window, 700, 600, 120, 25, "Col Resize?");

    Table_Box  : Chc.Choice := Chc.Forge.Create (The_Window, 150, 640, 120, 25, "Table Box");
    Widget_Box : Chc.Choice := Chc.Forge.Create (The_Window, 150, 670, 120, 25, "Widget Box");

    Table_Color   : Txt.Text_Input :=
        Txt.Forge.Create (The_Window, 400, 640, 120, 25, "Table Color");
    Cell_BG_Color : Txt.Text_Input :=
        Txt.Forge.Create (The_Window, 400, 670, 120, 25, "Cell BG Color");
    Cell_FG_Color : Txt.Text_Input :=
        Txt.Forge.Create (The_Window, 400, 700, 120, 25, "Cell FG Color");

    Kind : Chc.Choice := Chc.Forge.Create (The_Window, 650, 640, 120, 25, "Type");


    procedure Setup_Input
           (This  : in out Txt.Text_Input;
            Value : in     String;
            CB    : in     FLTK.Widgets.Widget_Callback) is
    begin
        This.Set_Label_Size (12);
        This.Set_Value (Value);
        This.Set_Callback (CB);
        This.Set_When (FLTK.When_Release);
    end Setup_Input;


    procedure Setup_Check
           (This  : in out Chk.Check_Button;
            CB    : in     FLTK.Widgets.Widget_Callback;
            Value : in     Boolean) is
    begin
        This.Set_Label_Size (12);
        This.Set_Callback (CB);
        This.Set_State (if Value then Btn.On else Btn.Off);
    end Setup_Check;


    procedure Setup_Choice
           (This    : in out Chc.Choice;
            Choices : in     Box_Choice_Array;
            CB      : in     FLTK.Widgets.Widget_Callback) is
    begin
        This.Set_Label_Size (12);
        This.Set_Text_Size (12);
        for C of Choices loop
            This.Add (Ada.Strings.Fixed.Trim (C.Name, Ada.Strings.Right), CB);
        end loop;
    end Setup_Choice;


begin


    The_Table.Set_Callback (Event_Callback'Unrestricted_Access);
    The_Table.Set_Selection_Color (FLTK.Yellow_Color);
    The_Table.Set_When (FLTK.When_Release + FLTK.When_Changed);
    The_Table.Set_Table_Box (FLTK.No_Box);
    The_Table.Set_Column_Resize_Minimum (4);
    The_Table.Set_Row_Resize_Minimum (4);

    --  ROWS
    The_Table.Set_Row_Headers (True);
    The_Table.Set_Row_Header_Width (60);
    The_Table.Set_Row_Resize (True);
    The_Table.Set_Rows (500);
    The_Table.Set_All_Rows_Height (20);

    --  COLS
    The_Table.Set_Columns (500);
    The_Table.Set_Column_Headers (True);
    The_Table.Set_Column_Header_Height (25);
    The_Table.Set_Column_Resize (True);
    The_Table.Set_All_Columns_Width (80);

    --  After initialization, show table's callbacks
    The_Table.Show_Callbacks := True;

    Setup_Input (Set_Rows, Image (The_Table.Get_Rows), Set_Rows_CB'Unrestricted_Access);
    Setup_Input (Row_Height_All, Image (The_Table.Get_Row_Height (1)),
        Set_Row_Height_All_CB'Unrestricted_Access);
    Setup_Input (Position_Row, "1", Set_Position_Row_CB'Unrestricted_Access);

    Setup_Input (Set_Cols, Image (The_Table.Get_Columns), Set_Cols_CB'Unrestricted_Access);
    Setup_Input (Col_Width_All, Image (The_Table.Get_Column_Width (1)),
        Set_Col_Width_All_CB'Unrestricted_Access);
    Setup_Input (Position_Col, "1", Set_Position_Col_CB'Unrestricted_Access);

    Setup_Input (Row_Header_Width, Image (The_Table.Get_Row_Header_Width),
        Set_Row_Header_Width_CB'Unrestricted_Access);
    Setup_Input (Row_Header_Color, Image (Integer (The_Table.Get_Row_Header_Color)),
        Set_Row_Header_Color_CB'Unrestricted_Access);
    Setup_Check (Row_Header, Set_Row_Header_CB'Unrestricted_Access,
        The_Table.Row_Headers_Enabled);
    Setup_Check (Row_Resize, Set_Row_Resize_CB'Unrestricted_Access,
        The_Table.Row_Resize_Allowed);

    Setup_Input (Col_Header_Height, Image (The_Table.Get_Column_Header_Height),
        Set_Col_Header_Height_CB'Unrestricted_Access);
    Setup_Input (Col_Header_Color, Image (Integer (The_Table.Get_Column_Header_Color)),
        Set_Col_Header_Color_CB'Unrestricted_Access);
    Setup_Check (Col_Header, Set_Col_Header_CB'Unrestricted_Access,
        The_Table.Column_Headers_Enabled);
    Setup_Check (Col_Resize, Set_Col_Resize_CB'Unrestricted_Access,
        The_Table.Column_Resize_Allowed);

    Setup_Choice (Table_Box, Table_Box_Choices, Table_Box_Choice_CB'Unrestricted_Access);
    Table_Box.Set_Chosen (1);

    Setup_Choice (Widget_Box, Widget_Box_Choices, Widget_Box_Choice_CB'Unrestricted_Access);
    Widget_Box.Set_Chosen (3);  --  down frame

    Setup_Input (Table_Color, Image (Integer (The_Table.Get_Background_Color)),
        Set_Table_Color_CB'Unrestricted_Access);
    Setup_Input (Cell_BG_Color, Image (Integer (The_Table.Cell_BG_Color)),
        Set_Cell_BG_Color_CB'Unrestricted_Access);
    Setup_Input (Cell_FG_Color, Image (Integer (The_Table.Cell_FG_Color)),
        Set_Cell_FG_Color_CB'Unrestricted_Access);

    Kind.Set_Label_Size (12);
    Kind.Set_Text_Size (12);
    Kind.Add ("SelectNone", Type_Choice_CB'Unrestricted_Access);
    Kind.Add ("SelectSingle", Type_Choice_CB'Unrestricted_Access);
    Kind.Add ("SelectMulti", Type_Choice_CB'Unrestricted_Access);
    Kind.Set_Chosen (3);

    The_Window.End_Current;
    The_Window.Set_Resizable (The_Table);
    The_Window.Show_With_Args;

    return FLTK.Run;


end Table;
