

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Inputs.Secret is


    type Secret_Input is new Input with private;

    type Secret_Input_Reference (Data : not null access Secret_Input'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Secret_Input;

    end Forge;




    procedure Draw
           (This : in out Secret_Input);

    function Handle
           (This  : in out Secret_Input;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Secret_Input is new Input with null record;

    overriding procedure Finalize
           (This : in out Secret_Input);

    procedure Extra_Init
           (This       : in out Secret_Input;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;


    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Inputs.Secret;

