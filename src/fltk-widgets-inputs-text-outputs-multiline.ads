

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Inputs.Text.Outputs.Multiline is


    type Multiline_Output is new Output with private;

    type Multiline_Output_Reference (Data : not null access Multiline_Output'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Multiline_Output;

    end Forge;


private


    type Multiline_Output is new Output with null record;

    overriding procedure Initialize
           (This : in out Multiline_Output);

    overriding procedure Finalize
           (This : in out Multiline_Output);

    procedure Extra_Init
           (This       : in out Multiline_Output;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Multiline_Output)
    with Inline;


end FLTK.Widgets.Inputs.Text.Outputs.Multiline;


