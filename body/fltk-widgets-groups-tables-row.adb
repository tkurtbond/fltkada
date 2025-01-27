

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Groups.Tables.Row is


    package Chk renames Ada.Assertions;




    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_table_row
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_table_row, "new_fl_table_row");
    pragma Inline (new_fl_table_row);

    procedure free_fl_table_row
           (T : in Storage.Integer_Address);
    pragma Import (C, free_fl_table_row, "free_fl_table_row");
    pragma Inline (free_fl_table_row);




    function fl_table_row_get_rows
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_row_get_rows, "fl_table_row_get_rows");
    pragma Inline (fl_table_row_get_rows);

    procedure fl_table_row_set_rows
           (T : in Storage.Integer_Address;
            R : in Interfaces.C.int);
    pragma Import (C, fl_table_row_set_rows, "fl_table_row_set_rows");
    pragma Inline (fl_table_row_set_rows);




    function fl_table_row_row_selected
           (T : in Storage.Integer_Address;
            R : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_table_row_row_selected, "fl_table_row_row_selected");
    pragma Inline (fl_table_row_row_selected);

    function fl_table_row_select_row
           (T    : in Storage.Integer_Address;
            R, F : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_table_row_select_row, "fl_table_row_select_row");
    pragma Inline (fl_table_row_select_row);

    procedure fl_table_row_select_all_rows
           (T : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_table_row_select_all_rows, "fl_table_row_select_all_rows");
    pragma Inline (fl_table_row_select_all_rows);

    function fl_table_row_get_type
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_row_get_type, "fl_table_row_get_type");
    pragma Inline (fl_table_row_get_type);

    procedure fl_table_row_set_type
           (T : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_table_row_set_type, "fl_table_row_set_type");
    pragma Inline (fl_table_row_set_type);




    procedure fl_table_row_draw
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_table_row_draw, "fl_table_row_draw");
    pragma Inline (fl_table_row_draw);

    procedure fl_table_row_draw_cell
           (T                   : in Storage.Integer_Address;
            E, R, C, X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_table_row_draw_cell, "fl_table_row_draw_cell");
    pragma Inline (fl_table_row_draw_cell);

    function fl_table_row_find_cell
           (T          : in     Storage.Integer_Address;
            E, R, C    : in     Interfaces.C.int;
            X, Y, W, H :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_table_row_find_cell, "fl_table_row_find_cell");
    pragma Inline (fl_table_row_find_cell);

    function fl_table_row_handle
           (T : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_table_row_handle, "fl_table_row_handle");
    pragma Inline (fl_table_row_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Row_Table) is
    begin
        Extra_Final (Table (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Row_Table) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_table_row (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Row_Table;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Table (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Row_Table) is
    begin
        This.Draw_Ptr      := fl_table_row_draw'Address;
        This.Handle_Ptr    := fl_table_row_handle'Address;
        This.Draw_Cell_Ptr := fl_table_row_draw_cell'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Row_Table is
        begin
            return This : Row_Table do
                This.Void_Ptr := new_fl_table_row
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Row_Table is
        begin
            return This : Row_Table := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    procedure Clear
           (This : in out Row_Table) is
    begin
        This.Set_Rows (0);  --  Set_Rows is reimplemented.
        This.Set_Columns (0);
        This.Playing_Area.Clear;
    end Clear;




    function Get_Rows
           (This : in Row_Table)
        return Natural
    is
        Result : Interfaces.C.int := fl_table_row_get_rows (This.Void_Ptr);
    begin
        return Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::rows returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Rows;


    procedure Set_Rows
           (This  : in out Row_Table;
            Value : in     Natural) is
    begin
        fl_table_row_set_rows (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_Rows;




    function Is_Row_Selected
           (This : in Row_Table;
            Row  : in Positive)
        return Boolean
    is
        Result : Interfaces.C.int := fl_table_row_row_selected
            (This.Void_Ptr, Interfaces.C.int (Row) - 1);
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table_Row::row_selected returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Is_Row_Selected;


    procedure Select_Row
           (This  : in out Row_Table;
            Row   : in     Positive;
            Value : in     Selection_State := Selected)
    is
        Result : Interfaces.C.int := fl_table_row_select_row
           (This.Void_Ptr,
            Interfaces.C.int (Row) - 1,
            Selection_State'Pos (Value));
    begin
        if Result = -1 then
            raise Range_Error with "Row = " & Positive'Image (Row);
        else
            pragma Assert (Result in 0 .. 1);
        end if;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Table_Row::select_row returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Select_Row;


    function Select_Row
           (This  : in out Row_Table;
            Row   : in     Positive;
            Value : in     Selection_State := Selected)
        return Boolean
    is
        Result : Interfaces.C.int := fl_table_row_select_row
           (This.Void_Ptr,
            Interfaces.C.int (Row) - 1,
            Selection_State'Pos (Value));
    begin
        if Result = -1 then
            raise Range_Error with "Row = " & Positive'Image (Row);
        else
            return Boolean'Val (Result);
        end if;
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table_Row::select_row returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Select_Row;


    procedure Select_All_Rows
           (This  : in out Row_Table;
            Value : in     Selection_State := Selected) is
    begin
        fl_table_row_select_all_rows (This.Void_Ptr, Selection_State'Pos (Value));
    end Select_All_Rows;


    function Get_Row_Select_Mode
           (This : in Row_Table)
        return Row_Select_Mode
    is
        Result : Interfaces.C.int := fl_table_row_get_type (This.Void_Ptr);
    begin
        return Row_Select_Mode'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table_Row::type returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Row_Select_Mode;


    procedure Set_Row_Select_Mode
           (This  : in out Row_Table;
            Value : in     Row_Select_Mode) is
    begin
        fl_table_row_set_type (This.Void_Ptr, Row_Select_Mode'Pos (Value));
    end Set_Row_Select_Mode;




    procedure Cell_Dimensions
           (This        : in     Row_Table;
            Context     : in     Table_Context;
            Row, Column : in     Positive;
            X, Y, W, H  :    out Integer)
    is
        Result : Interfaces.C.int := fl_table_row_find_cell
           (This.Void_Ptr,
            To_Cint (Context),
            Interfaces.C.int (Row) - 1,
            Interfaces.C.int (Column) - 1,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    begin
        if Result = -1 then
            raise Range_Error with
                "Row = " & Integer'Image (Row) & ", Column = " & Integer'Image (Column);
        else
            pragma Assert (Result = 0);
        end if;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Table_Row::find_cell returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Cell_Dimensions;


    function Handle
           (This  : in out Row_Table;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Table (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups.Tables.Row;


