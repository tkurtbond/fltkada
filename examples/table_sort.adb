

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/table-sort.cxx: a table of the output of
--  "ls -l" that sorts on a column when its header is clicked.
--
--  Draw_Cell and Callback_Column are 1-based, which lines up directly
--  with the 1-based vectors holding the rows and their columns.  Only the
--  Unix side of the original is ported.  The sort is not guaranteed to
--  order equal rows the same way as the std::sort in the original.


with

    Ada.Containers.Indefinite_Vectors,
    Ada.Containers.Vectors,
    Ada.Strings.Fixed,
    Ada.Strings.Maps,
    FLTK.Draw,
    FLTK.Events,
    FLTK.Screen,
    FLTK.Widgets.Groups.Tables.Row,
    FLTK.Widgets.Groups.Windows.Double,
    GNAT.Expect,
    GNAT.OS_Lib;

use type

    FLTK.Event_Kind,
    FLTK.Mouse_Button;


function Table_Sort
    return Integer
is


    package FD  renames FLTK.Draw;
    package Tbl renames FLTK.Widgets.Groups.Tables;
    package TR  renames FLTK.Widgets.Groups.Tables.Row;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;

    use type Tbl.Table_Context;


    Margin : constant := 20;

    --  UNIX
    Dir_Cmd : constant String := "ls -l";

    type String_Access is access constant String;

    Perms_Str : aliased constant String := "Perms";
    Links_Str : aliased constant String := "#L";
    Own_Str   : aliased constant String := "Own";
    Group_Str : aliased constant String := "Group";
    Size_Str  : aliased constant String := "Size";
    Date_Str  : aliased constant String := "Date";
    Empty_Str : aliased constant String := "";
    File_Str  : aliased constant String := "Filename";

    G_Header : constant array (Positive range <>) of String_Access :=
       (Perms_Str'Access, Links_Str'Access, Own_Str'Access, Group_Str'Access,
        Size_Str'Access, Date_Str'Access, Empty_Str'Access, Empty_Str'Access,
        File_Str'Access);

    --  Font face/sizes for header and rows
    Header_Fontface : constant FLTK.Font_Kind := FLTK.Helvetica_Bold;
    Header_Fontsize : constant := 16;
    Row_Fontface    : constant FLTK.Font_Kind := FLTK.Helvetica;
    Row_Fontsize    : constant := 16;


    --  A single row of columns
    package Column_Vectors is new Ada.Containers.Indefinite_Vectors (Positive, String);

    package Row_Vectors is new Ada.Containers.Vectors
       (Positive, Column_Vectors.Vector, Column_Vectors."=");


    --  Derive a custom type from Row_Table
    type My_Table is new TR.Row_Table with record
        Row_Data     : Row_Vectors.Vector;   --  data in each row
        Sort_Reverse : Boolean := False;
        Sort_Lastcol : Natural := 0;
    end record;

    --  table cell drawing
    overriding procedure Draw_Cell
           (This        : in out My_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0);


    --  The leading digits of S, as sscanf's "%d" reads them
    function Leading_Number
           (S : in String)
        return Long_Long_Integer
    is
        Last : Natural := S'First - 1;
    begin
        while Last < S'Last and then S (Last + 1) in '0' .. '9' loop
            Last := Last + 1;
        end loop;
        return Long_Long_Integer'Value (S (S'First .. Last));
    end Leading_Number;


    --  Sort a column up or down
    procedure Sort_Column
           (This         : in out My_Table;
            Col          : in     Positive;
            Reverse_Sort : in     Boolean := False)
    is
        function Get
               (R : in Column_Vectors.Vector)
            return String is
        begin
            return (if Col <= Natural (R.Length) then R (Col) else "");
        end Get;

        function Before
               (A, B : in Column_Vectors.Vector)
            return Boolean
        is
            AP : constant String := Get (A);
            BP : constant String := Get (B);
        begin
            --  cheezy detection of numeric data
            if AP'Length > 0 and then BP'Length > 0 and then
                AP (AP'First) in '0' .. '9' and then BP (BP'First) in '0' .. '9'
            then
                --  Numeric sort
                declare
                    AV : constant Long_Long_Integer := Leading_Number (AP);
                    BV : constant Long_Long_Integer := Leading_Number (BP);
                begin
                    return (if Reverse_Sort then AV < BV else BV < AV);
                end;
            else
                --  Alphabetic sort
                return (if Reverse_Sort then AP > BP else AP < BP);
            end if;
        end Before;

        package Sorting is new Row_Vectors.Generic_Sorting ("<" => Before);
    begin
        Sorting.Sort (This.Row_Data);
        This.Redraw;
    end Sort_Column;


    --  Draw sort arrow
    procedure Draw_Sort_Arrow
           (This       : in My_Table;
            X, Y, W, H : in Integer)
    is
        Xlft : constant Integer := X + (W - 6) - 8;
        Xctr : constant Integer := X + (W - 6) - 4;
        Xrit : constant Integer := X + (W - 6) - 0;
        Ytop : constant Integer := Y + (H / 2) - 4;
        Ybot : constant Integer := Y + (H / 2) + 4;
    begin
        if This.Sort_Reverse then
            --  Engraved down arrow
            FD.Set_Color (FLTK.White_Color);
            FD.Line (Xrit, Ytop, Xctr, Ybot);
            FD.Set_Color (FLTK.Color (41));   --  dark gray
            FD.Line (Xlft, Ytop, Xrit, Ytop);
            FD.Line (Xlft, Ytop, Xctr, Ybot);
        else
            --  Engraved up arrow
            FD.Set_Color (FLTK.White_Color);
            FD.Line (Xrit, Ybot, Xctr, Ytop);
            FD.Line (Xrit, Ybot, Xlft, Ybot);
            FD.Set_Color (FLTK.Color (41));   --  dark gray
            FD.Line (Xlft, Ybot, Xctr, Ytop);
        end if;
    end Draw_Sort_Arrow;


    --  Handle drawing all cells in table
    overriding procedure Draw_Cell
           (This        : in out My_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0)
    is
        function Cell_Text
            return String is
        begin
            if Row in 1 .. Natural (This.Row_Data.Length) and then
                Column in 1 .. Natural (This.Row_Data (Row).Length)
            then
                return This.Row_Data (Row) (Column);
            else
                return "";
            end if;
        end Cell_Text;
    begin
        case Context is
        when Tbl.Column_Header =>
            FD.Push_Clip (X, Y, W, H);
            FD.Draw_Box (X, Y, W, H, FLTK.Thin_Up_Box, FLTK.Background_Color);
            if Column <= G_Header'Last then
                FD.Set_Font (Header_Fontface, Header_Fontsize);
                FD.Set_Color (FLTK.Black_Color);
                --  +2=pad left
                FD.Draw_Text
                   (X + 2, Y, W, H, G_Header (Column).all, FLTK.Align_Left, Symbols => False);
                --  Draw sort arrow
                if Column = This.Sort_Lastcol then
                    Draw_Sort_Arrow (This, X, Y, W, H);
                end if;
            end if;
            FD.Pop_Clip;

        when Tbl.Within_Cell =>
            FD.Push_Clip (X, Y, W, H);
            --  Bg color
            FD.Set_Color
               (if This.Is_Row_Selected (Row)
                then This.Get_Selection_Color
                else FLTK.White_Color);
            FD.Rect_Fill (X, Y, W, H);
            FD.Set_Font (Row_Fontface, Row_Fontsize);
            FD.Set_Color (FLTK.Black_Color);
            FD.Draw_Text (X + 2, Y, W, H, Cell_Text, FLTK.Align_Left);   --  +2=pad left
            --  Border
            FD.Set_Color (FLTK.Light2_Color);
            FD.Rect (X, Y, W, H);
            FD.Pop_Clip;

        when others =>
            null;
        end case;
    end Draw_Cell;


    --  Automatically set column widths to widest data in each column
    procedure Auto_Width
           (This : in out My_Table;
            Pad  : in     Natural)
    is
        W, H : Natural;
    begin
        --  Initialize all column widths to header width
        FD.Set_Font (Header_Fontface, Header_Fontsize);
        for C in G_Header'Range loop
            FD.Measure (G_Header (C).all, W, H, Symbols => False);   --  pixel width of header text
            This.Set_Column_Width (C, W + Pad);
        end loop;
        FD.Set_Font (Row_Fontface, Row_Fontsize);
        for R of This.Row_Data loop
            for C in 1 .. Natural (R.Length) loop
                FD.Measure (R (C), W, H, Symbols => False);           --  pixel width of row text
                if W + Pad > This.Get_Column_Width (C) then
                    This.Set_Column_Width (C, W + Pad);
                end if;
            end loop;
        end loop;
        This.Table_Resized;
        This.Redraw;
    end Auto_Width;


    --  Resize parent window to size of table
    procedure Resize_Window
           (This : in out My_Table)
    is
        --  Determine exact outer width of table with all columns visible
        Width : Integer := 2;                                --  width of table borders
    begin
        for T in 1 .. This.Get_Columns loop
            Width := Width + This.Get_Column_Width (T);     --  total width of all columns
        end loop;
        Width := Width + This.V_Bar.Get_W;                  --  include width of scrollbar
        Width := Width + Margin * 2;
        if Width < 200 or Width > FLTK.Screen.Get_W then
            return;
        end if;
        declare
            Win : constant access FLTK.Widgets.Groups.Windows.Window'Class :=
                This.Nearest_Window;
        begin
            Win.Resize (Win.Get_X, Win.Get_Y, Width, Win.Get_H);   --  resize window to fit
        end;
    end Resize_Window;


    --  Load table with output of 'Cmd'
    procedure Load_Command
           (This : in out My_Table;
            Cmd  : in     String)
    is
        Delim  : constant Ada.Strings.Maps.Character_Set :=
            Ada.Strings.Maps.To_Set (" " & ASCII.HT & ASCII.LF);
        Args   : GNAT.OS_Lib.Argument_List := (new String'("-c"), new String'(Cmd));
        Status : aliased Integer;
        Output : constant String :=
            GNAT.Expect.Get_Command_Output ("/bin/sh", Args, "", Status'Access, True);
        Start  : Positive := Output'First;
        Line   : Natural := 0;
    begin
        for A of Args loop
            GNAT.OS_Lib.Free (A);
        end loop;
        This.Set_Columns (0);
        while Start <= Output'Last loop
            declare
                Stop : constant Natural :=
                    Ada.Strings.Fixed.Index (Output (Start .. Output'Last), (1 => ASCII.LF));
                Last : constant Natural := (if Stop = 0 then Output'Last else Stop - 1);
                S    : constant String := Output (Start .. Last);
            begin
                Start := Last + 2;
                --  UNIX
                if not (Line = 0 and then S'Length >= 6 and then
                    S (S'First .. S'First + 5) = "total ")
                then
                    --  Add a new row, breaking the line into separate word 'columns'
                    declare
                        Columns : Column_Vectors.Vector;
                        From    : Positive := S'First;
                        First   : Positive;
                        Upto    : Natural;
                    begin
                        loop
                            Ada.Strings.Fixed.Find_Token
                               (S (From .. S'Last), Delim, Ada.Strings.Outside, First, Upto);
                            exit when Upto = 0;
                            Columns.Append (S (First .. Upto));
                            From := Upto + 1;
                            exit when From > S'Last;
                        end loop;
                        This.Row_Data.Append (Columns);
                        --  Keep track of max # columns
                        if Natural (Columns.Length) > This.Get_Columns then
                            This.Set_Columns (Natural (Columns.Length));
                        end if;
                    end;
                end if;
                Line := Line + 1;
            end;
        end loop;
        --  How many rows we loaded
        This.Set_Rows (Natural (This.Row_Data.Length));
        --  Auto-calculate widths, with 20 pixel padding
        Auto_Width (This, 20);
    end Load_Command;


    --  Callback whenever someone clicks on different parts of the table
    procedure Event_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        This : My_Table renames My_Table (Item);
        Col  : constant Positive := This.Callback_Column;
    begin
        case This.Callback_Context is
        when Tbl.Column_Header =>
            --  someone clicked on column header
            if FLTK.Events.Last = FLTK.Release and then
                FLTK.Events.Last_Button = FLTK.Left_Button
            then
                if This.Sort_Lastcol = Col then
                    --  Click same column? Toggle sort
                    This.Sort_Reverse := not This.Sort_Reverse;
                else
                    --  Click diff column? Up sort
                    This.Sort_Reverse := False;
                end if;
                Sort_Column (This, Col, This.Sort_Reverse);
                This.Sort_Lastcol := Col;
            end if;
        when others =>
            null;
        end case;
    end Event_Callback;


    The_Window : DW.Double_Window := DW.Forge.Create (900, 500, "Table Sort");

    The_Table : My_Table :=
        (TR.Forge.Create (The_Window, Margin, Margin, 900 - Margin * 2, 500 - Margin * 2)
         with others => <>);


begin


    The_Table.End_Current;
    The_Table.Set_Callback (Event_Callback'Unrestricted_Access);

    The_Table.Set_Selection_Color (FLTK.Yellow_Color);
    The_Table.Set_Column_Headers (True);
    The_Table.Set_Column_Resize (True);
    The_Table.Set_When (FLTK.When_Release);   --  handle table events on release
    Load_Command (The_Table, Dir_Cmd);         --  load table with a directory listing
    The_Table.Set_All_Rows_Height (18);        --  height of all rows
    The_Table.Set_Tooltip ("Click on column headings to toggle column sorting");
    The_Table.Set_Background_Color (FLTK.White_Color);
    The_Window.End_Current;
    The_Window.Set_Resizable (The_Table);
    Resize_Window (The_Table);
    The_Window.Show;
    return FLTK.Run;


end Table_Sort;
