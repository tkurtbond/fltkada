

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Clocks.Updated is


    type Updated_Clock is new Clock with private;

    type Updated_Clock_Reference (Data : not null access Updated_Clock'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Updated_Clock;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Updated_Clock;

        function Create
               (Kind       : in Box_Kind;
                X, Y, W, H : in Integer;
                Text       : in String := "")
            return Updated_Clock;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                Kind       : in     Box_Kind;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Updated_Clock;

    end Forge;




    function Handle
           (This  : in out Updated_Clock;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Updated_Clock is new Clock with null record;

    overriding procedure Initialize
           (This : in out Updated_Clock);

    overriding procedure Finalize
           (This : in out Updated_Clock);

    procedure Extra_Init
           (This       : in out Updated_Clock;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Updated_Clock)
    with Inline;


    pragma Inline (Handle);


end FLTK.Widgets.Clocks.Updated;


