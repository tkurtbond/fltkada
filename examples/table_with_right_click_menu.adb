

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/table-with-right-click-menu.cxx: a simple
--  table that posts a context sensitive popup menu when cells or column
--  headers are right clicked.
--
--  Draw_Cell and the Callback_Row/Callback_Column functions are 1-based,
--  so the labels print Row - 1 to match the 0-based numbers the original
--  shows.


with

    Ada.Text_IO,
    FLTK.Draw,
    FLTK.Events,
    FLTK.Widgets.Groups.Tables,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Menu_Buttons;

use type

    FLTK.Menu_Flag,
    FLTK.Mouse_Button;


function Table_With_Right_Click_Menu
    return Integer
is


    package FD  renames FLTK.Draw;
    package Tbl renames FLTK.Widgets.Groups.Tables;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;
    package Men renames FLTK.Widgets.Menus;
    package MB  renames FLTK.Widgets.Menus.Menu_Buttons;

    use type Tbl.Table_Context;


    Max_Rows : constant := 30;
    Max_Cols : constant := 26;   --  A-Z


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


    --  'A' + Column, for a 1-based Column
    function Column_Letter
           (Column : in Positive)
        return Character is
    begin
        return Character'Val (Character'Pos ('A') + Column - 1);
    end Column_Letter;


    type My_Table is new Tbl.Table with null record;

    overriding procedure Draw_Cell
           (This        : in out My_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0);


    --  Post context menu at current event x,y
    procedure Post_Context_Menu
           (This : in out My_Table)
    is
        Context : constant Tbl.Table_Context := This.Callback_Context;
    begin
        case Context is
        when Tbl.Column_Header | Tbl.Within_Cell =>
            declare
                --  Create context sensitive menu label
                S : constant String :=
                    (if Context = Tbl.Within_Cell
                     then "Cell " & Column_Letter (This.Callback_Column) &
                         Image (This.Callback_Row - 1)
                     else "Column " & Column_Letter (This.Callback_Column));

                --  Post dynamically created context menu, get user's choice
                Menu : MB.Menu_Button :=
                    MB.Forge.Create (FLTK.Events.Mouse_X, FLTK.Events.Mouse_Y, 80, 1);
                Item : Men.Extended_Index;
            begin
                Menu.Add (S, Flags => FLTK.Flag_Divider + FLTK.Flag_Inactive);
                --  The null Action picks one of the otherwise ambiguous Add overloads
                Menu.Add ("Item 1", null);
                Menu.Add ("Item 2", null);
                Item := Menu.Popup;
                if Item /= Men.No_Index then
                    Ada.Text_IO.Put_Line ("You chose '" & Menu.Get_Label (Place => Item) & "'");
                end if;
            end;
        when others =>
            null;
        end case;
    end Post_Context_Menu;


    --  My_Table callback
    procedure My_Callback
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if FLTK.Events.Last_Button = FLTK.Right_Button then
            Post_Context_Menu (My_Table (Item));
        end if;
    end My_Callback;


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


    --  Draw the cells
    procedure Draw_Data
           (This       : in My_Table;
            S          : in String;
            X, Y, W, H : in Integer) is
    begin
        FD.Push_Clip (X, Y, W, H);
        FD.Set_Color (FLTK.White_Color);
        FD.Rect_Fill (X, Y, W, H);                       --  Draw cell bg
        FD.Set_Color (FLTK.Grey0_Color);
        FD.Draw_Text (X, Y, W, H, S, FLTK.Align_Center);  --  Draw cell text
        FD.Set_Color (This.Get_Background_Color);
        FD.Rect (X, Y, W, H);                            --  Draw box border
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
            Draw_Header (This, (1 => Column_Letter (Column)), X, Y, W, H);
        when Tbl.Row_Header =>
            --  "000:", "001:", etc
            Draw_Header (This, Row_Image (Row - 1), X, Y, W, H);
        when Tbl.Within_Cell =>
            Draw_Data (This, Column_Letter (Column) & Image (Row - 1), X, Y, W, H);
        when others =>
            null;
        end case;
    end Draw_Cell;


    The_Window : DW.Double_Window := DW.Forge.Create (900, 400, "Table Simple");

    The_Table : My_Table :=
        (Tbl.Forge.Create (The_Window, 10, 10, 880, 380) with null record);


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
    The_Table.Set_Callback (My_Callback'Unrestricted_Access);   --  set a callback for the table

    The_Window.End_Current;
    The_Window.Set_Resizable (The_Table);
    The_Window.Show_With_Args;
    return FLTK.Run;


end Table_With_Right_Click_Menu;
