

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Valuators.Dials.Fill is


    type Fill_Dial is new Dial with private;

    type Fill_Dial_Reference (Data : not null access Fill_Dial'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Fill_Dial;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Fill_Dial;

    end Forge;


private


    type Fill_Dial is new Dial with null record;

    overriding procedure Initialize
           (This : in out Fill_Dial);

    overriding procedure Finalize
           (This : in out Fill_Dial);

    procedure Extra_Init
           (This       : in out Fill_Dial;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Fill_Dial)
    with Inline;


end FLTK.Widgets.Valuators.Dials.Fill;


