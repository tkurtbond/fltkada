

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Valuators.Counters.Simple is


    type Simple_Counter is new Counter with private;

    type Simple_Counter_Reference (Data : not null access Simple_Counter'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Simple_Counter;

    end Forge;


private


    type Simple_Counter is new Counter with null record;

    overriding procedure Initialize
           (This : in out Simple_Counter);

    overriding procedure Finalize
           (This : in out Simple_Counter);

    procedure Extra_Init
           (This       : in out Simple_Counter;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Simple_Counter)
    with Inline;


end FLTK.Widgets.Valuators.Counters.Simple;


