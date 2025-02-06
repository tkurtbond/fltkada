

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Groups.Tables.Row is


    type Row_Table is new Table with private;

    type Row_Table_Reference (Data : not null access Row_Table'Class) is limited null record
        with Implicit_Dereference => Data;

    type Row_Select_Mode is (Select_None, Select_Single, Select_Multiple);

    type Selection_State is (Deselected, Selected, Toggle);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Row_Table;

        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Row_Table;

    end Forge;




    --  Contents Modification  --

    procedure Clear
           (This : in out Row_Table);




    --  Rows  --

    function Get_Rows
           (This : in Row_Table)
        return Natural;

    procedure Set_Rows
           (This  : in out Row_Table;
            Value : in     Natural);




    --  Selection  --

    function Is_Row_Selected
           (This : in Row_Table;
            Row  : in Positive)
        return Boolean;

    procedure Select_Row
           (This  : in out Row_Table;
            Row   : in     Positive;
            Value : in     Selection_State := Selected);

    function Select_Row
           (This  : in out Row_Table;
            Row   : in     Positive;
            Value : in     Selection_State := Selected)
        return Boolean;

    procedure Select_All_Rows
           (This  : in out Row_Table;
            Value : in     Selection_State := Selected);

    function Get_Row_Select_Mode
           (This : in Row_Table)
        return Row_Select_Mode;

    procedure Set_Row_Select_Mode
           (This  : in out Row_Table;
            Value : in     Row_Select_Mode);




    --  Drawing, Events  --

    procedure Cell_Dimensions
           (This        : in     Row_Table;
            Context     : in     Table_Context;
            Row, Column : in     Positive;
            X, Y, W, H  :    out Integer);

    function Handle
           (This  : in out Row_Table;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Row_Table is new Table with null record;

    overriding procedure Initialize
           (This : in out Row_Table);

    overriding procedure Finalize
           (This : in out Row_Table);

    procedure Extra_Init
           (This       : in out Row_Table;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Row_Table)
    with Inline;


    pragma Inline (Get_Rows);
    pragma Inline (Set_Rows);

    pragma Inline (Is_Row_Selected);
    pragma Inline (Select_Row);
    pragma Inline (Select_All_Rows);
    pragma Inline (Get_Row_Select_Mode);
    pragma Inline (Set_Row_Select_Mode);

    pragma Inline (Cell_Dimensions);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Tables.Row;


