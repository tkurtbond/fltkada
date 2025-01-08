

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Inputs.Text.Floating_Point is


    type Float_Input is new Text_Input with private;

    type Float_Input_Reference (Data : not null access Float_Input'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Float_Input;

    end Forge;




    function Get_Value
           (This : in Float_Input)
        return Long_Float;


private


    type Float_Input is new Text_Input with null record;

    overriding procedure Initialize
           (This : in out Float_Input);

    overriding procedure Finalize
           (This : in out Float_Input);

    procedure Extra_Init
           (This       : in out Float_Input;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Float_Input)
    with Inline;


    pragma Inline (Get_Value);


end FLTK.Widgets.Inputs.Text.Floating_Point;


