

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Valuators.Dials.Line is


    type Line_Dial is new Dial with private;

    type Line_Dial_Reference (Data : not null access Line_Dial'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Line_Dial;

    end Forge;


private


    type Line_Dial is new Dial with null record;

    overriding procedure Initialize
           (This : in out Line_Dial);

    overriding procedure Finalize
           (This : in out Line_Dial);

    procedure Extra_Init
           (This       : in out Line_Dial;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Line_Dial)
    with Inline;


end FLTK.Widgets.Valuators.Dials.Line;


