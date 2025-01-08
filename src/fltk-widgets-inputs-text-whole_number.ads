

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Inputs.Text.Whole_Number is


    type Integer_Input is new Text_Input with private;

    type Integer_Input_Reference (Data : not null access Integer_Input'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Standard.Integer;
                Text       : in String := "")
            return Integer_Input;

    end Forge;




    function Get_Value
           (This : in Integer_Input)
        return Long_Integer;


private


    type Integer_Input is new Text_Input with null record;

    overriding procedure Initialize
           (This : in out Integer_Input);

    overriding procedure Finalize
           (This : in out Integer_Input);

    procedure Extra_Init
           (This       : in out Integer_Input;
            X, Y, W, H : in     Standard.Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Integer_Input)
    with Inline;


    pragma Inline (Get_Value);


end FLTK.Widgets.Inputs.Text.Whole_Number;


