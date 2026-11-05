

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


package FLTK.Widgets.Groups.Grids is


    type Grid is new Group with private;

    type Grid_Reference (Data : not null access Grid'Class) is
        limited null record with Implicit_Dereference => Data;


    --  Rows and columns are numbered from 1, as elsewhere in the binding.
    --  For the array setters, element N applies to row or column N, and
    --  a negative value leaves that row or column unchanged.
    type Size_Array is array (Positive range <>) of Integer;




    --  Grid Alignment  --

    --  A bitmask, combined with "+" and removed with "-"
    type Grid_Alignment is private;

    function "+" (Left, Right : in Grid_Alignment) return Grid_Alignment;
    function "-" (Left, Right : in Grid_Alignment) return Grid_Alignment;

    Grid_Center       : constant Grid_Alignment;
    Grid_Top          : constant Grid_Alignment;
    Grid_Bottom       : constant Grid_Alignment;
    Grid_Left         : constant Grid_Alignment;
    Grid_Right        : constant Grid_Alignment;
    Grid_Horizontal   : constant Grid_Alignment;
    Grid_Vertical     : constant Grid_Alignment;
    Grid_Fill         : constant Grid_Alignment;
    Grid_Proportional : constant Grid_Alignment;
    Grid_Top_Left     : constant Grid_Alignment;
    Grid_Top_Right    : constant Grid_Alignment;
    Grid_Bottom_Left  : constant Grid_Alignment;
    Grid_Bottom_Right : constant Grid_Alignment;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Grid;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Grid;

    end Forge;




    --  Layout  --

    --  A negative Margin or Gap leaves the current value unchanged.  A
    --  span that a smaller grid cuts through is cut to fit (FLTK-issues.md F5).
    procedure Set_Layout
           (This          : in out Grid;
            Rows, Columns : in     Natural;
            Margin, Gap   : in     Integer := -1);

    procedure Layout
           (This : in out Grid);

    procedure Clear_Layout
           (This : in out Grid);

    function Get_Need_Layout
           (This : in Grid)
        return Boolean;

    procedure Set_Need_Layout
           (This : in out Grid;
            To   : in     Boolean := True);

    function Get_Rows
           (This : in Grid)
        return Natural;

    function Get_Columns
           (This : in Grid)
        return Natural;




    --  Margins and Gaps  --

    procedure Get_Margin
           (This                     : in     Grid;
            Left, Top, Right, Bottom :    out Integer);

    --  Returns whether all four margins are equal
    function Get_Margin
           (This                     : in     Grid;
            Left, Top, Right, Bottom :    out Integer)
        return Boolean;

    --  A negative value leaves that margin unchanged
    procedure Set_Margin
           (This               : in out Grid;
            Left               : in     Integer;
            Top, Right, Bottom : in     Integer := -1);

    procedure Get_Gap
           (This                : in     Grid;
            Row_Gap, Column_Gap :    out Integer);

    --  A negative value leaves that gap unchanged
    procedure Set_Gap
           (This       : in out Grid;
            Row_Gap    : in     Integer;
            Column_Gap : in     Integer := -1);




    --  Widget Assignment  --

    procedure Set_Widget
           (This        : in out Grid;
            Item        : in     Widget'Class;
            Row, Column : in     Positive;
            Align       : in     Grid_Alignment := Grid_Fill);

    --  Returns False if Row or Column is out of range, or if Item is not a child.
    --  The procedures do nothing then.
    function Set_Widget
           (This        : in out Grid;
            Item        : in     Widget'Class;
            Row, Column : in     Positive;
            Align       : in     Grid_Alignment := Grid_Fill)
        return Boolean;

    procedure Set_Widget
           (This                  : in out Grid;
            Item                  : in     Widget'Class;
            Row, Column           : in     Positive;
            Row_Span, Column_Span : in     Positive;
            Align                 : in     Grid_Alignment := Grid_Fill);

    --  As above, and False too if the span goes past the grid's edge.
    --  Set_Layout cuts a span to fit a grid made smaller, and it stays cut.
    function Set_Widget
           (This                  : in out Grid;
            Item                  : in     Widget'Class;
            Row, Column           : in     Positive;
            Row_Span, Column_Span : in     Positive;
            Align                 : in     Grid_Alignment := Grid_Fill)
        return Boolean;




    --  Cells  --

    --  Where Set_Widget put a widget.  Row and Column are the cell's top
    --  left.  Min_Width and Min_Height are the size the widget keeps where
    --  its alignment doesn't fill the cell, and a row or column the cell
    --  alone spans is at least as big; Set_Widget sets them to the
    --  widget's size.  FLTK frees a cell when its widget is set elsewhere
    --  or removed, or the layout is changed, so a cell is named by its
    --  widget.  Its span is set by Set_Widget, which checks it fits
    --  (FLTK-issues.md F27).
    type Cell_Info is record
        Row, Column           : Positive;
        Row_Span, Column_Span : Positive;
        Align                 : Grid_Alignment;
        Min_Width, Min_Height : Natural;
    end record;

    function Has_Cell
           (This : in Grid;
            Item : in Widget'Class)
        return Boolean;

    --  Raises Constraint_Error if Item has no cell in This.
    function Get_Cell
           (This : in Grid;
            Item : in Widget'Class)
        return Cell_Info;

    --  The widget whose cell's top left is at Row, Column, or null if
    --  there is none.
    function Cell_Widget
           (This        : in Grid;
            Row, Column : in Positive)
        return access Widget'Class;

    --  These lay the grid out again, which FLTK's own don't (F27), and
    --  raise Constraint_Error if Item has no cell in This.
    procedure Set_Cell_Alignment
           (This  : in out Grid;
            Item  : in     Widget'Class;
            Align : in     Grid_Alignment);

    procedure Set_Cell_Minimum_Size
           (This          : in out Grid;
            Item          : in     Widget'Class;
            Width, Height : in     Natural);




    --  Columns  --

    function Get_Column_Width
           (This   : in Grid;
            Column : in Positive)
        return Integer;

    procedure Set_Column_Width
           (This   : in out Grid;
            Column : in     Positive;
            Value  : in     Integer);

    procedure Set_Column_Width
           (This   : in out Grid;
            Values : in     Size_Array);

    function Get_Column_Weight
           (This   : in Grid;
            Column : in Positive)
        return Integer;

    procedure Set_Column_Weight
           (This   : in out Grid;
            Column : in     Positive;
            Value  : in     Integer);

    procedure Set_Column_Weight
           (This   : in out Grid;
            Values : in     Size_Array);

    function Get_Column_Gap
           (This   : in Grid;
            Column : in Positive)
        return Integer;

    procedure Set_Column_Gap
           (This   : in out Grid;
            Column : in     Positive;
            Value  : in     Integer);

    procedure Set_Column_Gap
           (This   : in out Grid;
            Values : in     Size_Array);

    function Computed_Column_Width
           (This   : in Grid;
            Column : in Positive)
        return Integer;




    --  Rows  --

    function Get_Row_Height
           (This : in Grid;
            Row  : in Positive)
        return Integer;

    procedure Set_Row_Height
           (This  : in out Grid;
            Row   : in     Positive;
            Value : in     Integer);

    procedure Set_Row_Height
           (This   : in out Grid;
            Values : in     Size_Array);

    function Get_Row_Weight
           (This : in Grid;
            Row  : in Positive)
        return Integer;

    procedure Set_Row_Weight
           (This  : in out Grid;
            Row   : in     Positive;
            Value : in     Integer);

    procedure Set_Row_Weight
           (This   : in out Grid;
            Values : in     Size_Array);

    function Get_Row_Gap
           (This : in Grid;
            Row  : in Positive)
        return Integer;

    procedure Set_Row_Gap
           (This  : in out Grid;
            Row   : in     Positive;
            Value : in     Integer);

    procedure Set_Row_Gap
           (This   : in out Grid;
            Values : in     Size_Array);

    function Computed_Row_Height
           (This : in Grid;
            Row  : in Positive)
        return Integer;




    --  Debugging  --

    procedure Show_Grid
           (This  : in out Grid;
            State : in     Boolean);

    procedure Show_Grid
           (This       : in out Grid;
            State      : in     Boolean;
            Line_Color : in     Color);

    --  Prints the layout to standard error
    procedure Debug
           (This  : in out Grid;
            Level : in     Integer := 127);




    --  Drawing, Events  --

    procedure Draw
           (This : in out Grid);

    function Handle
           (This  : in out Grid;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Grid is new Group with null record;

    overriding procedure Initialize
           (This : in out Grid);

    overriding procedure Finalize
           (This : in out Grid);

    procedure Extra_Init
           (This       : in out Grid;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Grid)
    with Inline;


    type Grid_Alignment is mod 2 ** 16
    with Default_Value => 0;

    for Grid_Alignment'Size use 16;

    pragma Import (C, Grid_Center,       "fl_grid_center");
    pragma Import (C, Grid_Top,          "fl_grid_top");
    pragma Import (C, Grid_Bottom,       "fl_grid_bottom");
    pragma Import (C, Grid_Left,         "fl_grid_left");
    pragma Import (C, Grid_Right,        "fl_grid_right");
    pragma Import (C, Grid_Horizontal,   "fl_grid_horizontal");
    pragma Import (C, Grid_Vertical,     "fl_grid_vertical");
    pragma Import (C, Grid_Fill,         "fl_grid_fill");
    pragma Import (C, Grid_Proportional, "fl_grid_proportional");
    pragma Import (C, Grid_Top_Left,     "fl_grid_top_left");
    pragma Import (C, Grid_Top_Right,    "fl_grid_top_right");
    pragma Import (C, Grid_Bottom_Left,  "fl_grid_bottom_left");
    pragma Import (C, Grid_Bottom_Right, "fl_grid_bottom_right");


    pragma Inline ("+");
    pragma Inline ("-");

    pragma Inline (Set_Layout);
    pragma Inline (Layout);
    pragma Inline (Clear_Layout);
    pragma Inline (Get_Need_Layout);
    pragma Inline (Set_Need_Layout);
    pragma Inline (Get_Rows);
    pragma Inline (Get_Columns);

    pragma Inline (Get_Margin);
    pragma Inline (Set_Margin);
    pragma Inline (Get_Gap);
    pragma Inline (Set_Gap);

    pragma Inline (Set_Widget);

    pragma Inline (Get_Column_Width);
    pragma Inline (Set_Column_Width);
    pragma Inline (Get_Column_Weight);
    pragma Inline (Set_Column_Weight);
    pragma Inline (Get_Column_Gap);
    pragma Inline (Set_Column_Gap);
    pragma Inline (Computed_Column_Width);

    pragma Inline (Get_Row_Height);
    pragma Inline (Set_Row_Height);
    pragma Inline (Get_Row_Weight);
    pragma Inline (Set_Row_Weight);
    pragma Inline (Get_Row_Gap);
    pragma Inline (Set_Row_Gap);
    pragma Inline (Computed_Row_Height);

    pragma Inline (Show_Grid);
    pragma Inline (Debug);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Grids;


