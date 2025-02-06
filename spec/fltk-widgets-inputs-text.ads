

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Inputs.Text is


    type Text_Input is new Input with private;

    type Text_Input_Reference (Data : not null access Text_Input'Class) is limited null record
        with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Text_Input;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Text_Input;

    end Forge;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Text_Input);

    function Handle
           (This  : in out Text_Input;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Text_Input is new Input with null record;

    overriding procedure Initialize
           (This : in out Text_Input);

    overriding procedure Finalize
           (This : in out Text_Input);

    procedure Extra_Init
           (This       : in out Text_Input;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Text_Input)
    with Inline;


    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Inputs.Text;


