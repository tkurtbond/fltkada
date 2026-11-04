

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    Interfaces.C,
    System;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Groups.Grids is


    type C_Size_Array is array (Positive range <>) of aliased Interfaces.C.int
    with Convention => C;




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_grid
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_grid, "new_fl_grid");
    pragma Inline (new_fl_grid);

    procedure free_fl_grid
           (G : in Storage.Integer_Address);
    pragma Import (C, free_fl_grid, "free_fl_grid");
    pragma Inline (free_fl_grid);




    --  Layout  --

    procedure fl_grid_set_layout
           (G          : in Storage.Integer_Address;
            R, C, M, P : in Interfaces.C.int);
    pragma Import (C, fl_grid_set_layout, "fl_grid_set_layout");
    pragma Inline (fl_grid_set_layout);

    procedure fl_grid_layout
           (G : in Storage.Integer_Address);
    pragma Import (C, fl_grid_layout, "fl_grid_layout");
    pragma Inline (fl_grid_layout);

    procedure fl_grid_clear_layout
           (G : in Storage.Integer_Address);
    pragma Import (C, fl_grid_clear_layout, "fl_grid_clear_layout");
    pragma Inline (fl_grid_clear_layout);

    function fl_grid_get_need_layout
           (G : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_get_need_layout, "fl_grid_get_need_layout");
    pragma Inline (fl_grid_get_need_layout);

    procedure fl_grid_set_need_layout
           (G : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_grid_set_need_layout, "fl_grid_set_need_layout");
    pragma Inline (fl_grid_set_need_layout);

    function fl_grid_rows
           (G : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_rows, "fl_grid_rows");
    pragma Inline (fl_grid_rows);

    function fl_grid_cols
           (G : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_cols, "fl_grid_cols");
    pragma Inline (fl_grid_cols);




    --  Margins and Gaps  --

    function fl_grid_get_margin
           (G          : in     Storage.Integer_Address;
            L, T, R, B :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_get_margin, "fl_grid_get_margin");
    pragma Inline (fl_grid_get_margin);

    procedure fl_grid_set_margin
           (G          : in Storage.Integer_Address;
            L, T, R, B : in Interfaces.C.int);
    pragma Import (C, fl_grid_set_margin, "fl_grid_set_margin");
    pragma Inline (fl_grid_set_margin);

    procedure fl_grid_get_gap
           (G    : in     Storage.Integer_Address;
            R, C :    out Interfaces.C.int);
    pragma Import (C, fl_grid_get_gap, "fl_grid_get_gap");
    pragma Inline (fl_grid_get_gap);

    procedure fl_grid_set_gap
           (G    : in Storage.Integer_Address;
            R, C : in Interfaces.C.int);
    pragma Import (C, fl_grid_set_gap, "fl_grid_set_gap");
    pragma Inline (fl_grid_set_gap);




    --  Widget Assignment  --

    function fl_grid_set_widget
           (G, W : in Storage.Integer_Address;
            R, C : in Interfaces.C.int;
            A    : in Grid_Alignment)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_set_widget, "fl_grid_set_widget");
    pragma Inline (fl_grid_set_widget);

    function fl_grid_set_widget2
           (G, W         : in Storage.Integer_Address;
            R, C, RS, CS : in Interfaces.C.int;
            A            : in Grid_Alignment)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_set_widget2, "fl_grid_set_widget2");
    pragma Inline (fl_grid_set_widget2);




    --  Columns  --

    procedure fl_grid_set_col_width
           (G    : in Storage.Integer_Address;
            C, V : in Interfaces.C.int);
    pragma Import (C, fl_grid_set_col_width, "fl_grid_set_col_width");
    pragma Inline (fl_grid_set_col_width);

    procedure fl_grid_set_col_width2
           (G : in Storage.Integer_Address;
            V : in System.Address;
            S : in Interfaces.C.size_t);
    pragma Import (C, fl_grid_set_col_width2, "fl_grid_set_col_width2");
    pragma Inline (fl_grid_set_col_width2);

    function fl_grid_get_col_width
           (G : in Storage.Integer_Address;
            C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_get_col_width, "fl_grid_get_col_width");
    pragma Inline (fl_grid_get_col_width);

    procedure fl_grid_set_col_weight
           (G    : in Storage.Integer_Address;
            C, V : in Interfaces.C.int);
    pragma Import (C, fl_grid_set_col_weight, "fl_grid_set_col_weight");
    pragma Inline (fl_grid_set_col_weight);

    procedure fl_grid_set_col_weight2
           (G : in Storage.Integer_Address;
            V : in System.Address;
            S : in Interfaces.C.size_t);
    pragma Import (C, fl_grid_set_col_weight2, "fl_grid_set_col_weight2");
    pragma Inline (fl_grid_set_col_weight2);

    function fl_grid_get_col_weight
           (G : in Storage.Integer_Address;
            C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_get_col_weight, "fl_grid_get_col_weight");
    pragma Inline (fl_grid_get_col_weight);

    procedure fl_grid_set_col_gap
           (G    : in Storage.Integer_Address;
            C, V : in Interfaces.C.int);
    pragma Import (C, fl_grid_set_col_gap, "fl_grid_set_col_gap");
    pragma Inline (fl_grid_set_col_gap);

    procedure fl_grid_set_col_gap2
           (G : in Storage.Integer_Address;
            V : in System.Address;
            S : in Interfaces.C.size_t);
    pragma Import (C, fl_grid_set_col_gap2, "fl_grid_set_col_gap2");
    pragma Inline (fl_grid_set_col_gap2);

    function fl_grid_get_col_gap
           (G : in Storage.Integer_Address;
            C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_get_col_gap, "fl_grid_get_col_gap");
    pragma Inline (fl_grid_get_col_gap);

    function fl_grid_computed_col_width
           (G : in Storage.Integer_Address;
            C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_computed_col_width, "fl_grid_computed_col_width");
    pragma Inline (fl_grid_computed_col_width);




    --  Rows  --

    procedure fl_grid_set_row_height
           (G    : in Storage.Integer_Address;
            R, V : in Interfaces.C.int);
    pragma Import (C, fl_grid_set_row_height, "fl_grid_set_row_height");
    pragma Inline (fl_grid_set_row_height);

    procedure fl_grid_set_row_height2
           (G : in Storage.Integer_Address;
            V : in System.Address;
            S : in Interfaces.C.size_t);
    pragma Import (C, fl_grid_set_row_height2, "fl_grid_set_row_height2");
    pragma Inline (fl_grid_set_row_height2);

    function fl_grid_get_row_height
           (G : in Storage.Integer_Address;
            R : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_get_row_height, "fl_grid_get_row_height");
    pragma Inline (fl_grid_get_row_height);

    procedure fl_grid_set_row_weight
           (G    : in Storage.Integer_Address;
            R, V : in Interfaces.C.int);
    pragma Import (C, fl_grid_set_row_weight, "fl_grid_set_row_weight");
    pragma Inline (fl_grid_set_row_weight);

    procedure fl_grid_set_row_weight2
           (G : in Storage.Integer_Address;
            V : in System.Address;
            S : in Interfaces.C.size_t);
    pragma Import (C, fl_grid_set_row_weight2, "fl_grid_set_row_weight2");
    pragma Inline (fl_grid_set_row_weight2);

    function fl_grid_get_row_weight
           (G : in Storage.Integer_Address;
            R : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_get_row_weight, "fl_grid_get_row_weight");
    pragma Inline (fl_grid_get_row_weight);

    procedure fl_grid_set_row_gap
           (G    : in Storage.Integer_Address;
            R, V : in Interfaces.C.int);
    pragma Import (C, fl_grid_set_row_gap, "fl_grid_set_row_gap");
    pragma Inline (fl_grid_set_row_gap);

    procedure fl_grid_set_row_gap2
           (G : in Storage.Integer_Address;
            V : in System.Address;
            S : in Interfaces.C.size_t);
    pragma Import (C, fl_grid_set_row_gap2, "fl_grid_set_row_gap2");
    pragma Inline (fl_grid_set_row_gap2);

    function fl_grid_get_row_gap
           (G : in Storage.Integer_Address;
            R : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_get_row_gap, "fl_grid_get_row_gap");
    pragma Inline (fl_grid_get_row_gap);

    function fl_grid_computed_row_height
           (G : in Storage.Integer_Address;
            R : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_computed_row_height, "fl_grid_computed_row_height");
    pragma Inline (fl_grid_computed_row_height);




    --  Debugging  --

    procedure fl_grid_show_grid
           (G : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_grid_show_grid, "fl_grid_show_grid");
    pragma Inline (fl_grid_show_grid);

    procedure fl_grid_show_grid2
           (G : in Storage.Integer_Address;
            S : in Interfaces.C.int;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_grid_show_grid2, "fl_grid_show_grid2");
    pragma Inline (fl_grid_show_grid2);

    procedure fl_grid_debug
           (G : in Storage.Integer_Address;
            L : in Interfaces.C.int);
    pragma Import (C, fl_grid_debug, "fl_grid_debug");
    pragma Inline (fl_grid_debug);




    --  Drawing, Events  --

    procedure fl_grid_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_grid_draw, "fl_grid_draw");
    pragma Inline (fl_grid_draw);

    function fl_grid_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_grid_handle, "fl_grid_handle");
    pragma Inline (fl_grid_handle);




    ------------------------
    --  Internal Utility  --
    ------------------------

    function To_C
           (Values : in Size_Array)
        return C_Size_Array is
    begin
        return Result : C_Size_Array (1 .. Values'Length) do
            for I in Result'Range loop
                Result (I) := Interfaces.C.int (Values (Values'First + I - 1));
            end loop;
        end return;
    end To_C;




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Grid) is
    begin
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Grid) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_grid (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Grid;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Grid) is
    begin
        This.Draw_Ptr   := fl_grid_draw'Address;
        This.Handle_Ptr := fl_grid_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Grid is
        begin
            return This : Grid do
                This.Void_Ptr := new_fl_grid
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Grid is
        begin
            return This : Grid := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Grid Alignment  --

    function "+"
           (Left, Right : in Grid_Alignment)
        return Grid_Alignment is
    begin
        return Left or Right;
    end "+";


    function "-"
           (Left, Right : in Grid_Alignment)
        return Grid_Alignment is
    begin
        return Left and not Right;
    end "-";




    --  Layout  --

    procedure Set_Layout
           (This          : in out Grid;
            Rows, Columns : in     Natural;
            Margin, Gap   : in     Integer := -1) is
    begin
        fl_grid_set_layout
           (This.Void_Ptr,
            Interfaces.C.int (Rows),
            Interfaces.C.int (Columns),
            Interfaces.C.int (Margin),
            Interfaces.C.int (Gap));
    end Set_Layout;


    procedure Layout
           (This : in out Grid) is
    begin
        fl_grid_layout (This.Void_Ptr);
    end Layout;


    procedure Clear_Layout
           (This : in out Grid) is
    begin
        fl_grid_clear_layout (This.Void_Ptr);
    end Clear_Layout;


    function Get_Need_Layout
           (This : in Grid)
        return Boolean is
    begin
        return fl_grid_get_need_layout (This.Void_Ptr) /= 0;
    end Get_Need_Layout;


    procedure Set_Need_Layout
           (This : in out Grid;
            To   : in     Boolean := True) is
    begin
        fl_grid_set_need_layout (This.Void_Ptr, Boolean'Pos (To));
    end Set_Need_Layout;


    function Get_Rows
           (This : in Grid)
        return Natural is
    begin
        return Natural (fl_grid_rows (This.Void_Ptr));
    end Get_Rows;


    function Get_Columns
           (This : in Grid)
        return Natural is
    begin
        return Natural (fl_grid_cols (This.Void_Ptr));
    end Get_Columns;




    --  Margins and Gaps  --

    procedure Get_Margin
           (This                     : in     Grid;
            Left, Top, Right, Bottom :    out Integer)
    is
        Ignore_Ret : Boolean;
    begin
        Ignore_Ret := This.Get_Margin (Left, Top, Right, Bottom);
    end Get_Margin;


    function Get_Margin
           (This                     : in     Grid;
            Left, Top, Right, Bottom :    out Integer)
        return Boolean
    is
        L, T, R, B : Interfaces.C.int;
        Result     : constant Interfaces.C.int :=
            fl_grid_get_margin (This.Void_Ptr, L, T, R, B);
    begin
        Left   := Integer (L);
        Top    := Integer (T);
        Right  := Integer (R);
        Bottom := Integer (B);
        return Result /= 0;
    end Get_Margin;


    procedure Set_Margin
           (This               : in out Grid;
            Left               : in     Integer;
            Top, Right, Bottom : in     Integer := -1) is
    begin
        fl_grid_set_margin
           (This.Void_Ptr,
            Interfaces.C.int (Left),
            Interfaces.C.int (Top),
            Interfaces.C.int (Right),
            Interfaces.C.int (Bottom));
    end Set_Margin;


    procedure Get_Gap
           (This                : in     Grid;
            Row_Gap, Column_Gap :    out Integer)
    is
        R, C : Interfaces.C.int;
    begin
        fl_grid_get_gap (This.Void_Ptr, R, C);
        Row_Gap    := Integer (R);
        Column_Gap := Integer (C);
    end Get_Gap;


    procedure Set_Gap
           (This       : in out Grid;
            Row_Gap    : in     Integer;
            Column_Gap : in     Integer := -1) is
    begin
        fl_grid_set_gap
           (This.Void_Ptr,
            Interfaces.C.int (Row_Gap),
            Interfaces.C.int (Column_Gap));
    end Set_Gap;




    --  Widget Assignment  --

    procedure Set_Widget
           (This        : in out Grid;
            Item        : in     Widget'Class;
            Row, Column : in     Positive;
            Align       : in     Grid_Alignment := Grid_Fill)
    is
        Ignore_Ret : Boolean;
    begin
        Ignore_Ret := This.Set_Widget (Item, Row, Column, Align);
    end Set_Widget;


    function Set_Widget
           (This        : in out Grid;
            Item        : in     Widget'Class;
            Row, Column : in     Positive;
            Align       : in     Grid_Alignment := Grid_Fill)
        return Boolean is
    begin
        --  Fl_Grid::widget makes a cell one past the last row or column
        --  (Fl_Grid.cxx:834-842, pofltk 21).
        if Row > This.Get_Rows or Column > This.Get_Columns then
            return False;
        end if;
        return fl_grid_set_widget
           (This.Void_Ptr,
            Item.Void_Ptr,
            Interfaces.C.int (Row) - 1,
            Interfaces.C.int (Column) - 1,
            Align) /= 0;
    end Set_Widget;


    procedure Set_Widget
           (This                  : in out Grid;
            Item                  : in     Widget'Class;
            Row, Column           : in     Positive;
            Row_Span, Column_Span : in     Positive;
            Align                 : in     Grid_Alignment := Grid_Fill)
    is
        Ignore_Ret : Boolean;
    begin
        Ignore_Ret := This.Set_Widget (Item, Row, Column, Row_Span, Column_Span, Align);
    end Set_Widget;


    function Set_Widget
           (This                  : in out Grid;
            Item                  : in     Widget'Class;
            Row, Column           : in     Positive;
            Row_Span, Column_Span : in     Positive;
            Align                 : in     Grid_Alignment := Grid_Fill)
        return Boolean is
    begin
        --  Fl_Grid::layout reads the rows and columns a span covers
        --  (Fl_Grid.cxx:470-478), so the span must fit as well (pofltk 21).
        if Row > This.Get_Rows or Column > This.Get_Columns
            or Row_Span > This.Get_Rows - Row + 1
            or Column_Span > This.Get_Columns - Column + 1
        then
            return False;
        end if;
        return fl_grid_set_widget2
           (This.Void_Ptr,
            Item.Void_Ptr,
            Interfaces.C.int (Row) - 1,
            Interfaces.C.int (Column) - 1,
            Interfaces.C.int (Row_Span),
            Interfaces.C.int (Column_Span),
            Align) /= 0;
    end Set_Widget;




    --  Columns  --

    function Get_Column_Width
           (This   : in Grid;
            Column : in Positive)
        return Integer is
    begin
        return Integer (fl_grid_get_col_width (This.Void_Ptr, Interfaces.C.int (Column) - 1));
    end Get_Column_Width;


    procedure Set_Column_Width
           (This   : in out Grid;
            Column : in     Positive;
            Value  : in     Integer) is
    begin
        fl_grid_set_col_width
           (This.Void_Ptr, Interfaces.C.int (Column) - 1, Interfaces.C.int (Value));
    end Set_Column_Width;


    procedure Set_Column_Width
           (This   : in out Grid;
            Values : in     Size_Array)
    is
        C_Values : constant C_Size_Array := To_C (Values);
    begin
        fl_grid_set_col_width2 (This.Void_Ptr, C_Values'Address, C_Values'Length);
    end Set_Column_Width;


    function Get_Column_Weight
           (This   : in Grid;
            Column : in Positive)
        return Integer is
    begin
        return Integer (fl_grid_get_col_weight (This.Void_Ptr, Interfaces.C.int (Column) - 1));
    end Get_Column_Weight;


    procedure Set_Column_Weight
           (This   : in out Grid;
            Column : in     Positive;
            Value  : in     Integer) is
    begin
        fl_grid_set_col_weight
           (This.Void_Ptr, Interfaces.C.int (Column) - 1, Interfaces.C.int (Value));
    end Set_Column_Weight;


    procedure Set_Column_Weight
           (This   : in out Grid;
            Values : in     Size_Array)
    is
        C_Values : constant C_Size_Array := To_C (Values);
    begin
        fl_grid_set_col_weight2 (This.Void_Ptr, C_Values'Address, C_Values'Length);
    end Set_Column_Weight;


    function Get_Column_Gap
           (This   : in Grid;
            Column : in Positive)
        return Integer is
    begin
        return Integer (fl_grid_get_col_gap (This.Void_Ptr, Interfaces.C.int (Column) - 1));
    end Get_Column_Gap;


    procedure Set_Column_Gap
           (This   : in out Grid;
            Column : in     Positive;
            Value  : in     Integer) is
    begin
        fl_grid_set_col_gap
           (This.Void_Ptr, Interfaces.C.int (Column) - 1, Interfaces.C.int (Value));
    end Set_Column_Gap;


    procedure Set_Column_Gap
           (This   : in out Grid;
            Values : in     Size_Array)
    is
        C_Values : constant C_Size_Array := To_C (Values);
    begin
        fl_grid_set_col_gap2 (This.Void_Ptr, C_Values'Address, C_Values'Length);
    end Set_Column_Gap;


    function Computed_Column_Width
           (This   : in Grid;
            Column : in Positive)
        return Integer is
    begin
        return Integer (fl_grid_computed_col_width (This.Void_Ptr, Interfaces.C.int (Column) - 1));
    end Computed_Column_Width;




    --  Rows  --

    function Get_Row_Height
           (This  : in Grid;
            Row   : in Positive)
        return Integer is
    begin
        return Integer (fl_grid_get_row_height (This.Void_Ptr, Interfaces.C.int (Row) - 1));
    end Get_Row_Height;


    procedure Set_Row_Height
           (This  : in out Grid;
            Row   : in     Positive;
            Value : in     Integer) is
    begin
        fl_grid_set_row_height
           (This.Void_Ptr, Interfaces.C.int (Row) - 1, Interfaces.C.int (Value));
    end Set_Row_Height;


    procedure Set_Row_Height
           (This   : in out Grid;
            Values : in     Size_Array)
    is
        C_Values : constant C_Size_Array := To_C (Values);
    begin
        fl_grid_set_row_height2 (This.Void_Ptr, C_Values'Address, C_Values'Length);
    end Set_Row_Height;


    function Get_Row_Weight
           (This  : in Grid;
            Row   : in Positive)
        return Integer is
    begin
        return Integer (fl_grid_get_row_weight (This.Void_Ptr, Interfaces.C.int (Row) - 1));
    end Get_Row_Weight;


    procedure Set_Row_Weight
           (This  : in out Grid;
            Row   : in     Positive;
            Value : in     Integer) is
    begin
        fl_grid_set_row_weight
           (This.Void_Ptr, Interfaces.C.int (Row) - 1, Interfaces.C.int (Value));
    end Set_Row_Weight;


    procedure Set_Row_Weight
           (This   : in out Grid;
            Values : in     Size_Array)
    is
        C_Values : constant C_Size_Array := To_C (Values);
    begin
        fl_grid_set_row_weight2 (This.Void_Ptr, C_Values'Address, C_Values'Length);
    end Set_Row_Weight;


    function Get_Row_Gap
           (This  : in Grid;
            Row   : in Positive)
        return Integer is
    begin
        return Integer (fl_grid_get_row_gap (This.Void_Ptr, Interfaces.C.int (Row) - 1));
    end Get_Row_Gap;


    procedure Set_Row_Gap
           (This  : in out Grid;
            Row   : in     Positive;
            Value : in     Integer) is
    begin
        fl_grid_set_row_gap
           (This.Void_Ptr, Interfaces.C.int (Row) - 1, Interfaces.C.int (Value));
    end Set_Row_Gap;


    procedure Set_Row_Gap
           (This   : in out Grid;
            Values : in     Size_Array)
    is
        C_Values : constant C_Size_Array := To_C (Values);
    begin
        fl_grid_set_row_gap2 (This.Void_Ptr, C_Values'Address, C_Values'Length);
    end Set_Row_Gap;


    function Computed_Row_Height
           (This : in Grid;
            Row  : in Positive)
        return Integer is
    begin
        return Integer (fl_grid_computed_row_height (This.Void_Ptr, Interfaces.C.int (Row) - 1));
    end Computed_Row_Height;




    --  Debugging  --

    procedure Show_Grid
           (This  : in out Grid;
            State : in     Boolean) is
    begin
        fl_grid_show_grid (This.Void_Ptr, Boolean'Pos (State));
    end Show_Grid;


    procedure Show_Grid
           (This       : in out Grid;
            State      : in     Boolean;
            Line_Color : in     Color) is
    begin
        fl_grid_show_grid2
           (This.Void_Ptr,
            Boolean'Pos (State),
            Interfaces.C.unsigned (Line_Color));
    end Show_Grid;


    procedure Debug
           (This  : in out Grid;
            Level : in     Integer := 127) is
    begin
        fl_grid_debug (This.Void_Ptr, Interfaces.C.int (Level));
    end Debug;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Grid) is
    begin
        Group (This).Draw;
    end Draw;


    function Handle
           (This  : in out Grid;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Group (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups.Grids;


