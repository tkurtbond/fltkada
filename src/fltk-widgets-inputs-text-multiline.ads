

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Inputs.Text.Multiline is


    type Multiline_Input is new Text_Input with private;

    type Multiline_Input_Reference (Data : not null access Multiline_Input'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Multiline_Input;

    end Forge;


private


    type Multiline_Input is new Text_Input with null record;

    overriding procedure Initialize
           (This : in out Multiline_Input);

    overriding procedure Finalize
           (This : in out Multiline_Input);

    procedure Extra_Init
           (This       : in out Multiline_Input;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Multiline_Input)
    with Inline;


end FLTK.Widgets.Inputs.Text.Multiline;


