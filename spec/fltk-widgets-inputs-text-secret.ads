

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Inputs.Text.Secret is


    type Secret_Input is new Text_Input with private;

    type Secret_Input_Reference (Data : not null access Secret_Input'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Secret_Input;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Secret_Input;

    end Forge;




    function Handle
           (This  : in out Secret_Input;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Secret_Input is new Text_Input with null record;

    overriding procedure Initialize
           (This : in out Secret_Input);

    overriding procedure Finalize
           (This : in out Secret_Input);

    procedure Extra_Init
           (This       : in out Secret_Input;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Secret_Input)
    with Inline;


    pragma Inline (Handle);


end FLTK.Widgets.Inputs.Text.Secret;


