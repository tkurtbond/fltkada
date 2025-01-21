

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Clocks.Updated.Round is


    type Round_Clock is new Updated_Clock with private;

    type Round_Clock_Reference (Data : not null access Round_Clock'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Round_Clock;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Round_Clock;

    end Forge;


private


    type Round_Clock is new Updated_Clock with null record;

    overriding procedure Initialize
           (This : in out Round_Clock);

    overriding procedure Finalize
           (This : in out Round_Clock);

    procedure Extra_Init
           (This       : in out Round_Clock;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Round_Clock)
    with Inline;


end FLTK.Widgets.Clocks.Updated.Round;


