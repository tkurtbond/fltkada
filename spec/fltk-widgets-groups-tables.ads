

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups.Scrolls,
    FLTK.Widgets.Valuators.Sliders.Scrollbars;

private with

    Interfaces.C;


package FLTK.Widgets.Groups.Tables is


    type Table is new Group with private;

    type Table_Reference (Data : not null access Table'Class) is limited null record
        with Implicit_Dereference => Data;

    type Table_Context is
       (No_Context,    Start_Page,  End_Page,  Row_Header,
        Column_Header, Within_Cell, Dead_Zone, Row_Column_Resize);

    type Resize_Flag is (Resize_None, Column_Left, Column_Right, Row_Above, Row_Below);

    type Tab_Navigation is (Widget_Focus, Navigate_Cells);


    Out_Of_Range_Error : exception;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Table;

        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Table;

    end Forge;




    function H_Bar
           (This : in out Table)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference;

    function V_Bar
           (This : in out Table)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference;

    function Scroll_Area
           (This : in out Table)
        return Scrolls.Scroll_Reference;




    procedure Add
           (This : in out Table;
            Item : in out Widget'Class);

    procedure Insert
           (This  : in out Table;
            Item  : in out Widget'Class;
            Place : in     Index);

    procedure Insert
           (This   : in out Table;
            Item   : in out Widget'Class;
            Before : in     Widget'Class);

    procedure Remove
           (This : in out Table;
            Item : in out Widget'Class);

    procedure Clear
           (This : in out Table);




    function Has_Child
           (This  : in Table;
            Place : in Index)
        return Boolean;

    function Has_Child
           (Place : in Cursor)
        return Boolean;

    function Child
           (This  : in Table;
            Place : in Index)
        return Widget_Reference
    with Pre => This.Has_Child (Place);

    function Child
           (This  : in Table;
            Place : in Cursor)
        return Widget_Reference;

    function Find
           (This : in Table;
            Item : in Widget'Class)
        return Extended_Index;

    function Number_Of_Children
           (This : in Table)
        return Natural;

    function Used_As_Container
           (This : in Table)
        return Boolean;




    procedure Begin_Current
           (This : in out Table);

    procedure End_Current
           (This : in out Table);




    procedure Set_Callback
           (This : in out Table;
            Func : in     Widget_Callback);

    function Callback_Column
           (This : in Table)
        return Positive;

    function Callback_Row
           (This : in Table)
        return Positive;

    function Callback_Context
           (This : in Table)
        return Table_Context;

    procedure Do_Callback
           (This        : in out Table;
            Context     : in     Table_Context;
            Row, Column : in     Positive);

    procedure Set_When
           (This  : in out Table;
            Value : in     Callback_Flag);

    --  This is the callback used for the horizontal and vertical scrollbars
    --  inside the Table object. Assigning it to other widgets will cause errors.
    procedure Scroll_Callback
           (Item : in out Widget'Class);




    function Column_Headers_Enabled
           (This : in Table)
        return Boolean;

    procedure Set_Column_Headers
           (This  : in out Table;
            Value : in     Boolean);

    function Get_Column_Header_Color
           (This : in Table)
        return Color;

    procedure Set_Column_Header_Color
           (This  : in out Table;
            Value : in     Color);

    function Get_Column_Header_Height
           (This : in Table)
        return Positive;

    procedure Set_Column_Header_Height
           (This  : in out Table;
            Value : in     Positive);

    function Get_Column_Width
           (This   : in Table;
            Column : in Positive)
        return Positive;

    procedure Set_Column_Width
           (This   : in out Table;
            Column : in     Positive;
            Value  : in     Positive);

    procedure Set_All_Columns_Width
           (This  : in out Table;
            Value : in     Positive);

    function Get_Columns
           (This : in Table)
        return Natural;

    procedure Set_Columns
           (This  : in out Table;
            Value : in     Natural);

    function Get_Column_Position
           (This : in Table)
        return Positive;

    procedure Set_Column_Position
           (This  : in out Table;
            Value : in     Positive);

    function Get_Column_Scroll_Position
           (This   : in Table;
            Column : in Positive)
        return Long_Integer;

    function Column_Resize_Allowed
           (This : in Table)
        return Boolean;

    procedure Set_Column_Resize
           (This  : in out Table;
            Value : in     Boolean);

    function Get_Column_Resize_Minimum
           (This : in Table)
        return Positive;

    procedure Set_Column_Resize_Minimum
           (This  : in out Table;
            Value : in     Positive);




    function Row_Headers_Enabled
           (This : in Table)
        return Boolean;

    procedure Set_Row_Headers
           (This  : in out Table;
            Value : in     Boolean);

    function Get_Row_Header_Color
           (This : in Table)
        return Color;

    procedure Set_Row_Header_Color
           (This  : in out Table;
            Value : in     Color);

    function Get_Row_Header_Width
           (This : in Table)
        return Positive;

    procedure Set_Row_Header_Width
           (This  : in out Table;
            Value : in     Positive);

    function Get_Row_Height
           (This : in Table;
            Row  : in Positive)
        return Positive;

    procedure Set_Row_Height
           (This  : in out Table;
            Row   : in     Positive;
            Value : in     Positive);

    procedure Set_All_Rows_Height
           (This  : in out Table;
            Value : in     Positive);

    function Get_Rows
           (This : in Table)
        return Natural;

    procedure Set_Rows
           (This  : in out Table;
            Value : in     Natural);

    function Get_Row_Position
           (This : in Table)
        return Positive;

    procedure Set_Row_Position
           (This  : in out Table;
            Value : in     Positive);

    function Get_Row_Scroll_Position
           (This : in Table;
            Row  : in Positive)
        return Long_Integer;

    function Row_Resize_Allowed
           (This : in Table)
        return Boolean;

    procedure Set_Row_Resize
           (This  : in out Table;
            Value : in     Boolean);

    function Get_Row_Resize_Minimum
           (This : in Table)
        return Positive;

    procedure Set_Row_Resize_Minimum
           (This  : in out Table;
            Value : in     Positive);

    function Get_Top_Row
           (This : in Table)
        return Positive;

    procedure Set_Top_Row
           (This  : in out Table;
            Value : in     Positive);




    procedure Set_Cursor_Kind
           (This : in out Table;
            Kind : in     Mouse_Cursor_Kind);

    procedure Cursor_To_Row_Column
           (This        : in     Table;
            Row, Column :    out Positive;
            Context     :    out Table_Context;
            Resize      :    out Resize_Flag);

    --  Unsure if Row_Bottom and Column_Right can ever be zero, but just to be safe...
    procedure Get_Visible_Cells
           (This         : in     Table;
            Row_Top      :    out Positive;
            Column_Left  :    out Positive;
            Row_Bottom   :    out Natural;
            Column_Right :    out Natural);

    procedure Get_Selection
           (This         : in     Table;
            Row_Top      :    out Positive;
            Column_Left  :    out Positive;
            Row_Bottom   :    out Positive;
            Column_Right :    out Positive);

    procedure Set_Selection
           (This         : in out Table;
            Row_Top      : in     Positive;
            Column_Left  : in     Positive;
            Row_Bottom   : in     Positive;
            Column_Right : in     Positive);

    function Is_Selected
           (This        : in Table;
            Row, Column : in Positive)
        return Boolean;

    procedure Move_Cursor
           (This         : in out Table;
            Row, Column  : in     Positive;
            Shift_Select : in     Boolean := True);

    function Move_Cursor
           (This         : in out Table;
            Row, Column  : in     Positive;
            Shift_Select : in     Boolean := True)
        return Boolean;

    function Get_Tab_Mode
           (This : in Table)
        return Tab_Navigation;

    procedure Set_Tab_Mode
           (This  : in out Table;
            Value : in     Tab_Navigation);

    function Get_Table_Box
           (This : in Table)
        return Box_Kind;

    procedure Set_Table_Box
           (This : in out Table;
            Box  : in     Box_Kind);




    function Get_Scrollbar_Size
           (This : in Table)
        return Integer;

    procedure Set_Scrollbar_Size
           (This  : in out Table;
            Value : in     Integer);

    procedure Resize
           (This       : in out Table;
            X, Y, W, H : in     Integer);

    function Is_Interactive_Resize
           (This : in Table)
        return Boolean;

    procedure Reset_Sizes
           (This : in out Table);

    procedure Recalculate_Dimensions
           (This : in out Table);

    procedure Table_Resized
           (This : in out Table);

    procedure Table_Scrolled
           (This : in out Table);




    procedure Draw
           (This : in out Table);

    --  Derived types must override this to handle drawing cells
    procedure Draw_Cell
           (This        : in out Table;
            Context     : in     Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0);

    procedure Redraw_Range
           (This         : in out Table;
            Row_Top      : in     Positive;
            Column_Left  : in     Positive;
            Row_Bottom   : in     Positive;
            Column_Right : in     Positive);

    procedure Damage_Zone
           (This         : in out Table;
            Row_Top      : in     Positive;
            Column_Left  : in     Positive;
            Row_Bottom   : in     Positive;
            Column_Right : in     Positive;
            Reach_Row    : in     Positive := 1;
            Reach_Column : in     Positive := 1);

    procedure Cell_Dimensions
           (This        : in     Table;
            Context     : in     Table_Context;
            Row, Column : in     Positive;
            X, Y, W, H  :    out Integer);

    procedure Bounding_Region
           (This       : in     Table;
            Context    : in     Table_Context;
            X, Y, W, H :    out Integer);

    procedure Row_Column_Clamp
           (This        : in     Table;
            Context     : in     Table_Context;
            Row, Column : in out Integer);

    function Row_Column_Clamp
           (This        : in     Table;
            Context     : in     Table_Context;
            Row, Column : in out Integer)
        return Boolean;

    function Handle
           (This  : in out Table;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Table is new Group with record
        Horizon, Vertigo : aliased Valuators.Sliders.Scrollbars.Scrollbar;
        Playing_Area     : aliased Scrolls.Scroll;
    end record;

    overriding procedure Initialize
           (This : in out Table);

    overriding procedure Finalize
           (This : in out Table);

    procedure Extra_Init
           (This       : in out Table;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out Table);


    function To_Cint
           (Context : in Table_Context)
        return Interfaces.C.int;

    function To_Context
           (Value : in Interfaces.C.int)
        return Table_Context;


    pragma Inline (H_Bar);
    pragma Inline (V_Bar);
    pragma Inline (Scroll_Area);

    pragma Inline (Add);
    pragma Inline (Insert);
    pragma Inline (Remove);

    pragma Inline (Has_Child);
    pragma Inline (Find);
    pragma Inline (Number_Of_Children);
    pragma Inline (Used_As_Container);

    pragma Inline (Begin_Current);
    pragma Inline (End_Current);

    pragma Inline (Set_Callback);
    pragma Inline (Callback_Column);
    pragma Inline (Callback_Row);
    pragma Inline (Callback_Context);
    pragma Inline (Do_Callback);
    pragma Inline (Set_When);
    pragma Inline (Scroll_Callback);

    pragma Inline (Column_Headers_Enabled);
    pragma Inline (Set_Column_Headers);
    pragma Inline (Get_Column_Header_Color);
    pragma Inline (Set_Column_Header_Color);
    pragma Inline (Get_Column_Header_Height);
    pragma Inline (Set_Column_Header_Height);
    pragma Inline (Get_Column_Width);
    pragma Inline (Set_Column_Width);
    pragma Inline (Set_All_Columns_Width);
    pragma Inline (Get_Columns);
    pragma Inline (Set_Columns);
    pragma Inline (Get_Column_Position);
    pragma Inline (Set_Column_Position);
    pragma Inline (Get_Column_Scroll_Position);
    pragma Inline (Column_Resize_Allowed);
    pragma Inline (Set_Column_Resize);
    pragma Inline (Get_Column_Resize_Minimum);
    pragma Inline (Set_Column_Resize_Minimum);

    pragma Inline (Row_Headers_Enabled);
    pragma Inline (Set_Row_Headers);
    pragma Inline (Get_Row_Header_Color);
    pragma Inline (Set_Row_Header_Color);
    pragma Inline (Get_Row_Header_Width);
    pragma Inline (Set_Row_Header_Width);
    pragma Inline (Get_Row_Height);
    pragma Inline (Set_Row_Height);
    pragma Inline (Set_All_Rows_Height);
    pragma Inline (Get_Rows);
    pragma Inline (Set_Rows);
    pragma Inline (Get_Row_Position);
    pragma Inline (Set_Row_Position);
    pragma Inline (Get_Row_Scroll_Position);
    pragma Inline (Row_Resize_Allowed);
    pragma Inline (Set_Row_Resize);
    pragma Inline (Get_Row_Resize_Minimum);
    pragma Inline (Set_Row_Resize_Minimum);
    pragma Inline (Get_Top_Row);
    pragma Inline (Set_Top_Row);

    pragma Inline (Set_Cursor_Kind);
    pragma Inline (Set_Selection);
    pragma Inline (Is_Selected);
    pragma Inline (Move_Cursor);
    pragma Inline (Get_Tab_Mode);
    pragma Inline (Set_Tab_Mode);
    pragma Inline (Get_Table_Box);
    pragma Inline (Set_Table_Box);

    pragma Inline (Get_Scrollbar_Size);
    pragma Inline (Set_Scrollbar_Size);
    pragma Inline (Resize);
    pragma Inline (Is_Interactive_Resize);
    pragma Inline (Reset_Sizes);
    pragma Inline (Recalculate_Dimensions);
    pragma Inline (Table_Resized);
    pragma Inline (Table_Scrolled);

    pragma Inline (Draw);
    pragma Inline (Redraw_Range);
    pragma Inline (Damage_Zone);
    pragma Inline (Cell_Dimensions);
    pragma Inline (Bounding_Region);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Tables;


