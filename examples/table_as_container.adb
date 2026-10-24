

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/table-as-container.cxx: a table whose
--  cells are live FLTK widgets, alternating input fields and light
--  buttons.
--
--  Draw_Cell gets 1-based rows and columns, so the headers print
--  Row - 1 and Column - 1 to match the 0-based numbers the original shows.


with

    Ada.Text_IO,
    FLTK.Draw,
    FLTK.Widgets.Buttons.Light,
    FLTK.Widgets.Groups.Tables,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text;

use type

    FLTK.Alignment;


function Table_As_Container
    return Integer
is


    package FD  renames FLTK.Draw;
    package Btn renames FLTK.Widgets.Buttons;
    package LB  renames FLTK.Widgets.Buttons.Light;
    package Tbl renames FLTK.Widgets.Groups.Tables;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;
    package TI  renames FLTK.Widgets.Inputs.Text;


    --  The table owns these for the rest of the program, as in the original
    type Input_Access is access TI.Text_Input;
    type Button_Access is access LB.Light_Button;


    function Image
           (N : in Integer)
        return String
    is
        S : constant String := Integer'Image (N);
    begin
        return S (S'First + 1 .. S'Last);
    end Image;


    procedure Button_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error, "BUTTON: " & Item.Get_Label);
    end Button_CB;


    --  Simple demonstration type deriving from Table
    type Widget_Table is new Tbl.Table with null record;

    --  table cell drawing
    overriding procedure Draw_Cell
           (This        : in out Widget_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0);


    procedure Set_Size
           (This     : in out Widget_Table;
            New_Rows : in     Natural;
            New_Cols : in     Natural) is
    begin
        This.Clear;            --  clear any previous widgets, if any
        This.Set_Rows (New_Rows);
        This.Set_Columns (New_Cols);

        This.Begin_Current;    --  start adding widgets to group
        for R in 1 .. New_Rows loop
            for C in 1 .. New_Cols loop
                declare
                    X, Y, W, H : Integer;
                begin
                    This.Cell_Dimensions (Tbl.Dead_Zone, R, C, X, Y, W, H);

                    if (C - 1) mod 2 = 1 then
                        --  Create the input widgets
                        declare
                            Field : constant Input_Access :=
                                new TI.Text_Input'(TI.Forge.Create (X, Y, W, H));
                        begin
                            Field.Set_Value (Image (R - 1) & "." & Image (C - 1));
                        end;
                    else
                        --  Create the light buttons
                        declare
                            Butt : constant Button_Access :=
                                new LB.Light_Button'(LB.Forge.Create (X, Y, W, H));
                        begin
                            Butt.Set_Label (Image (R - 1) & "/" & Image (C - 1) & " ");
                            Butt.Set_Alignment (FLTK.Align_Center + FLTK.Align_Inside);
                            Butt.Set_Callback (Button_CB'Unrestricted_Access);
                            Butt.Set_State
                               (if ((R - 1) + (C - 1) * 2) mod 8 >= 4 then Btn.On else Btn.Off);
                        end;
                    end if;
                end;
            end loop;
        end loop;
        This.End_Current;
    end Set_Size;


    --  Handle drawing all cells in table
    overriding procedure Draw_Cell
           (This        : in out Widget_Table;
            Context     : in     Tbl.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0) is
    begin
        case Context is
        when Tbl.Start_Page =>
            FD.Set_Font (FLTK.Helvetica, 12);   --  font used by all headers

        when Tbl.Row_Column_Resize =>
            declare
                CX, CY, CW, CH : Integer;
                Index          : Positive := 1;
            begin
                Rows : for R in 1 .. This.Get_Rows loop
                    for C in 1 .. This.Get_Columns loop
                        exit Rows when Index > This.Number_Of_Children;
                        This.Cell_Dimensions (Tbl.Dead_Zone, R, C, CX, CY, CW, CH);
                        This.Child (Index).Resize (CX, CY, CW, CH);
                        Index := Index + 1;
                    end loop;
                end loop Rows;
                This.Reset_Sizes;   --  tell group children resized
            end;

        when Tbl.Row_Header =>
            FD.Push_Clip (X, Y, W, H);
            FD.Draw_Box (X, Y, W, H, FLTK.Thin_Up_Box, This.Get_Row_Header_Color);
            FD.Set_Color (FLTK.Black_Color);
            FD.Draw_Text (X, Y, W, H, "Row " & Image (Row - 1), FLTK.Align_Center);
            FD.Pop_Clip;

        when Tbl.Column_Header =>
            FD.Push_Clip (X, Y, W, H);
            FD.Draw_Box (X, Y, W, H, FLTK.Thin_Up_Box, This.Get_Column_Header_Color);
            FD.Set_Color (FLTK.Black_Color);
            FD.Draw_Text (X, Y, W, H, "Column " & Image (Column - 1), FLTK.Align_Center);
            FD.Pop_Clip;

        when Tbl.Within_Cell =>
            null;   --  fltk handles drawing the widgets

        when others =>
            null;
        end case;
    end Draw_Cell;


    Win_W : constant := 940;
    Win_H : constant := 500;

    The_Window : DW.Double_Window := DW.Forge.Create (Win_W, Win_H, "Table As Container");

    The_Table : Widget_Table :=
        (Tbl.Forge.Create (The_Window, 20, 20, Win_W - 40, Win_H - 40, "FLTK widget table")
         with null record);


begin


    The_Table.Set_Column_Headers (True);
    The_Table.Set_Column_Resize (True);
    The_Table.Set_Column_Header_Height (25);
    The_Table.Set_Row_Headers (True);
    The_Table.Set_Row_Resize (True);
    The_Table.Set_Row_Header_Width (80);
    The_Table.End_Current;

    Set_Size (The_Table, 50, 50);
    The_Window.End_Current;
    The_Window.Set_Resizable (The_Table);
    The_Window.Show;
    return FLTK.Run;


end Table_As_Container;
