--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/grid_alignment.cxx: boxes in a 7x7 Fl_Grid showing how a
--  widget is aligned in its cell, with a vertical line and a title and a
--  footer spanning cells, and inputs and a button of fixed height.
--  FLTK's rows and columns are numbered from 0, FLTKAda's from 1.  The
--  boxes are allocated, in FLTK's order, and freed after the event loop.
--  Guided by pofltk's GridAlignment.Mod.


with

    Ada.Unchecked_Deallocation,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Grids,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text;

use type

    FLTK.Alignment,
    FLTK.Widgets.Groups.Grids.Grid_Alignment;


function Grid_Alignment
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Grd renames FLTK.Widgets.Groups.Grids;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Inp renames FLTK.Widgets.Inputs.Text;

    type Box_Access is access Bx.Box;

    procedure Free is new Ada.Unchecked_Deallocation (Bx.Box, Box_Access);

    Boxes : array (1 .. 32) of Box_Access;
    Count : Natural := 0;

begin

    FLTK.Static.Parse_Args;

    declare

        Win  : Dbl.Double_Window := Dbl.Forge.Create (440, 350, "Fl_Grid Alignment Test");
        Grid : Grd.Grid := Grd.Forge.Create (Win, 10, 10, 420, 330);


        --  A new box in the grid, of a flat box and a colour.
        function New_Box
               (W, H : in Integer;
                Hue  : in FLTK.Color := FLTK.Background_Color)
            return Box_Access is
        begin
            Count := Count + 1;
            Boxes (Count) := new Bx.Box'(Bx.Forge.Create (Grid, 0, 0, W, H));
            Boxes (Count).Set_Box (FLTK.Flat_Box);
            Boxes (Count).Set_Background_Color (Hue);
            return Boxes (Count);
        end New_Box;

        B : Box_Access;

    begin

        Grid.Set_Layout (7, 7, 8, 4);  --  cols, rows, margin, gap
        Grid.Set_Box (FLTK.Flat_Box);
        Grid.Set_Background_Color (FLTK.White_Color);

        --  add boxes (top and bottom rows)

        for Col in 1 .. 7 loop
            Grid.Set_Column_Width (Col, 50);
            B := New_Box (20, 20, FLTK.Blue_Color);  --  variable size
            if Col = 6 then
                B.Resize (4, 20);                     --  reduce width
                Grid.Set_Column_Width (Col, 4);       --  new min. width
                Grid.Set_Column_Weight (Col, 0);      --  no hor. resizing
            end if;
            Grid.Set_Widget (B.all, 1, Col);

            if Col = 6 then
                B := New_Box (4, 20, FLTK.Red_Color);   --  variable size
            else
                B := New_Box (20, 20, FLTK.Red_Color);  --  variable size
            end if;
            Grid.Set_Widget (B.all, 7, Col);
        end loop;

        --  add boxes (left and right columns)

        Grid.Set_Row_Height (1, 40);
        Grid.Set_Row_Height (7, 40);

        for Row in 2 .. 6 loop
            Grid.Set_Row_Height (Row, 40);
            B := New_Box (20, 20, FLTK.Red_Color);  --  fixed size, see alignment below
            case Row is
                when 2 => Grid.Set_Widget (B.all, Row, 1, Grd.Grid_Fill);
                when 3 => Grid.Set_Widget (B.all, Row, 1, Grd.Grid_Center);
                when 4 => Grid.Set_Widget (B.all, Row, 1, Grd.Grid_Bottom_Right);
                when 5 => Grid.Set_Widget (B.all, Row, 1, Grd.Grid_Bottom_Right);
                when others => Grid.Set_Widget (B.all, Row, 1, Grd.Grid_Top_Right);
            end case;

            B := New_Box (20, 20, FLTK.Green_Color);
            Grid.Set_Widget (B.all, Row, 7, Grd.Grid_Center);
        end loop;

        --  two more boxes to demonstrate widget alignment inside the cell;
        --  FLTK sets the cell's alignment after placing the widget, which
        --  is the same as placing it with that alignment

        B := New_Box (20, 20, FLTK.Magenta_Color);  --  fixed size
        Grid.Set_Widget (B.all, 5, 2, Grd.Grid_Bottom_Left);  --  alignment uses widget size
        B := New_Box (20, 20, FLTK.Magenta_Color);
        Grid.Set_Widget (B.all, 6, 2, Grd.Grid_Top_Left);     --  alignment uses widget size

        --  one vertical box (line), spanning 5 rows

        B := New_Box (2, 2, FLTK.Black_Color);  --  extends vertically
        Grid.Set_Widget (B.all, 2, 6, 5, 1, Grd.Grid_Vertical + Grd.Grid_Right);

        --  add a textbox with label or title, spanning 5 cells, centered

        Count := Count + 1;
        Boxes (Count) := new Bx.Box'(Bx.Forge.Create (Grid, 0, 0, 1, 1));  --  variable size
        B := Boxes (Count);
        B.Set_Label ("Hello, Fl_Grid !");
        B.Set_Label_Font (FLTK.Helvetica_Bold_Italic);
        B.Set_Label_Size (30);
        B.Set_Label_Kind (FLTK.Shadow_Label);
        Grid.Set_Widget (B.all, 2, 2, 1, 5);  --  rowspan = 1, colspan = 5

        --  add a footer textbox, spanning 3 cells, right aligned

        Count := Count + 1;
        Boxes (Count) := new Bx.Box'(Bx.Forge.Create (Grid, 0, 0, 1, 10));  --  variable size
        B := Boxes (Count);
        B.Set_Label ("FLTK/test/grid_alignment.cxx");
        B.Set_Label_Font (FLTK.Courier);
        B.Set_Label_Size (11);
        B.Set_Alignment (FLTK.Align_Inside + FLTK.Align_Right);
        Grid.Set_Widget (B.all, 6, 3, 1, 3, Grd.Grid_Horizontal + Grd.Grid_Bottom);

        declare

            --  input widgets with fixed size and alignment inside the cell
            I1 : constant Inp.Text_Input := Inp.Forge.Create (Grid, 0, 0, 100, 30, "Username:");
            I2 : constant Inp.Text_Input := Inp.Forge.Create (Grid, 0, 0, 100, 30, "Password:");

            --  the login button spans 2 columns
            BT : constant Btn.Button := Btn.Forge.Create (Grid, 0, 0, 10, 30, "Login");

        begin

            --  widget, row, col, rowspan, colspan, alignment; FLTK sets the
            --  inputs' alignment after placing them
            Grid.Set_Widget (I1, 3, 4, 1, 2, Grd.Grid_Horizontal);
            Grid.Set_Widget (I2, 4, 4, 1, 2, Grd.Grid_Horizontal);
            Grid.Set_Widget (BT, 5, 4, 1, 2, Grd.Grid_Horizontal);

            Grid.Set_Row_Weight (2, 90);
            Grid.Set_Row_Weight (3, 0);
            Grid.Set_Row_Weight (4, 0);
            Grid.Set_Row_Weight (5, 0);

            Grid.Set_Column_Weight (1, 30);
            Grid.Set_Column_Weight (5, 90);

            Grid.Set_Row_Gap (6, 12);

            Grid.End_Current;
            Grid.Layout;
            Win.End_Current;
            Win.Set_Resizable (Grid);
            Win.Set_Size_Range (440, 350);
            Win.Show_With_Args;

            return Result : constant Integer := FLTK.Run do
                Grid.Clear_Layout;
                for Item of Boxes (1 .. Count) loop
                    Free (Item);
                end loop;
            end return;

        end;

    end;

end Grid_Alignment;

